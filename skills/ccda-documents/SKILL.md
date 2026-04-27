---
name: ccda-documents
description: C-CDA R2 clinical document parsing and bidirectional FHIR conversion in Ballerina with health.ccda.r3, ccdatofhir, and fhirtoccda. Covers CCD/Continuity of Care/Discharge Summary/Referral Note parsing, section navigation by LOINC template ID, C-CDA → FHIR Bundle (US Core profiles), FHIR → C-CDA generation with race/ethnicity extensions, and custom mapper injection. Requires Ballerina 2201.12.0+. Use when parsing CDA XML or converting between C-CDA and FHIR R4.
---

# Skill: C-CDA Documents

Parse, navigate, and convert Consolidated CDA (C-CDA R2) clinical documents. Ballerina provides a dedicated `health.ccda` module for raw CDA processing, plus `ccdatofhir` and `fhirtoccda` utilities for bidirectional FHIR interoperability.

**Packages:** `health.ccda` (module: `ccda.r3`), `health.fhir.r4utils.ccdatofhir`, `health.fhir.r4utils.fhirtoccda`

**Requires:** Ballerina 2201.12.0+

---

## Sub-Skills

### 1. C-CDA R2 Parsing

Parse a CDA XML document into typed Ballerina records.

```ballerina
import ballerinax/health.ccda.r3 as ccda;

string xml = check io:fileReadString("ccd.xml");
ccda:ClinicalDocument doc = check ccda:parse(xml);
```

The parser supports CCD, Continuity of Care, Discharge Summary, and Referral Note document types.

---

### 2. Section Navigation

C-CDA organizes clinical data into sections. Common sections (LOINC template IDs):

| Section | LOINC | Typical Templates |
|---|---|---|
| Allergies | 48765-2 | Allergy Concern Act |
| Problems | 11450-4 | Problem Concern Act |
| Medications | 10160-0 | Medication Activity |
| Results | 30954-2 | Result Organizer |
| Vital Signs | 8716-3 | Vital Signs Organizer |
| Immunizations | 11369-6 | Immunization Activity |
| Procedures | 47519-4 | Procedure Activity |
| Encounters | 46240-8 | Encounter Activity |
| Plan of Care | 18776-5 | Planned Act / Encounter |

Use the parser's section accessors to iterate entries within each section.

---

### 3. C-CDA → FHIR R4 Conversion

**Package:** `health.fhir.r4utils.ccdatofhir`

Single-call transformation:

```ballerina
import ballerinax/health.fhir.r4utils.ccdatofhir;
import ballerinax/health.fhir.r4 as r4;

r4:Bundle bundle = check ccdatofhir:ccdaToFhir(xmlPayload);
```

**Section → FHIR Profile mappings:**

| C-CDA Section | FHIR Profile (US Core) |
|---|---|
| Allergies | AllergyIntolerance |
| Problems | Condition |
| Medications | MedicationRequest |
| Results | DiagnosticReport + Observation |
| Vital Signs | Observation |
| Immunizations | Immunization |
| Procedures | Procedure |
| Patient demographics | Patient |
| Author / Custodian | Practitioner, Organization |

---

### 4. FHIR R4 → C-CDA Conversion

**Package:** `health.fhir.r4utils.fhirtoccda`

```ballerina
import ballerinax/health.fhir.r4utils.fhirtoccda;

xml ccdaXml = check fhirtoccda:fhirToCcda(bundle);
```

Covers patient demographics, allergies, conditions, medications, procedures, immunizations, encounters, and diagnostic reports. Handles race/ethnicity extensions, deceased status, and HL7 date/time formatting.

---

### 5. Custom Mapper Injection

Both `ccdatofhir` and `fhirtoccda` accept a mapper record to override section-level logic:

```ballerina
import ballerinax/health.fhir.r4utils.ccdatofhir;

ccdatofhir:CcdaToFhirMapper customMapper = {
    problemsMapper: myProblemMappingFn,
    medicationsMapper: myMedicationMappingFn
};

r4:Bundle bundle = check ccdatofhir:ccdaToFhir(xmlPayload, customMapper);
```

Use this for site-specific coded vocabularies or legacy template variants.

---

### 6. Common Integration Patterns

- **Legacy migration:** bulk-ingest CDA archive → `ccdaToFhir()` → load to FHIR store.
- **Portal export:** pull FHIR resources → `fhirToCcda()` → deliver CDA to requesting systems.
- **Mixed exchange:** receive CDA on one interface, FHIR on another — normalize to FHIR internally.

---

### 7. Validation Considerations

The parser is lenient; downstream validation should:
- Check required US Core fields after conversion.
- Validate terminology via the terminology module.
- Emit `OperationOutcome` for any conversion failures (track with `Provenance`).

See `parser-and-validator`.

---

## Related
- `data-transformation` — broader transformation pipelines.
- `fhir-r4-development` — US Core profiles.
- `parser-and-validator` — validate converted Bundles.
- `skill-router` — CDA migration workflow.
