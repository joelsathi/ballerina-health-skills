---
name: fhir-r4-development
description: FHIR R4 development with Ballerina — resource modeling (Patient, Observation, Bundle, MedicationRequest, etc.), JSON/XML serialization, search parameters with modifiers, profile-aware validation, FHIRContext, error handling, Bundle operations, and Implementation Guides (US Core, Da Vinci, IPS, CARIN BB, regional). Use when working with FHIR R4 resources, profiles, search, bundles, or building FHIR-compliant APIs in Ballerina with health.fhir.r4 or health.fhir.r4.international401.
---

# Skill: FHIR R4 Development

Build FHIR-compliant healthcare APIs and applications using Ballerina's native FHIR R4 support. Covers resource modeling, serialization, validation, search, and working with implementation guides.

**Packages:** `health.fhir.r4`, `health.fhir.r4.international401`, `health.fhir.r4.uscore501`

---

## Sub-Skills

### 1. FHIR Resource Modeling

Work with FHIR R4 resource types as native Ballerina records with full type safety and cardinality constraints.

**Key Concepts:**
- Base resource types: Bundle, CodeSystem, OperationOutcome, ValueSet
- Clinical resources: Patient, Practitioner, Observation, Condition, Encounter, Procedure, DiagnosticReport, AllergyIntolerance, Immunization, MedicationRequest
- Financial resources: Claim, ClaimResponse, Coverage, CoverageEligibilityRequest
- Workflow resources: CarePlan, Goal, ServiceRequest, Appointment, Slot, Schedule
- Infrastructure resources: CapabilityStatement, StructureMap, Contract, Communication

**Key Data Types:**
- Primitives: string, boolean, integer, decimal, date, dateTime, instant, uri, url, canonical, code, id, oid, uuid, markdown, base64Binary, positiveInt, unsignedInt
- Complex types: Address, Annotation, Attachment, CodeableConcept, Coding, ContactPoint, HumanName, Identifier, Period, Quantity, Range, Ratio, Reference
- Specialized types: Age, Count, Distance, Duration, Money, Dosage, DataRequirement, TriggerDefinition

**Example:**
```ballerina
import ballerinax/health.fhir.r4.international401 as r4;

r4:Patient patient = {
    resourceType: "Patient",
    name: [{family: "Smith", given: ["John"]}],
    gender: "male",
    birthDate: "1990-01-15",
    identifier: [{
        system: "http://hospital.org/mrn",
        value: "MRN-12345"
    }]
};
```

---

### 2. FHIR Serialization & Deserialization

Convert FHIR resources between Ballerina records, JSON, and XML formats.

**Key Concepts:**
- JSON serializers for resources, bundles, and complex data types
- XML serializers for resources, bundles, and complex data types
- Resource entity wrappers with `toJson()` and `toXml()` convenience methods
- Parsing incoming FHIR payloads (application/fhir+json, application/fhir+xml)

**Supported MIME Types:**
- `application/fhir+json`
- `application/fhir+xml`

---

### 3. FHIR Search Parameters

Implement FHIR search operations with full search parameter support.

**Key Concepts:**
- Search parameter types: Number, Date, String, Token, Reference, Composite, Quantity, URI, Special
- Search modifiers: `:missing`, `:exact`, `:contains`, `:above`, `:below`, `:text`, `:in`, `:not-in`, `:of-type`
- Common search parameters: `_id`, `_lastUpdated`, `_profile`, `_security`, `_tag`, `_source`, `_text`, `_content`, `_filter`, `_has`, `_list`, `_query`, `_type`
- Search parameter encoding and decoding utilities
- Search result pagination

---

### 4. FHIR Resource Validation

Validate FHIR resources against profiles, constraints, and the FHIR specification.

**Package:** `health.fhir.r4.validator`

**Key Concepts:**
- Profile-based validation against StructureDefinitions
- Cardinality constraint enforcement
- Data type validation for complex types: Annotation, Dosage, DoseAndRate, ElementDefinition, DataRequirement, Population, Range, Ratio, SubstanceAmount, TriggerDefinition
- FHIRValidationError with severity levels, diagnostic messages, and FHIR path expressions
- OperationOutcome generation from validation errors

---

### 5. FHIR Context & Error Handling

Manage FHIR request/response lifecycle and structured error handling.

**Key Concepts:**
- FHIRContext: request/response handling, pagination, consent management, security info, HTTP headers, custom properties
- FHIRRegistry: profile management, search parameter registration, operation definitions, service tracking
- Error types: FHIRError, FHIRValidationError, FHIRParseError, FHIRProcessingError, FHIRSerializerError, FHIRTypeError
- Error factory functions with severity levels and diagnostic messages
- OperationOutcome generation from errors

---

### 6. Implementation Guides

Work with standard FHIR Implementation Guides (IGs) that define profiles, extensions, and constraints for specific use cases.

**Supported IGs:**
| Implementation Guide | Package |
|---------------------|---------|
| FHIR R4 International 4.0.1 | `health.fhir.r4.international401` |
| US Core 5.0.1 | `health.fhir.r4.uscore501` |
| AU Base 4.1.0 | `health.fhir.r4.au` |
| LK Core 0.1.0 | `health.fhir.r4.lkcore010` |
| Belgium Federal | `health.fhir.r4.belgiumfederal` |
| IPS | `health.fhir.r4.ips` |
| CARIN Blue Button 2.0.0 | `health.fhir.r4.carinbb200` |
| Da Vinci HRex 1.0.0 | `health.fhir.r4.davincihrex100` |
| Da Vinci CRD 2.1.0 | `health.fhir.r4.davincicrd210` |
| Da Vinci DTR 2.1.0 | `health.fhir.r4.davincidtr210` |
| Da Vinci PAS | `health.fhir.r4.davincipas` |
| Da Vinci PDex 2.2.0 | `health.fhir.r4.davincipdex220` |
| Da Vinci Plan-Net 1.2.0 | `health.fhir.r4.davinciplannet120` |

For details on selecting and combining IGs, see `implementation-guides`.

**Key Concepts:**
- Profile-specific resource types with constrained fields
- Extensions defined per IG
- IG-specific ValueSets and CodeSystems
- Custom IG package generation via the Health Tool

---

### 7. Bundle Operations

Create and manage FHIR Bundles for grouping resources in transactions, batches, and search results.

**Key Concepts:**
- Bundle types: document, message, transaction, transaction-response, batch, batch-response, history, searchset, collection
- Bundle creation helpers
- Batch and transaction processing
- Search result bundle pagination (next/previous)
- Reference resolution within bundles (absolute, relative, contained)

---

### 8. Parser & Validator Integration

The `health.fhir.r4.parser` and `health.fhir.r4.validator` modules are the canonical entry points for ingesting untrusted FHIR payloads. Use `parseWithValidation()` to combine both in one call.

```ballerina
import ballerinax/health.fhir.r4.parser;

r4:Patient patient =
    <r4:Patient> check parser:parseWithValidation(payload, r4:Patient);
```

Both consume the same `terminologyConfig` block in `Config.toml`. See `parser-and-validator` for the full pattern.

---

## Related
- `parser-and-validator` — typed payload ingestion.
- `implementation-guides` — profile-constrained types.
- `terminology-services` — code validation.
- `configuration-best-practices` — terminology wiring.
- `skill-router` — task-to-skill navigation.
