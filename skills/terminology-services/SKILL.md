---
name: terminology-services
description: FHIR R4 terminology operations in Ballerina with health.fhir.r4.terminology — CodeSystem operations ($lookup, $subsumes), ValueSet operations ($expand, $validate-code), ConceptMap $translate (e.g. ICD-10 → SNOMED CT), TerminologyProcessor utilities for CodeableConcept/Coding, custom terminology integration, and Config.toml wiring shared with parser/validator. Use when validating codes against systems like SNOMED CT, LOINC, ICD-10, CPT, RxNorm, or hosting a custom terminology service.
---

# Skill: Terminology Services

Work with healthcare terminologies, code systems, value sets, and concept maps using Ballerina's FHIR R4 terminology package. Supports standard terminology operations for accurate representation and exchange of healthcare data.

**Package:** `health.fhir.r4.terminology`

---

## Sub-Skills

### 1. CodeSystem Operations

Manage and query code systems that define sets of concepts with codes.

**Key Concepts:**
- CodeSystem resource search and read interactions
- `$lookup` operation: retrieve details about a specific code
- `$subsumes` operation: test subsumption relationships between codes
- In-memory terminology loading via `InMemoryTerminologyLoader`
- Standard code systems: SNOMED CT, LOINC, ICD-10, CPT, RxNorm, CVX, NDC

**Example Use Cases:**
- Validate that a code exists in a given code system
- Retrieve display names and definitions for codes
- Check hierarchical relationships between codes

---

### 2. ValueSet Operations

Work with value sets that define specific sets of codes drawn from one or more code systems.

**Key Concepts:**
- ValueSet resource search and read interactions
- `$expand` operation: expand a value set into its constituent codes
- `$validate-code` operation: check if a code is a member of a value set
- Binding value sets to FHIR resource elements
- Creating custom value sets for implementation-specific needs

**Example Use Cases:**
- Validate that a code is within an allowed set of values
- Expand a value set for dropdown/picker UI elements
- Cross-reference codes across different value sets

---

### 3. ConceptMap & Translation

Map codes between different code systems using ConceptMaps.

**Key Concepts:**
- `$translate` operation: map a code from one system to another
- Cross-value-set mapping support
- Equivalence types: equivalent, wider, narrower, inexact, unmatched
- Bidirectional translation support

**Example Use Cases:**
- Translate ICD-10 codes to SNOMED CT
- Map local codes to standard terminologies
- Support multi-standard interoperability (e.g., HL7 v2 tables to FHIR code systems)

---

### 4. Terminology Processing Utilities

Use utility classes and functions for working with coded data in FHIR resources.

**Key Concepts:**
- `TerminologyProcessor`: create CodeableConcept and Coding instances with code system validation
- Code system validation during resource creation
- CodeableConcept construction helpers
- Coding construction helpers
- Integration with external terminology services

---

### 5. Custom Terminology Integration

Integrate organization-specific or regional terminology systems.

**Key Concepts:**
- Loading custom code systems and value sets
- Registering custom terminologies with the FHIRRegistry
- Combining standard and custom terminologies in validation
- Terminology versioning and lifecycle management

---

### 6. Config.toml Wiring

The `health.fhir.r4.parser` and `health.fhir.r4.validator` modules share the same terminology configuration block. Point them at an external terminology server (or an in-process one) via Config.toml:

```toml
[ballerinax.health.fhir.r4.parser.terminologyConfig]
isTerminologyValidationEnabled = true
terminologyServiceApi = "https://tx.fhir.org/r4"

# Optional OAuth2
tokenUrl = "${TERM_TOKEN_URL}"
clientId = "${TERM_CLIENT_ID}"
clientSecret = "${TERM_CLIENT_SECRET}"
```

- Set `isTerminologyValidationEnabled = false` in dev/offline.
- Host a local terminology server for SNOMED-heavy workloads (Snowstorm, Ontoserver).

See `configuration-best-practices` §2 for the full pattern.

---

## Related
- `parser-and-validator` — consumes the terminology block.
- `fhir-r4-development` — Coding/CodeableConcept types.
- `configuration-best-practices` — terminology block.
- `implementation-guides` — IG-specific ValueSets.
