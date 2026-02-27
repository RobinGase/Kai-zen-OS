# Framework Stack: Rig vs llm-chain

## Scope

Evaluate orchestration frameworks for Kai-zen-OS's autonomous pipeline.
The framework must support multi-model routing, tool integration,
observability, and provider abstraction.

## Language Commitment: Rust

Both candidates are **Rust** frameworks. This is a deliberate choice:

- Kai-zen-OS's orchestration layer will be written in Rust
- Rust provides memory safety without garbage collection — important for
  a system that may eventually interact with low-level device operations
- Rust's type system catches routing errors at compile time
- Alignment with Redox R&D stream (Redox is Rust-native)

This does **not** mean all project tooling is Rust. Test scripts,
automation glue, and emulator harness code may use Python or shell.

## Evaluation Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Agent abstraction | High | Support for tool-using, multi-turn agents |
| Multi-provider routing | High | Switch between Gemini, OpenAI, NVIDIA with same interface |
| Chain/pipeline composition | Medium | Sequential and parallel task flows |
| Observability | Medium | Tracing, logging, metrics hooks |
| Maturity / community | Medium | Active development, documentation quality, issue responsiveness |
| Structured output | High | JSON schema enforcement on model responses |
| Error handling | High | Retry logic, fallback behavior, timeout management |

## Rig Assessment

- **Repository**: https://github.com/0xPlaygrounds/rig
- **Documentation**: https://docs.rig.rs/docs
- **Language**: Rust
- **License**: MIT
- **Maturity**: Active development, growing community, used in production
  by several projects. Not yet at 1.0 — API may change.

### Strengths

1. **Agent abstractions**: first-class `Agent` type with tool registration,
   context injection, and multi-turn conversation management.
2. **Provider abstraction**: built-in support for OpenAI, Anthropic, and
   Cohere providers. Custom providers can be added via trait implementation.
   Gemini support via OpenAI-compatible endpoint. NVIDIA NIM via same
   OpenAI adapter (different base URL).
3. **Chain/pipeline patterns**: `Pipeline` and `Chain` types for
   sequential and parallel flow composition. Supports map-reduce
   patterns.
4. **Observability**: tracing integration via `tracing` crate. Supports
   OpenTelemetry-compatible exporters.
5. **Structured output**: JSON schema enforcement on completions via
   `response_schema` parameter forwarding.
6. **Error handling**: Result types with retry middleware, timeout
   configuration, and provider fallback chains.

### Weaknesses

1. **Pre-1.0 API**: breaking changes possible between minor versions.
   Mitigation: pin exact version in `Cargo.toml`.
2. **Smaller community** than Python frameworks (LangChain, CrewAI).
   Fewer examples, tutorials, and Stack Overflow answers.
3. **No native Gemini provider**: relies on OpenAI-compatible endpoint,
   which may not expose all Gemini-specific features (e.g., thinking mode).
4. **Limited testing utilities**: no built-in mock providers for unit
   testing. Must build test doubles manually.

### Version Evaluated

- Rig v0.5.x (as of Q1 2026 — check https://crates.io/crates/rig-core)
- Source verification: https://docs.rig.rs/docs

## llm-chain Assessment

- **Repository**: https://github.com/sobelio/llm-chain
- **Documentation**: https://docs.llm-chain.xyz/docs/introduction/
- **Language**: Rust
- **License**: MIT
- **Maturity**: Active but smaller community than Rig. Focused on
  chain-of-thought and template-driven workflows.

### Strengths

1. **Prompt templates**: first-class template system with variable
   injection and chain composition.
2. **Deterministic sequencing**: strong support for fixed-step chains
   where each step has a known template and expected output format.
3. **Map-reduce**: built-in patterns for splitting work across multiple
   calls and merging results.
4. **Simple API**: lower learning curve for straightforward chain tasks.

### Weaknesses

1. **No agent abstraction**: llm-chain is chain-focused, not agent-focused.
   No tool registration, no multi-turn conversation management.
2. **Limited provider support**: primarily OpenAI. Other providers require
   manual integration.
3. **Less active development**: commit frequency and issue response time
   are lower than Rig.
4. **No observability hooks**: no built-in tracing or metrics integration.

### Version Evaluated

- llm-chain v0.13.x (as of Q1 2026)
- Source verification: https://docs.llm-chain.xyz/docs/introduction/

## Comparison Matrix

| Criterion | Rig | llm-chain | Winner |
|-----------|-----|-----------|--------|
| Agent abstraction | Strong (first-class) | None | Rig |
| Multi-provider routing | Good (OpenAI adapter) | Limited | Rig |
| Chain composition | Good | Strong | llm-chain |
| Observability | Good (tracing crate) | None | Rig |
| Maturity | Pre-1.0 but active | Pre-1.0, less active | Rig |
| Structured output | Good | Limited | Rig |
| Error handling | Good (retry, fallback) | Basic | Rig |
| Template system | Basic | Strong | llm-chain |
| Learning curve | Moderate | Lower | llm-chain |

## Recommendation

**Primary framework: Rig** — handles orchestration, agent management,
provider routing, and observability.

**Secondary (selective use): llm-chain patterns** — for deterministic,
template-heavy chain steps within individual agents. Specifically:

- Use llm-chain-style templates for fixed-format outputs (e.g., test
  case generation, structured assessment reports)
- Use Rig's agent/pipeline system for everything else

### Suggested Architecture

```
┌─────────────────────────────────────────┐
│  M-ORCH (Claude Opus 4)                │
│  ┌───────────────────────────────────┐  │
│  │  Rig Pipeline                     │  │
│  │  ┌──────┐ ┌──────┐ ┌──────────┐  │  │
│  │  │Router│→│Worker│→│Validator │  │  │
│  │  │Agent │ │Agents│ │  Agent   │  │  │
│  │  └──────┘ └──────┘ └──────────┘  │  │
│  └───────────────────────────────────┘  │
│                                         │
│  Worker agents use:                     │
│  - Rig Agent for tool-using tasks       │
│  - llm-chain templates for fixed output │
└─────────────────────────────────────────┘
```

### Agent Roles (from orchestrator model spec)

| Role | Framework | Model Slot |
|------|-----------|------------|
| Router | Rig Agent | M-ORCH |
| Planner | Rig Agent | M-FAST |
| Skeptic/Verifier | Rig Agent | M-VERIFY |
| Reconciler | Rig Agent | M-ORCH |
| Template worker | llm-chain chain | M-FAST |
| Kernel reviewer | Rig Agent | M-KERNEL |

## Risks

- **Rig pre-1.0 instability**: API may break on update. Mitigation:
  pin exact version, monitor changelog.
- **Framework abandonment**: both are community projects. Mitigation:
  Rig has MIT license; we can fork if needed. The abstraction layer
  means switching frameworks affects implementation, not architecture.
- **Rust learning curve**: Rust is harder to onboard contributors to
  than Python. Mitigation: test harness and automation scripts can use
  Python; only the orchestration core is Rust.

## Sources

- Rig docs: https://docs.rig.rs/docs
- Rig agents: https://docs.rig.rs/docs/concepts/agent
- Rig chains: https://docs.rig.rs/docs/concepts/chains
- Rig observability: https://docs.rig.rs/docs/concepts/observability
- Rig crate: https://crates.io/crates/rig-core
- llm-chain docs: https://docs.llm-chain.xyz/docs/introduction/
- llm-chain chains: https://docs.llm-chain.xyz/docs/chains/what-are-chains
- llm-chain crate: https://docs.rs/llm-chain/latest/llm_chain/
