# Orchestrator Model Specification

## Status

Accepted (planning baseline) — supplements ADR-0003

## Purpose

Define **which AI models handle which task tiers** in a modular,
project-agnostic format.  Any NAP-governed project can import this spec,
override the model table, and inherit the routing logic, escalation rules,
and governance hooks unchanged.

This spec is designed so a fresh agent session can pick it up and continue
work without prior conversation context.

---

## 1  Model Roster

| Slot | Model | Vendor | Primary Role | Status |
|------|-------|--------|--------------|--------|
| **M-FAST** | Gemini 2.5 Flash | Google | High-volume, low-cost work: tests, mocks, readings, assessments, logging, heartbeat checks, syntax audits, primitive path audits, wiring | Verified — GA, $0.15/1M input tokens, 1M context window |
| **M-HEAVY** | GPT-4o | OpenAI | High-complexity tasks: multi-file refactors, deep architecture reasoning, novel algorithm design, security-critical code generation | Verified — GA, $2.50/1M input tokens, 128K context |
| **M-FRONT** | Gemini 2.5 Pro | Google | Front-end work: UI components, styling, layout, accessibility, client-side interaction logic | Verified — GA, $1.25/1M input, 1M context window |
| **M-ORCH** | Claude Opus 4 (claude-opus-4-6) | Anthropic | **Orchestrator**: report consolidation, authenticity verification, governance routing, final decision authority | Active — current session model |
| **M-VERIFY** | NVIDIA NIM (Llama 3.1 70B / Nemotron) | NVIDIA | Independent investigation and cross-vendor verification for high-assurance decisions | Verified — NIM API, OpenAI-compatible endpoint |
| **M-KERNEL** | Claude Opus 4 (claude-opus-4-6) OR GPT-4o | Anthropic / OpenAI | **Core kernel patches only**: device tree modifications, bootloader chain reasoning, partition table changes, SELinux policy, HAL integration | Restricted — Kai-zen-OS repo only, xtra-high priority |

> **M-KERNEL note**: This slot exists exclusively for this repository's
> kernel-critical work. It is not part of the general NAP orchestrator
> template. The `.gitignore` excludes kernel-patch routing config from
> upstream sync. M-KERNEL tasks always require human review (Class 3+,
> NAP A2 ceiling enforced).

### Slot semantics

- **M-FAST** is the default. Every task starts here unless a routing rule
  explicitly assigns it elsewhere.
- **M-HEAVY** is invoked only when M-FAST confidence is below threshold or
  the task matches a complexity trigger (see Section 3).
- **M-FRONT** handles any task tagged `frontend`, `ui`, `css`, `a11y`, or
  `client-side`.
- **M-ORCH** never executes leaf tasks. It consolidates outputs from all
  other slots, performs authenticity checks, and applies NAP governance
  decisions.
- **M-VERIFY** provides independent second-opinion verification. Used in
  Tier C dual-vendor consensus (see Section 4).
- **M-KERNEL** is the highest-privilege slot. Invoked only for tasks that
  directly affect kernel, bootloader, partition layout, or HAL layers.
  Always requires dual review: M-KERNEL produces output, M-VERIFY
  independently validates, M-ORCH arbitrates with human approval mandatory.

---

## 2  Task Classification Tags

Every task entering the orchestrator must carry at least one tag.
Tags determine the initial model slot.

### Tag → Slot mapping

