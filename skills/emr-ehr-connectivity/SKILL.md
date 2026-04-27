---
name: emr-ehr-connectivity
description: Connect to FHIR-based EMR/EHR systems with health.clients.fhir — generic CRUD/search/patch/history/$callOperation, conditional create/update/delete, batch/transaction Bundle submission, CapabilityStatement-based conformance, EMR-specific template connectors (Epic with PKJWT backend services, Cerner system scopes, athenahealth practice management), Epic 6-domain prebuilt connectors (administration, clinical, diagnostics, financial, medications, workflow), FHIR Bulk Data Access (system/patient/group export with async polling), and OpenAPI connectors for non-FHIR systems. Use when integrating with Epic, Cerner, athena, or any FHIR R4 server.
---

# Skill: EMR/EHR Connectivity

Connect to Electronic Medical Record and Electronic Health Record systems using Ballerina's FHIR client, EMR-specific connectors, and bulk data export capabilities.

**Package:** `health.clients.fhir`

---

## Sub-Skills

### 1. FHIR Client Operations

Use the generic FHIR client to perform CRUD operations, search, and advanced interactions against any FHIR-compliant server.

**Package:** `health.clients.fhir`

**CRUD Operations:**
| Operation | Function | Description |
|-----------|----------|-------------|
| Create | `create()` | Create a new resource |
| Read | `getById()` | Read a resource by ID |
| vRead | `getByVersion()` | Read a specific version |
| Update | `update()` | Update an existing resource |
| Patch | `patch()` | Partially update a resource |
| Delete | `delete()` | Delete a resource |
| Search | `search()` | Search resources (GET/POST) |
| History | `history()` | Retrieve resource history |

**Advanced Operations:**
- Conditional create, update, and delete with search parameters
- Batch and transaction bundle submission
- Custom FHIR operation invocation (`callOperation()`)
- Conformance/CapabilityStatement retrieval
- Bundle pagination (next/previous page navigation)
- HTTP request proxying

**Configuration Options:**
- HTTP version selection (HTTP/1.x, HTTP/2)
- Response size limits and timeout settings
- Circuit breaker and retry policies
- Proxy configuration
- FHIR server URL rewriting in responses

---

### 2. Authentication & Security

Configure authentication for FHIR server connections including OAuth2, SMART on FHIR, and other methods.

**Supported Authentication Methods:**
| Method | Description |
|--------|-------------|
| OAuth2 Client Credentials | Server-to-server with client ID/secret |
| PKJWT (Public Key JWT) | Asymmetric key-based authentication |
| Basic Authentication | Username/password |
| Bearer Token | Pre-obtained access tokens |

**Key Concepts:**
- OAuth2 token management and refresh
- SMART on FHIR launch context handling
- HTTP caching and compression support
- CapabilityStatement-based server compliance verification

---

### 3. EMR-Specific Connectors

Pre-built connectors live in the **`health.fhir.templates`** repository, not a separate clients module. Import the vendor-specific template package for your target EMR.

**Authentication is already wired into these connectors** — Epic uses PKJWT backend services, Cerner uses system/user scopes, athenahealth uses its practice-management auth. You do not need to layer `security-and-authz` on top; just supply the connector's required credentials/keys via `Config.toml` (see `configuration-best-practices`).

**Supported EMR Systems:**
| EMR System | Template Package | Capabilities |
|---|---|---|
| Epic | `health.fhir.templates/epic` | FHIR R4 API, PKJWT backend auth (built-in), patient/clinical/diagnostic/financial/medications/workflow |
| Cerner (Oracle Health) | `health.fhir.templates/cerner` | FHIR R4 API, system/user scopes (built-in) |
| athenahealth | `health.fhir.templates/athena` | FHIR R4 API, practice management auth (built-in) |

**Epic 6-domain prebuilt connectors** (WSO2 Open Healthcare Prebuilt Services):

| Domain | Purpose |
|---|---|
| administration | Facility, practitioner, scheduling |
| clinical | Conditions, diagnoses, procedures |
| diagnostics | Lab results, imaging references |
| financial | Billing, coverage, claims |
| medications | Prescriptions, dispenses, administrations |
| workflow | Appointments, tasks |

See `prebuilt-services` for deployment.

**Key Concepts:**
- EMR-specific auth is preconfigured inside each template — only credential/key configuration is required
- EMR-specific FHIR profile handling
- Handling EMR-specific extensions and custom operations
- Integration with non-FHIR EMR APIs via OpenAPI connectors

---

### 4. Bulk Data Export

Export large volumes of FHIR data using the FHIR Bulk Data Access specification.

**Export Levels:**
| Level | Description |
|-------|-------------|
| System-level | Export all data from the FHIR server |
| Patient-level | Export data for all patients |
| Group-level | Export data for a specific patient group |

**Key Concepts:**
- Asynchronous export initiation and status monitoring
- Export status polling via exportId or polling URL
- Output file retrieval and management
- Configurable file servers: FTP, FHIR, local filesystem
- Resource type filtering during export
- Date-based incremental exports

---

### 5. Non-FHIR System Integration

Connect to healthcare systems that don't expose FHIR APIs.

**Key Concepts:**
- OpenAPI-based connector generation for REST APIs
- HL7 v2 TCP/MLLP connectivity for legacy systems
- Database connectors for direct data access
- Salesforce and other CRM integration for care coordination
- 100+ pre-built connectors available via Ballerina Central

---

## Related
- `prebuilt-services` — deployable EHR connectors and FHIR server.
- `security-and-authz` — SMART, OAuth, PKJWT flows.
- `fhir-r4-development` — typed resource handling.
- `configuration-best-practices` — FHIR client and auth blocks.
