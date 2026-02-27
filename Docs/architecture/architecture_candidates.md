# Architecture Candidates: Autonomous Image Pipeline

> **Phase**: 2 (Debate Architecture)
> **Date**: 2026-02-27
> **Decision**: Pending — evaluate A, B, C then select in ADR-0004

---

## Context

Kai-zen-OS needs an autonomous pipeline architecture that:

1. Routes tasks to the correct AI model tier (M-FAST → M-KERNEL)
2. Validates outputs with independent cross-vendor verification
3. Enforces NAP governance (Class 3 floor, A2 ceiling, fail-closed)
4. Controls cost (fast-model-first, ≥80% on M-FAST)
5. Supports emulator-first testing without hardware dependency
6. Produces audit trails for every decision
7. Handles session continuity (agent handoffs without knowledge loss)
8. Eventually orchestrates real device operations (Phase 4+)

Three candidate architectures are evaluated below.

---

## Architecture A: Monolithic Orchestrator

### Description

A single long-running Claude Opus session manages everything. The
orchestrator receives all tasks, delegates to external model APIs for
M-FAST/M-HEAVY/M-FRONT/M-VERIFY work, collects results, and makes
all routing decisions within one context window.

```
┌─────────────────────────────────────────────────────────┐
│                    Claude Opus Session                   │
│                                                         │
│  User → [Task Queue] → [Router Logic] → [API Calls] → │
│         [Result Collection] → [Governance Check] →      │
│         [Output to User]                                │
│                                                         │
│  External calls:                                        │
│    Gemini 2.5 Flash API  (M-FAST tasks)                │
│    GPT-4o API            (M-HEAVY tasks)                │
│    Gemini 2.5 Pro API    (M-FRONT tasks)                │
│    NVIDIA NIM API        (M-VERIFY tasks)               │
└─────────────────────────────────────────────────────────┘
```

### How it works

1. User submits a task (e.g., "generate test cases for ADB provider routing")
2. Claude Opus (M-ORCH) analyzes the task, assigns tags, determines tier
3. For Tier A: Claude calls Gemini 2.5 Flash API directly
4. For Tier B: Claude calls GPT-4o or Gemini 2.5 Pro API
5. For Tier C: Claude calls both GPT-4o and NVIDIA NIM independently,
   then compares results
6. Claude applies governance scoring, logs the decision, returns output
7. All state lives in the Claude context window

### Strengths

| Strength | Detail |
|----------|--------|
| Simplest to build | No infrastructure beyond API keys; works today |
| Lowest operational overhead | Single session, no message queues, no deployment |
| Best context coherence | All history in one context window |
| Easiest governance enforcement | Orchestrator sees everything, can't be bypassed |
| Immediate start | We're already doing this — current session is Architecture A |

### Weaknesses

| Weakness | Severity | Detail |
|----------|----------|--------|
| Context window limit | High | Claude Opus: 200K tokens. Long sessions will hit this. |
| Session fragility | High | If session crashes or times out, all in-progress state is lost |
| Single point of failure | High | One model outage blocks everything |
| No parallelism | Medium | Claude processes tasks sequentially; can't run multiple model calls simultaneously within a single tool-use turn |
| Cost concentration | Medium | All orchestration tokens are Opus-priced ($15/1M input) |
| No persistent state | High | Between sessions, state must be manually serialized to files |

### NAP compliance

- Class 3 floor: **Met** — orchestrator applies governance to every task
- A2 ceiling: **Met** — human approves consequential steps
- Fail-closed: **Met** — if API call fails, orchestrator doesn't auto-approve
- Audit trail: **Partial** — decisions logged in session but lost if session resets

### Estimated cost profile (monthly, planning phase)

| Component | Tokens/month | Cost |
|-----------|-------------|------|
| M-ORCH (Claude Opus) | ~5M input, ~2M output | ~$225 |
| M-FAST (Gemini Flash) | ~20M input, ~5M output | ~$6 |
| M-HEAVY (GPT-4o) | ~2M input, ~1M output | ~$15 |
| M-VERIFY (NVIDIA NIM) | ~1M input, ~0.5M output | ~$1 |
| **Total** | | **~$247/month** |

