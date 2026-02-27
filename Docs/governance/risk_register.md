# Risk Register

| ID | Risk | Likelihood | Impact | Mitigation | Owner |
|---|---|---|---|---|---|
| R-01 | Model-level support confusion (marketing name vs exact SKU) | High | Critical | Require exact model/region/carrier mapping before pilot | Platform |
| R-02 | Bootloader unlock unavailable on target variant | High | Critical | Preflight unlock viability gate per model | Platform |
| R-03 | Rollback/anti-tamper constraints trigger hard lockout | Medium | Critical | Maintain stock restore path + rollback matrix | Platform |
| R-04 | OAuth/provider path unstable | High | High | Emulator + staged auth diagnostics + provider health checks | Runtime |
| R-05 | Over-automation causes unsafe operations | Medium | Critical | ADR safety boundary, manual gates for destructive steps | Governance |
| R-06 | Source quality drift and stale assumptions | Medium | High | Confidence labels + scheduled source refresh | Research |
| R-07 | Cost explosion in autonomous model usage | Medium | High | Tiered routing, budget caps, fallback model policy | AI Ops |
| R-08 | Secret leakage into repo/logs | Medium | Critical | Redaction policy, no secrets in repo, masked logs | Governance |
| R-09 | Drift from NAP alignment envelope (Class/Autonomy) | Medium | High | Decision router + ADR updates + profile declaration checks | Governance |

## Review Cadence

- Weekly during planning.
- Immediately after any architecture decision update.
