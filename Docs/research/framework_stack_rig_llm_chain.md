# Framework Stack: Rig vs llm-chain

## Summary

- Use **Rig** as orchestration backbone (agents, tools, chains, observability, provider abstraction).
- Use **llm-chain patterns** for deterministic, template-heavy chain steps where needed.

## Rig Strengths

- Agent abstractions for tools/context and multi-turn behavior.
- Chain/pipeline patterns for sequential + parallel flow composition.
- Observability guidance with tracing/telemetry integration.
- Provider abstraction model suitable for multi-vendor routing.

## llm-chain Strengths

- Straightforward prompt templates and chain ergonomics.
- Useful for deterministic step sequencing and map-reduce style flows.
- Good fit for small, tightly scoped transformation tasks.

## Suggested Hybrid Pattern

1. Rig orchestrates planner, skeptic, reconciler, and verifier agents.
2. llm-chain style templates drive deterministic subtasks in those agents.
3. All outputs pass through rule-based validation + source checks.

## Sources

- https://docs.rig.rs/docs
- https://docs.rig.rs/docs/concepts/agent
- https://docs.rig.rs/docs/concepts/chains
- https://docs.rig.rs/docs/concepts/observability
- https://docs.llm-chain.xyz/docs/introduction/
- https://docs.llm-chain.xyz/docs/chains/what-are-chains
- https://docs.rs/llm-chain/latest/llm_chain/
