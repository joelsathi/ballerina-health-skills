---
name: hl7-v2-integration
description: HL7 v2.3-v2.8 message parsing, construction, and TCP/MLLP exchange in Ballerina with health.hl7v2* modules and health.clients.hl7. Covers stringToHl7() parsing, typed segment access, ADT/ORM/ORU/MDM/SIU message families, MLLP-framed TCP client, ACK/NAK handling, HL7 v2 composite types (CE, CWE, XAD, XPN, XTN, XCN, EI, TS/DTM, CX), and the v2-to-FHIR custom mapper service template. Use when integrating with HIS/LIS/RIS systems or other legacy HL7 v2 sources.
---

# Skill: HL7 v2 Integration

Parse, create, send, and receive HL7 v2.x messages for integration with legacy and modern healthcare systems. Ballerina supports HL7 versions 2.3 through 2.8 with typed message models and TCP connectivity.

**Packages:** `health.hl7v2commons`, `health.hl7v23`, `health.hl7v231`, `health.hl7v24`, `health.hl7v25`, `health.hl7v251`, `health.hl7v26`, `health.hl7v27`, `health.hl7v28`, `health.clients.hl7`

---

## Sub-Skills

### 1. HL7 Message Parsing

Parse raw HL7 v2 messages (pipe-delimited strings) into typed Ballerina records.

**Key Concepts:**
- `stringToHl7()` function to parse HL7 message strings into typed message objects
- Support for all standard HL7 v2.x message types (ADT, ORM, ORU, MDM, SIU, etc.)
- Segment-level access with typed fields
- Version-specific parsing (v2.3, v2.3.1, v2.4, v2.5, v2.5.1, v2.6, v2.7, v2.8)

**Common Message Types:**
| Message | Description |
|---------|-------------|
| ADT_A01 | Patient Admit |
| ADT_A02 | Patient Transfer |
| ADT_A03 | Patient Discharge |
| ADT_A08 | Patient Update |
| ORM_O01 | Order Message |
| ORU_R01 | Observation Result |
| SIU_S12 | Schedule Information |
| MDM_T02 | Document Notification |

---

### 2. HL7 Message Construction

Create HL7 v2 messages programmatically using Ballerina records.

**Key Concepts:**
- Typed record constructors for each message type
- Segment population (MSH, PID, PV1, OBX, OBR, etc.)
- Repetition and component handling
- Message serialization back to pipe-delimited format

**Core Segments:**
| Segment | Description | Typical FHIR Mapping |
|---------|-------------|---------------------|
| MSH | Message Header | MessageHeader |
| PID | Patient Identification | Patient |
| PV1 | Patient Visit | Encounter |
| PV2 | Patient Visit (Additional) | Encounter |
| PD1 | Patient Demographics | Patient |
| NK1 | Next of Kin | RelatedPerson |
| OBX | Observation | Observation |
| OBR | Observation Request | DiagnosticReport, ServiceRequest |
| ORC | Common Order | ServiceRequest |
| DG1 | Diagnosis | Condition |
| AL1 | Allergy | AllergyIntolerance |
| EVN | Event Type | Provenance |

---

### 3. HL7 Client Connectivity

Send and receive HL7 v2 messages over TCP/MLLP (Minimal Lower Layer Protocol).

**Package:** `health.clients.hl7`

**Key Concepts:**
- TCP-based HL7 client with MLLP framing
- Sending ADT, ORM, ORU, and other message types to downstream systems
- Receiving acknowledgment (ACK/NAK) messages
- Connection management and retry configuration
- Integration with hospital information systems (HIS), lab systems (LIS), and radiology systems (RIS)

---

### 4. HL7 v2 Data Types

Work with HL7 v2 composite data types.

**Key Data Types:**
| HL7 Type | Description | Example |
|----------|-------------|---------|
| CE | Coded Entry | Diagnosis codes, procedure codes |
| CWE | Coded With Exceptions | Extended coded values |
| XAD | Extended Address | Patient/provider addresses |
| XPN | Extended Person Name | Patient/provider names |
| XTN | Extended Telecommunication | Phone numbers, emails |
| XON | Extended Organization | Organization names |
| XCN | Extended Composite ID | Provider identifiers |
| EI | Entity Identifier | Order numbers, accession numbers |
| TS / DTM | Timestamp / Date-Time | Event timestamps |
| CX | Extended Composite ID with Check Digit | MRNs, account numbers |

---

### 5. HL7 Version Management

Handle multiple HL7 v2 versions within a single integration.

**Supported Versions:**
- HL7 v2.3 (`health.hl7v23`)
- HL7 v2.3.1 (`health.hl7v231`)
- HL7 v2.4 (`health.hl7v24`)
- HL7 v2.5 (`health.hl7v25`)
- HL7 v2.5.1 (`health.hl7v251`)
- HL7 v2.6 (`health.hl7v26`)
- HL7 v2.7 (`health.hl7v27`)
- HL7 v2.7.1 (`health.hl7v271`)
- HL7 v2.8 (`health.hl7v28`)

**Key Concepts:**
- Version-specific segment definitions and constraints
- Common utilities shared across versions via `health.hl7v2commons`
- Version negotiation in MSH segment
- Backward compatibility considerations

---

### 6. v2-to-FHIR Custom Mapper Service

**Template package:** `health.fhir.templates/data-mappers/v2-to-fhir-custom-mapper-service`

Ballerina ships a deployable microservice that accepts HL7 v2 messages and emits FHIR Bundles. Use this service rather than rolling your own transformer when you need:
- HTTP and TCP/MLLP ingress
- Pluggable per-segment custom mappers (`V2SegmentToFhirMapper`)
- Prebuilt handling for ADT, ORM, ORU, SIU, MDM families

Generate and customize:

```bash
bal new my-v2-mapper --template health.fhir.templates/data-mappers/v2-to-fhir-custom-mapper-service
```

See `data-transformation` for the underlying `v2ToFhir()` mechanics and custom mapper contract.

---

## Related
- `data-transformation` — v2 → FHIR mappings and custom mapper records.
- `fhir-r4-development` — target Bundle/resource types.
- `prebuilt-services` — deployable hl7v2-to-fhir service.
- `configuration-best-practices` — TCP listener tuning.
