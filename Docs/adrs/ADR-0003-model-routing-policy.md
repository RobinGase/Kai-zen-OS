# ADR-0003: Model Routing Policy

## Status

Accepted (planning baseline)

## Decision

Adopt tiered model routing with independent-vendor verification.

- Tier A (cheap/fast): default planning and drafting
- Tier B (balanced): escalate when confidence/quality insufficient
- Tier C (high assurance): dual-vendor consensus for critical decisions

Gemini 2.5 Flash and NVIDIA endpoints are included in the planning architecture through a provider-agnostic adapter.

## Rationale

- Control cost while preserving reliability.
- Reduce single-vendor bias on high-risk decisions.

## Consequences

- Requires stronger observability and routing metadata.
- Requires explicit model allowlist governance.
