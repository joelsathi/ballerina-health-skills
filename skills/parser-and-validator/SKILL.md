---
name: parser-and-validator
description: Parse and validate untrusted FHIR R4/R5 payloads in Ballerina with health.fhir.r4.parser and health.fhir.r4.validator. Covers parse(), parseWithValidation(), profile-targeted parsing (e.g. USCorePatientProfile), standalone validate(), OperationOutcome generation from validation errors, and shared terminologyConfig wiring. Use when ingesting FHIR JSON/XML from external sources or gating an API's incoming payloads with FHIR-compliant 4xx responses.
---

# Skill: Parser & Validator

Ingest untrusted FHIR payloads safely with the `parser` and `validator` modules. Parser converts JSON → typed records; validator enforces structural, cardinality, profile, and value-domain constraints. Together they form the gate for any FHIR data entering a Ballerina service.

**Packages:** `health.fhir.r4.parser`, `health.fhir.r4.validator`
**R5 equivalents:** `health.fhir.r5.parser`, `health.fhir.r5.validator`

---

## Sub-Skills

### 1. Parse Untrusted FHIR JSON

```ballerina
import ballerinax/health.fhir.r4.parser;
import ballerinax/health.fhir.r4.international401 as r4;

// Parse to base type
r4:Patient patient = <r4:Patient> check parser:parse(payload);
```

Always use `check` — parsing can fail on malformed JSON or unknown resource types.

---

### 2. Parse to a Profile Type

For profile-constrained payloads, target the specific profile:

```ballerina
import ballerinax/health.fhir.r4.uscore501 as uscore;

uscore:USCorePatientProfile patient =
    <uscore:USCorePatientProfile> check parser:parse(payload, uscore:USCorePatientProfile);
```

The parser enforces profile-specific cardinality at parse time.

---

### 3. Parse With Validation

Combine parse + validate in one call:

```ballerina
r4:Patient patient =
    <r4:Patient> check parser:parseWithValidation(payload, r4:Patient);
```

This is the recommended entry for any external payload.

---

### 4. Standalone Validation

Validate a resource already in memory:

```ballerina
import ballerinax/health.fhir.r4.validator;

error? result = validator:validate(patient);              // base type
error? result2 = validator:validate(patient, uscore:USCorePatientProfile);  // profile
```

Returns `FHIRValidationError` on failure with severity, diagnostic message, and FHIR path.

---

### 5. Error Handling → OperationOutcome

Convert validation errors into a FHIR `OperationOutcome`:

```ballerina
import ballerinax/health.fhir.r4;

r4:OperationOutcome outcome = r4:createOperationOutcome(
    severity = "error",
    code = "invalid",
    diagnostics = validationError.message()
);
```

Return `OperationOutcome` in a `400 Bad Request` response.

---

### 6. Terminology Validation Wiring

Both parser and validator read the same terminology config block from `Config.toml`:

```toml
[ballerinax.health.fhir.r4.parser.terminologyConfig]
isTerminologyValidationEnabled = true
terminologyServiceApi = "https://tx.fhir.org/r4"
tokenUrl = "${TERM_TOKEN_URL}"
clientId = "${TERM_CLIENT_ID}"
clientSecret = "${TERM_CLIENT_SECRET}"
```

- **Dev/offline:** set `isTerminologyValidationEnabled = false` to skip terminology lookups.
- **Prod:** always enable for regulated workloads.

See `configuration-best-practices` section 2.

---

### 7. Validation Pipeline Pattern

Standard ingestion sequence:

```
HTTP request
  → parse(payload)                    [syntactic]
  → validate(resource, Profile)        [structural + profile]
  → business rules check
  → persist
  → AuditEvent emit
```

On any failure, respond with a FHIR `OperationOutcome` and a 4xx status.

---

### 8. Error Types

| Error | When |
|---|---|
| `FHIRParseError` | Malformed JSON, unknown resourceType, type mismatch |
| `FHIRValidationError` | Cardinality violation, missing required element, invalid code |
| `FHIRTypeError` | Expected one profile, received another |
| `FHIRProcessingError` | Downstream terminology service failure |
| `FHIRSerializerError` | Output serialization failure |

All extend a common `FHIRError` with severity, code, and FHIR path fields.

---

## Related
- `fhir-r4-development` — resource types and serialization.
- `terminology-services` — terminology server hosting.
- `implementation-guides` — profile-specific types for validation.
- `configuration-best-practices` — terminology wiring.
