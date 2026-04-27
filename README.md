# Ballerina Healthcare Skills for Claude Code

A collection of 18 [Anthropic Agent Skills](https://code.claude.com/docs/en/skills) that teach Claude Code how to build healthcare applications with [Ballerina](https://ballerina.io/) — covering FHIR R4/R5, HL7 v2, C-CDA, DICOM, CDS Hooks, EMR connectivity, security, de-identification, and the WSO2 Open Healthcare prebuilt services.

Each skill is **self-contained**: pick only the ones you need. No plugin install, no marketplace — just drop a folder into `~/.claude/skills/` (or your project's `.claude/skills/`) and Claude picks it up automatically.

---

## Install

Three ways, pick whichever fits. After installing, restart Claude Code so it discovers the new skills.

### Option A — Convenience script

```bash
curl -fsSL https://raw.githubusercontent.com/joelsathi/ballerina-healthcare-skills/main/scripts/install.sh \
  | bash -s fhir-r4-development hl7-v2-integration
```

Pass any number of skill names. Use `--all` to install everything, or `--project` to install into the current directory's `.claude/skills/` instead of `~/.claude/skills/`.

### Option B — Sparse checkout

```bash
git clone --filter=blob:none --no-checkout \
  https://github.com/joelsathi/ballerina-healthcare-skills.git
cd ballerina-healthcare-skills
git sparse-checkout init --cone
git sparse-checkout set skills/fhir-r4-development skills/hl7-v2-integration
git checkout
mkdir -p ~/.claude/skills
cp -r skills/* ~/.claude/skills/
```

---

## Catalog

> **Tip:** if you're not sure which skill to start with, install `skill-router` first — it's a decision guide that maps tasks to skills.

### Start Here

| Skill | What it covers | Common companions |
|---|---|---|
| [`skill-router`](skills/skill-router/) | Task → skill matrix, canonical workflows, decision forks, anti-patterns | (catalog only) |
| [`configuration-best-practices`](skills/configuration-best-practices/) | `Config.toml` patterns for every `health.*` module | every other skill |

### Core FHIR

| Skill | What it covers | Common companions |
|---|---|---|
| [`fhir-r4-development`](skills/fhir-r4-development/) | R4 resources, profiles, search, bundles, validation | `parser-and-validator`, `implementation-guides` |
| [`fhir-r5-development`](skills/fhir-r5-development/) | R5 resources, R4↔R5 differences, coexistence | `fhir-r4-development` |
| [`implementation-guides`](skills/implementation-guides/) | Da Vinci, US Core, AU/LK/Belgium, IPS, CARIN BB | `fhir-r4-development`, `health-tool-cli` |
| [`parser-and-validator`](skills/parser-and-validator/) | Ingest untrusted FHIR with type safety + profile validation | `terminology-services`, `fhir-r4-development` |
| [`terminology-services`](skills/terminology-services/) | CodeSystem, ValueSet, ConceptMap operations | `parser-and-validator` |

### Legacy & Interoperability

| Skill | What it covers | Common companions |
|---|---|---|
| [`hl7-v2-integration`](skills/hl7-v2-integration/) | Parse/build/exchange HL7 v2.3–v2.8 messages | `data-transformation`, `fhir-r4-development` |
| [`ccda-documents`](skills/ccda-documents/) | C-CDA R2 parsing and C-CDA ↔ FHIR conversion | `data-transformation`, `fhir-r4-development` |
| [`dicom-integration`](skills/dicom-integration/) | DICOM Part 10 + DICOMweb (QIDO-RS, WADO-RS, STOW-RS) | `healthcare-api-development` |
| [`data-transformation`](skills/data-transformation/) | Cross-format pipelines (HL7v2, C-CDA, EDI → FHIR) + JSON merge | `hl7-v2-integration`, `ccda-documents` |

### Workflows

| Skill | What it covers | Common companions |
|---|---|---|
| [`clinical-decision-support`](skills/clinical-decision-support/) | CDS Hooks 2.0 with prefetch and cards | `health-tool-cli`, `implementation-guides` |
| [`emr-ehr-connectivity`](skills/emr-ehr-connectivity/) | Epic, Cerner, athenahealth connectors; bulk export | `prebuilt-services`, `security-and-authz` |

### Cross-Cutting

| Skill | What it covers | Common companions |
|---|---|---|
| [`security-and-authz`](skills/security-and-authz/) | SMART on FHIR, OAuth 2.0, cascading RBAC, AuditEvent | `healthcare-api-development` |
| [`privacy-and-deidentification`](skills/privacy-and-deidentification/) | De-id rules, patient matching, MPI reconciliation | `data-transformation` |
| [`healthcare-api-development`](skills/healthcare-api-development/) | API architecture, CapabilityStatement, deployment | `security-and-authz`, `parser-and-validator` |

### Tooling

| Skill | What it covers | Common companions |
|---|---|---|
| [`health-tool-cli`](skills/health-tool-cli/) | `bal health fhir -m {package\|template\|cds}` v2.0.0 | `implementation-guides`, `clinical-decision-support` |
| [`prebuilt-services`](skills/prebuilt-services/) | WSO2 Open Healthcare — FHIR server, Epic connectors, metadata, audit | `emr-ehr-connectivity` |

---

## How the skills work

Each skill is a folder containing a `SKILL.md` with YAML frontmatter:

```
skills/
├── fhir-r4-development/
│   └── SKILL.md          # name, description, body
├── hl7-v2-integration/
│   └── SKILL.md
└── …
```

When you install a skill into `~/.claude/skills/<name>/`, Claude reads its `description` and decides automatically when to use it during a conversation. For project-specific work, install into `<your-project>/.claude/skills/<name>/` instead — it'll only be loaded when Claude Code runs in that directory.

The `skill-router` skill (recommended as your first install) is a navigation aid: it lists every skill in this collection and maps common tasks to skill chains. Skills it references are not links — install each one separately.

---

## Prerequisites

- [Ballerina Swan Lake](https://ballerina.io/downloads/) `2201.12.0` or later
- [Health Tool](https://ballerina.io/learn/health-tool/) v2.0.0: `bal tool pull health`
- [Claude Code](https://code.claude.com/)

---

## Contributing

Issues and PRs welcome. To add or update a skill:

1. Each skill is one folder under `skills/<name>/` containing a single `SKILL.md`.
2. Frontmatter must include `name` (matches directory) and `description` (combined with optional `when_to_use` must stay under 1,536 characters — the description is what Claude uses to decide when to invoke the skill).
3. Reference other skills by bare name in backticks (e.g. `` `fhir-r4-development` ``), not relative links — users may install only a subset.
4. Update this README's catalog table when adding a new skill.

## License

Apache-2.0. See [LICENSE](LICENSE).
