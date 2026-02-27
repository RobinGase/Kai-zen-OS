# Kai-zen-OS End-to-End Implementation Plan (Planning Phase)

> **Current phase**: Phase 3 (Emulator-First Test Design) — ACTIVE
> **Last updated**: 2026-02-27 (session 2)
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

### WS-B: Samsung Platform Matrix (COMPLETE)

**Status**: Done — variant-level matrix with Exynos/Snapdragon split

- Deliverable: `Docs/research/samsung_device_support_matrix.md`
- Output: 200+ line matrix covering S10-S24 families at variant level
  - [x] SoC type (Exynos vs Snapdragon) per variant
  - [x] Bootloader unlock feasibility by region/carrier
  - [x] Knox counter / Vault implications (Vault timeline: S21+)
  - [x] LineageOS maintainer status per variant
  - [x] Confidence label per variant
  - [x] Explicit do-not-attempt list (all US Snapdragon variants)
  - [x] AVB enforcement status per family

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

**Status**: Partial — Layer 1 tests pass, Layers 2-5 pending

- Deliverables:
  - `Docs/operations/remote_control_setup.md`
  - `Docs/operations/emulator_first_validation.md`
- Output:
  - Emulator test suite bound to `boomies_api35` AVD
  - Clear "can prove in emulator" vs "cannot prove" split
  - 45-test taxonomy across 5 layers

**Completed**:

1. [x] Validate emulator boot and ADB connectivity (Layer 1: 7/7 PASS)
2. [x] Define test taxonomy (45 tests across 5 layers in emulator_first_validation.md)
3. [x] Document emulator limitations vs hardware-only behaviors

**Remaining work**:

1. Install scrcpy and test emulator screen mirroring (Layer 3: T-020)
2. Run Layer 2 logic tests (routing, escalation, safety guards)
3. Run Layer 3 UI/automation tests (Appium, Maestro)
4. Run Layer 4 fault/resilience tests
5. Run Layer 5 evidence/audit tests

### WS-E: Autonomous Orchestration (MOSTLY COMPLETE)

**Status**: Core spec and research done; model_provider_investigation.md needs sync

- Deliverables:
  - `Docs/research/framework_stack_rig_llm_chain.md` — DONE (150+ lines)
  - `Docs/research/model_provider_investigation.md` — needs update to match v2 roster
  - `Docs/research/gemini_2_5_flash_investigation.md` — DONE (120+ lines)
  - `Docs/research/nvidia_api_investigation.md` — DONE (130+ lines)
  - `Docs/adrs/ADR-0003-model-routing-policy.md` — DONE (full standard format)
  - `Docs/architecture/orchestrator_model_spec.md` — DONE (v2 with M-KERNEL)
- Output: routing policy, verification pipeline, concrete model assignments

**Completed**:

1. [x] Fix phantom model names (Codex 5.3 → GPT-4o, Gemini 3.1 Pro → Gemini 2.5 Pro)
2. [x] Add M-KERNEL tier for core kernel patches (Opus 4.6 / GPT-4o, xtra-high)
3. [x] Flesh out Gemini 2.5 Flash with pricing, benchmarks, 1M context
4. [x] Flesh out NVIDIA with Llama 3.1 70B, Nemotron, Mixtral, API details
5. [x] Add framework comparison criteria and evaluation methodology
6. [x] Reconcile ADR-0003 with orchestrator spec (model allowlist matches)

**Remaining work**:

1. Update `model_provider_investigation.md` to match v2 orchestrator roster
2. Add model version pinning strategy to orchestrator spec
3. Add endpoint failure/fallback behavior to orchestrator spec

### WS-F: Governance and Safety (MOSTLY COMPLETE)

**Status**: Core artifacts done; rollback plan still needed

- Deliverables:
  - `Docs/governance/risk_register.md` — DONE (15 risks, full detail)
  - `Docs/governance/source_verification.md` — DONE (dated, categorized)
  - `Docs/adrs/ADR-0001-safety-boundary.md` — DONE (full standard format)
  - `Docs/adrs/ADR-0002-kernel-and-os-strategy.md` — DONE (full standard format)

**Completed**:

1. [x] Expand risk register to 15 risks with full detail per entry
2. [x] Add AI hallucination (R-10), framework abandonment (R-11), LineageOS EOL (R-14)
3. [x] Add risk status tracking (open/mitigated/accepted)
4. [x] Add source access dates to verification log
5. [x] All ADR standard fields: date, context, alternatives, approval

**Remaining work**:

1. Create rollback plan artifact (`Docs/operations/s10plus_rollback_plan.md`)

### WS-G: Nex Alignment Integration (MOSTLY COMPLETE)

