# NAP Glossary for Kai-zen-OS

This glossary defines Nex Alignment Protocol (NAP) terminology used
throughout Kai-zen-OS documentation. For the full NAP specification,
see `references/Nex_Alignment/` or https://github.com/RobinGase/Nex_Alignment.

---

## Risk Classes (0-4)

NAP assigns every task a risk class based on potential harm from failure.
Higher class = stricter governance requirements.

| Class | Label | Description | Example in Kai-zen-OS |
|-------|-------|-------------|----------------------|
| **0** | Negligible | No meaningful harm from failure | Formatting a markdown file |
| **1** | Minor | Easily reversible, low impact | Updating a research note |
| **2** | Moderate | Requires effort to reverse, noticeable impact | Changing the orchestrator model roster |
| **3** | Significant | Difficult to reverse, potential for data loss or service disruption | Modifying device flash command sequences, changing partition layouts |
| **4** | Critical | Irreversible or catastrophic harm possible | Executing flash commands on hardware, modifying bootloader chain |

**Kai-zen-OS effective floor: Class 3** — all planning decisions that
could influence future flash operations are treated as at least Class 3.

---

## Autonomy Tiers (A0-A4)

NAP defines how much independent authority an AI agent has.

| Tier | Label | Description | Human Role |
|------|-------|-------------|------------|
| **A0** | No autonomy | Human does everything; AI provides information only | AI answers questions, human acts |
| **A1** | Suggestion | AI proposes actions; human reviews and executes | AI drafts, human approves and runs |
| **A2** | Supervised autonomy | AI executes pre-approved action types; human approves each consequential step | AI writes docs and runs emulator tests; human approves any hardware-affecting plan |
| **A3** | Conditional autonomy | AI acts independently within defined boundaries; human monitors | AI handles routine tasks, human reviews exceptions |
| **A4** | Full autonomy | AI operates independently with minimal oversight | Human sets goals, AI handles everything else |

**Kai-zen-OS ceiling: A2** — no AI agent may operate above supervised
autonomy. Every consequential decision requires human approval.

A4 is prohibited for Class 0-2 tasks and allowed only for Class 3-4
under exceptional controls that Kai-zen-OS does not currently meet.

---

## Governance Bundles

NAP groups related compliance requirements into bundles. Each bundle
addresses a specific governance concern.

| Bundle | Name | What it requires |
|--------|------|-----------------|
| **B01** | Core Governance | Risk classification, autonomy tier assignment, governance scoring, ADR trail |
| **B02** | Change & Data Integrity | Change safety gates, rollback plans, traceability, data validation |
| **B05** | Privacy & Regulated Data | Sensitive data handling, no-secrets policy, data minimization |
| **B06** | Runtime Containment | Override logic, slot boundaries, fail-closed behavior, enforcement engine |
| **B07** | AI Model Supply Chain | Model allowlist, version pinning, provider verification, no unauthorized models |
| **B09** | Security Incident & Forensics | Incident response plan, forensic readiness, rollback/recovery procedures |

**Kai-zen-OS requires all 6 bundles** (B01, B02, B05, B06, B07, B09)
based on its profile composition.

---

## Profile Composition

NAP allows up to 3 use-case profiles per project. When profiles conflict,
**highest-safety-wins**: the strictest requirement from any profile applies.

Kai-zen-OS profiles:

| Priority | Profile | Why |
|----------|---------|-----|
| Primary | `infrastructure_devops` | Core work is building/deploying system images |
| Secondary | `ai_stack_training_inference` | AI model orchestration is central to the pipeline |
| Secondary | `security_incident_response` | Flash operations can cause irreversible security events |

---

## Key NAP Principles

### Highest-safety-wins
When two profiles or rules disagree on a safety requirement, the
stricter rule always applies. There is no mechanism to override this
without a formal override request (`templates/use_case_override_request_template.md`).

### Fail-closed
When the governance system cannot determine if an action is safe, it
blocks the action. Uncertainty defaults to denial, not approval.

### Governance score
A numerical score (0-100) computed from base score, compliance penalties,
reliability metrics, economic risk, and residual risk. Determines
whether a task is approved, requires manual review, or is blocked.
See `runtime/unified_governance_decision_model.md` for the full formula.

### Residual risk
Risk that remains after all mitigation controls are applied. Must be
formally accepted with an expiry date. Expired residual risk acceptances
automatically increase governance penalties.

---

## Quick Reference

| Term | Kai-zen-OS value |
|------|-----------------|
| Risk class floor | Class 3 |
| Autonomy ceiling | A2 |
| Conflict resolution | highest-safety-wins |
| Required bundles | B01, B02, B05, B06, B07, B09 |
| Profile count | 3 (max allowed) |
| Override mechanism | `templates/use_case_override_request_template.md` |
