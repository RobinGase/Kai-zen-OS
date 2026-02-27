# Redox Microkernel Assessment

## Executive Verdict

Redox is a strong research target for microkernel architecture, but not a practical deployment kernel for the Samsung phone-flash program in its current state.

## Feasibility by Objective

## Objective: Run Kali desktop directly on Redox kernel

- **Status**: Not practical today
- **Reason**: Redox strategy emphasizes source-compatibility and recompilation instead of Linux binary compatibility layer parity.

## Objective: Use Redox as phone-image base (S10+ to S24+)

- **Status**: Not practical today
- **Reason**: Smartphone boot/driver ecosystem and hardware support are not aligned with Redox deployment maturity for this use-case.

## Objective: Use Redox knowledge to improve architecture quality

- **Status**: Strong fit
- **Reason**: Redox design choices (modularity, isolation, user-space services) are useful for planning principles and reliability patterns.

## High-Confidence Findings

1. Redox is still in alpha and not yet daily-driver-ready.
2. Linux compatibility-layer approach is explicitly deprioritized vs source-level porting.
3. Hardware support remains selective and model-dependent.
4. Boot and peripheral support variability introduces high uncertainty for wide device fleets.

## Program-Level Impact

- Keep Redox as a strategic R&D stream.
- Do not bind Samsung flash roadmap to Redox kernel assumptions.
- Maintain Android-native toolchain for execution path.

## Risk Snapshot (if Redox were forced into phone program)

| Risk | Likelihood | Impact | Comment |
|---|---|---|---|
| Missing smartphone driver paths | High | Critical | Not a target maturity area today |
| Linux userspace/runtime mismatch | High | Critical | Kali-on-Redox-kernel not practical |
| Hardware variability failures | High | High | Even laptop support is model-specific |

## Recommended Positioning in Kai-zen-OS

1. Keep Redox docs in `research/` and ADR trail.
2. Revisit only after clear upstream milestones for broader hardware/runtime support.
3. Continue extracting design patterns (isolation, service boundaries, fault containment) into Android pipeline architecture.

## Sources

- https://www.redox-os.org/faq/
- https://www.redox-os.org/news/porting-strategy/
- https://doc.redox-os.org/book/real-hardware.html
- https://doc.redox-os.org/book/installing.html
- https://gitlab.redox-os.org/redox-os/redox/-/raw/master/HARDWARE.md
