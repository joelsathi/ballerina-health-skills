---
name: implementation-guides
description: FHIR R4 Implementation Guide packages in Ballerina — Da Vinci family (CRD, DTR, HRex, PAS, PDex, PlanNet) for payer-provider workflows, regional (US Core, AU Base, LK Core, Belgium Federal), International Patient Summary (IPS), CARIN Blue Button, custom IG generation via the Health Tool, and IG layering. Use when building prior auth, coverage discovery, payer-to-payer exchange, provider directory, regional compliance, or cross-border patient summaries.
---

# Skill: Implementation Guides

FHIR Implementation Guides (IGs) define profiles, extensions, and constraints for specific use cases. Ballerina ships pre-generated typed packages for 12+ IGs covering payer-provider workflows (Da Vinci), regional (US Core, AU, LK, Belgium), cross-border (IPS), and consumer access (CARIN Blue Button).

**Packages:** `health.fhir.r4.<ig-package>` — one per IG. Generate custom IG packages via the Health Tool.

---

## Sub-Skills

### 1. Da Vinci Family (Payer-Provider Interoperability)

Da Vinci IGs enable coverage, prior authorization, and payer data exchange workflows.

| IG | Package | Purpose |
|---|---|---|
| CRD 2.1.0 | `health.fhir.r4.davincicrd210` | Coverage Requirements Discovery — real-time coverage checks at ordering time. 17 resources. |
| DTR 2.1.0 | `health.fhir.r4.davincidtr210` | Documentation Templates & Rules — structured data collection via Questionnaires for prior auth. 9 resources. |
| HRex 1.0.0 | `health.fhir.r4.davincihrex100` | Health Record Exchange — member match, consent, payer-provider data requests. 11 resources. |
| PAS | `health.fhir.r4.davincipas` | Prior Authorization Support — claim submission, inquiry, response. 23 resources. |
| PDex 2.2.0 | `health.fhir.r4.davincipdex220` | Payer Data Exchange — `$bulk-member-match`, `$davinci-data-export`. |
| Plan-Net 1.2.0 | `health.fhir.r4.davinciplannet120` | Provider directory — network, organization, practitioner, location. 9 resources. |

**When to use:** US payer-provider integrations, prior authorization pipelines, provider directory APIs.

```ballerina
import ballerinax/health.fhir.r4.davincipas as pas;

pas:PASClaim claim = {
    resourceType: "Claim",
    status: "active",
    type: {...},
    use: "preauthorization",
    // ...
};
```

---

### 2. Regional Implementation Guides

| IG | Package | Region |
|---|---|---|
| US Core 5.0.1 | `health.fhir.r4.uscore501` | United States (21st Century Cures) |
| AU Base 4.1.0 | `health.fhir.r4.au` | Australia |
| LK Core 0.1.0 | `health.fhir.r4.lkcore010` | Sri Lanka (41 resources incl. BP, Cholesterol, BMI, notifiable disease) |
| Belgium Federal | `health.fhir.r4.belgiumfederal` | Belgium |

**When to use:** Market-specific compliance.

---

### 3. International Patient Summary (IPS)

**Package:** `health.fhir.r4.ips`

Cross-border patient summary for continuity of care across jurisdictions.

**Key APIs:**
- `ips:getIpsBundle(bundle | IpsData)` → IPS-compliant Bundle
- `ips:registerCustomGenerateIps(impl)` — customize generation
- 28 profiles including `MedicationStatementIPS`, `AllergyIntoleranceUvIps`, `ConditionUvIps`, `ImmunizationUvIps`, `ObservationLab/Radiology`, `PatientUvIps`.

---

### 4. CARIN Blue Button

**Package:** `health.fhir.r4.carinbb200`

Consumer-directed access to health plan claims data (11 resources including `C4BBPatient`, `C4BBCoverage`, EOB profiles for Outpatient/Inpatient/Pharmacy/Professional/Oral).

**When to use:** Building consumer-facing apps that expose claim and coverage data.

---

### 5. IG Selection Guide

| Use case | Recommended IG |
|---|---|
| US general clinical data | US Core |
| Prior authorization | Da Vinci PAS + DTR |
| Coverage check at ordering | Da Vinci CRD |
| Payer-to-payer data transfer | Da Vinci PDex + HRex |
| Provider directory lookup | Da Vinci PlanNet |
| Cross-border patient summary | IPS |
| Consumer claim access | CARIN BB |
| Australian clinical data | AU Base |
| Sri Lankan clinical data | LK Core |
| Belgian clinical data | Belgium Federal |

---

### 6. Custom IG Generation

When no prebuilt package exists for your IG, generate one from StructureDefinition / ValueSet / CodeSystem files:

```bash
bal health fhir -m package \
  --org-name myorg \
  --package-name myig \
  -o ./packages \
  /path/to/ig-definitions
```

Then generate API templates from the package:

```bash
bal health fhir -m template \
  --org-name myorg \
  --dependent-package myorg/myig \
  -o ./services \
  /path/to/ig-definitions
```

See `health-tool-cli` for full flag reference.

---

### 7. Combining IGs

IGs can layer. For example, a US Core Patient can be further constrained by a Da Vinci profile. When combining:
- Import both packages.
- Use the most specific profile type in your records.
- Validate against the narrowest profile.

---

## Related
- `fhir-r4-development` — base resource modeling.
- `health-tool-cli` — generate custom IG packages.
- `parser-and-validator` — profile-targeted validation.
- `skill-router` — IG selection fork.
