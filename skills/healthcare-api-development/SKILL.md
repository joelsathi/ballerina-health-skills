---
name: healthcare-api-development
description: Build production FHIR APIs in Ballerina — RESTful interactions (read/vread/search/create/update/patch/delete/history), Bundle responses with pagination, JSON/XML content negotiation, OperationOutcome error responses, CapabilityStatement auto-generation and conformance, SMART on FHIR with EHR/standalone launch and scope-based access control, FHIRPath query/manipulation via health.fhir.r4utils.fhirpath, AuditEvent for HIPAA, and deployment to Choreo/Docker/Kubernetes with API gateway integration. Use when designing FHIR API service architecture or production deployment.
---

# Skill: Healthcare API Development

Build production-ready healthcare APIs with SMART on FHIR security, CapabilityStatement conformance, FHIRPath queries, and audit event handling.

**Packages:** `health.fhir.r4`, `health.fhir.r4utils.fhirpath`, `health.fhir.r4.validator`

---

## Sub-Skills

### 1. FHIR API Service Implementation

Build RESTful FHIR API services that expose healthcare resources with standard FHIR interactions.

**Key Concepts:**
- FHIR resource endpoints with standard HTTP methods (GET, POST, PUT, PATCH, DELETE)
- FHIR interaction types: read, vread, search, create, update, patch, delete, history
- Bundle response construction for search results
- Pagination support for large result sets
- Content negotiation (JSON/XML)
- FHIR-compliant error responses via OperationOutcome

**Pre-Built API Templates:**
Templates are available for 100+ FHIR resources including:
- Patient, Practitioner, PractitionerRole, Organization
- Observation, Condition, Procedure, DiagnosticReport
- MedicationRequest, MedicationAdministration, MedicationDispense
- Encounter, Appointment, Slot, Schedule
- Claim, ClaimResponse, Coverage, CoverageEligibilityRequest
- CarePlan, Goal, ServiceRequest, Communication
- AllergyIntolerance, Immunization
- HealthcareService, ResearchStudy, Contract, StructureMap

---

### 2. CapabilityStatement & Conformance

Declare and enforce server capabilities through the FHIR CapabilityStatement resource.

**Key Concepts:**
- Auto-generation of CapabilityStatement from registered services
- Declaring supported resources, interactions, and search parameters
- Profile declarations and implementation guide references
- Server metadata (name, version, publisher, description)
- REST mode declaration (server/client)
- Security scheme advertisement (OAuth2, SMART)

---

### 3. SMART on FHIR Security

Implement SMART on FHIR authorization for secure access to FHIR APIs.

**Key Concepts:**
- SMART configuration template generation
- SMART security validation utilities
- OAuth 2.0 authorization code flow for EHR launch
- Standalone launch and EHR launch sequences
- Scope-based access control (patient/*.read, user/*.write, etc.)
- Launch context handling (patient, encounter)
- Token introspection and validation

---

### 4. FHIRPath Query & Manipulation

Query and manipulate FHIR resources using the FHIRPath expression language.

**Package:** `health.fhir.r4utils.fhirpath`

**Key Concepts:**
- Extract values from FHIR resources using FHIRPath expressions
- Update resource values using FHIRPath-based targeting
- Type-safe FHIRPath evaluation
- Standard FHIRPath functions and operators
- Error handling for invalid expressions

**Example Expressions:**
```
Patient.name.where(use='official').given
Observation.value.ofType(Quantity).value
MedicationRequest.dosageInstruction.timing.repeat.period
Bundle.entry.resource.ofType(Patient)
```

---

### 5. Audit Event Handling

Track and record access to FHIR resources for compliance and security auditing.

**Key Concepts:**
- AuditEvent resource creation for FHIR operations
- Recording who accessed what, when, and from where
- Integration with audit event repositories
- HIPAA and compliance audit trail support
- Consent management integration via FHIRContext

---

### 6. FHIR API Deployment

Deploy healthcare APIs to cloud environments with proper configuration.

**Key Concepts:**
- WSO2 Choreo platform deployment for managed API hosting
- Containerized deployment (Docker/Kubernetes)
- API gateway integration for rate limiting, throttling, and analytics
- Cross-language accessibility: expose Ballerina FHIR APIs to Java, .NET, Python clients
- Internal vs external API exposure patterns
- Health check and monitoring endpoints

---

## Related
- `security-and-authz` — SMART on FHIR, OAuth, authz, audit.
- `parser-and-validator` — ingress validation.
- `configuration-best-practices` — service and HTTP config.
- `prebuilt-services` — ready-made FHIR R4 server.
- `health-tool-cli` — generate API templates.
- `skill-router` — full API build workflow.
