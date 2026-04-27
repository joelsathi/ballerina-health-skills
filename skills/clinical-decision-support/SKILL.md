---
name: clinical-decision-support
description: CDS Hooks 2.0 service development in Ballerina with health.fhir.cds — patient-view, order-sign, order-select, order-dispatch, appointment-book, encounter-start, encounter-discharge hooks; CdsService discovery, CdsRequest/Response, cards (info/warning/critical) with suggestions and links, prefetch handling via validateAndProcessPrefetch(), feedback capture, SMART app launch deep links, and template generation via 'bal health fhir -m cds -i hooks.toml'. Use when building CDS services that integrate with EHR clinical workflows.
---

# Skill: Clinical Decision Support (CDS)

Build CDS Hooks 2.0 services that provide real-time clinical decision support within EHR workflows. Ballerina provides typed models, validation, prefetch handling, and template generation.

**Package:** `health.fhir.cds`

---

## Sub-Skills

### 1. CDS Hooks Service Development

Implement CDS Hooks 2.0 services that respond to clinical workflow events with actionable guidance.

**Supported Hook Types:**
| Hook | Trigger | Use Case |
|------|---------|----------|
| `patient-view` | Patient record opened | Show alerts, reminders, care gaps |
| `order-sign` | Clinician signs an order | Drug interaction checks, formulary guidance |
| `order-select` | Clinician selects an order | Real-time order recommendations |
| `order-dispatch` | Order dispatched for fulfillment | Fulfillment routing, specialty pharmacy |
| `appointment-book` | Appointment being scheduled | Scheduling constraints, prep instructions |
| `encounter-start` | Encounter initiated | Protocol activation, screening reminders |
| `encounter-discharge` | Patient being discharged | Discharge checklist, follow-up scheduling |

**Key Concepts:**
- CdsService definition for service discovery
- CdsRequest processing with context validation
- CdsResponse construction with cards and system actions
- FhirAuthorization for OAuth 2.0 token handling

---

### 2. CDS Cards & Suggestions

Build informational cards, actionable suggestions, and app links to return to EHR clients.

**Card Properties:**
- Summary and detail text
- Indicator levels: `info`, `warning`, `critical`
- Source attribution with labels, URLs, and icons
- Selection behavior: `at-most-one`, `any`

**Suggestion Actions:**
| Action Type | Description |
|-------------|-------------|
| `create` | Suggest creating a new FHIR resource |
| `update` | Suggest modifying an existing FHIR resource |
| `delete` | Suggest removing a FHIR resource |

**Link Types:**
- Absolute URLs for external resources
- SMART app launch URLs with app context
- App context passing for deep linking into clinical apps

---

### 3. CDS Prefetch & Context Validation

Validate incoming CDS requests and manage FHIR data prefetching.

**Key Functions:**
| Function | Purpose |
|----------|---------|
| `validateContext()` | Validate CDS request context against service definitions |
| `validateAndProcessPrefetch()` | Validate and fetch missing FHIR prefetch data |
| `createCdsError()` | Create structured CDS error objects |
| `cdsErrorToHttpResponse()` | Convert CDS errors to HTTP responses |

**Key Concepts:**
- Prefetch template definitions in service discovery
- Automatic fetching of missing prefetch data from FHIR servers
- Context validation per hook type
- Graceful error handling with structured CDS error responses

---

### 4. CDS Feedback Processing

Capture clinician responses to CDS cards for analytics and quality improvement.

**Key Concepts:**
- Acceptance/override outcome recording
- User comments and override reasoning capture
- Feedback analytics for CDS rule effectiveness measurement
- Integration with quality reporting systems

---

### 5. CDS Template Generation

Use the Ballerina Health Tool to generate CDS service scaffolding from hook definitions.

**Key Concepts:**
- TOML-based CDS hook definition files
- Template generation via `bal health fhir -m cds -i hooks.toml` (Health Tool v2.0.0)
- Generated templates include validation, prefetch, and service structure
- Developer fills in decision logic connecting to external decision engines
- Template customization for organization-specific workflows

**Updated TOML shape (v2 health tool):**

```toml
[[cds_services]]
id = "patient-view-alert"
hook = "patient-view"
title = "Patient View Alert"
description = "Show alerts when a patient record is opened"

[cds_services.prefetch]
patient = "Patient/{{context.patientId}}"

[[cds_services]]
id = "order-sign-check"
hook = "order-sign"
title = "Order Verification"
```

Generate:

```bash
bal health fhir -m cds \
  -i hooks.toml \
  --org-name myorg \
  --package-name my_cds \
  -o ./cds-service
```

---

### 6. Integration With Da Vinci DTR / CRD

When a CDS card suggests structured data collection, link to Da Vinci Documentation Templates & Rules (DTR) questionnaires. When coverage needs to be checked at order time, use Da Vinci Coverage Requirements Discovery (CRD) resource types. See `implementation-guides`.

---

## Related
- `health-tool-cli` — CDS template generation.
- `implementation-guides` — DTR and CRD IGs.
- `emr-ehr-connectivity` — CDS clients are typically EHRs.
- `configuration-best-practices` — CDS block.
