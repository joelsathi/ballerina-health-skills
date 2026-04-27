---
name: skill-router
description: Catalog and decision guide for the Ballerina healthcare skill set — task-to-skill matrix, canonical workflows (HL7v2 → FHIR pipelines, FHIR API builds, CDS services, CDA migration, research extracts), decision forks (FHIR R4 vs R5, build vs prebuilt, IG selection), and anti-patterns. Use when the user asks 'which Ballerina health skill should I use for X', when planning a multi-skill workflow, or to check whether a prebuilt service exists before building from scratch.
---

# Skill: Skill Router (Start Here)

Entry point for the Ballerina healthcare skill set. Answers **"I want to do X — which skill(s) should I use, and in what order?"** Use this skill as a decision guide before diving into individual skills.

> **This skill is a catalog.** Names in `backticks` (e.g. `fhir-r4-development`) refer to other skills in this collection. They are not links — install each named skill separately into `~/.claude/skills/<name>/` (or your project's `.claude/skills/<name>/`) to make it active. See the repository README for install instructions.

---

## Task → Skill Matrix

| Task | Skills (in order) |
|---|---|
| Build a US Core Patient API | `fhir-r4-development` → `implementation-guides` → `parser-and-validator` → `healthcare-api-development` → `security-and-authz` → `configuration-best-practices` |
| Convert HL7 v2 ADT to FHIR | `hl7-v2-integration` → `data-transformation` → `fhir-r4-development` |
| Build a CDS Hooks service | `clinical-decision-support` → `health-tool-cli` → `configuration-best-practices` |
| Connect to Epic / Cerner / athenahealth | `emr-ehr-connectivity` → `prebuilt-services` → `security-and-authz` |
| Bulk export from a FHIR server | `emr-ehr-connectivity` → `configuration-best-practices` |
| Ingest a C-CDA document | `ccda-documents` → `data-transformation` → `fhir-r4-development` |
| Parse DICOM + expose DICOMweb | `dicom-integration` → `healthcare-api-development` |
| De-identify data for research | `privacy-and-deidentification` → `configuration-best-practices` |
| Implement prior authorization (Da Vinci PAS) | `implementation-guides` → `fhir-r4-development` → `healthcare-api-development` |
| Payer-to-payer data exchange (Da Vinci PDex/HRex) | `implementation-guides` → `security-and-authz` |
| Provider directory service (Da Vinci PlanNet) | `implementation-guides` → `fhir-r4-development` |
| Deploy a ready-made FHIR server | `prebuilt-services` → `configuration-best-practices` |
| Translate ICD-10 → SNOMED CT | `terminology-services` → `parser-and-validator` |
| Validate incoming FHIR payloads | `parser-and-validator` → `terminology-services` → `configuration-best-practices` |
| Implement SMART on FHIR | `security-and-authz` → `healthcare-api-development` → `configuration-best-practices` |
| Generate a package from a custom IG | `health-tool-cli` → `implementation-guides` → `fhir-r4-development` |
| Patient matching / MPI reconciliation | `privacy-and-deidentification` → `fhir-r4-development` |
| Cross-border patient summary (IPS) | `implementation-guides` → `fhir-r4-development` |
| Consumer claims access (CARIN BB) | `implementation-guides` → `security-and-authz` |

---

## Canonical Workflows

### W1. "HL7 v2 in → FHIR out" pipeline
1. **Parse** the incoming v2 message — `hl7-v2-integration`.
2. **Transform** to FHIR Bundle — `data-transformation` (uses `v2ToFhir()` or custom mapper).
3. **Validate** against US Core — `parser-and-validator`.
4. **Persist** via FHIR server — `prebuilt-services` or `emr-ehr-connectivity`.

### W2. "Build a FHIR API from scratch"
1. **Generate** the types from an IG — `health-tool-cli` (`bal health fhir -m package`).
2. **Generate** service templates — `health-tool-cli` (`-m template`).
3. **Wire** parser/validator — `parser-and-validator`.
4. **Secure** with SMART — `security-and-authz`.
5. **Configure** — `configuration-best-practices`.
6. **Deploy** — `healthcare-api-development`.

### W3. "CDS service that calls a decision engine"
1. **Scaffold** from TOML — `health-tool-cli` (`-m cds`).
2. **Implement** hook handlers — `clinical-decision-support`.
3. **Configure** prefetch server — `configuration-best-practices`.
4. **Optionally** integrate with DTR / CRD — `implementation-guides`.

### W4. "Legacy CDA migration"
1. **Parse** CDA XML — `ccda-documents`.
2. **Transform** to FHIR — `data-transformation` (`ccdaToFhir()`).
3. **Validate** — `parser-and-validator`.

### W5. "Research data extract"
1. **Read** from FHIR server — `emr-ehr-connectivity` (bulk export).
2. **De-identify** — `privacy-and-deidentification`.
3. **Configure** rules — `configuration-best-practices`.

---

## Decision Forks

### FHIR R4 vs R5
- **Default: R4.** Full IG support, mature ecosystem.
- **R5** only if your target consumer requires it. The Ballerina R5 repo is early — no Da Vinci / regional / utility modules yet.
- See `fhir-r4-development` and `fhir-r5-development`.

### Generate from IG vs use Prebuilt
- **Prebuilt first.** Check `prebuilt-services` for WSO2 open-healthcare services covering your use case (FHIR R4 server, Epic connectors, metadata, audit, authz).
- **Generate** via `health-tool-cli` when you need a custom IG or profile variant.

### Which HL7 v2 version?
- Match the sending system. When greenfield, prefer **v2.5.1** (widely supported, modern segments).
- Older legacy: v2.3.1 or v2.4. Newer hospital vendors: v2.7+.
- See `hl7-v2-integration`.

### Local DB vs managed
- Dev / POC: **H2** embedded.
- Prod: **PostgreSQL**.
- Both patterns in `configuration-best-practices`.

### Which Implementation Guide?
- **US Core** — US clinical data exchange, 21st Century Cures compliance.
- **Da Vinci CRD / DTR / PAS** — payer-provider workflows (coverage, prior auth, questionnaires).
- **Da Vinci PDex / HRex** — payer-to-payer / member matching.
- **Da Vinci PlanNet** — provider directory.
- **IPS** — cross-border patient summary.
- **CARIN BB** — consumer claims access.
- **AU / LK Core / Belgium Federal** — regional.
- See `implementation-guides`.

---

## Anti-Patterns

| Don't | Do |
|---|---|
| Hand-roll a FHIR JSON parser | Use `health.fhir.r4.parser` (`parser-and-validator`) |
| Hand-roll OAuth 2.0 | Use `smartconfig` + `utils/authz` (`security-and-authz`) |
| Skip profile validation | Enable `parseWithValidation()` + profile-targeted `validate()` |
| Store secrets in Config.toml | Use `${ENV_VAR}` interpolation (`configuration-best-practices`) |
| Build EHR connectors from scratch | Use `fhir.templates/{epic,cerner,athena}` (`emr-ehr-connectivity`) |
| Write custom C-CDA parsers | Use `health.ccda.r3` (`ccda-documents`) |
| Inline de-id logic in transforms | Use `utils/deidentify` rules (`privacy-and-deidentification`) |
| Mix R4 and R5 resources in one bundle | Pick one; convert at boundaries |

---

## Related
- `configuration-best-practices` — runtime wiring for every skill below.
- `health-tool-cli` — generates packages / templates / CDS stubs.
- `prebuilt-services` — check before building.