---

## Architecture B: Multi-Agent Pipeline (Rig-Based)

### Description

A Rust application built with Rig orchestrates multiple specialized
agents. Each agent corresponds to a model slot. The Rig pipeline
manages routing, tool execution, and result composition. State is
persisted to disk.

```
┌──────────────────────────────────────────────────────────┐
│                    Rig Pipeline (Rust)                    │
│                                                          │
│  ┌─────────┐    ┌──────────┐    ┌───────────┐          │
│  │  Router  │───>│  Worker   │───>│ Validator │          │
│  │  Agent   │    │  Pool     │    │   Agent   │          │
│  │ (M-ORCH) │    │(M-FAST,   │    │(M-VERIFY) │          │
│  │          │    │ M-HEAVY,  │    │           │          │
│  │          │    │ M-FRONT,  │    │           │          │
│  │          │    │ M-KERNEL) │    │           │          │
│  └─────────┘    └──────────┘    └───────────┘          │
│       │              │               │                   │
│       └──────────────┴───────────────┘                   │
│                      │                                   │
│              ┌───────────────┐                           │
│              │  State Store  │                           │
│              │  (SQLite/JSON)│                           │
│              └───────────────┘                           │
│                                                          │
│  ┌────────────────┐  ┌────────────────┐                 │
│  │  Tracing/OTel   │  │ Governance     │                 │
│  │  (observability)│  │ Engine (NAP)   │                 │
│  └────────────────┘  └────────────────┘                 │
└──────────────────────────────────────────────────────────┘
```

### How it works

1. Task arrives via CLI command or API endpoint
2. Router Agent (backed by Claude Opus) analyzes task, assigns tags/tier
3. Task dispatched to Worker Pool — correct agent selected by tier
4. Worker agent executes task using its assigned model (Gemini/GPT-4o/etc.)
5. For Tier C/K: Validator Agent independently processes same task
6. Router Agent compares outputs, applies governance scoring
7. Result, decision log, and token usage persisted to state store
8. OpenTelemetry traces emitted for observability

### Strengths

| Strength | Detail |
|----------|--------|
| True parallelism | Multiple workers can run simultaneously |
| Persistent state | SQLite/JSON store survives crashes and restarts |
| Type-safe routing | Rust compiler catches routing errors |
| Built-in observability | Rig's tracing integration with OpenTelemetry |
| Scalable | Add more workers without changing architecture |
| Cost-efficient orchestration | Router agent uses smaller prompts; workers do bulk work |

### Weaknesses

| Weakness | Severity | Detail |
|----------|----------|--------|
| Build effort | High | Requires writing a Rust application from scratch |
| Rig pre-1.0 | Medium | API instability; may need migration on updates |
| Operational complexity | Medium | Must deploy and run a long-lived process |
| Rust expertise required | Medium | Higher onboarding bar than Python |
| Over-engineered for planning phase | High | We're writing docs, not running a production pipeline |
| Testing the pipeline itself | Medium | Need to test the orchestration code, not just the tasks |

### NAP compliance

- Class 3 floor: **Met** — governance engine embedded in pipeline
- A2 ceiling: **Met** — human approval gates built into Tier C/K flows
- Fail-closed: **Met** — Rust Result types force error handling
- Audit trail: **Strong** — persistent state store + OTel traces

### Estimated cost profile (monthly, planning phase)

| Component | Tokens/month | Cost |
|-----------|-------------|------|
| Router (Claude Opus, smaller prompts) | ~2M input, ~1M output | ~$105 |
| M-FAST (Gemini Flash) | ~20M input, ~5M output | ~$6 |
| M-HEAVY (GPT-4o) | ~2M input, ~1M output | ~$15 |
| M-VERIFY (NVIDIA NIM) | ~1M input, ~0.5M output | ~$1 |
| Infrastructure (compute) | — | ~$0 (local) |
| **Total** | | **~$127/month** |

---

## Architecture C: Event-Driven with Message Queue

