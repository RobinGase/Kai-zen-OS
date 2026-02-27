# Repo Blueprint (Planning Codebase Style)

> **Last updated**: 2026-02-27 (session 2)

## Purpose

Use documentation modules like a codebase so decisions, constraints, and
test plans are easy to navigate and debate.

## Structure

```text
Kai-zen-OS/
  README.md                          # Project overview and start-here links
  implementation_plan.md             # Pointer to Docs/implementation_plan.md
  .gitignore                         # Exclusions incl. kernel-patch routing
  .gitmodules                        # Nex_Alignment submodule config
  Docs/
    README.md                        # Master doc index
    implementation_plan.md           # End-to-end plan with phase tracking
    alignment/
      README.md                      # Alignment module overview
      kai_zen_nap_alignment.md       # NAP profile composition + bundle mapping
      kai_zen_decision_router.md     # Quick routing checklist + decision log
      nap_glossary.md                # Class 0-4, A0-A4, bundles defined locally
    architecture/
      repo_blueprint.md              # This file — repo structure and conventions
      orchestrator_model_spec.md     # Model routing: M-FAST/HEAVY/FRONT/ORCH/VERIFY/KERNEL
    research/
      redox_microkernel_assessment.md     # Redox feasibility (verdict: R&D only)
      samsung_device_support_matrix.md    # S10-S24 variant-level matrix
      framework_stack_rig_llm_chain.md    # Rig vs llm-chain evaluation
      model_provider_investigation.md     # Multi-vendor provider roster and routing
      gemini_2_5_flash_investigation.md   # Gemini 2.5 Flash deep assessment
      nvidia_api_investigation.md         # NVIDIA NIM deep assessment
      subagent_report_digest.md           # Research methodology and consolidated outcomes
    operations/
      s10plus_current_setup.md       # S10+ observed state (sanitized)
      s10plus_rollback_plan.md       # Rollback/recovery procedures (doc only)
      remote_control_setup.md        # ADB/scrcpy/Appium control model
      emulator_first_validation.md   # AVD test taxonomy (45 tests, 5 layers)
    governance/
      risk_register.md               # 15 risks with full detail and status
      source_verification.md         # Dated source log with confidence tiers
    adrs/
      ADR-0001-safety-boundary.md    # Planning-only, no flash commands
      ADR-0002-kernel-and-os-strategy.md  # Redox = R&D, Linux kernel for phones
      ADR-0003-model-routing-policy.md    # Tiered multi-vendor model allowlist
  references/
    Nex_Alignment/                   # Git submodule → github.com/RobinGase/Nex_Alignment
```

## Ownership Model

| Directory | Concern | Owner role |
|-----------|---------|------------|
| `alignment/` | NAP governance mapping and routing | Governance |
| `architecture/` | System design and orchestration specs | Architecture |
| `research/` | Evidence, feasibility, and provider assessment | Research |
| `operations/` | Real-world device setup and test harness | Platform |
| `governance/` | Risk, source authenticity, and compliance | Governance |
| `adrs/` | Explicit architectural decisions | Architecture |
| `references/` | External dependency snapshots | All |

## File Naming Conventions

- Use `snake_case` for all filenames
- ADRs: `ADR-NNNN-short-description.md` (zero-padded 4-digit)
- Research: descriptive name reflecting the subject
- Operations: device or tool name prefix (e.g., `s10plus_`, `emulator_`)

## Change Control

- Every major change updates or creates one ADR.
- Any new claim in `research/` requires a source URL in `governance/source_verification.md`.
- Any high-risk proposal (Class 3+) must include rollback/recovery notes
  in `governance/risk_register.md`.
- Any new model added to the orchestrator roster must have a vendor
  documentation URL in `source_verification.md` (no phantom models).
- Changes to the model roster require an ADR-0003 update.

## Phase Status

Current phase and status are tracked in `Docs/implementation_plan.md`
(line 3). This is the single source of truth for project progress.
