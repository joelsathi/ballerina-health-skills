---
name: health-tool-cli
description: Ballerina Health Tool CLI v2.0.0 — 'bal health fhir -m {package|template|cds}' for generating typed Ballerina library packages from FHIR Implementation Guides (StructureDefinition/ValueSet/CodeSystem), FHIR API service templates (with --dependent-package referencing a generated package), and CDS Hooks 2.0 service scaffolding from a TOML hook definition file. Supports profile filtering (--included-profile/--excluded-profile), custom org/package names, and incremental publishing to Ballerina Central. Install via 'bal tool pull health'. Requires Ballerina Swan Lake 2201.8.1+.
---

# Skill: Health Tool CLI

Use the Ballerina Health Tool command-line interface to generate FHIR packages, API templates, and CDS service scaffolding from Implementation Guides and hook definitions.

**Tool version:** 2.0.0
**Prerequisite:** Ballerina Swan Lake 2201.8.1 or later
**Install:**

```bash
bal tool pull health
```

**Command prefix (v2):**

```bash
bal health fhir -m <package|template|cds> [flags] <ig-path>
```

---

## Sub-Skills

### 1. FHIR Package Generation

Generate Ballerina library packages from FHIR Implementation Guide resources, producing typed Ballerina records with cardinality constraints and metadata.

**Command:**
```bash
bal health fhir -m package --org-name <org> --package-name <name> -o <output-dir> <ig-path>
```

**CLI Options:**
| Option | Description |
|--------|-------------|
| `-m package` | Set mode to package generation |
| `--org-name` | Organization name for the generated package |
| `--package-name` | Name of the generated Ballerina package |
| `-o, --output` | Output directory for generated files |
| `--included-profile` | Generate only specific FHIR profiles |
| `--excluded-profile` | Exclude specific FHIR profiles |
| `--dependent-package` | Reference a published package containing IG resources |

**Required Input Files:**
- StructureDefinition files (JSON)
- ValueSet files (JSON)
- CodeSystem files (JSON)
- Recommended: STU (Standard for Trial Use) release level or higher

**Generated Output:**
```
<package-name>/
├── Ballerina.toml          # Package configuration
├── Package.md              # Package documentation
├── resource_<name>.bal     # Resource-specific type definitions
├── variables.bal           # Variable definitions
├── types.bal               # Shared type definitions
├── initializers.bal        # Resource initializers
└── tests/                  # Test files
```

---

### 2. FHIR API Template Generation

Generate customizable Ballerina API service templates for FHIR resources, allowing developers to implement business logic behind standard FHIR API endpoints.

**Command:**
```bash
bal health fhir -m template --org-name <org> --package-name <name> --dependent-package <pkg> -o <output-dir> <ig-path>
```

**CLI Options:**
| Option | Description |
|--------|-------------|
| `-m template` | Set mode to template generation |
| `--dependent-package` | Published Ballerina Central package containing IG resources |
| `--package-version` | Version for the generated template |
| `--included-profile` | Generate templates for specific profiles only |
| `--excluded-profile` | Skip specific profiles |

**Key Concepts:**
- Each template exposes standard FHIR interactions (read, search, create, update, delete)
- Developer fills in business logic (database queries, external service calls)
- Templates include proper FHIR content negotiation and error handling
- Generated code follows FHIR R4 specification compliance

---

### 3. CDS Template Generation

Generate Ballerina service templates for CDS Hooks 2.0 services from hook definition files.

**Command:**
```bash
bal health fhir -m cds -i <hooks-definition.toml> --org-name <org> --package-name <name> -o <output-dir>
```

**CLI Options:**
| Option | Description |
|--------|-------------|
| `-m cds` | Set mode to CDS template generation |
| `-i, --input` | Path to TOML file defining CDS hooks |

**Hook Definition Format (TOML):**
```toml
[[hooks]]
id = "patient-view-alert"
hook = "patient-view"
title = "Patient View Alert"
description = "Show alerts when a patient record is opened"

[[hooks]]
id = "order-check"
hook = "order-sign"
title = "Order Verification"
description = "Check drug interactions when orders are signed"
```

**Generated Template Includes:**
- CDS service discovery endpoint
- Hook-specific service handlers
- Request validation logic
- Prefetch data handling
- Placeholder for decision engine integration
- Error handling and response construction

---

### 4. Custom Implementation Guide Processing

Generate packages and templates from custom or third-party Implementation Guides.

**Key Concepts:**
- Support for any IG that provides StructureDefinition, ValueSet, and CodeSystem resources
- Profile-level filtering with `--included-profile` and `--excluded-profile`
- Combining base IGs (International, US Core) with custom extensions
- Versioned package output for dependency management
- Publishing generated packages to Ballerina Central for team sharing

**Workflow:**
1. Obtain IG resources (download from IG publisher or registry)
2. Generate base package: `bal health fhir -m package ...`
3. Generate API templates: `bal health fhir -m template --dependent-package <base-pkg> ...`
4. Implement business logic in generated templates
5. Build and deploy: `bal build`

---

### 5. Mode Selection Matrix

| Scenario | Mode | Notes |
|---|---|---|
| Need typed records from an IG | `package` | Foundation; output consumed by `template` and downstream services |
| Need REST API scaffolding for resources | `template` | Requires `--dependent-package` referencing a `package` output |
| Need a CDS Hooks service | `cds` | Takes a `-i <file.toml>` hook definition |
| Need profile subsetting | add `--included-profile` / `--excluded-profile` to `package` or `template` |

---

## Related
- `fhir-r4-development` — output types flow into development work.
- `implementation-guides` — bundled IG packages that bypass manual generation.
- `clinical-decision-support` — CDS template input TOML shape.
- `configuration-best-practices` — generated services use standard config blocks.
