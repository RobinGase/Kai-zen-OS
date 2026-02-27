# ADR-0004: Pipeline Architecture Selection

## Metadata

- **Date**: 2026-02-27
- **Status**: Accepted
- **Deciders**: RobinGase (owner), Claude orchestrator (advisory)
- **Review date**: Re-evaluate at Phase 4 entry (when execution begins)
- **Related risks**: R-07 (cost explosion), R-11 (Rig immaturity)
- **Related docs**: `Docs/architecture/architecture_candidates.md`

## Context

The Kai-zen-OS pipeline needs an architecture to route tasks to the
correct AI model tier, validate outputs with cross-vendor verification,
enforce NAP governance, and control costs. Three candidates were
evaluated:

- **A: Monolithic Orchestrator** — single Claude Opus session manages everything
- **B: Multi-Agent Rig Pipeline** — Rust application with specialized agents
- **C: Event-Driven with Message Queue** — distributed consumers with queue

Full analysis with red-team, cost profiles, and scoring is in
`Docs/architecture/architecture_candidates.md`.

## Decision

**Architecture A (Monolithic Orchestrator)** for Phases 0-3.
**Architecture B (Rig Pipeline)** as planned evolution for Phase 4+.
**Architecture C (Event-Driven)** rejected permanently for this project.

### Phase architecture map

| Phase | Architecture | Rationale |
|-------|-------------|-----------|
| 0-3 | A: Monolithic | Zero build overhead; planning work only |
| 3-4 | A + B prototype | Build Rig pipeline incrementally while A handles daily work |
| 4+ | B: Rig Pipeline | Execution phase needs persistence, parallelism, observability |

## Alternatives Considered

### Architecture B (now)

Rejected for current phase because:
- Requires building a Rust application before any planning work can proceed
- Planning-phase task volume doesn't justify infrastructure investment
- Rig is pre-1.0 — better to let it stabilize while we're in planning
- Over-engineered: we're writing documents, not running a production pipeline

Accepted as future evolution because:
- Persistent state survives session crashes
- True parallelism for multi-model calls
- Built-in observability via OpenTelemetry
- Type-safe routing catches errors at compile time

### Architecture C (event-driven)

Rejected permanently because:
- Massively over-engineered for project scope (planning → single-device pilot)
- Context fragmentation degrades decision quality
- Governance enforcement in a distributed system is harder, with higher bypass risk
- Developer overwhelm: 5+ components to build and maintain
- No scenario where project scale justifies this complexity

## Consequences

### Positive
- Zero infrastructure delay — Architecture A is already running
- All planning work continues at full velocity
- Clear migration path to B when execution phase begins
- Simple governance enforcement — orchestrator sees everything

### Negative
- Session fragility — context lost on crash/timeout
  - Mitigated by: aggressive file writes, continuity protocol, git persistence
- Context window limit (200K tokens)
  - Mitigated by: session handoff summaries, modular task decomposition
- No true parallelism in current phase
  - Acceptable: planning-phase task volume is manageable sequentially
- Cost premium for Opus orchestration tokens
  - Acceptable: ~$120/month premium vs $0 infrastructure

## Compliance

- NAP B01 (Core governance): **Met** — single orchestrator enforces all rules
- NAP B06 (Runtime containment): **Met** — orchestrator controls all slot routing
- NAP B07 (Model supply chain): **Met** — allowlist enforced at orchestrator level
