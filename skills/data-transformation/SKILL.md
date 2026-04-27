---
name: data-transformation
description: Cross-format healthcare data transformation in Ballerina — HL7 v2.3 → FHIR R4 (v2tofhirr4 with v2ToFhir(), segment-level mappers, 18 patient + 10 clinical mapping functions, custom V2SegmentToFhirMapper), C-CDA → FHIR (ccdatofhir with section-to-US-Core profile mappings), EDI/X12 (834 enrollment, 837 claims), FHIR-aware JSON merge (jsonmerge), and pipeline patterns chaining de-identification and patient matching. Use for converting legacy formats to FHIR or building multi-step transformation workflows.
---

# Skill: Data Transformation

Transform healthcare data between legacy formats (HL7 v2, C-CDA, EDI) and the modern FHIR R4 standard. Ballerina provides pre-built mappings and customizable transformation pipelines.

**Packages:** `health.hl7v23.utils.v2tofhirr4`, `health.fhir.r4utils.ccdatofhir`

---

## Sub-Skills

### 1. HL7 v2 to FHIR R4 Transformation

Convert HL7 v2.3 messages to FHIR R4 Bundles using pre-built segment-level mappings.

**Package:** `health.hl7v23.utils.v2tofhirr4`

**Primary Functions:**
| Function | Description |
|----------|-------------|
| `v2ToFhir()` | Convert a complete HL7 message or string to a FHIR R4 Bundle |
| `segmentToFhir()` | Transform individual segments with optional custom mapping |

**Segment-to-FHIR Mappings:**

| HL7 Segment | FHIR Resource(s) |
|-------------|-------------------|
| MSH (Message Header) | MessageHeader |
| EVN (Event Type) | Provenance |
| PID (Patient ID) | Patient |
| PV1 (Patient Visit) | Patient, Encounter |
| PV2 (Visit Additional) | Encounter |
| PD1 (Patient Demographics) | Patient |
| NK1 (Next of Kin) | Patient (contact) |
| DG1 (Diagnosis) | Condition, Encounter, EpisodeOfCare |
| AL1 (Allergy) | AllergyIntolerance |
| OBX (Observation) | Observation |
| OBR (Observation Request) | DiagnosticReport, ServiceRequest |
| ORC (Common Order) | DiagnosticReport, Immunization |

**Patient Mapping Functions (18 total):**
- `pidToPatient()`, `pv1ToPatient()`, `nk1ToPatient()`, `pd1ToPatient()`
- Supporting functions for address, names, contact info, demographics

**Clinical Mapping Functions (10 total):**
- `dg1ToCondition()`, `dg1ToEncounter()`, `dg1ToEpisodeOfCare()`
- `obxToObservation()`, `obrToDiagnosticReport()`, `obrToServiceRequest()`
- `orcToImmunization()`, `al1ToAllergyIntolerance()`
- `mshToMessageHeader()`, `evnToProvenance()`

**Data Type Mappings:**
| HL7 v2 Type | FHIR Type(s) |
|-------------|--------------|
| CE (Coded Entry) | Code, CodeableConcept, Coding, URI |
| XAD (Extended Address) | Address |
| XPN (Person Name) | HumanName |
| XTN (Telecom) | ContactPoint |
| XON (Organization) | Organization, Reference |
| XCN (Composite ID) | Coding, Reference, CodeableConcept |
| EI (Entity Identifier) | Identifier, Coding, Reference |
| TS/DTM (Timestamp) | dateTime, instant |

**Custom Mapping Support:**
- `V2SegmentToFhirMapper` record for holding custom mapping functions
- `V2ToFhirCustomMapperServiceConfig` for segment-level customization
- Override any standard segment transformation with custom logic

---

### 2. C-CDA to FHIR R4 Transformation

Convert Clinical Document Architecture (C-CDA) documents to FHIR R4 Bundles following the C-CDA on FHIR implementation guide.

**Package:** `health.fhir.r4utils.ccdatofhir`

**Primary Function:**
- `ccdaToFhir()` - Main entry point accepting C-CDA XML and optional custom mappers
- `ccdaToEncounter()` - Map encounter activities and encompassing encounters
- `ccdaToDocumentReference()` - Transform document references

**Section-to-FHIR Mappings:**
| C-CDA Section | FHIR Profile |
|---------------|-------------|
| Allergy Intolerance | US Core AllergyIntolerance |
| Problems | US Core Condition |
| Results | US Core DiagnosticReport |
| Immunizations | US Core Immunization |
| Medications | US Core MedicationRequest |
| Patient Demographics | US Core Patient |
| Practitioners | US Core Practitioner |
| Procedures | US Core Procedure |

**Additional Features:**
- 36+ utility functions for granular element mapping (dates, identifiers, codings, addresses, telecom)
- Output as FHIR R4 Bundle with optional Provenance records
- Custom mapper injection via `CcdaToFhirMapper` record type
- Override default transformation logic for specific use cases

---

### 3. EDI / X12 Transformation

Transform EDI (Electronic Data Interchange) and X12 formats used in healthcare claims and enrollment.

**Key Concepts:**
- EDI formats to Ballerina records and back
- 834 (Benefit Enrollment and Maintenance) processing
- 837 (Healthcare Claims) processing
- Region-specific EDI standard handling
- Integration with payer and clearinghouse systems

---

### 4. Custom Transformation Pipelines

Build multi-step transformation workflows combining multiple data format conversions.

**Key Concepts:**
- Chaining transformations: HL7 v2 -> FHIR -> downstream system format
- Data enrichment during transformation (terminology lookup, reference resolution)
- Error handling and partial transformation support
- Validation at each transformation stage
- Audit trail and provenance tracking through transformation steps

---

### 5. DICOM ↔ FHIR

There is **no prebuilt DICOM↔FHIR mapper** in the Ballerina healthcare stack. When building this integration, use `health.dicom.dicomparser` to extract dataset attributes, then build FHIR `ImagingStudy` / `DiagnosticReport` resources using `health.fhir.r4`. See `dicom-integration` for the extraction side.

---

### 6. JSON Merge with FHIR Support

**Package:** `health.fhir.r4utils.jsonmerge`

Deep recursive JSON merge with FHIR-aware behavior — key-based array matching, append modes, composite keys, optional pre/post validation.

**Use cases:**
- Patch-style updates where two partial payloads merge into a canonical resource
- Layering organization defaults over incoming Bundle entries
- Overlay configuration onto reference templates

```ballerina
import ballerinax/health.fhir.r4utils.jsonmerge;

json merged = check jsonmerge:mergeFHIRResources(base, overlay);
```

---

### 7. De-Identification in Transformation Pipelines

When a transformation feeds a research or analytics target, chain `utils/deidentify` as a final step. See `privacy-and-deidentification` for rule definition and key handling.

---

### 8. Patient Matching in Transformation Pipelines

When transforming incoming data from multiple sources into a canonical FHIR store, insert `utils/patient-matching` between parsing and persistence to reconcile duplicates. See `privacy-and-deidentification` §6.

---

## Related
- `hl7-v2-integration` — source format parsing.
- `ccda-documents` — CDA parsing separate from transformation.
- `dicom-integration` — imaging integration.
- `privacy-and-deidentification` — de-id + matching steps.
- `parser-and-validator` — validate output Bundles.
