# ADR-0002: Kernel and OS Strategy

## Status

Accepted

## Decision

Use Android/Samsung-compatible image strategy for phone targets.

- Redox remains an R&D workstream, not deployment kernel for Samsung phone targets.
- Kali-on-Redox-kernel is not a current implementation target.

## Rationale

- Redox maturity and hardware support are not aligned with near-term Samsung flash objectives.
- Phone program needs realistic, model-specific Android ecosystem tooling.

## Consequences

- Keep Redox knowledge as architecture inspiration and research artifact.
- Avoid dead-end execution work against unsupported assumptions.