| Tag | Default Slot | Notes |
|-----|-------------|-------|
| `test` | M-FAST | Unit tests, integration test scaffolds |
| `mock` | M-FAST | Mock data, stub services |
| `reading` | M-FAST | File reads, doc parsing, summarization |
| `assessment` | M-FAST | Feasibility checks, risk scoring |
| `logging` | M-FAST | Log format design, telemetry wiring |
| `heartbeat` | M-FAST | Health checks, liveness probes |
| `syntax-audit` | M-FAST | Lint, format, parse validation |
| `path-audit` | M-FAST | File path / import resolution checks |
| `wiring` | M-FAST | Glue code, config plumbing, adapter stubs |
| `frontend` | M-FRONT | UI components, styles, layouts |
| `ui` | M-FRONT | Same as frontend |
| `css` | M-FRONT | Stylesheet work |
| `a11y` | M-FRONT | Accessibility audit and fixes |
| `client-side` | M-FRONT | Browser/device client logic |
| `refactor` | M-HEAVY | Multi-file structural changes |
| `architecture` | M-HEAVY | System design, ADR drafting |
| `security` | M-HEAVY | Crypto, auth, vulnerability analysis |
| `novel-algorithm` | M-HEAVY | New algorithmic design |
| `consolidation` | M-ORCH | Report merging, cross-source synthesis |
| `verification` | M-VERIFY | Independent cross-vendor fact-check |
| `kernel-patch` | M-KERNEL | Device tree, kernel config, defconfig changes |
| `bootloader` | M-KERNEL | Bootloader chain, AVB, partition table |
| `selinux-policy` | M-KERNEL | SELinux/SEAndroid policy modifications |
| `hal-integration` | M-KERNEL | Hardware abstraction layer bindings |
| `partition-layout` | M-KERNEL | Partition table changes, super partition |

Tags not in this table default to **M-FAST**.

> **Kernel-tagged tasks are never auto-dispatched.** M-ORCH must
> explicitly confirm the kernel tag before routing to M-KERNEL. Any
> task incorrectly tagged as kernel is re-routed to M-HEAVY.

---

## 3  Escalation Rules

Escalation moves a task from its current slot to a higher-capability slot.
Escalation is **one-way up**; a task never de-escalates mid-execution.

### 3.1  Confidence-based escalation

If M-FAST returns a result with self-reported confidence below
**CONFIDENCE_THRESHOLD** (default: 0.7), the orchestrator re-dispatches to
M-HEAVY.

### 3.2  Complexity triggers

The orchestrator escalates to M-HEAVY when any of these conditions are true:

- Task touches **≥ 4 files** simultaneously.
- Task requires reasoning across **≥ 3 architectural layers**.
- Task is tagged `security` and risk class ≥ 3.
- M-FAST output fails a syntax/correctness check on first attempt.

### 3.3  Dual-vendor escalation (Tier C)

For NAP Class 3+ tasks where the consequence of error is high:

1. M-HEAVY produces the primary output.
2. M-VERIFY independently produces a second output (no access to M-HEAVY's
   result).
3. M-ORCH compares both outputs and applies the **highest-safety-wins**
   conflict resolution rule.
4. If outputs conflict on a safety-relevant dimension, M-ORCH flags the
   task for **human review** (NAP autonomy ceiling A2 applies).

### 3.4  Kernel-critical routing (Tier K)

For any task tagged `kernel-patch`, `bootloader`, `selinux-policy`,
`hal-integration`, or `partition-layout`:

1. M-ORCH validates the kernel tag is correct (not a mislabeled refactor).
2. M-KERNEL (Opus 4.6 or GPT-4o, whichever is available) produces the
   primary output with full reasoning trace.
3. M-VERIFY independently validates the output against known-good
   references (LineageOS device tree, upstream kernel configs).
4. M-ORCH compares both, applies highest-safety-wins.
5. **Human approval is mandatory** — no kernel-critical output is accepted
   without explicit user confirmation.
6. All kernel-critical outputs are logged to `governance/risk_register.md`
   with the task ID and approval status.

**This tier exists only in the Kai-zen-OS repo.** The general NAP
orchestrator template in `references/Nex_Alignment/templates/` does not
include Tier K. See `.gitignore` for exclusion rules.

### 3.5  Front-end escalation

If M-FRONT encounters logic that requires back-end integration reasoning,
it flags the task. M-ORCH splits the task:

- Front-end rendering → stays with M-FRONT.
- Integration logic → dispatched to M-FAST or M-HEAVY per normal rules.

---

## 4  Tier Summary (ADR-0003 alignment)

| Tier | Description | Models Used | NAP Gate |
|------|------------|-------------|----------|
| **A** (cheap/fast) | Default planning, drafting, bulk work | M-FAST | Standard compliance scoring |
| **B** (balanced) | Escalated when confidence or quality insufficient | M-HEAVY, M-FRONT | Manual review band if Class ≥ 3 |
| **C** (high assurance) | Dual-vendor consensus for critical decisions | M-HEAVY + M-VERIFY, arbitrated by M-ORCH | Block/Escalate thresholds from unified governance decision model |
| **K** (kernel-critical) | Core kernel patches — Kai-zen-OS only | M-KERNEL + M-VERIFY, arbitrated by M-ORCH | Mandatory human approval, dual-vendor validation, Class 3+ always |