### Description

Tasks are posted to a message queue (e.g., Redis Streams, RabbitMQ, or
even a file-based queue). Independent consumer agents poll the queue,
process tasks, and post results back. A governance service validates
results before they're accepted.

```
┌──────────┐     ┌─────────────────┐     ┌──────────────┐
│   User   │────>│   Task Queue    │<───>│  Governance   │
│          │     │ (Redis/File)    │     │  Service      │
└──────────┘     └────────┬────────┘     └──────────────┘
                          │
              ┌───────────┼───────────┐
              │           │           │
       ┌──────────┐ ┌──────────┐ ┌──────────┐
       │Consumer A│ │Consumer B│ │Consumer C│
       │(M-FAST)  │ │(M-HEAVY) │ │(M-VERIFY)│
       │ Gemini   │ │  GPT-4o  │ │  NIM     │
       └──────────┘ └──────────┘ └──────────┘
              │           │           │
              └───────────┼───────────┘
                          │
                  ┌───────────────┐
                  │  Result Store  │
                  │  (DB/Files)    │
                  └───────────────┘
```

### How it works

1. User posts task to queue with metadata (tags, tier, priority)
2. Queue routes to appropriate consumer based on tier
3. Consumer processes task using its assigned model
4. Result posted back to queue / result store
5. For Tier C/K: governance service waits for both primary and
   verification results before accepting
6. Governance service applies NAP scoring, logs decision
7. Accepted results available for user retrieval

### Strengths

| Strength | Detail |
|----------|--------|
| Maximum parallelism | All consumers independent; no blocking |
| Fault isolation | One consumer crash doesn't affect others |
| Language-agnostic | Consumers can be Python, Rust, Node, etc. |
| Scalable | Add/remove consumers without changing anything else |
| Decoupled | Each component can be developed/tested independently |

### Weaknesses

| Weakness | Severity | Detail |
|----------|----------|--------|
| Highest operational complexity | Very High | Queue infrastructure, multiple processes, monitoring |
| Massive over-engineering | Very High | This is a planning repo with docs — not a distributed system |
| Context fragmentation | High | No single agent has full context; decisions lose coherence |
| Orchestration becomes distributed | High | Governance must be a separate service, harder to enforce |
| Debugging difficulty | High | Distributed tracing needed to follow a task through the system |
| Infrastructure cost | Medium | Even local, running Redis + multiple consumers is overhead |

### NAP compliance

- Class 3 floor: **Possible** — but governance is a separate service, so
  enforcement depends on correct message routing. Bypass risk is higher.
- A2 ceiling: **Possible** — human approval gates need explicit
  implementation in governance service
- Fail-closed: **Risky** — message queues default to "delivered", not
  "validated". Must implement dead-letter queues carefully.
- Audit trail: **Strong** — message queues naturally log everything

### Estimated cost profile (monthly, planning phase)

| Component | Tokens/month | Cost |
|-----------|-------------|------|
| Router (Claude Opus) | ~2M input, ~1M output | ~$105 |
| M-FAST (Gemini Flash) | ~20M input, ~5M output | ~$6 |
| M-HEAVY (GPT-4o) | ~2M input, ~1M output | ~$15 |
| M-VERIFY (NVIDIA NIM) | ~1M input, ~0.5M output | ~$1 |
| Infrastructure (Redis/monitoring) | — | ~$10-30 |
| **Total** | | **~$137-157/month** |

---

## Red-Team Analysis

### Architecture A: Monolithic — Failure Modes

1. **Context overflow**: At ~200K tokens, a complex multi-task session
   will lose early context. Tasks later in the session may contradict
   earlier decisions.
   - **Severity**: High. **Mitigation**: Session handoff protocol + summary docs.

2. **Session loss**: If the CLI session crashes, all in-progress work
   is lost except what was written to files.
   - **Severity**: High. **Mitigation**: Write to files aggressively.

3. **API cascade failure**: If Gemini API is down, the whole session
   blocks waiting for a response.
   - **Severity**: Medium. **Mitigation**: Timeouts + fallback models.

