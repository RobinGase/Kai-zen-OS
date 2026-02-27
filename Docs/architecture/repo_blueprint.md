# Repo Blueprint (Planning Codebase Style)

## Purpose

Use documentation modules like a codebase so decisions, constraints, and test plans are easy to navigate and debate.

## Structure

```text
Kai-zen-OS/
  README.md
  implementation_plan.md
  Docs/
    README.md
    implementation_plan.md
    alignment/
      README.md
      kai_zen_nap_alignment.md
      kai_zen_decision_router.md
    architecture/
      repo_blueprint.md
      orchestrator_model_spec.md
    research/
      redox_microkernel_assessment.md
      samsung_device_support_matrix.md
      framework_stack_rig_llm_chain.md
      model_provider_investigation.md
      gemini_2_5_flash_investigation.md
      nvidia_api_investigation.md
      subagent_report_digest.md
    operations/
      s10plus_current_setup.md
      remote_control_setup.md
      emulator_first_validation.md
    governance/
      risk_register.md
      source_verification.md
    adrs/
      ADR-0001-safety-boundary.md
      ADR-0002-kernel-and-os-strategy.md
      ADR-0003-model-routing-policy.md
```

## Ownership Model

- `research/` - evidence and feasibility
- `operations/` - real-world setup and runbook planning
- `governance/` - authenticity, safety, and risk
- `adrs/` - explicit architectural decisions

## Change Control

- Every major change updates one ADR.
- Any new claim in `research/` requires source URL in `governance/source_verification.md`.
- Any high-risk proposal must include rollback/recovery notes in `governance/risk_register.md`.
