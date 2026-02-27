# Source Verification and Authenticity Log

> **Last verified**: 2026-02-27
> **Next scheduled refresh**: 2026-03-27

## Method

Claims are labeled by source quality:

- **High confidence**: official project/vendor docs or primary repos.
  URLs verified accessible. Content cross-checked against project README
  or official announcements.
- **Medium confidence**: strong community sources with cross-checks.
  At least two independent references agree.
- **Low confidence**: community-only, fast-moving, or unverified in
  current session. Marked as research-only in planning docs.

---

## High-Confidence Sources

### Orchestration Frameworks

| Source | URL | Last verified | Used in |
|--------|-----|---------------|---------|
| Rig docs | https://docs.rig.rs/docs | 2026-02-27 | framework_stack_rig_llm_chain.md |
| Rig agents | https://docs.rig.rs/docs/concepts/agent | 2026-02-27 | framework_stack_rig_llm_chain.md |
| Rig chains | https://docs.rig.rs/docs/concepts/chains | 2026-02-27 | framework_stack_rig_llm_chain.md |
| Rig observability | https://docs.rig.rs/docs/concepts/observability | 2026-02-27 | framework_stack_rig_llm_chain.md |
| Rig crate (crates.io) | https://crates.io/crates/rig-core | 2026-02-27 | framework_stack_rig_llm_chain.md |
| llm-chain docs | https://docs.llm-chain.xyz/docs/introduction/ | 2026-02-27 | framework_stack_rig_llm_chain.md |
| llm-chain chains | https://docs.llm-chain.xyz/docs/chains/what-are-chains | 2026-02-27 | framework_stack_rig_llm_chain.md |
| llm-chain crate | https://docs.rs/llm-chain/latest/llm_chain/ | 2026-02-27 | framework_stack_rig_llm_chain.md |

### AI Model Providers

| Source | URL | Last verified | Used in |
|--------|-----|---------------|---------|
| Gemini 2.5 Flash model page | https://ai.google.dev/gemini-api/docs/models#gemini-2.5-flash | 2026-02-27 | gemini_2_5_flash_investigation.md |
| Gemini pricing | https://ai.google.dev/gemini-api/docs/pricing | 2026-02-27 | gemini_2_5_flash_investigation.md |
| Gemini rate limits | https://ai.google.dev/gemini-api/docs/rate-limits | 2026-02-27 | gemini_2_5_flash_investigation.md |
| Gemini function calling | https://ai.google.dev/gemini-api/docs/function-calling | 2026-02-27 | gemini_2_5_flash_investigation.md |
| Vertex AI OpenAI compat | https://cloud.google.com/vertex-ai/generative-ai/docs/migrate/openai/overview | 2026-02-27 | gemini_2_5_flash_investigation.md, model_provider_investigation.md |
| NVIDIA NIM chat endpoint | https://docs.api.nvidia.com/nim/reference/create_chat_completion_v1_chat_completions_post | 2026-02-27 | nvidia_api_investigation.md |
| NVIDIA NIM model catalog | https://docs.api.nvidia.com/nim/reference/models-1 | 2026-02-27 | nvidia_api_investigation.md |
| NVIDIA Build portal | https://build.nvidia.com | 2026-02-27 | nvidia_api_investigation.md |
| Llama 3.1 model card | https://ai.meta.com/blog/meta-llama-3-1/ | 2026-02-27 | nvidia_api_investigation.md |
| NVIDIA Nemotron | https://developer.nvidia.com/nemotron | 2026-02-27 | nvidia_api_investigation.md |

### Samsung / Android

| Source | URL | Last verified | Used in |
|--------|-----|---------------|---------|
| LineageOS S10+ install | https://wiki.lineageos.org/devices/beyond2lte/install/ | 2026-02-27 | samsung_device_support_matrix.md |
| LineageOS S10+ device page | https://wiki.lineageos.org/devices/beyond2lte/ | 2026-02-27 | samsung_device_support_matrix.md |
| LineageOS device index | https://wiki.lineageos.org/devices/ | 2026-02-27 | samsung_device_support_matrix.md |
| Heimdall README | https://raw.githubusercontent.com/Benjamin-Dobell/Heimdall/master/README.md | 2026-02-27 | samsung_device_support_matrix.md |
| Samsung Knox security | https://docs.samsungknox.com/admin/fundamentals/whitepaper/samsung-knox-mobile-security/system-security/hw-backed-security/ | 2026-02-27 | samsung_device_support_matrix.md, ADR-0001 |
| AVB reference | https://github.com/AndroidBootloader/platform_external_avb | 2026-02-27 | samsung_device_support_matrix.md |

### Redox OS

| Source | URL | Last verified | Used in |
|--------|-----|---------------|---------|
| Redox FAQ | https://www.redox-os.org/faq/ | 2026-02-27 | redox_microkernel_assessment.md |
| Redox porting strategy | https://www.redox-os.org/news/porting-strategy/ | 2026-02-27 | redox_microkernel_assessment.md |
| Redox hardware table | https://gitlab.redox-os.org/redox-os/redox/-/raw/master/HARDWARE.md | 2026-02-27 | redox_microkernel_assessment.md |

### Testing / Remote Control

| Source | URL | Last verified | Used in |
|--------|-----|---------------|---------|
| Appium docs | https://appium.io/docs/en/latest/ | 2026-02-27 | remote_control_setup.md |
| scrcpy repo | https://github.com/Genymobile/scrcpy | 2026-02-27 | remote_control_setup.md |

### Governance

| Source | URL | Last verified | Used in |
|--------|-----|---------------|---------|
| Nex Alignment repo | https://github.com/RobinGase/Nex_Alignment | 2026-02-27 | kai_zen_nap_alignment.md, nap_glossary.md |

---

## Medium-Confidence Sources

| Source | URL | Notes | Used in |
|--------|-----|-------|---------|
| XDA S23 Ultra forum | https://xdaforums.com/f/samsung-galaxy-s23-ultra.12713/ | Community threads, need per-post evaluation | samsung_device_support_matrix.md |
| XDA S24 Ultra forum | https://xdaforums.com/f/samsung-galaxy-s24-ultra.12819/ | Community threads, very early | samsung_device_support_matrix.md |

---

## Low-Confidence Sources

| Claim | Status | Notes |
|-------|--------|-------|
| S23/S24 bootloader unlock varies by region | Unverified in current session | Based on XDA thread patterns, not confirmed per-model |
| Exynos 2200 GPU issues affecting S22 ROMs | Unverified | Reported in XDA, needs specific thread citation |
| NVIDIA NIM pricing for Llama 3.1 70B | Approximate | Based on build.nvidia.com estimates, not contractual |

---

## Integrity Rules

1. **No claim without URL reference.** Every factual assertion in a
   research or planning document must link to an entry in this log.
2. **Any destructive operation requires two-source confirmation.** Flash
   procedures must cite at least two independent high-confidence sources.
3. **If source confidence is low, mark feature as research-only.** No
   low-confidence claim may drive a pilot decision.
4. **Model roster verification.** Every model in the orchestrator spec
   allowlist must have a vendor documentation URL in this log. No
   phantom models.
5. **Monthly refresh.** All high-confidence URLs are re-verified monthly.
   Dead links are flagged and dependent claims are downgraded.
