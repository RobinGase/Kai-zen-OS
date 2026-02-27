# Kai-zen Decision Router (NAP-Aligned)

Use this quick router before writing or approving any plan update.

---

## Step 1: Declare profile set

- Primary: `infrastructure_devops`
- Secondary: `ai_stack_training_inference`
- Secondary: `security_incident_response`

If your change does not fit this set, flag for profile review before
proceeding.

## Step 2: Determine safety class

- Class 1-2: documentation-level, no device-impact path
- Class 3+: any operation that could impact boot chain, flash safety,
  auth trust, or irreversible device state

Default to **Class 3** when uncertain.

See `Docs/alignment/nap_glossary.md` for full class definitions.

## Step 3: Apply autonomy ceiling

- Maximum autonomy for this program: **A2**
- No fully autonomous destructive workflow planning

See `Docs/alignment/nap_glossary.md` for full tier definitions.

## Step 4: Evidence gate

For Class 3+ decisions, require:

1. At least two high-confidence sources (see `Docs/governance/source_verification.md`)
2. Explicit rollback/recovery path
3. Emulator-vs-hardware validation boundary callout

## Step 5: Publish artifact updates

- Update relevant plan doc(s) in `Docs/`
- Update risk register (`Docs/governance/risk_register.md`) if risk posture changes
- Update ADR if decision authority or guardrails change
- Log the decision in the decision log below

---

## Worked Example: Adding M-KERNEL Tier to Orchestrator Spec

**Scenario**: We want to add a new model routing tier specifically for
kernel-critical patches (device tree, bootloader, SELinux policy).

### Step 1: Profile check

This change falls under `infrastructure_devops` (primary) — it's about
the orchestration infrastructure. Also touches `security_incident_response`
because kernel patches affect device security. Profiles match.

### Step 2: Safety class

Kernel patches directly affect boot chain and flash safety → **Class 3**.
This is above Class 2, so full evidence gate applies.

### Step 3: Autonomy ceiling

The M-KERNEL tier must require **human approval** for every output.
This satisfies A2 ceiling — AI produces output, human approves.
We also add M-VERIFY independent validation for defense in depth.

### Step 4: Evidence gate

1. **Two high-confidence sources**: Samsung Knox hardware security docs
   (confirms kernel changes trip Knox counter), LineageOS install guide
   (confirms vbmeta/boot partition sensitivity).
2. **Rollback path**: If a kernel patch recommendation is wrong, the
   rollback is to not apply it (planning-only phase). For future hardware
   pilot, stock firmware restore via Heimdall is the rollback.
3. **Emulator boundary**: Kernel patch logic can be reviewed in emulator
   for syntax/correctness, but actual kernel boot behavior is
   hardware-only (documented in emulator_first_validation.md).

### Step 5: Artifacts updated

- `Docs/architecture/orchestrator_model_spec.md` — added M-KERNEL slot,
  Tier K routing rules, kernel tags
- `Docs/adrs/ADR-0003-model-routing-policy.md` — added Tier K and
  M-KERNEL to model allowlist
- `Docs/governance/risk_register.md` — no new risk (R-03 already covers
  kernel-related device lockout)
- `.gitignore` — added kernel_routing.yaml exclusion

**Result**: Change approved. M-KERNEL tier added with appropriate
safeguards.

---

## Decision Log

| Date | Decision | Class | Approved by | Artifacts changed |
|------|----------|-------|-------------|-------------------|
| 2026-02-27 | Safety boundary: planning-only, no flash commands | 3 | RobinGase | ADR-0001 |
| 2026-02-27 | Kernel strategy: Redox = R&D only | 3 | RobinGase | ADR-0002 |
| 2026-02-27 | Model routing: tiered multi-vendor with allowlist | 3 | RobinGase | ADR-0003, orchestrator_model_spec.md |
| 2026-02-27 | Add M-KERNEL tier for kernel-critical patches | 3 | RobinGase | orchestrator_model_spec.md, ADR-0003, .gitignore |
| 2026-02-27 | Fix phantom models (Codex 5.3 → GPT-4o, Gemini 3.1 Pro → Gemini 2.5 Pro) | 2 | RobinGase | orchestrator_model_spec.md, ADR-0003 |
