# Risk Register

> **Last reviewed**: 2026-02-27
> **Review cadence**: Weekly during planning; immediately after any ADR update
> **Owner**: RobinGase

---

## R-01: Model-level support confusion

- **Risk**: Generalizing Samsung support by marketing name (e.g., "S23")
  instead of exact model number leads to attempting flash on unsupported
  variant
- **Likelihood**: High
- **Impact**: Critical — could brick device or trigger Knox lockout
- **Status**: Open — mitigated by policy
- **Mitigation**: Require exact model/region/carrier/SoC mapping before
  any pilot. Hard rule in `samsung_device_support_matrix.md`.
- **Residual risk**: Someone may bypass the matrix check under time pressure
- **Owner**: Platform

## R-02: Bootloader unlock unavailable

- **Risk**: Target device variant has OEM unlock disabled by carrier
  firmware (common on US Snapdragon models) or is permanently locked
- **Likelihood**: High (for US variants), Low (for Exynos international)
- **Impact**: Critical — custom image cannot be installed at all
- **Status**: Open — mitigated by device selection
- **Mitigation**: Baseline device (SM-G975F) is Exynos international
  with confirmed bootloader unlock. US Snapdragon variants are on
  do-not-attempt list. Pre-flight checklist verifies unlock status.
- **Residual risk**: A specific Exynos variant may have carrier lock
  in certain markets
- **Owner**: Platform

## R-03: Irreversible anti-tamper lockout

- **Risk**: Flash operation trips Knox counter, burns rollback fuses,
  or corrupts AVB metadata, leaving device in unrecoverable state
- **Likelihood**: Medium
- **Impact**: Critical — device may be permanently bricked
- **Status**: Open — mitigated by safety boundary (ADR-0001)
- **Mitigation**: No flash commands in planning phase. Rollback plan
  required before Phase 4 entry. Knox counter status recorded pre-flash.
  Stock firmware restore path documented.
- **Residual risk**: Even documented rollback may fail on hardware
  defects or previously-unknown fuse state
- **Owner**: Platform

## R-04: OAuth/provider path unstable

- **Risk**: ZeroClaw API on S10+ has zero active providers and unstable
  OAuth flow, blocking autonomous agent integration
- **Likelihood**: High (currently observed)
- **Impact**: High — orchestration pipeline cannot function without
  working provider connections
- **Status**: Open — active investigation
- **Mitigation**: Emulator-based testing with mock providers first.
  Debug OAuth flow in isolated environment before device testing.
  Provider health checks in orchestration pipeline.
- **Residual risk**: OAuth instability may be fundamental to the
  ZeroClaw architecture
- **Owner**: Runtime

## R-05: Over-automation causes unsafe operations

- **Risk**: AI agent executes destructive command (flash, partition
  write, bootloader modify) without human approval
- **Likelihood**: Medium
- **Impact**: Critical — irreversible device damage
- **Status**: Open — mitigated by design
- **Mitigation**: ADR-0001 safety boundary. NAP A2 autonomy ceiling.
  No destructive commands in codebase. Orchestrator model spec
  requires human approval for all Tier K operations.
- **Residual risk**: A misconfigured agent could bypass safety checks
  if the enforcement layer has bugs
- **Owner**: Governance

## R-06: Source quality drift

- **Risk**: Research citations become stale (dead links, outdated
  information) and decisions based on them become incorrect
- **Likelihood**: Medium
- **Impact**: High — could lead to incorrect flash procedures or
  incompatible configurations
- **Status**: Open — mitigated by process
- **Mitigation**: Confidence labels on all claims. Source verification
  log with access dates. Scheduled source refresh (monthly).
- **Residual risk**: Refresh may miss changes between check intervals
- **Owner**: Research

## R-07: Cost explosion in model usage

- **Risk**: Uncontrolled AI model API calls accumulate unexpected costs,
  especially if Tier C dual-vendor verification is overused
- **Likelihood**: Medium
- **Impact**: High — project becomes financially unsustainable
- **Status**: Open — mitigated by design
- **Mitigation**: Fast-model-first policy (M-FAST handles ≥80% of
  tasks). Per-task token budgets. Tier C restricted to Class 3+
  decisions only. Budget monitoring with 80% alerts.
- **Residual risk**: A runaway loop in the orchestration pipeline
  could burn through budget before alerts trigger
- **Owner**: AI Ops

## R-08: Secret leakage into repo/logs

- **Risk**: API keys, OAuth tokens, device unlock codes, or signing
  keys accidentally committed to git or exposed in logs
- **Likelihood**: Medium
- **Impact**: Critical — compromised credentials, potential device
  takeover
- **Status**: Open — mitigated by policy
- **Mitigation**: .gitignore excludes credential paths. .env files
  excluded. No-secrets policy in ADR-0001. All prompts sanitized
  before sending to external APIs. Log masking for sensitive patterns.