**Status**: Core artifacts done; decision router needs worked example

- Deliverables:
  - `Docs/alignment/kai_zen_nap_alignment.md` — DONE
  - `Docs/alignment/kai_zen_decision_router.md` — needs worked example
  - `Docs/alignment/nap_glossary.md` — DONE (Class 0-4, A0-A4, bundles)
- Output: profile-composed governance envelope and decision routing

**Completed**:

1. [x] NAP glossary with Class 0-4, A0-A4, bundles, highest-safety-wins

**Remaining work**:

1. Add worked example to decision router
2. Add decision log template

---

## 5  Phase Plan

### Phase 0 — Alignment (COMPLETE)

**Objective**: Freeze assumptions, non-goals, and safety boundaries.

**Tasks**:

- [x] ADR-0001: safety boundary (no automated flash commands)
- [x] ADR-0002: kernel strategy (Redox = R&D only)
- [x] ADR-0003: model routing policy (tiered, multi-vendor)
- [x] NAP alignment mapping (profile composition, bundles)
- [x] Decision router
- [x] NAP glossary for local readers
- [x] Fix ADR format (add date, context, alternatives, approval)

**Exit criteria**: ALL MET

- [x] All three ADRs have full standard format
- [x] NAP glossary exists
- [x] Phase status formally marked "complete"

### Phase 1 — Research Consolidation (ACTIVE — nearly complete)

**Objective**: Bring all research documents to substantive depth.
Label every claim by confidence tier and source quality.

**Tasks**:

- [x] Samsung device matrix: expand to variant-level with SoC/carrier split
- [x] Gemini 2.5 Flash: pricing, benchmarks, context window (1M), rate limits
- [x] NVIDIA NIM: specific models (Llama 3.1 70B, Mixtral, Nemotron), pricing, auth
- [x] Framework stack: evaluation criteria, maturity assessment, Rust commitment
- [x] Fix orchestrator model roster: phantom names replaced with real models
- [x] Add M-KERNEL tier to orchestrator spec
- [x] Source verification log: access dates, source-to-claim mapping
- [x] Reconcile cross-references between research docs and ADRs
- [ ] Subagent report digest: expand with methodology, confidence ratings
- [ ] Update model_provider_investigation.md to match v2 orchestrator roster
- [ ] Update repo_blueprint.md to match current file tree

**Exit criteria** (progress):

- [x] Every research doc ≥ 60 lines with cited sources
- [x] Source verification file covers all claims in all docs
- [x] No phantom model names anywhere
- [x] Orchestrator spec passes internal consistency check against ADR-0003
- [ ] model_provider_investigation.md reconciled with orchestrator spec

### Phase 2 — Debate Architecture (COMPLETE)

**Objective**: Define and evaluate candidate autonomous pipeline architectures.

**Tasks**:

- [x] Define Architecture A: monolithic orchestrator (single Claude session)
- [x] Define Architecture B: multi-agent with Rig (planner → worker → verifier)
- [x] Define Architecture C: event-driven with message queue
- [x] Red-team each candidate: failure modes, cost profile, NAP compliance
- [x] Score candidates: A=7.25, B=6.85, C=4.35
- [x] Write ADR-0004: architecture selection (A now, B later, C never)
- [x] Update orchestrator spec to reference architecture decision

**Result**: Architecture A (Monolithic) selected for Phases 0-3.
Architecture B (Rig Pipeline) planned for Phase 4+ evolution.
Architecture C rejected permanently.

See `Docs/architecture/architecture_candidates.md` and
`Docs/adrs/ADR-0004-architecture-selection.md`.

**Exit criteria**: ALL MET

- [x] ADR-0004 written with all standard fields
- [x] One architecture selected (A) with quantified tradeoffs
- [x] Losing candidates documented with reasons

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

1. ~~Fix orchestrator model spec~~ DONE
2. ~~Update .gitignore~~ DONE
3. ~~Fix all three ADRs~~ DONE
4. ~~Write NAP glossary~~ DONE
5. ~~Boot emulator and validate ADB~~ DONE (Layer 1: 7/7 PASS)
6. ~~Expand Samsung device matrix~~ DONE
7. ~~Flesh out thin research docs~~ DONE
8. ~~Expand risk register~~ DONE (15 risks)

### Current priorities:

1. Finish Phase 1 stragglers (model_provider_investigation, subagent digest, blueprint)
2. Create S10+ rollback plan artifact
3. Add worked example to decision router
4. **Phase 2**: Define and evaluate 3 candidate architectures (A/B/C)
5. **Phase 2**: Write ADR-0004 architecture selection
6. **Phase 3**: Run Layer 2-5 emulator tests
