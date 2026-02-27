# Subagent Research Digest

> **Last updated**: 2026-02-27 (session 2)

## Methodology

Research was conducted across two Claude Opus orchestrator sessions using
the following approach:

1. **Parallel research streams**: Multiple sub-agent tasks dispatched
   simultaneously, each focused on one domain (Redox, Samsung, frameworks,
   model providers).
2. **Source-first**: Each stream started by fetching and reading official
   vendor/project documentation before forming conclusions.
3. **Cross-check**: Key claims verified against at least two independent
   sources. Discrepancies flagged in source verification log.
4. **Confidence labeling**: Each claim tagged High / Medium / Low per the
   method in `Docs/governance/source_verification.md`.

### Agent configuration

| Stream | Agent type | Model slot | Depth |
|--------|-----------|------------|-------|
| Redox assessment | explore (very thorough) | M-ORCH | Deep — read FAQ, porting strategy, hardware table |
| Samsung matrix | explore (very thorough) | M-ORCH | Deep — read LineageOS wiki, Knox docs, Heimdall |
| Gemini investigation | general | M-ORCH | Medium — read model docs, pricing, rate limits |
| NVIDIA investigation | general | M-ORCH | Medium — read NIM API docs, model catalog |
| Framework comparison | explore (medium) | M-ORCH | Medium — read Rig and llm-chain docs |
| Full doc review | general | M-ORCH | Very thorough — read all 22 files, cross-reference |

---

## Consolidated Outcomes

### Stream 1: Redox Microkernel

- **Verdict**: R&D value only, not viable for Samsung targets
- **Confidence**: High (based on official Redox sources)
- **Key finding**: No ARM64 support, no Android HAL, no cellular baseband
- **Design patterns extracted**: capability-based security, microkernel
  message-passing, Rust memory safety

### Stream 2: Samsung Platform Matrix

- **Verdict**: S10+ (Exynos, SM-G975F) is the only high-confidence baseline
- **Confidence**: High for S10 family, Medium for S20, Low for S21-S24
- **Key finding**: Exynos vs Snapdragon is the critical split; US
  Snapdragon models are do-not-attempt
- **Disagreement**: Some XDA threads claim S23 bootloader unlock is possible
  in certain regions, but no official confirmation found. Kept as
  low-confidence / research-only.

### Stream 3: Model Providers & Orchestration

- **Verdict**: Tiered routing with Gemini 2.5 Flash (fast), GPT-4o (heavy),
  NVIDIA NIM (verify), Claude Opus 4 (orchestrate)
- **Confidence**: High for Gemini and NVIDIA API compatibility; Medium for
  Rig framework maturity
- **Key finding**: Initial orchestrator spec contained two phantom models
  (Codex 5.3, Gemini 3.1 Pro). Fixed in session 2 review.
- **Disagreement**: Whether Rig's pre-1.0 status is acceptable risk.
  Decision: accept with version pinning and MIT fork option.

### Stream 4: Full Documentation Review (Session 2)

- **Verdict**: 22 files reviewed, 8 cross-cutting issues identified
- **Key findings**:
  - Phantom models in orchestrator spec (fixed)
  - ADRs lacked standard format (fixed)
  - Research stubs too thin (expanded to 60-200+ lines each)
  - Risk register underweight (expanded 9 → 15 risks)
  - Samsung matrix missing Exynos/Snapdragon distinction (fixed)
  - Rollback plan artifact missing (still needed)

---

## Evidence Handling

- All high-confidence claims cross-checked with official/vendor/project docs
- Source verification log updated with access dates and claim mappings:
  `Docs/governance/source_verification.md`
- Claims with weaker source quality explicitly marked lower confidence
- Phantom model issue caught during review stream and corrected immediately

## Open Questions

1. Is Rig's pre-1.0 API stable enough to build on? (accepted risk with pin)
2. What is ZeroClaw's architecture? (needs owner input — not in any public docs)
3. Are any S21+ Exynos variants viable for pilot? (research-only, needs deeper XDA analysis)