- **Residual risk**: A new file type not covered by .gitignore could
  contain secrets
- **Owner**: Governance

## R-09: NAP alignment drift

- **Risk**: Planning decisions gradually exceed the NAP governance
  envelope (Class 3 floor, A2 ceiling) without formal override
- **Likelihood**: Medium
- **Impact**: High — governance becomes decorative rather than
  functional
- **Status**: Open — mitigated by process
- **Mitigation**: Decision router checklist. ADR updates required for
  major changes. Profile declaration checks. NAP glossary for team
  education.
- **Residual risk**: Pressure to move fast may cause informal
  bypassing of governance checks
- **Owner**: Governance

## R-10: AI hallucination in recommendations

- **Risk**: AI model produces plausible-sounding but incorrect
  recommendations about flash procedures, partition layouts, or
  device compatibility, leading to device damage if followed
- **Likelihood**: High (inherent to current LLM technology)
- **Impact**: Critical — incorrect flash procedure could brick device
- **Status**: Open — mitigated by design
- **Mitigation**: Tier C dual-vendor verification for critical
  decisions. All claims require source citation. Source verification
  log cross-checks AI outputs against official documentation.
  Human approval mandatory for all Tier K operations.
- **Residual risk**: Both models in Tier C could hallucinate the same
  incorrect information if it's a common misconception in training data
- **Owner**: AI Ops / Governance

## R-11: Rig framework immaturity or abandonment

- **Risk**: Rig (primary orchestration framework) is pre-1.0 and
  community-maintained. Breaking API changes or project abandonment
  would require migration
- **Likelihood**: Medium
- **Impact**: High — significant rework to switch frameworks
- **Status**: Open — mitigated by design
- **Mitigation**: MIT license allows forking. Provider abstraction
  layer means model routing logic is separate from framework internals.
  llm-chain as partial fallback for chain-style tasks.
- **Residual risk**: Migration effort could be weeks of work
- **Owner**: Runtime

## R-12: Emulator-hardware behavior gap

- **Risk**: Tests that pass on Android emulator may fail on real
  Samsung hardware due to differences in firmware, drivers, bootloader
  behavior, Knox integration, or cellular stack
- **Likelihood**: High (certain for some categories)
- **Impact**: Medium — false confidence in test results
- **Status**: Open — documented by design
- **Mitigation**: Explicit "can prove / cannot prove" boundary in
  `emulator_first_validation.md`. Hardware-only behaviors flagged
  as untested until Phase 4.
- **Residual risk**: Unknown unknowns — behaviors we don't know are
  hardware-specific until we try
- **Owner**: Platform

## R-13: NVIDIA NIM model deprecation

- **Risk**: NVIDIA deprecates or removes a specific model from the NIM
  catalog, breaking the M-VERIFY slot
- **Likelihood**: Medium
- **Impact**: Medium — verification capability degraded until
  replacement configured
- **Status**: Open — mitigated by design
- **Mitigation**: Fallback model defined (Mixtral 8x22B). Model
  version pinning in config. Monitor NVIDIA deprecation notices.
- **Residual risk**: All suitable models could be deprecated
  simultaneously in a major platform change
- **Owner**: AI Ops

## R-14: LineageOS drops S10+ support

- **Risk**: LineageOS community maintainer (Linux4) stops maintaining
  S10+ builds, leaving us without upstream kernel patches and security
  updates
- **Likelihood**: Medium (device is aging; S10+ released 2019)
- **Impact**: High — no more security patches, increasing vulnerability
  surface
- **Status**: Open — monitoring
- **Mitigation**: Monitor LineageOS wiki and maintainer activity.
  If support drops, evaluate: (a) self-maintaining the device tree,
  (b) switching baseline to a newer device, (c) accepting frozen
  firmware version.
- **Residual risk**: Self-maintenance requires significant kernel
  expertise
- **Owner**: Platform

## R-15: Phantom model reference propagation

- **Risk**: Documentation references AI models that don't exist (as
  happened with initial "Codex 5.3" and "Gemini 3.1 Pro" entries),
  undermining credibility and causing integration failures
- **Likelihood**: Low (after current fix)
- **Impact**: High — builds trust erosion, impossible to integrate
- **Status**: Mitigated — phantom models replaced in v2 of orchestrator
  spec
- **Mitigation**: Model allowlist in ADR-0003 with vendor verification
  links. Source verification log must include vendor model page URL
  for every model in the roster.
- **Residual risk**: New models added without verification
- **Owner**: Governance

---

## Summary

| Status | Count |
|--------|-------|
| Open | 14 |
| Mitigated | 1 |
| Accepted | 0 |
| Closed | 0 |
| **Total** | **15** |

Critical-impact risks: R-01, R-02, R-03, R-05, R-08, R-10
