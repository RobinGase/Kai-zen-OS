# Kai-zen-OS End-to-End Implementation Plan (Planning Phase)

> **Current phase**: Phase 0 (Alignment) — transitioning to Phase 1
> **Last updated**: 2026-02-27
> **Owner**: RobinGase
> **NAP envelope**: Class 3 floor | A2 ceiling | highest-safety-wins

---

## 1  Program Intent

Design a complete, autonomous, low-cost pipeline for building and
validating Android flash images, starting with Samsung Galaxy S10+
(Exynos, SM-G975F) and expanding toward S24+ where feasible.

This repo is a debate/test-planning environment only.

**Hard constraints** (non-negotiable):

- No production flashing automation — emulator only
- No secrets or credentials stored in repo
- No irreversible device operations from any automated system
- All AI-driven decisions capped at NAP autonomy tier A2
  (human approval required for anything above)

**Alignment overlay**: This plan adopts the `Nex_Alignment` governance
envelope. See `Docs/alignment/kai_zen_nap_alignment.md` for full mapping.

---

## 2  Reality Check (Critical)

These findings constrain every downstream decision.

### 2.1  Redox microkernel

- Redox is valuable for microkernel R&D and systems design learning.
- Redox is **not** a practical base kernel for Samsung phone daily-driver images.
  It lacks ARM/AArch64 device trees, Android HAL compatibility, cellular
  baseband integration, and the Samsung-specific driver stack.
- Running Kali Linux desktop directly on the Redox kernel is not practical.
- **Decision**: Redox stays as architecture-inspiration R&D stream only (ADR-0002).
- **Evidence**: `Docs/research/redox_microkernel_assessment.md`

### 2.2  Samsung image strategy

- **Exynos vs Snapdragon is the critical split**. US-market Snapdragon
  Samsung devices are typically bootloader-locked by carriers and OEM
  unlock is often disabled. Exynos (international) models are the viable
  target for custom images.
- Our baseline device (SM-G975F) is Exynos 9820, international variant —
  bootloader unlock is possible.
- S10+ has mature LineageOS support (`lineage_beyond2lte`, maintainer: Linux4).
- S21-S24 support is model/region/carrier dependent, often community-led,
  and increasingly locked down (Knox Vault on S21+, stronger AVB on S22+).
- **Expect 60-70% of Samsung models to be non-viable for custom images.**

### 2.3  Current S10+ state

- Running LineageOS with Kali proot in Termux
- ZeroClaw API server in Termux (local LLM/tool orchestration layer)
- OpenWebUI in Kali proot
- Provider count: 0 (no active LLM providers configured)
- OAuth flow: unstable
- **Evidence**: `Docs/operations/s10plus_current_setup.md`

### 2.4  Local development environment

- **OS**: Windows 10 (build 26200)
- **Android SDK**: Scoop-installed at `%ANDROID_HOME%` (`android-clt`)
- **ADB**: v36.0.2
- **Emulator**: v36.4.9 (QEMU-based)
- **Platforms**: android-34, android-35, android-36
- **System images**: `android-35/google_apis` (x86_64)
- **AVD**: `boomies_api35` (API 35, Google APIs)
- **Git**: configured as RobinGase / gaserobin@gmail.com
- **gh CLI**: not installed (git push over HTTPS works)

---

## 3  Program Goals

| # | Goal | Measurable outcome |
|---|------|--------------------|
| G1 | Robust planning architecture for autonomous image engineering | All decisions traceable to cited sources with confidence labels |
| G2 | Safe S10+ baseline runbook with preflight gates | Complete preflight checklist, rollback plan, and recovery procedure |
| G3 | Scalable device matrix S10+ → S24+ | Per-variant support table with Exynos/Snapdragon split, confidence labels, and do-not-attempt list |
| G4 | Model-driven orchestration design | Orchestrator model spec with validated model roster (no phantom models) |
| G5 | Cost-controlled model routing | Fast-model-first policy with measured escalation rates |
| G6 | Emulator-validated test suite | Passing test harness on `boomies_api35` AVD proving ADB, scrcpy, provider routing logic |
| G7 | NAP-compliant governance | All planning artifacts pass NAP bundle requirements B01-B09 |

---

