---
name: configuration-best-practices
description: Ballerina healthcare Config.toml conventions — terminology, database (H2 dev / PostgreSQL prod), FHIR client with OAuth2/PKJWT/Basic/Bearer auth and retry, SMART on FHIR, cascading authz, de-identification rules, audit, CDS, HTTP/CORS/TLS, and secrets hygiene with ${ENV} interpolation and per-environment layering. Use when wiring runtime configuration for any Ballerina health.* module.
---

# Skill: Configuration & Config.toml Best Practices

Ballerina healthcare modules use `Config.toml` for runtime configuration. This skill shows the conventions and layout for common blocks — terminology, database, FHIR client, SMART on FHIR, authz, de-identification, audit, CDS — with secrets handled via environment variables.

**Scope:** Applies to every Ballerina service built on `ballerinax/health.*` modules.

---

## Sub-Skills

### 1. Anatomy of a Healthcare Config.toml

Ballerina modules expose configurable values under their module path. For the `health.fhir.r4.parser` module's terminology config, the TOML key is namespaced as:

```toml
[ballerinax.health.fhir.r4.parser.terminologyConfig]
```

**Rules:**
- One Config.toml per Ballerina project root.
- Load order: `Config.toml` → env vars → CLI `-Ckey=value` overrides.
- Use `${ENV_VAR}` for any secret.
- Keep `Config.toml` git-ignored.

---

### 2. Terminology Block (Shared by parser, validator, terminology)

Wire a terminology service once; parser and validator both consume it.

```toml
[ballerinax.health.fhir.r4.parser.terminologyConfig]
isTerminologyValidationEnabled = true
terminologyServiceApi = "https://tx.fhir.org/r4"

# Optional OAuth2
tokenUrl = "https://auth.example.org/oauth/token"
clientId = "${TERM_CLIENT_ID}"
clientSecret = "${TERM_CLIENT_SECRET}"
```

- Set `isTerminologyValidationEnabled = false` in dev/offline environments.
- Point at a local mirror (e.g. Snowstorm) for SNOMED-heavy workloads.

---

### 3. Database / Persistence Block

Pick H2 for local dev, PostgreSQL for production.

```toml
[database]
type = "postgresql"           # or "h2"
host = "${DB_HOST}"
port = 5432
name = "fhirdb"
user = "${DB_USER}"
password = "${DB_PASSWORD}"
maxPoolSize = 20
connectionTimeoutSeconds = 30
```

H2 dev override:

```toml
[database]
type = "h2"
url = "jdbc:h2:mem:fhirdb;DB_CLOSE_DELAY=-1"
```

---

### 4. FHIR Client Block

For services that call out to a FHIR server (EHR connectivity, CDS prefetch, transformation pipelines).

```toml
[fhirClient]
baseUrl = "https://fhir.example.org/r4"
timeoutSeconds = 30
followRedirects = true
urlRewrite = true              # rewrite absolute URLs in responses

[fhirClient.auth]
type = "oauth2"                # oauth2 | pkjwt | basic | bearer
tokenUrl = "${OAUTH_TOKEN_URL}"
clientId = "${OAUTH_CLIENT_ID}"
clientSecret = "${OAUTH_CLIENT_SECRET}"
scopes = ["system/*.read"]

[fhirClient.retry]
count = 3
intervalSeconds = 2
backoffFactor = 2.0
```

---

### 5. SMART on FHIR Block

```toml
[smart]
issuer = "https://auth.example.org"
jwksUri = "https://auth.example.org/.well-known/jwks.json"
audience = "https://fhir.example.org"
scopes = [
    "patient/*.read",
    "user/*.read",
    "launch",
    "openid",
    "fhirUser"
]
clockSkewSeconds = 60
```

---

### 6. Authorization Block

Used by `health.fhir.r4.utils.authz`.

```toml
[ballerinax.health.fhir.r4.utils.authz]
patientIdClaim = "patient_id"
practitionerIdClaim = "practitioner_id"
privilegedUserRoles = ["admin", "system"]
enableCascadingChecks = true
```

---

### 7. De-Identification Block

Used by `health.fhir.r4.utils.deidentify`.

