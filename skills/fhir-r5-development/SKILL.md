---
name: fhir-r5-development
description: FHIR R5 development with Ballerina — typed R5 records (179+ resources via health.fhir.r5.international500), R4 vs R5 differences (MedicationRequest, Observation, Subscription rewrite, new resources), R5 parser/validator, FHIRPath for R5, and R4/R5 coexistence strategies. Use when the integration target requires FHIR R5 specifically; otherwise default to FHIR R4. Note: Ballerina R5 has no Da Vinci, US Core, regional IGs, or utility modules yet.
---

# Skill: FHIR R5 Development

Work with FHIR R5 resources in Ballerina. The R5 module is newer and narrower than R4 — use this skill when your integration target requires R5 specifically.

**Packages:** `health.fhir.r5`, `health.fhir.r5.fhirr5`, `health.fhir.r5.international500`, `health.fhir.r5.parser`, `health.fhir.r5.validator`, `health.fhir.r5utils.fhirpath`

**Repo:** https://github.com/ballerina-platform/module-ballerinax-health.fhir.r5

---

## Sub-Skills

### 1. R5 Resource Modeling

Typed Ballerina records for 179+ FHIR R5 resources via `health.fhir.r5.international500`.

```ballerina
import ballerinax/health.fhir.r5.international500 as r5;

r5:Patient patient = {
    resourceType: "Patient",
    name: [{family: "Doe", given: ["Jane"]}],
    gender: "female",
    birthDate: "1985-03-12"
};
```

---

### 2. R4 vs R5 Differences

Notable R5 changes you'll hit in practice:
- `MedicationRequest` → renamed fields around substitution and dose form.
- `Observation` — new `triggeredBy`, refined `instantiates`.
- `Subscription` — rewritten topic-based subscription model.
- New resources: `ActorDefinition`, `Requirements`, `ArtifactAssessment`, `EvidenceReport`, `InventoryItem`.
- Stricter cardinality on several workflow resources.

Consult the official R5 diff for field-level migration.

---

### 3. R5 Parser & Validator

Same API shape as R4 counterparts:

```ballerina
import ballerinax/health.fhir.r5.parser;
import ballerinax/health.fhir.r5.international500 as r5;

r5:Patient patient = <r5:Patient> check parser:parse(payload);
```

Terminology validation block in Config.toml:

```toml
[ballerinax.health.fhir.r5.parser.terminologyConfig]
isTerminologyValidationEnabled = true
terminologyServiceApi = "https://tx.fhir.org/r5"
```

---

### 4. Coexistence Strategy (R4 + R5)

Most production deployments will run R4 for years. Patterns:
- **Boundary conversion:** keep R4 internally; convert to R5 only at interfaces that demand it.
- **Separate services:** route R5 endpoints to a dedicated Ballerina package to avoid mixing imports.
- **Don't mix records in the same Bundle** — FHIR bundles are version-specific.

---

### 5. R5 Gaps in Ballerina (as of 2026)

Not yet available in the R5 repo:
- No Da Vinci IGs (CRD, DTR, HRex, PAS, PDex, PlanNet).
- No US Core R5 profiles.
- No regional IGs (AU, LK Core, Belgium).
- No utility modules (`ccdatofhir`, `fhirtoccda`, `deidentify`, `jsonmerge`, `patient-matching`, `authz`).
- No CDS Hooks R5 module.
- No IPS / CARIN BB R5.

If you need any of the above, stay on R4 for now.

---

### 6. FHIRPath for R5

Via `health.fhir.r5utils.fhirpath`:

```ballerina
import ballerinax/health.fhir.r5utils.fhirpath;

anydata[] names = check fhirpath:getValuesFromFhirPath(patient, "Patient.name.given");
```

---

## Related
- `fhir-r4-development` — for R4 resources.
- `parser-and-validator` — parser patterns apply to both versions.
- `configuration-best-practices` — terminology wiring.
- `skill-router` — R4 vs R5 decision fork.
