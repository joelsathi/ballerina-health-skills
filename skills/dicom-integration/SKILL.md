---
name: dicom-integration
description: DICOM Part 10 binary parsing, DICOMweb (QIDO-RS query, WADO-RS retrieve, STOW-RS store), and imaging service development in Ballerina with health.dicom, health.dicom.dicomparser, health.dicom.dicomweb, and health.dicom.dicomservice. Covers DICOM VRs, dataset/data element types, DICOM tag dictionary, DICOMweb JSON serialization, and HTTP service patterns for PACS bridges and cross-enterprise retrieve. Use when parsing DICOM binaries or building DICOMweb endpoints. Note: no prebuilt DICOM↔FHIR mapper — build custom mappers for ImagingStudy/DiagnosticReport.
---

# Skill: DICOM & Imaging Integration

Work with DICOM (Digital Imaging and Communications in Medicine) data in Ballerina — parse binary DICOM Part 10 files, serve DICOMweb JSON responses (QIDO-RS, WADO-RS, STOW-RS), and build custom imaging services.

**Packages:** `health.dicom`, `health.dicom.dicomparser`, `health.dicom.dicomweb`, `health.dicom.dicomservice`

**Repo:** https://github.com/ballerina-platform/module-ballerinax-health.dicom

---

## Sub-Skills

### 1. DICOM Core Types

**Package:** `health.dicom`

Foundation layer providing DICOM Value Representations (VRs), tag dictionary, data element types, and validators.

**Key types:**
- `DataElement`, `DataSet`
- VR encoders/validators (AE, AS, AT, CS, DA, DS, DT, FD, FL, IS, LO, LT, OB, OD, OF, OW, PN, SH, SL, SQ, SS, ST, TM, UI, UL, UN, US, UT)
- Tag constants for standard DICOM data dictionary

---

### 2. Binary DICOM Parsing

**Package:** `health.dicom.dicomparser`

Parse DICOM Part 10 binary files into structured datasets.

```ballerina
import ballerinax/health.dicom.dicomparser;
import ballerinax/health.dicom;

byte[] fileBytes = check io:fileReadBytes("image.dcm");
dicom:DataSet ds = check dicomparser:parse(fileBytes);
```

---

### 3. DICOMweb JSON Responses

**Package:** `health.dicom.dicomweb`

Transform datasets into DICOMweb JSON per the standard.

**Supported operations:**
| Service | Purpose |
|---|---|
| QIDO-RS | Query — search for studies/series/instances |
| WADO-RS | Retrieve — fetch studies/series/instances/frames |
| STOW-RS | Store — upload DICOM instances |

```ballerina
import ballerinax/health.dicom.dicomweb;

json qidoResponse = check dicomweb:toQidoResponse(datasets);
```

---

### 4. Building a DICOMweb Service

**Package:** `health.dicom.dicomservice`

Ballerina service type for DICOMweb APIs.

```ballerina
import ballerina/http;
import ballerinax/health.dicom.dicomservice;

service /dicomweb on new http:Listener(8080) {
    resource function get studies(http:Request req) returns json|error {
        // QIDO-RS study query
    }

    resource function get studies/[string studyInstanceUid](http:Request req)
            returns http:Response|error {
        // WADO-RS study retrieve
    }

    resource function post studies(http:Request req) returns json|error {
        // STOW-RS store
    }
}
```

---

### 5. DICOM → FHIR Integration

There is **no prebuilt DICOM↔FHIR mapper** in the Ballerina healthcare stack. When building this integration:

- **DICOM Study** → FHIR `ImagingStudy` resource.
- **DICOM SR** (Structured Report) → FHIR `DiagnosticReport` + `Observation`.
- **DICOM Instance UIDs** → FHIR `ImagingStudy.series.instance.uid`.
- **Patient tags** (0010,xxxx) → FHIR `Patient`.

Build custom mappers using `fhirpath` for dynamic extraction; validate the generated FHIR via the validator module.

---

### 6. Common Integration Patterns

- **PACS bridge:** receive DICOM from modalities → store in PACS → expose via DICOMweb.
- **Report linkage:** generate FHIR `ImagingStudy` references whenever a DICOM study lands, linked to an `Encounter`.
- **Cross-enterprise retrieve:** WADO-RS endpoint backed by S3/object storage.

---

### 7. Deployment Notes

- DICOM binaries are large — configure HTTP response size limits accordingly.
- For WADO-RS, stream responses rather than buffering whole instances in memory.
- STOW-RS uploads are multipart/related; configure the HTTP listener with high max-request-size.

---

## Related
- `healthcare-api-development` — service hosting patterns.
- `fhir-r4-development` — `ImagingStudy` and `DiagnosticReport`.
- `configuration-best-practices` — HTTP listener tuning.
