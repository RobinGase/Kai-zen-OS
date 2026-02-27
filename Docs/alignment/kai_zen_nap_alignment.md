# Kai-zen-OS x Nex Alignment (NAP) Mapping

## Purpose

Apply your `Nex_Alignment` governance model directly to the Kai-zen-OS planning program.

## Source of Truth

- Local snapshot: `references/Nex_Alignment`
- Upstream remote: `https://github.com/RobinGase/Nex_Alignment`

## Selected NAP Profile Composition

Using NAP composite rules (`max_total_profiles: 3`, highest-safety-wins), Kai-zen-OS uses:

1. `infrastructure_devops` (primary)
2. `ai_stack_training_inference` (secondary)
3. `security_incident_response` (secondary)

## Effective Governance Envelope

- Effective minimum risk class: **Class 3**
- Effective autonomy ceiling: **A2**
- Conflict resolution: **highest-safety-wins**

## Effective Required Bundles (union)

- `B01_CORE_GOV`
- `B02_CHANGE_DATA_INTEGRITY`
- `B05_PRIVACY_REGULATED_DATA`
- `B06_RUNTIME_CONTAINMENT`
- `B07_AI_MODEL_SUPPLY_CHAIN`
- `B09_SECURITY_INCIDENT_FORENSICS`

## Bundle-to-Kai-zen Plan Mapping

| Bundle | NAP intent | Kai-zen docs mapping |
|---|---|---|
| B01 | Core governance and risk/autonomy baseline | `Docs/implementation_plan.md`, `Docs/adrs/ADR-0001-safety-boundary.md` |
| B02 | Change safety, rollback, traceability | `Docs/operations/emulator_first_validation.md`, `Docs/governance/risk_register.md` |
| B05 | Sensitive data and regulated handling | `Docs/governance/source_verification.md` + no-secrets policy |
| B06 | Runtime containment and override logic | `Docs/adrs/ADR-0003-model-routing-policy.md`, `Docs/operations/remote_control_setup.md` |
| B07 | Model/dataset supply chain integrity | `Docs/research/model_provider_investigation.md`, `Docs/research/gemini_2_5_flash_investigation.md`, `Docs/research/nvidia_api_investigation.md` |
| B09 | Incident + forensic readiness | `Docs/governance/risk_register.md`, S10+ rollback/recovery planning artifacts |

## Alignment Rules for This Repo

1. No plan can exceed autonomy ceiling A2.
2. Any flash-affecting recommendation is treated as Class 3+ and requires dual-source validation.
3. Emulator-only evidence cannot be used as proof for hardware-only claims.
4. Runtime/evaluation recommendations remain advisory until explicit supervised pilot gate is approved.
5. All new safety-relevant plan changes require an ADR update.

## Required Validation Flow (Adopted from NAP)

Before pilot-ready status, run equivalent checks:

- Profile consistency validation
- Policy/runtime parity checks
- Enforcement simulation scenarios

In this planning phase, these are documented requirements; execution wiring is deferred.

## Deferred (Implementation Phase)

- Wire NAP scripts into Kai-zen CI pipeline.
- Add machine-readable profile declaration in Kai-zen root.
- Add automated fail-closed gate for Class 3+ changes.
