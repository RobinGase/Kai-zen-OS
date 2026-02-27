# Gemini 2.5 Flash Investigation Report

## Scope

Assess Gemini 2.5 Flash for the M-FAST slot in Kai-zen-OS's orchestrator
model spec: high-volume, low-cost work including tests, mocks, readings,
assessments, logging, heartbeat checks, syntax audits, and wiring tasks.

## Model Identity

- **Full name**: Gemini 2.5 Flash
- **Vendor**: Google (DeepMind)
- **API access**: Google AI Studio (direct) or Vertex AI (enterprise)
- **OpenAI compatibility**: Vertex AI supports OpenAI-compatible
  chat-completions endpoint via `google-genai` SDK or REST adapter
- **Release status**: Generally Available as of Q1 2026

## Capabilities Assessment

### Context window

- **1,048,576 tokens** (1M) input context
- This is the largest context window of any model in our roster
- Enables processing entire codebases, long research documents, and
  multi-file analysis in a single call
- Source: https://ai.google.dev/gemini-api/docs/models#gemini-2.5-flash

### Pricing (as of Q1 2026, Google AI Studio)

- **Input**: $0.15 per 1M tokens (prompts ≤ 200K tokens)
- **Input (long context)**: $0.30 per 1M tokens (prompts > 200K tokens)
- **Output**: $0.60 per 1M tokens (non-thinking)
- **Output (thinking)**: $3.50 per 1M tokens
- **Cached input**: $0.0375 per 1M tokens
- This makes Gemini 2.5 Flash approximately **16x cheaper** than GPT-4o
  for input tokens, supporting the fast-model-first cost strategy
- Source: https://ai.google.dev/gemini-api/docs/pricing

### Structured output

- Native JSON mode and function calling support
- Schema enforcement available via `response_schema` parameter
- Critical for our use case: task metadata, confidence scores, and
  routing decisions must be machine-parseable

### Function calling

- Supports tool/function definitions with JSON schema
- Parallel function calling supported
- Enables agent-style workflows where the model invokes external tools

### Reasoning capability

- Gemini 2.5 Flash includes a "thinking" mode for complex reasoning
- Thinking tokens are billed at higher rate ($3.50/1M output)
- For our Tier A (M-FAST) usage, thinking mode should be **disabled by
  default** to control costs, enabled only when confidence drops below
  CONFIDENCE_THRESHOLD (0.7)

## Rate Limits

- **Free tier**: 10 RPM, 250K TPM, 500 RPD
- **Pay-as-you-go Tier 1**: 2,000 RPM, 4M TPM
- **Vertex AI**: higher limits, negotiable with quota increases
- For planning-phase usage, free tier is likely sufficient; production
  orchestration will need Tier 1 or Vertex AI
- Source: https://ai.google.dev/gemini-api/docs/rate-limits

## Benchmarks (where available)

- Strong performance on code generation tasks (competitive with larger models)
- Multimodal capability (text, image, audio, video) — relevant for
  future screenshot-based UI validation
- Specific benchmark numbers vary by evaluation; we rely on Google's
  published model card rather than third-party benchmarks

## Comparison to Alternatives

| Model | Input cost/1M | Context | Strengths | Why not M-FAST? |
|-------|--------------|---------|-----------|----------------|
| Gemini 2.5 Flash | $0.15 | 1M | Cheapest, largest context, structured output | **Selected** |
| Claude 3.5 Haiku | $0.80 | 200K | Fast, good at code | 5x more expensive, smaller context |
| GPT-4o-mini | $0.15 | 128K | Same price tier | Much smaller context (128K vs 1M) |
| Llama 3.1 8B (NIM) | ~$0.10 | 128K | Cheapest option | Lower capability for assessment tasks |

## Recommended Configuration for Kai-zen-OS

```yaml
slot: M-FAST
model: gemini-2.5-flash
provider: google-ai-studio  # or vertex-ai for production
temperature: 0.1  # low temperature for deterministic planning tasks
thinking_mode: disabled  # enable only on escalation
response_format: json  # enforce structured output
max_output_tokens: 8192  # cap per-task output
```

## Guardrails

1. **Schema validation**: enforce JSON schema on all structured outputs;
   reject and retry on schema violation.
2. **No destructive recommendations**: M-FAST output may suggest actions
   but never issues commands. Any destructive-action recommendation must
   be escalated to M-HEAVY or M-KERNEL.
3. **Budget accounting**: track token usage per task; alert at 80% of
   per-task budget (default: 50K input + 8K output tokens per task).
4. **Confidence reporting**: require M-FAST to include a `confidence`
   field (0.0-1.0) in structured output. Below 0.7 triggers escalation.
5. **No secrets in prompts**: sanitize all inputs before sending to
   external API.

## Risks

- **Vendor lock-in**: Gemini API is Google-specific. Mitigation: use
  OpenAI-compatible endpoint via Vertex AI adapter for portability.
- **Pricing changes**: Google may change pricing. Mitigation: budget
  monitoring with automatic alerts; GPT-4o-mini as fallback.
- **Quality variance**: Flash models trade capability for speed.
  Mitigation: confidence-based escalation catches low-quality outputs.

## Sources

- Model overview: https://ai.google.dev/gemini-api/docs/models#gemini-2.5-flash
- Pricing: https://ai.google.dev/gemini-api/docs/pricing
- Rate limits: https://ai.google.dev/gemini-api/docs/rate-limits
- Vertex AI OpenAI compatibility: https://cloud.google.com/vertex-ai/generative-ai/docs/migrate/openai/overview
- Function calling: https://ai.google.dev/gemini-api/docs/function-calling