## 4  Workstreams

### WS-A: Redox Assessment (COMPLETE)

**Status**: Done — kept as R&D reference only

- Deliverable: `Docs/research/redox_microkernel_assessment.md`
- Output: feasibility limits, where Redox fits, where it does not
- Verdict: not viable for Samsung target; retained for microkernel design patterns

### WS-B: Samsung Platform Matrix

**Status**: Partial — needs Exynos/Snapdragon expansion

- Deliverable: `Docs/research/samsung_device_support_matrix.md`
- Output: per-variant support table with:
  - SoC type (Exynos vs Snapdragon)
  - Bootloader unlock feasibility by region/carrier
  - Knox counter / Vault implications
  - LineageOS maintainer status and last build date
  - Confidence label per variant
  - Explicit do-not-attempt list

**Remaining work**:

1. Expand S10 family with all model numbers (SM-G970F/N/U, SM-G973F/N/U, SM-G975F/N/U)
2. Mark Snapdragon US variants as "do-not-attempt" with explanation
3. Add S20-S24 families at variant level (not marketing-name level)
4. Add Knox Vault introduction timeline (S21+)
5. Add AVB 2.0 enforcement status per family

### WS-C: Baseline Device (S10+) State

**Status**: Partial — needs ZeroClaw documentation, device state details

- Deliverable: `Docs/operations/s10plus_current_setup.md`
- Output: verified current architecture including:
  - Exact firmware version and baseband
  - Bootloader state (unlocked/OEM-unlocked)
  - Knox counter status
  - Recovery type (Lineage recovery / TWRP / stock)
  - ZeroClaw architecture explanation
  - Storage/RAM utilization
  - Android version and security patch level

### WS-D: Remote Control + Test Harness

**Status**: Partial — plans exist, no validation yet

- Deliverables:
  - `Docs/operations/remote_control_setup.md`
  - `Docs/operations/emulator_first_validation.md`
- Output:
  - Reproducible lab control model with network topology
  - Emulator test suite bound to `boomies_api35` AVD
  - Clear "can prove in emulator" vs "cannot prove" split

**Remaining work**:

1. Validate emulator boot and ADB connectivity
2. Install scrcpy and test emulator screen mirroring
3. Define test taxonomy for provider routing, auth flow, runtime behavior
4. Write initial emulator test scripts (ADB shell commands)
5. Document emulator limitations vs hardware-only behaviors

### WS-E: Autonomous Orchestration

**Status**: Partial — orchestrator spec written, research docs thin

- Deliverables:
  - `Docs/research/framework_stack_rig_llm_chain.md`
  - `Docs/research/model_provider_investigation.md`
  - `Docs/research/gemini_2_5_flash_investigation.md`
  - `Docs/research/nvidia_api_investigation.md`
  - `Docs/adrs/ADR-0003-model-routing-policy.md`
  - `Docs/architecture/orchestrator_model_spec.md`
- Output: routing policy, verification pipeline, concrete model assignments

**Remaining work**:

1. Fix phantom model names (Codex 5.3 → real model, Gemini 3.1 Pro → real model)
2. Add M-KERNEL tier for core kernel patches (Opus 4.6 / Codex 5.3 xtra-high)
3. Flesh out Gemini 2.5 Flash investigation with pricing, benchmarks, context window
4. Flesh out NVIDIA investigation with specific NIM models and pricing
5. Add framework comparison criteria and evaluation methodology
6. Reconcile ADR-0003 with orchestrator spec (currently out of sync)
7. Add model version pinning strategy
8. Add endpoint failure/fallback behavior

### WS-F: Governance and Safety

**Status**: Partial — structure exists, content too thin

- Deliverables:
  - `Docs/governance/risk_register.md`
  - `Docs/governance/source_verification.md`
  - `Docs/adrs/ADR-0001-safety-boundary.md`
  - `Docs/adrs/ADR-0002-kernel-and-os-strategy.md`

**Remaining work**:

1. Expand risk register from 9 to 15+ risks with full detail per entry
2. Add missing risks: AI hallucination, framework abandonment, LineageOS S10+ EOL
3. Add risk status tracking (open/mitigated/accepted)
4. Add source access dates to verification log
5. Add all ADR standard fields: date, context, alternatives, approval
6. Create rollback plan artifact (referenced everywhere, exists nowhere)

