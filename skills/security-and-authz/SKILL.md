---
name: security-and-authz
description: Secure FHIR APIs in Ballerina with SMART on FHIR (.well-known/smart-configuration via the smartconfig template, EHR launch and standalone launch flows), OAuth 2.0 (client_credentials, PKCE authorization code, PKJWT public-key client auth, bearer tokens), cascading role-based authorization via health.fhir.r4.utils.authz (privileged role → patient → practitioner-with-treatment-relationship), custom AuthzContext functions, JWT claim extraction, and AuditEvent emission via the audit-service template for HIPAA compliance. Use for authentication, authorization, scope enforcement, or audit trail generation.
---

# Skill: Security & Authorization

Secure FHIR APIs with SMART on FHIR, OAuth 2.0, and fine-grained authorization. Covers `utils/authz` cascading RBAC, the `smartconfig` template for SMART discovery endpoints, the `authz-service` template, and `AuditEvent` generation for compliance.

**Packages:** `health.fhir.r4.utils.authz`, `health.fhir.templates/smartconfig`, `health.fhir.templates/authz-service`, `health.fhir.templates/audit-service`

---

## Sub-Skills

### 1. SMART on FHIR Launch

SMART supports two launch modes:

| Mode | Trigger | Flow |
|---|---|---|
| EHR launch | EHR opens the app with launch token | `authorize → token → launch context (patient, encounter)` |
| Standalone launch | App launched outside EHR | `authorize → token → scopes only` |

Generate the SMART `.well-known/smart-configuration` endpoint from the `smartconfig` template:

```bash
bal new my-smart-config --template health.fhir.templates/smartconfig
```

Config.toml SMART block:

```toml
[smart]
issuer = "${SMART_ISSUER}"
jwksUri = "${SMART_JWKS_URI}"
audience = "https://fhir.example.org"
scopes = ["patient/*.read", "user/*.read", "launch", "openid", "fhirUser"]
```

---

### 2. OAuth 2.0 Flows

Supported methods for FHIR clients and resource servers:

| Method | Use case |
|---|---|
| Client credentials | Server-to-server (backend services) |
| Authorization code (PKCE) | SMART launch (user-facing apps) |
| PKJWT | Public-key client auth (Epic backend services, Cerner system scopes) |
| Bearer token | Pre-obtained tokens (proxied scenarios) |

---

### 3. Cascading Role-Based Authorization

**Package:** `health.fhir.r4.utils.authz`

Implements a cascading check:
1. Is the user a privileged role (admin / system)? → allow.
2. Is the user the patient themselves? → restrict to their own compartment.
3. Is the user a practitioner with a treatment relationship? → allow within their panel.
4. Otherwise → deny.

```ballerina
import ballerinax/health.fhir.r4.utils.authz;

boolean allowed = check authz:authorize(
    jwt,
    resourceType = "Patient",
    resourceId = "123"
);
```

Custom claim extraction:

```ballerina
string patientId = check authz:getClaimValue(jwt, "patient_id");
```

---

### 4. Config.toml Wiring for Authz

```toml
[ballerinax.health.fhir.r4.utils.authz]
patientIdClaim = "patient_id"
practitionerIdClaim = "practitioner_id"
privilegedUserRoles = ["admin", "system"]
enableCascadingChecks = true
```

Secrets (JWKS URIs, signing keys) belong in env vars, referenced via `${ENV}` interpolation.

---

### 5. Custom Authorization Functions

Plug in database lookups, attribute-based checks, or consent rules:

```ballerina
import ballerinax/health.fhir.r4.utils.authz;

function customAuthz(authz:AuthzContext ctx) returns boolean|error {
    // custom rule: check consent directive
    return check checkConsent(ctx.patientId, ctx.purposeOfUse);
}

// Register at service init
authz:registerPrivilegedUserAuthorizer(customAuthz);
```

---

### 6. Audit Event Generation

**Template:** `health.fhir.templates/audit-service`

Emit FHIR `AuditEvent` resources for every resource access, per HIPAA requirements.

```ballerina
r4:AuditEvent auditEvent = {
    resourceType: "AuditEvent",
    type: {system: "http://terminology.hl7.org/CodeSystem/audit-event-type", code: "rest"},
    action: "R",
    recorded: check time:utcNow().toString(),
    agent: [{who: {reference: "Practitioner/" + practitionerId}, requestor: true}],
    'source: {observer: {reference: "Device/fhir-api"}},
    entity: [{what: {reference: "Patient/" + patientId}}]
};
```

Config.toml audit block (see `configuration-best-practices` §8).

---

### 7. Compliance Checklist

- [ ] TLS enabled on all endpoints (mTLS for backend services).
- [ ] Tokens validated against JWKS with clock-skew tolerance.
- [ ] Scopes enforced per resource and interaction.
- [ ] Consent directives applied (patient-level opt-out for `Observation`, `Condition`).
- [ ] `AuditEvent` emitted for every create/read/update/delete.
- [ ] Secrets rotated, stored in a vault, never in repo.
- [ ] `OperationOutcome` returned on auth failures with `security` issue code.

---

## Related
- `healthcare-api-development` — where services are deployed.
- `configuration-best-practices` — SMART + authz blocks.
- `prebuilt-services` — the authz-service and audit-service are ready-made.
- `skill-router` — SMART on FHIR workflow.