---

## 5  Orchestrator Responsibilities (M-ORCH)

The orchestrator (Claude opus-class) is the **only** model that:

1. **Routes tasks** to the correct slot based on tags and escalation rules.
2. **Consolidates reports** from sub-agents (Gemini research sweeps,
   NVIDIA verification passes).
3. **Verifies authenticity** of cited sources against
   `governance/source_verification.md`.
4. **Applies NAP governance** — computes or delegates governance scoring per
   the unified governance decision model
   (`runtime/unified_governance_decision_model.md`).
5. **Enforces the autonomy ceiling** — no model may take autonomous action
   beyond A2 without human approval.
6. **Produces the session handoff document** when context must transfer to
   a new agent session.

The orchestrator **does not**:

- Execute leaf implementation tasks.
- Self-approve Class 3+ decisions without human review.
- Override a M-VERIFY safety objection without escalation.

---

## 6  Cost Control

| Principle | Implementation |
|-----------|---------------|
| Fast-model-first | M-FAST handles ≥80% of tasks by volume |
| Escalation-only heavy models | M-HEAVY invoked only on trigger, never as default |
| Batch research sweeps | Gemini 2.5 Flash sub-agents handle large-scale parallel research; results consolidated by M-ORCH |
| Token budget per task | Orchestrator tracks cumulative token spend; warns at 80% of session budget |
| No redundant verification | Tier C dual-vendor is used only for Class 3+ safety-critical decisions, not routine work |

---

## 7  NAP Integration Hooks

This spec operates within the NAP governance envelope defined in
`alignment/kai_zen_nap_alignment.md`:

- **Profile composition**: `infrastructure_devops` (primary) +
  `ai_stack_training_inference` + `security_incident_response`
- **Effective risk floor**: Class 3
- **Autonomy ceiling**: A2
- **Conflict resolution**: highest-safety-wins
- **Required bundles**: B01, B02, B05, B06, B07, B09

### Bundle touchpoints

| Bundle | How this spec satisfies it |
|--------|--------------------------|
| B01 (Core governance) | Tier classification and escalation rules enforce risk-proportionate model selection |
| B02 (Change/data integrity) | Dual-vendor verification (Tier C) provides independent validation before critical changes |
| B06 (Runtime containment) | Orchestrator enforces slot boundaries; no model can self-escalate |
| B07 (Model supply chain) | Model roster is an explicit allowlist; no unlisted model may be invoked |

---

## 8  Continuity Protocol

When a session ends or context transfers to a new agent:

1. M-ORCH writes a **session summary** covering: completed tasks, pending
   tasks, open decisions, current risk register state.
2. The summary references this spec by path so the new agent knows the
   routing rules.
3. The new agent **must** re-read this spec before executing any routed
   task.

This ensures no routing knowledge is lost across agent handoffs.

---

## 9  Modularity: Using This Spec in Other Projects

This file is designed as a **drop-in template**:

1. Copy this file into your project's architecture or governance directory.
2. Update Section 1 (Model Roster) with your actual models and vendors.
3. Update Section 2 (Tag → Slot mapping) for your domain.
4. Update Section 7 (NAP Integration Hooks) with your project's NAP
   profile composition, or remove if not using NAP.
5. Leave Sections 3-6 and 8 unchanged unless your escalation or cost
   policies differ.

The spec is intentionally **vendor-neutral in structure** — the slot names
(M-FAST, M-HEAVY, M-FRONT, M-ORCH, M-VERIFY) are abstract; only the
roster table binds them to concrete models.

---

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2026-02-27 | Initial version — Kai-zen-OS planning baseline | RobinGase / Claude orchestrator session |
| 2026-02-27 | v2: Fixed phantom models (Codex 5.3 → GPT-4o, Gemini 3.1 Pro → Gemini 2.5 Pro), added M-KERNEL tier (Opus 4.6 / GPT-4o) for kernel-critical patches, added Tier K routing, added pricing/status to roster | RobinGase / Claude orchestrator session |
