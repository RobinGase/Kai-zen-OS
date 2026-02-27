# Model Provider Investigation (Gemini + NVIDIA)

## Objective

Define a vendor-agnostic routing model for autonomous planning and verification agents.

## Gemini 2.5 Flash (planning fit)

- Strong price/performance positioning for fast-first routing.
- Large context window and structured/function features suitable for planning pipelines.
- Can be used through Vertex AI and OpenAI-compatible chat-completions path.

## NVIDIA API (planning fit)

- OpenAI-compatible chat endpoint documented.
- Broad model catalog enables secondary/independent verification paths.
- Useful as independent vendor in consensus loops.

## Proposed Routing Policy

## Tier A (cheap/fast)

- Primary: Gemini 2.5 Flash
- Secondary: Small/fast NVIDIA endpoint model
- Use for first-pass planning, summarization, and classification

## Tier B (balanced)

- Larger model on either vendor for difficult planning synthesis

## Tier C (high-assurance)

- Dual-vendor agreement required on critical decisions
- Tie-break by judge model + deterministic policy checks

## Verification Rules

- Any claim affecting flash safety must be validated by at least two independent evidence paths.
- Unsupported parameters/models must fail closed.
- No secrets in prompts or repository artifacts.

## Sources

- https://cloud.google.com/vertex-ai/generative-ai/docs/models/gemini/2-5-flash
- https://docs.cloud.google.com/vertex-ai/generative-ai/docs/migrate/openai/overview
- https://docs.api.nvidia.com/nim/reference/create_chat_completion_v1_chat_completions_post
- https://docs.api.nvidia.com/nim/reference/models-1
