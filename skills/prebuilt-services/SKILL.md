---
name: prebuilt-services
description: WSO2 Open Healthcare Prebuilt Services catalog — production-ready Ballerina services. Conformance: metadata (CapabilityStatement), smart-config. Platform: fhir-r4-server (full CRUD/search/history with H2 or PostgreSQL), authz-service, audit-service, fhirpath-service. Transformation: hl7v2-to-fhir, ccda-to-fhir. EHR Epic: administration, clinical, diagnostics, financial, medications, workflow connectors. Deploy to local/Choreo/Docker/Kubernetes. Use to check before building from scratch — most common healthcare service needs are covered.
---

# Skill: Prebuilt Services

WSO2 Open Healthcare Prebuilt Services ships production-ready Ballerina services for common healthcare needs — FHIR R4 server, SMART/metadata endpoints, audit, authz, transformation, and EHR connectors. **Check this catalog before building from scratch.**

**Repo:** https://github.com/wso2/open-healthcare-prebuilt-services

---

## Sub-Skills

### 1. Service Catalog

| Category | Service | Purpose |
|---|---|---|
| Conformance | `metadata` | CapabilityStatement endpoint describing server features |
| Conformance | `smart-config` | `.well-known/smart-configuration` for SMART discovery |
| Platform | `fhir-r4-server` | Full FHIR R4 REST server (CRUD, search, history, versioning, operations) |
| Platform | `authz-service` | Cascading RBAC for FHIR APIs |
| Platform | `audit-service` | `AuditEvent` emission + sink |
| Platform | `fhirpath-service` | FHIRPath evaluation endpoint |
| Transformation | `hl7v2-to-fhir` | HL7 v2 → FHIR conversion |
| Transformation | `ccda-to-fhir` | C-CDA → FHIR conversion |
| EHR — Epic | `administration` | Facility, practitioner, scheduling data |
| EHR — Epic | `clinical` | Conditions, diagnoses, procedures |
| EHR — Epic | `diagnostics` | Lab results, imaging references |
| EHR — Epic | `financial` | Billing, coverage, claims |
| EHR — Epic | `medications` | Prescriptions, dispenses, administrations |
| EHR — Epic | `workflow` | Appointments, tasks |

---

### 2. FHIR R4 Server

Production FHIR R4 REST server with pluggable storage.

**Storage:**
- H2 (default, zero-config) — dev / POC
- PostgreSQL — production. Schema provided in repo.

**Features:**
- All CRUD + search + `_history`
- Resource versioning
- Custom operation support
- Bundle transactions
- Conditional create/update

Config.toml:

```toml
[database]
type = "postgresql"
host = "${DB_HOST}"
port = 5432
name = "fhirdb"
user = "${DB_USER}"
password = "${DB_PASSWORD}"

[http]
port = 9090
```

---

### 3. Epic Domain Connectors

Six domain-scoped Epic connectors abstract the vendor's FHIR R4 API.

Use when building an Epic integration — avoids re-implementing auth, pagination, and endpoint-specific quirks.

```ballerina
import ballerinax/health.fhir.templates.epic.clinical;

clinical:EpicClinicalClient client = check new(config);
r4:Condition[] conditions = check client.getConditions(patientId);
```

Config.toml:

```toml
[epic]
baseUrl = "https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/R4"
clientId = "${EPIC_CLIENT_ID}"
privateKey = "${EPIC_PKJWT_PRIVATE_KEY}"
tokenUrl = "${EPIC_TOKEN_URL}"
```

---

### 4. Conformance Endpoints

Drop-in services for FHIR conformance:
- `metadata` — publishes `CapabilityStatement` auto-generated from registered resources.
- `smart-config` — publishes SMART endpoints and supported scopes.

Deploy alongside any FHIR API to satisfy inspector/consumer requirements.

---

### 5. Transformation Services

| Service | Input | Output |
|---|---|---|
| `hl7v2-to-fhir` | HL7 v2 message (TCP/HTTP) | FHIR Bundle |
| `ccda-to-fhir` | C-CDA XML (HTTP) | FHIR Bundle |

Both services allow custom mapper injection at deploy time for site-specific tweaks.

---

### 6. Deployment Targets

| Target | Notes |
|---|---|
| Local | `bal run` (Ballerina 2201.8.1+) |
| Choreo | Native WSO2 platform, one-click deploy |
| Docker | Dockerfiles in each service directory |
| Kubernetes | Manifests/Helm charts under `deploy/` where present |

---

### 7. "Use Before Building" Decision Tree

```
Need a feature?
  ├── Is there a prebuilt service?
  │     ├── YES → deploy it, configure Config.toml, done.
  │     └── NO → is it an EHR connector?
  │              ├── YES (Epic/Cerner/Athena) → use fhir.templates EHR packages.
  │              └── NO → is it covered by an IG?
  │                        ├── YES → generate via `bal health fhir -m template`.
  │                        └── NO → build from scratch with fhir.r4 + parser + validator.
```

---

### 8. Composition Pattern

Real deployments typically compose multiple prebuilt services:
- **FHIR R4 server** + **metadata** + **smart-config** + **authz** + **audit** = a compliant, secured FHIR endpoint.
- Add **hl7v2-to-fhir** fronting the server to accept legacy feeds.
- Add **Epic connectors** sidewise to federate reads from an Epic instance.

---

## Related
- `emr-ehr-connectivity` — connector details.
- `healthcare-api-development` — deployment patterns.
- `configuration-best-practices` — wiring every service.
- `skill-router` — "use before building" fork.
