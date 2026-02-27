# NVIDIA API Investigation Report

## Scope

Assess NVIDIA NIM (NVIDIA Inference Microservice) API for the M-VERIFY
slot in Kai-zen-OS's orchestrator model spec: independent cross-vendor
verification of safety-critical decisions.

## Platform Identity

- **Service name**: NVIDIA NIM
- **API style**: OpenAI-compatible chat completions endpoint
- **Base URL**: `https://integrate.api.nvidia.com/v1`
- **Authentication**: API key via `Authorization: Bearer` header
- **Release status**: Generally Available

## Available Models (Relevant to Kai-zen-OS)

NVIDIA NIM hosts a large catalog of models. The following are relevant
for our M-VERIFY verification role:

### Primary candidates

| Model | Parameters | Context | Strengths | Recommended for |
|-------|-----------|---------|-----------|----------------|
| **Llama 3.1 70B Instruct** | 70B | 128K | Strong reasoning, open-weight, independent from Google/OpenAI | Primary M-VERIFY model |
| **Nemotron-4-340B-Instruct** | 340B | 4K | NVIDIA's own model, highest capability | Tier C high-assurance verification |
| **Mixtral 8x22B Instruct** | 141B MoE | 65K | Good reasoning, efficient via MoE | Alternative M-VERIFY |

### Why these models?

The M-VERIFY slot requires **vendor independence** from M-FAST (Google)
and M-HEAVY (OpenAI). NVIDIA-hosted open-weight models (Meta's Llama,
Mistral's Mixtral) provide this independence because:

1. Different training data and methodology than Gemini or GPT
2. Different failure modes and biases
3. Correlated errors between M-HEAVY and M-VERIFY are minimized

## API Integration

### Endpoint compatibility

NVIDIA NIM uses the OpenAI chat completions format:

```
POST https://integrate.api.nvidia.com/v1/chat/completions
Headers:
  Authorization: Bearer $NVIDIA_API_KEY
  Content-Type: application/json

Body:
{
  "model": "meta/llama-3.1-70b-instruct",
  "messages": [...],
  "temperature": 0.1,
  "max_tokens": 4096
}
```

This means any OpenAI-compatible client library (including Rig's OpenAI
provider) can connect to NVIDIA NIM by changing the base URL and model
name. No custom integration code required.

### Authentication

- API key obtained from https://build.nvidia.com
- Free tier: limited credits for evaluation
- Paid tier: usage-based pricing
- **No API key stored in repo** — must be injected via environment
  variable at runtime

## Pricing

NVIDIA NIM pricing is model-dependent and usage-based. As of Q1 2026:

- **Llama 3.1 70B**: approximately $0.30-$0.60 per 1M tokens (varies
  by plan)
- **Nemotron-4-340B**: higher cost, approximately $2-4 per 1M tokens
- **Free evaluation credits**: available for initial testing

Exact pricing should be confirmed at https://build.nvidia.com before
production commitment.

## Rate Limits

- Free tier: limited RPM (typically 5-10 RPM)
- Paid tier: higher limits, negotiable
- For our Tier C usage (verification only, not bulk), even low rate
  limits are sufficient — M-VERIFY is invoked only for Class 3+
  decisions, estimated at <10% of total task volume

## Comparison to Alternative Verification Approaches

| Approach | Independence | Cost | Capability | Selected? |
|----------|-------------|------|------------|-----------|
| NVIDIA NIM (Llama/Nemotron) | High (different vendor + different model family) | Moderate | Strong | **Yes** |
| Self-hosted Llama via Ollama | High (local, no API dependency) | Low (compute only) | Limited by local hardware | Future option for offline work |
| AWS Bedrock (Anthropic/Cohere) | Medium (different platform, some model overlap) | Moderate | Strong | Not evaluated — adds vendor complexity |
| Azure OpenAI | Low (same models as M-HEAVY) | Similar to OpenAI | Same as M-HEAVY | Rejected — correlated errors |

## Recommended Configuration for Kai-zen-OS

```yaml
slot: M-VERIFY
model: meta/llama-3.1-70b-instruct  # primary
fallback_model: mistralai/mixtral-8x22b-instruct-v0.1
provider: nvidia-nim
base_url: https://integrate.api.nvidia.com/v1
temperature: 0.1
max_tokens: 4096
# For Tier C: M-VERIFY must NOT see M-HEAVY's output
# Orchestrator sends the original task, not M-HEAVY's response
isolation: true
```

## Guardrails

1. **Model allowlist**: only models listed in this document may be used
   via NVIDIA NIM. No automatic model selection.
2. **Model ID logging**: every verification call logs the exact model ID
   and response metadata for audit trail.
3. **Fail-closed**: if NVIDIA NIM is unreachable or returns an error,
   the verification step fails and the task is blocked (not auto-approved).
4. **Isolation**: M-VERIFY must receive the original task prompt, never
   M-HEAVY's output. The orchestrator enforces this isolation to prevent
   anchoring bias.
5. **No secrets in prompts**: same sanitization rules as M-FAST.

## Risks

- **API availability**: NVIDIA NIM is a cloud service; outages block
  Tier C verification. Mitigation: fail-closed behavior + self-hosted
  Llama as future fallback.
- **Model catalog changes**: NVIDIA may deprecate models. Mitigation:
  pin to specific model versions in config; monitor deprecation notices.
- **Free tier limitations**: evaluation credits may expire. Mitigation:
  budget for paid tier before Tier C becomes critical path.

## Sources

- NIM API reference: https://docs.api.nvidia.com/nim/reference/create_chat_completion_v1_chat_completions_post
- NIM model catalog: https://docs.api.nvidia.com/nim/reference/models-1
- NVIDIA Build portal: https://build.nvidia.com
- Llama 3.1 model card: https://ai.meta.com/blog/meta-llama-3-1/
- Nemotron: https://developer.nvidia.com/nemotron
