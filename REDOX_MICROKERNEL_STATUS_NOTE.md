# Redox Microkernel Status Note (Agent Pickup)

Date: 2026-02-27
Project: Kai-zen-OS
Repo root (active): /home/robindev/Kaizen/Kai-zen-OS
Baseline commit: 0e02abf

## Where We Are

The Redox microkernel track is **research-only (R&D)** and is **not** the active implementation path.

- Decision status: Accepted in `Docs/adrs/ADR-0002-kernel-and-os-strategy.md`.
- Redox remains a source of architectural ideas, not a deployment kernel target.
- No Redox build/boot/flash work is currently planned for Samsung deliverables.

## Why

Per `Docs/research/redox_microkernel_assessment.md` and plan constraints:

- No practical ARM64 Samsung deployment path in current scope.
- No Android HAL compatibility path for target devices.
- No cellular/baseband integration path for this program.

## Active Mainline

- Mainline target remains Linux-kernel / Android-compatible path for Samsung devices.
- Program phase: **Phase 3 complete** (`Docs/implementation_plan.md`).
- Emulator validation: **64/64 PASS** across Layers 1-5 (`Docs/operations/emulator_first_validation.md`).

## Agent Instructions (Pickup)

1. Treat Redox as a **research branch only**.
2. Continue mainline work on Samsung/Linux path (Phase 4 planning artifacts).
3. Do **not** propose Redox for production flashing/pilot scope.
4. If new upstream Redox evidence appears (ARM64 + Android/HAL viability), open ADR revision proposal before scope change.

## Non-Negotiable Boundaries

- Planning-first safety boundary remains active.
- No production flash automation in this repo.
- Emulator-first validation remains mandatory before any hardware readiness claims.