4. **Orchestrator hallucination**: If Claude makes a routing error,
   there's no independent check on the routing itself.
   - **Severity**: Medium. **Mitigation**: Tier tags are metadata, not
   AI-generated in most cases.

### Architecture B: Multi-Agent Rig — Failure Modes

1. **Build delay**: Writing a Rig application will take days/weeks
   before we can use it. Meanwhile, planning work stalls.
   - **Severity**: High. **Mitigation**: Build incrementally while
   continuing to use Architecture A for current work.

2. **Rig API breakage**: Version update breaks our code.
   - **Severity**: Medium. **Mitigation**: Pin exact version in Cargo.toml.

3. **State corruption**: SQLite file gets corrupted.
   - **Severity**: Medium. **Mitigation**: Regular backups, WAL mode.

4. **Over-fit to Rig**: If Rig is abandoned, we're locked in.
   - **Severity**: Medium. **Mitigation**: MIT license, abstract
   interfaces, fork option.

### Architecture C: Event-Driven — Failure Modes

1. **Message loss**: Queue drops a task; result never comes back.
   - **Severity**: High. **Mitigation**: Persistent queues with
   acknowledgment, but adds complexity.

2. **Governance bypass**: Consumer posts directly to result store
   without governance check.
   - **Severity**: Critical. **Mitigation**: Only governance service
   has write access to accepted results. But this is hard to enforce
   without infrastructure.

3. **Context coherence lost**: A Tier C task requires comparing two
   model outputs, but the governance service has no context about
   the original task beyond what's in the message.
   - **Severity**: High. **Mitigation**: Rich message metadata. But
   this reduces the advantage of decoupling.

4. **Developer overwhelm**: Building and maintaining 5+ components
   for a planning-phase project.
   - **Severity**: Very High. **Mitigation**: Don't use this architecture.

---

## Scoring

| Criterion | Weight | A: Monolithic | B: Rig Pipeline | C: Event-Driven |
|-----------|--------|--------------|-----------------|-----------------|
| Build effort (lower = better) | 25% | **10** (zero build) | 4 (Rust app) | 2 (distributed) |
| Reliability | 20% | 5 (session fragile) | **8** (persistent state) | 6 (message risk) |
| NAP compliance ease | 20% | **9** (single enforcement) | 8 (embedded engine) | 5 (distributed) |
| Cost efficiency | 15% | 5 (Opus-heavy) | **8** (smaller prompts) | 7 (similar + infra) |
| Debuggability | 10% | **8** (single session) | 7 (traces) | 3 (distributed) |
| Scalability | 10% | 3 (single session) | 7 (add workers) | **9** (fully decoupled) |
| **Weighted score** | | **7.25** | **6.85** | **4.35** |

---

## Recommendation

**Architecture A (Monolithic Orchestrator)** for the current phase.

### Rationale

1. **We're in a planning phase**. The pipeline processes documents and
   research, not production workloads. The complexity of B or C is
   unjustified for the current task volume.

2. **Architecture A is already working**. This session is Architecture A.
   Every doc written, every test run, every decision made — all through
   a monolithic Claude Opus session.

3. **Session fragility is mitigated** by our continuity protocol: every
   session writes state to files, the orchestrator spec defines handoff
   format, and git provides persistent storage.

4. **Cost is acceptable** for planning phase. The $120/month premium
   for Opus orchestration tokens is offset by zero infrastructure cost.

5. **Architecture B is the natural evolution** when the project moves
   from planning to execution (Phase 4+). The Rig pipeline should be
   built incrementally during Phase 3-4, not as a prerequisite.

### Migration path: A → B

| Phase | Architecture | Reason |
|-------|-------------|--------|
| Phase 0-3 (current) | A (Monolithic) | Planning work; no build overhead |
| Phase 3-4 (transition) | A + B prototype | Build Rig pipeline while still using A |
| Phase 4+ (execution) | B (Rig Pipeline) | Production workloads need persistence and parallelism |
| Never | C (Event-Driven) | Over-engineered for project scope |
