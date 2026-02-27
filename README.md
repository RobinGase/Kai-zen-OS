# Kai-zen-OS

Planning-first repository for an autonomous, emulator-first image
engineering program targeting Samsung Galaxy phones (S10+ baseline).

> **Current phase**: Phase 1 (Research Consolidation) → Phase 2 starting
> **NAP envelope**: Class 3 floor | A2 ceiling | highest-safety-wins

This repo is intentionally **documentation-only**:

- No flashing automation or production code
- No secrets or credentials
- No irreversible device operations
- Emulator testing only (`boomies_api35` AVD, Android 15)
- All AI decisions capped at NAP autonomy tier A2

## Scope

- Design end-to-end Samsung image pipeline (baseline: SM-G975F Exynos)
- Variant-level device matrix S10 → S24+ with Exynos/Snapdragon split
- Multi-model orchestration: Gemini 2.5 Flash (fast) → GPT-4o (heavy) →
  NVIDIA NIM (verify) → Claude Opus 4 (orchestrate) → M-KERNEL (kernel patches)
- NAP governance via Nex_Alignment protocol
- Redox microkernel as R&D / architecture-inspiration stream only

## Start Here

- **Main plan**: `Docs/implementation_plan.md` (phase tracking, workstreams, exit criteria)
- **Docs index**: `Docs/README.md`
- **Orchestrator spec**: `Docs/architecture/orchestrator_model_spec.md` (model routing)
- **NAP alignment**: `Docs/alignment/kai_zen_nap_alignment.md`
- **NAP glossary**: `Docs/alignment/nap_glossary.md` (Class/Tier/Bundle definitions)
- **Device matrix**: `Docs/research/samsung_device_support_matrix.md`
- **S10+ baseline**: `Docs/operations/s10plus_current_setup.md`
- **Emulator tests**: `Docs/operations/emulator_first_validation.md`

## Integrated Reference

- Nex_Alignment (git submodule): `references/Nex_Alignment`
- Upstream: https://github.com/RobinGase/Nex_Alignment
