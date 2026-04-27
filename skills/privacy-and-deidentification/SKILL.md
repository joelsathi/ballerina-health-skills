---
name: privacy-and-deidentification
description: FHIR de-identification (redact/mask/hash via HMAC-SHA256/encrypt via AES-ECB) over FHIRPath rules and patient matching for MPI reconciliation in Ballerina with health.fhir.r4.utils.deidentify and health.fhir.r4.utils.patient-matching. Covers Config.toml rule definition, programmatic deidentify(), custom operations (e.g. date shifting, k-anonymity), key management with KMS rotation, default rule-based PatientMatcher with weighted demographics, and custom PatientMatcher subclasses for ML/EMPI integration. Use when preparing data for research/analytics or reconciling duplicate patient records.
---

# Skill: Privacy & De-Identification

De-identify FHIR data for research, analytics, and test environments. Reconcile patient identities across systems with the patient-matching module. Covers mask / encrypt / hash / redact operations over FHIRPath rules, plus rule-based MPI matching.

**Packages:** `health.fhir.r4.utils.deidentify`, `health.fhir.r4.utils.patient-matching`

---

## Sub-Skills

### 1. De-Identification Operations

`utils/deidentify` supports four operations, each selectable per FHIRPath rule:

| Operation | Description | Use case |
|---|---|---|
| `redact` | Remove element entirely | Names, addresses, notes |
| `mask` | Replace with asterisks | Phone numbers, MRNs in UI |
| `hash` | HMAC-SHA256 one-way hash | Linkable research IDs |
| `encrypt` | AES-ECB reversible encryption | Pseudonymized IDs recoverable with key custody |

---

### 2. Rule Definition in Config.toml

```toml
[ballerinax.health.fhir.r4.utils.deidentify]
hashKey = "${DEID_HASH_KEY}"
encryptionKey = "${DEID_ENC_KEY}"
skipOnError = false
validateInput = true
validateOutput = true

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
fhirPath = "Patient.identifier.where(system='http://hospital.org/mrn').value"
operation = "encrypt"
```

---

### 3. Programmatic De-Identification

```ballerina
import ballerinax/health.fhir.r4.utils.deidentify;

r4:Patient deidentified = check deidentify:deidentify(patient);

// or for a bundle
r4:Bundle deidentifiedBundle = check deidentify:deidentify(bundle);
```

---

### 4. Custom De-Identification Functions

Extend with organization-specific logic (date shifting, k-anonymity grouping):

```ballerina
import ballerinax/health.fhir.r4.utils.deidentify;

function shiftDate(anydata value) returns anydata|error {
    // custom date-shift logic
    return shiftedDate;
}

deidentify:registerOperation("shift", shiftDate);
```

Config.toml:

```toml
[[ballerinax.health.fhir.r4.utils.deidentify.rules]]
fhirPath = "Patient.birthDate"
operation = "shift"
```

---

### 5. Key Management

- **Never** hardcode `hashKey` or `encryptionKey`.
- Inject via `${ENV}` variables at deploy time.
- Rotate keys per policy (60/90/180 days depending on classification).
- Retain old keys in a KMS for re-identification of legacy records.

---

### 6. Patient Matching (MPI Reconciliation)

**Package:** `health.fhir.r4.utils.patient-matching`

Rule-based default matcher compares demographics (name, DOB, gender, identifiers) with configurable weights.

```ballerina
import ballerinax/health.fhir.r4.utils.patientmatching;

r4:Patient[] candidates = [...];
patientmatching:MatchResult[] matches = check patientmatching:match(
    incomingPatient,
    candidates
);
```

---

### 7. Custom Patient Matchers

Extend the abstract `PatientMatcher` type for probabilistic matching, ML-based, or external EMPI services:

```ballerina
public isolated class MlPatientMatcher {
    *patientmatching:PatientMatcher;

    public isolated function match(r4:Patient incoming, r4:Patient[] candidates)
            returns patientmatching:MatchResult[]|error {
        // call ML service
    }
}
```

---

### 8. De-ID + Matching Pipeline

Typical research extract pipeline:
1. Bulk-export FHIR data from source.
2. Run `deidentify()` per resource.
3. Run `match()` to reconcile duplicates.
4. Write to research warehouse with only pseudonymized IDs.
5. Retain encryption keys in KMS for future re-identification if IRB approves.

---

## Related
- `data-transformation` — de-id often sits in a transformation pipeline.
- `configuration-best-practices` — rules + keys block.
- `parser-and-validator` — validate pre and post de-id.
- `skill-router` — research extract workflow.
