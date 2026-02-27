# ADR-0003: Model Routing Policy

## Metadata

- **Date**: 2026-02-27
- **Status**: Accepted (planning baseline)
- **Deciders**: RobinGase (owner), Claude orchestrator (advisory)
- **Review date**: Re-evaluate when first live API integration is attempted
- **Related risks**: R-07 (cost explosion), R-10 (AI hallucination)
- **Implementation**: `Docs/architecture/orchestrator_model_spec.md`

## Context

Kai-zen-OS uses AI models for planning, research synthesis, code
generation, and safety validation. Different tasks have different
requirements:

- **Bulk work** (test generation, doc parsing, assessment): needs speed
  and low cost, not maximum intelligence.
- **Complex reasoning** (architecture design, security analysis, multi-file
  refactors): needs higher capability, willing to pay more.
- **Front-end work** (UI, styling, accessibility): needs design awareness
  and long context, moderate cost.
- **Kernel-critical patches** (device tree, bootloader, SELinux): needs
  maximum capability and mandatory dual validation.
- **Cross-vendor verification**: needs independence from the primary model
  vendor to avoid correlated errors.

Single-model approaches either waste money on simple tasks or produce
low-quality results on complex ones. Single-vendor approaches create
correlated failure risk on safety-critical decisions.

## Decision

Adopt **tiered model routing** with independent-vendor verification:

- **Tier A** (cheap/fast): Gemini 2.5 Flash — default for ≥80% of tasks
- **Tier B** (balanced): GPT-4o or Gemini 2.5 Pro — escalate when
  confidence or quality is insufficient
- **Tier C** (high assurance): dual-vendor consensus (GPT-4o + NVIDIA NIM)
  for critical decisions, arbitrated by orchestrator
- **Tier K** (kernel-critical): Opus 4.6 or GPT-4o with mandatory human
  approval and independent verification — Kai-zen-OS repo only

All routing goes through a provider-agnostic adapter layer. The
orchestrator (Claude Opus 4) controls routing; no model self-selects
its tier.

**Model allowlist** (only these models may be invoked):

| Slot | Model | Vendor |
|------|-------|--------|
| M-FAST | Gemini 2.5 Flash | Google |
| M-HEAVY | GPT-4o | OpenAI |
| M-FRONT | Gemini 2.5 Pro | Google |
| M-ORCH | Claude Opus 4 (claude-opus-4-6) | Anthropic |
| M-VERIFY | Llama 3.1 70B / Nemotron (NIM) | NVIDIA |
| M-KERNEL | Claude Opus 4 OR GPT-4o | Anthropic / OpenAI |

No model outside this allowlist may be invoked without updating this
ADR and the orchestrator spec.

## Alternatives Considered

1. **Single model for everything (Claude only)**:
   Rejected — too expensive for bulk tasks, creates single-vendor
   dependency, no independent verification capability.

2. **Two-tier only (fast + heavy)**:
   Rejected — front-end and kernel-critical work have distinct
   requirements that don't map cleanly to a cost-only split.

3. **Self-selecting models (let each model decide if it can handle the
   task)**:
   Rejected — models are poor judges of their own limitations. External
   routing based on task metadata is more reliable.

4. **Open-source only (Llama, Mistral everywhere)**:
   Rejected — current open-source models don't match proprietary models
   on the complex reasoning tasks this project requires. NVIDIA NIM
   provides open-source models for the verification role where
   independence matters more than peak capability.

## Consequences

### Positive
- Cost controlled: fast model handles bulk, heavy models invoked only
  when needed.
- Single-vendor bias mitigated on safety-critical decisions.
- Explicit allowlist prevents model sprawl.
- Kernel-critical tier provides maximum safety for the most dangerous
  operations.

### Negative
- Requires routing logic and metadata tagging for every task.
- Requires API access to multiple vendors (Google, OpenAI, NVIDIA,
  Anthropic).
- Model pricing and availability may change, requiring roster updates.
- Confidence-based escalation depends on self-reported model confidence,
  which is an imperfect signal.

## Observability Requirements

- Every routed task must log: task ID, assigned slot, model used,
  token count, latency, confidence score (if available).
- Tier C decisions must log both model outputs and the arbitration
  reasoning.
- Tier K decisions must log human approval status and approver identity.