### WS-G: Nex Alignment Integration

**Status**: Complete for planning phase

- Deliverables:
  - `Docs/alignment/kai_zen_nap_alignment.md`
  - `Docs/alignment/kai_zen_decision_router.md`
  - `Docs/alignment/nap_glossary.md` (NEW — needed)
- Output: profile-composed governance envelope and decision routing

**Remaining work**:

1. Write NAP glossary defining Class 0-4, A0-A4, bundles, highest-safety-wins
   for readers who don't have the upstream repo
2. Add worked example to decision router
3. Add decision log template

---

## 5  Phase Plan

### Phase 0 — Alignment (CURRENT → completing)

**Objective**: Freeze assumptions, non-goals, and safety boundaries.

**Tasks**:

- [x] ADR-0001: safety boundary (no automated flash commands)
- [x] ADR-0002: kernel strategy (Redox = R&D only)
- [x] ADR-0003: model routing policy (tiered, multi-vendor)
- [x] NAP alignment mapping (profile composition, bundles)
- [x] Decision router
- [ ] NAP glossary for local readers
- [ ] Fix ADR format (add date, context, alternatives, approval)

**Exit criteria**:

- All three ADRs have full standard format
- NAP glossary exists
- Phase status formally marked "complete" in this file

### Phase 1 — Research Consolidation

**Objective**: Bring all research documents to substantive depth.
Label every claim by confidence tier and source quality.

**Tasks**:

- [ ] Samsung device matrix: expand to variant-level with SoC/carrier split
- [ ] Gemini 2.5 Flash: add pricing ($0.15/1M input as of Q1 2026?), benchmarks, context window (1M tokens), rate limits
- [ ] NVIDIA NIM: identify specific models (Llama 3.x, Mixtral, Nemotron), pricing, latency, auth method
- [ ] Framework stack: add evaluation criteria, maturity assessment, language commitment (Rust), alternatives considered
- [ ] Fix orchestrator model roster: replace phantom names with real or explicitly-TBD models
- [ ] Add M-KERNEL tier to orchestrator spec
- [ ] Source verification log: add access dates, map sources to claims
- [ ] Reconcile all cross-references between research docs and ADRs
- [ ] Subagent report digest: expand with methodology, confidence ratings, disagreements

**Exit criteria**:

- Every research doc ≥ 60 lines with cited sources
- Source verification file covers all claims in all docs
- No phantom model names anywhere
- Orchestrator spec passes internal consistency check against ADR-0003

### Phase 2 — Debate Architecture

**Objective**: Define and evaluate candidate autonomous pipeline architectures.

**Tasks**:

- [ ] Define Architecture A: monolithic orchestrator (single Claude session manages everything)
- [ ] Define Architecture B: multi-agent with Rig (planner → worker → verifier pipeline)
- [ ] Define Architecture C: event-driven with message queue (tasks posted, agents consume)
- [ ] Red-team each candidate: failure modes, single points of failure, cost profile
- [ ] Score candidates against criteria: reliability, cost, NAP compliance, debuggability
- [ ] Write ADR-0004: architecture selection with explicit tradeoffs
- [ ] Update orchestrator spec to match selected architecture

**Exit criteria**:

- ADR-0004 written with all standard fields
- One architecture selected with quantified tradeoffs
- Losing candidates documented with reasons for rejection

### Phase 3 — Emulator-First Test Design

**Objective**: Build and run a test suite on the `boomies_api35` AVD
that validates everything that can be validated without hardware.

**Tasks**:

- [ ] Boot `boomies_api35` AVD and confirm ADB connectivity
- [ ] Test basic ADB commands: shell, push, pull, install, logcat
- [ ] Install and test scrcpy with emulator
- [ ] Define test taxonomy:
  - Auth flow simulation (OAuth mock endpoints)
  - Provider routing logic (mock LLM responses, test tier escalation)
  - ADB command sequences (non-destructive)
  - Filesystem layout validation
  - Service health checks
- [ ] Write test scripts (shell + Python) in `tests/emulator/`
- [ ] Define "can prove in emulator" boundary:
  - YES: ADB communication, app install/uninstall, filesystem ops, network calls, logcat parsing
  - NO: actual flash behavior, bootloader interaction, Knox counter, cellular baseband, hardware sensors