```toml
[ballerinax.health.fhir.r4.utils.deidentify]
skipOnError = false
validateInput = true
validateOutput = true
hashKey = "${DEID_HASH_KEY}"
encryptionKey = "${DEID_ENC_KEY}"

[[ballerinax.health.fhir.r4.utils.deidentify.rules]]
fhirPath = "Patient.name"
operation = "redact"

[[ballerinax.health.fhir.r4.utils.deidentify.rules]]
fhirPath = "Patient.telecom.value"
operation = "hash"

[[ballerinax.health.fhir.r4.utils.deidentify.rules]]
fhirPath = "Patient.address.line"
operation = "mask"

[[ballerinax.health.fhir.r4.utils.deidentify.rules]]
fhirPath = "Patient.identifier.value"
operation = "encrypt"
```

---

### 8. Audit Block

```toml
[audit]
enabled = true
destinationUrl = "${AUDIT_SINK_URL}"
logLevel = "INFO"
includeResources = ["Patient", "Observation", "MedicationRequest"]
excludeResources = ["AuditEvent"]
asyncDispatch = true
```

---

### 9. CDS Service Block

```toml
[cds]
prefetchServerUrl = "https://fhir.example.org/r4"
prefetchTimeoutSeconds = 10
decisionEngineUrl = "${DECISION_ENGINE_URL}"
decisionEngineApiKey = "${DECISION_ENGINE_KEY}"
feedbackLogPath = "/var/log/cds/feedback.jsonl"
```

---

### 10. Service / HTTP Block

```toml
[http]
port = 9090
host = "0.0.0.0"

[http.cors]
allowedOrigins = ["https://ehr.example.org"]
allowedMethods = ["GET", "POST", "PUT", "DELETE", "PATCH"]
allowedHeaders = ["Authorization", "Content-Type"]
maxAge = 3600

[http.tls]
certFile = "${TLS_CERT_PATH}"
keyFile = "${TLS_KEY_PATH}"
```

Never use `allowedOrigins = ["*"]` in production.

---

### 11. Secrets Hygiene

**Required practices:**
- `${ENV_VAR}` interpolation for passwords, API keys, cert paths.
- `.gitignore` entries: `Config.toml`, `Config.*.toml`, `.env`.
- Use a secrets manager (Vault / AWS Secrets Manager / Choreo Secrets) in production — inject as env vars at boot.

**Per-environment layering:**
```
Config.dev.toml     # committed, non-sensitive defaults
Config.prod.toml    # committed, non-sensitive prod defaults
Config.toml         # git-ignored, local overrides with secrets
```

Load with `BAL_CONFIG_FILES=Config.prod.toml:Config.toml`.

---

### 12. Full Worked Example — US Core FHIR Server

A production Config.toml for a US Core FHIR server with SMART on FHIR, terminology validation, PostgreSQL persistence, and audit to an external sink.

```toml
# ---- Persistence ----
[database]
type = "postgresql"
host = "${DB_HOST}"
port = 5432
name = "fhirdb"
user = "${DB_USER}"
password = "${DB_PASSWORD}"
maxPoolSize = 20

# ---- Terminology (parser + validator) ----
[ballerinax.health.fhir.r4.parser.terminologyConfig]
isTerminologyValidationEnabled = true
terminologyServiceApi = "https://tx.fhir.org/r4"

# ---- SMART on FHIR ----
[smart]
issuer = "${SMART_ISSUER}"
jwksUri = "${SMART_JWKS_URI}"
audience = "https://fhir.example.org"
scopes = ["patient/*.read", "user/*.read", "launch", "openid", "fhirUser"]

# ---- Authz ----
[ballerinax.health.fhir.r4.utils.authz]
patientIdClaim = "patient_id"
practitionerIdClaim = "practitioner_id"
privilegedUserRoles = ["admin", "system"]

# ---- Audit ----
[audit]
enabled = true
destinationUrl = "${AUDIT_SINK_URL}"
logLevel = "INFO"
includeResources = ["Patient", "Observation", "MedicationRequest", "Encounter"]

# ---- HTTP ----
[http]
port = 9090
host = "0.0.0.0"

[http.cors]
allowedOrigins = ["https://portal.example.org", "https://ehr.example.org"]
allowedMethods = ["GET", "POST", "PUT", "DELETE", "PATCH"]
allowedHeaders = ["Authorization", "Content-Type"]

[http.tls]
certFile = "${TLS_CERT_PATH}"
keyFile = "${TLS_KEY_PATH}"
```

---

## Related
- `skill-router` — start here.
- `parser-and-validator` — consumes the terminology block.
- `terminology-services` — when hosting your own terminology service.
- `security-and-authz` — SMART and authz blocks.
- `privacy-and-deidentification` — de-id rules block.
