# Model Provider Investigation (Multi-Vendor Routing)

> **Last updated**: 2026-02-27 (session 2)
> **Status**: Aligned with orchestrator_model_spec.md v2 and ADR-0003

## Objective

Define a vendor-agnostic routing model for autonomous planning and
verification agents. Support cost-controlled tiered routing with
independent cross-vendor verification for safety-critical decisions.

---

## Provider Roster

| Provider | Models used | Role | API style |
|----------|-----------|------|-----------|
| **Google** | Gemini 2.5 Flash, Gemini 2.5 Pro | M-FAST (bulk), M-FRONT (UI) | Google AI Studio / Vertex AI (OpenAI-compatible) |
| **OpenAI** | GPT-4o | M-HEAVY (complex), M-KERNEL (kernel patches) | OpenAI API |
| **Anthropic** | Claude Opus 4 (claude-opus-4-6) | M-ORCH (orchestrator) | Anthropic API |
| **NVIDIA** | Llama 3.1 70B, Nemotron, Mixtral 8x22B (via NIM) | M-VERIFY (independent verification) | NIM (OpenAI-compatible) |

### Provider independence matrix

For Tier C dual-vendor verification, the two models must come from
different training lineages to minimize correlated errors:

| Primary (M-HEAVY) | Verifier (M-VERIFY) | Independence |
|-------------------|---------------------|-------------|
| GPT-4o (OpenAI) | Llama 3.1 70B (Meta via NVIDIA) | High — different vendor, different training |
| GPT-4o (OpenAI) | Nemotron (NVIDIA) | High — different vendor, NVIDIA-trained |
| GPT-4o (OpenAI) | Mixtral 8x22B (Mistral via NVIDIA) | High — different vendor, different architecture |

---

## Gemini 2.5 Flash (M-FAST)

- **Role**: Default Tier-A planner model (fast-first)
- **Pricing**: $0.15/1M input tokens, $0.60/1M output tokens
- **Context**: 1,048,576 tokens (1M)
- **Strengths**: Cheapest in roster, largest context, structured output, function calling
- **Use for**: first-pass synthesis, classification, test generation, assessments, wiring
- **Escalate when**: confidence < 0.7 or task complexity triggers fire
- **Full assessment**: `Docs/research/gemini_2_5_flash_investigation.md`

## Gemini 2.5 Pro (M-FRONT)

- **Role**: Front-end and UI work
- **Pricing**: $1.25/1M input tokens
- **Context**: 1,048,576 tokens (1M)
- **Strengths**: Strong at design reasoning, long context for full-page analysis
- **Use for**: UI components, styling, accessibility, client-side logic

## GPT-4o (M-HEAVY, M-KERNEL)

- **Role**: Complex reasoning, security analysis, kernel-critical patches
- **Pricing**: $2.50/1M input tokens, $10.00/1M output tokens
- **Context**: 128,000 tokens
- **Strengths**: Strong multi-file reasoning, code generation, architecture analysis
- **Use for**: refactors, novel algorithms, security, kernel patches
- **Kernel note**: When used as M-KERNEL, requires mandatory human approval
  and M-VERIFY independent validation

## Claude Opus 4 (M-ORCH)

- **Role**: Orchestrator — routes tasks, consolidates reports, enforces governance
- **Pricing**: $15/1M input, $75/1M output
- **Context**: 200,000 tokens
- **Strengths**: Best at long-context synthesis, governance reasoning, careful analysis
- **Use for**: routing decisions, report consolidation, authenticity verification
- **Never used for**: leaf implementation tasks

## NVIDIA NIM (M-VERIFY)

- **Role**: Independent verification of critical decisions
- **Primary model**: Llama 3.1 70B Instruct
- **Fallback**: Mixtral 8x22B Instruct
- **High-assurance**: Nemotron-4-340B for Tier C
- **API**: OpenAI-compatible (`https://integrate.api.nvidia.com/v1`)
- **Use for**: cross-vendor consensus on Class 3+ decisions
- **Full assessment**: `Docs/research/nvidia_api_investigation.md`

---

## Routing Policy (mirrors ADR-0003 and orchestrator_model_spec.md)

### Tier A (cheap/fast) — ≥80% of tasks

- Primary: Gemini 2.5 Flash (M-FAST)
- Use for: first-pass planning, summarization, classification, tests, mocks
- NAP gate: standard compliance scoring

### Tier B (balanced) — ~15% of tasks

- Primary: GPT-4o (M-HEAVY) or Gemini 2.5 Pro (M-FRONT)
- Use for: escalated complex tasks, front-end work
- NAP gate: manual review band if Class ≥ 3

### Tier C (high-assurance) — ~5% of tasks

- Primary: GPT-4o (M-HEAVY)
- Verifier: NVIDIA NIM Llama 3.1 70B (M-VERIFY)
- Arbitrator: Claude Opus 4 (M-ORCH)
- Use for: dual-vendor consensus on critical decisions
- NAP gate: block/escalate thresholds

### Tier K (kernel-critical) — rare, Kai-zen-OS only

- Primary: Claude Opus 4 or GPT-4o (M-KERNEL)
- Verifier: NVIDIA NIM (M-VERIFY)
- Arbitrator: Claude Opus 4 (M-ORCH) + mandatory human approval
- Use for: device tree, bootloader, SELinux, HAL, partition layout

---

## Verification Rules

1. Any claim affecting flash safety must be validated by at least two
   independent evidence paths (Tier C minimum).
2. Unsupported parameters/models must fail closed.
3. No secrets in prompts or repository artifacts.
4. Every routed task logs: task ID, slot, model, tokens, latency, confidence.
5. Model roster is a strict allowlist — no unlisted model may be invoked.

## Sources

- Gemini: https://ai.google.dev/gemini-api/docs/models#gemini-2.5-flash
- Gemini pricing: https://ai.google.dev/gemini-api/docs/pricing
- Vertex AI: https://cloud.google.com/vertex-ai/generative-ai/docs/migrate/openai/overview
- NVIDIA NIM: https://docs.api.nvidia.com/nim/reference/create_chat_completion_v1_chat_completions_post
- NVIDIA models: https://docs.api.nvidia.com/nim/reference/models-1
- OpenAI GPT-4o: https://platform.openai.com/docs/models/gpt-4o
