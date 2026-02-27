# Kai-zen-OS

Planning-first repository for an autonomous, emulator-first Android image
engineering program targeting Samsung Galaxy phones (S10+ baseline).

> Current phase: Phase 3 complete, Phase 4 preparation active
> Governance envelope: NAP Class 3 floor | A2 ceiling | highest-safety-wins
> Runtime direction: Kilo-first orchestration (3x M-FAST worker fan-out)

This repository remains documentation and test-harness focused:

- No production flashing automation
- Emulator-first validation before any hardware readiness claims
- Redox microkernel track is R&D-only (not deployment kernel path)
- Kernel-critical recommendations require dual verification + human approval

## Start Here

- `Docs/implementation_plan.md` — master plan, phases, workstreams
- `Docs/architecture/orchestrator_model_spec.md` — routing model, escalation, gates
- `Docs/adrs/ADR-0003-model-routing-policy.md` — policy authority for model allowlist
- `Docs/operations/emulator_first_validation.md` — 5-layer emulator validation plan/results
- `REDOX_MICROKERNEL_STATUS_NOTE.md` — redox status handoff note for agents

## Current AI Routing Snapshot

- `M-ORCH`: Kilo control plane (gate/config owner)
- `M-FAST`: Kilo runtime worker pool (3 parallel workers)
- `M-HEAVY`: GPT-4o escalation lane
- `M-VERIFY`: NVIDIA NIM independent verification lane
- `M-KERNEL`: Kilo core agent or GPT-4o fallback (human approval mandatory)

## Tests

- Main runner: `tests/emulator/run_all.sh`
- Last-phase runner: `tests/emulator/run_layer5.sh`
- Layer 4 and 5 include hardened fail-closed checks for failure-path assertions.

## Reference

- Nex_Alignment submodule: `references/Nex_Alignment`
