# Kilo Code Integration Investigation (Provisional)

> **Last updated**: 2026-02-27
> **Status**: Provisional architecture note for immediate routing switch

## Objective

Evaluate Kilo Code as the primary AI runtime for Kai-zen-OS orchestration,
with direct integration points into the microkernel/core planning track and
ownership of runtime gates and configuration policy.

## Intended Role in Kai-zen-OS

- Replace Gemini-based fast lanes with **Kilo worker pool** (M-FAST).
- Replace front-end Gemini lane with **Kilo UI worker** (M-FRONT).
- Move orchestrator gate ownership to **Kilo control plane** (M-ORCH).
- Enable Kilo-driven core-policy hooks for kernel-critical planning paths,
  while keeping mandatory human approval and independent verification.

## Target Topology

1. Kilo M-ORCH receives task metadata and risk tags.
2. Tier A tasks fan out to 3 parallel Kilo M-FAST workers.
3. Kilo M-ORCH aggregates outputs and applies quorum policy.
4. Disagreement or low confidence escalates to M-HEAVY (GPT-4o).
5. Class 3+ safety work keeps independent M-VERIFY (NVIDIA NIM).

## Gate Ownership (Kilo)

Kilo control plane becomes the owner of:

- Routing gate (tag -> slot)
- Escalation gate (confidence/complexity)
- Policy gate (NAP class + A2 ceiling checks)
- Approval gate (human-in-the-loop for Class 3+/Tier K)
- Config gate (model endpoint selection and fallback policy)

## Compatibility Boundaries

- This repository remains **planning-first**; no flash automation is added.
- Emulator-first validation remains mandatory.
- Redox remains R&D-only; no production kernel migration assumptions change.

## Open Validation Items

- Confirm Kilo API/runtime contract and auth flow details.
- Confirm fan-out worker semantics and deterministic merge support.
- Confirm gate policy export format for auditable decision logs.
- Add source entries to `Docs/governance/source_verification.md` once
  official Kilo references are captured.

## Immediate Follow-up Tasks

1. Update orchestration spec and ADR allowlist to Kilo-first routing.
2. Update Layer 2 tests to validate Kilo roster presence.
3. Add failure-path tests for Kilo endpoint outage and fallback behavior.
4. Add explicit evidence fields for worker fan-out and quorum decisions.

## Risk Notes

- Vendor concentration risk increases if Kilo owns both fast lanes and gates.
- Maintain independent verification lane (NVIDIA NIM) for Class 3+ decisions.
- Preserve GPT-4o escalation path to avoid single-runtime lock-in.