- [ ] Run full test suite and document results
- [ ] Fix any failures

**Exit criteria**:

- All emulator-valid tests pass on `boomies_api35`
- Test results documented with timestamps
- Clear boundary document between emulator-proven and hardware-only claims

### Phase 4 — Hardware Pilot Readiness (S10+ only)

**Objective**: Produce a complete dry-run command plan and rollback
procedure for the S10+ — without executing any of it.

**NOTE**: This phase produces documentation only. No commands are
executed on hardware. NAP A2 ceiling means human must approve any
future execution.

**Tasks**:

- [ ] Write exact Heimdall/Odin flash command sequences (documented, not executed)
- [ ] Write pre-flash checklist:
  - Battery ≥ 80%
  - Backup verified
  - Correct firmware file hashes verified
  - ADB/Heimdall connectivity confirmed
  - Knox counter status recorded
  - Recovery mode type confirmed
- [ ] Write rollback procedure:
  - Stock firmware restore via Odin/Heimdall
  - TWRP/Lineage recovery fallback
  - Full data wipe procedure
  - Brick recovery options
- [ ] Write post-flash validation checklist
- [ ] Peer review all command plans for safety

**Exit criteria**:

- S10+ runbook marked "ready for supervised pilot"
- Rollback procedure exists and covers all identified failure modes
- No execution has occurred — still planning only

### Phase 5 — Scale Strategy to S24+

**Objective**: Expand the device matrix to production breadth with
per-variant safety assessments.

**Tasks**:

- [ ] Expand matrix by exact model/region/carrier for S20-S24 families
- [ ] Research Exynos 2100 (S21), 2200 (S22), 2300 (S23), 2400 (S24) flash procedures
- [ ] Document Knox Vault evolution per generation
- [ ] Assign confidence labels: "supported", "experimental", "research-only", "do-not-attempt"
- [ ] Identify which S21+ models have active LineageOS builds
- [ ] Write per-family risk assessment

**Exit criteria**:

- Expansion matrix with per-variant confidence scores
- Do-not-attempt list with explicit reasons
- At least one S21+ variant identified as feasible pilot candidate (or documented as all non-viable)

---

## 6  Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Decision traceability | 100% of decisions cite sources | Audit `source_verification.md` |
| Secrets in repo | Zero | Automated git-secrets scan |
| S10+ runbook completeness | Preflight + flash + rollback + recovery | Checklist review |
| Emulator test pass rate | 100% of defined tests | CI output from AVD run |
| Model roster validity | All models verifiably exist | Manual check of vendor docs |
| Source verification coverage | Every claim has a URL | Cross-reference audit |
| NAP compliance | All 6 required bundles satisfied | NAP alignment doc review |
| Risk register coverage | ≥15 risks with status tracking | Count + review |

---

## 7  Non-Goals (Current Phase)

- Writing production flashing code
- Running destructive device commands
- Flashing or testing on actual hardware
- Claiming universal support without per-variant verification
- Building a UI or user-facing application
- Monetization or distribution planning

---

## 8  Dependencies and Risks

| Dependency | Impact if unavailable | Mitigation |
|------------|----------------------|------------|
| Android SDK / emulator | Cannot validate any test harness | Already installed (confirmed) |
| Gemini API access | Cannot test M-FAST routing | Use mock responses; test routing logic without live API |
| NVIDIA NIM access | Cannot test M-VERIFY tier | Same as above |
| LineageOS S10+ builds | Device matrix becomes theoretical | Monitor Lineage wiki; builds are current as of 2026 |
| Nex_Alignment stability | Governance mapping may drift | Pin to submodule commit; re-sync periodically |

---

## 9  Immediate Next Actions (Prioritized)

1. Fix orchestrator model spec — add M-KERNEL, remove phantom models
2. Update .gitignore for kernel-patch routing lines
3. Fix all three ADRs to full format
4. Write NAP glossary
5. Boot emulator and validate ADB connectivity
6. Expand Samsung device matrix with Exynos/Snapdragon split
7. Flesh out thin research docs
8. Expand risk register
