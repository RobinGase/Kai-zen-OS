# ADR-0001: Safety Boundary

## Metadata

- **Date**: 2026-02-27
- **Status**: Accepted
- **Deciders**: RobinGase (owner), Claude orchestrator (advisory)
- **Review date**: Re-evaluate at Phase 4 entry (hardware pilot readiness)
- **Related risks**: R-03, R-05, R-08
- **Related bundles**: B01 (core governance), B02 (change/data integrity)

## Context

Kai-zen-OS targets Samsung Galaxy phones for custom image engineering.
Samsung devices have multiple irreversible or difficult-to-reverse
security mechanisms:

- **Knox counter**: trips permanently when a non-Samsung-signed image is
  flashed; affects warranty status and Samsung Pay. Cannot be reset on
  most models.
- **Android Verified Boot (AVB)**: cryptographic chain of trust that can
  reject unsigned partitions. Incorrect AVB configuration can soft-brick
  a device.
- **EFUSE / rollback index**: some Samsung bootloaders burn hardware fuses
  on firmware update, preventing downgrade. Once burned, this is
  physically irreversible.
- **Carrier-locked bootloaders**: US Snapdragon models often have OEM
  unlock permanently disabled by carrier firmware.

A single bad flash command — especially to critical partitions (boot,
recovery, vbmeta, super) — can result in a device that requires
specialized JTAG/ISP recovery or is permanently bricked.

## Decision

This repository remains **planning-only** until explicit transition
approval from the project owner. Specifically:

1. **No production flashing code** in this repo.
2. **No unattended destructive commands** — no script may execute
   `heimdall flash`, `odin`, `fastboot flash`, `dd` to block devices,
   or any partition-write operation without a human physically confirming
   each command.
3. **Emulator-first test requirement** — all automated validation runs
   against the Android emulator (`boomies_api35` AVD). Hardware testing
   is documentation-only until Phase 4 exit.
4. **No credentials or secrets in repository** — API keys, OAuth tokens,
   device unlock codes, and firmware signing keys are never stored in
   any tracked file.
5. **NAP autonomy ceiling A2** — no AI agent may take autonomous action
   beyond A2 (supervised autonomy with human approval for each
   consequential step).

## Alternatives Considered

1. **Allow dry-run flash commands on hardware with safety wrapper**:
   Rejected — "dry-run" modes for Heimdall/Odin are not reliably
   side-effect-free, and the risk of misconfiguration outweighs the
   value during planning phase.

2. **Allow automated emulator flashing without gate**:
   Rejected — even emulator flash operations should be reviewed before
   execution to build the habit and tooling for hardware safety gates.

3. **Defer all safety constraints to runtime enforcement**:
   Rejected — safety must be designed in from the planning phase, not
   bolted on later. NAP B01 requires governance from project inception.

## Consequences

### Positive
- Higher confidence before any hardware interaction.
- Audit trail establishes safety-first culture.
- Reduces risk of irreversible device damage during development.
- NAP-compliant from Phase 0.

### Negative
- Slower initial progress — cannot validate hardware-specific behaviors
  until Phase 4.
- Some emulator limitations cannot be discovered until hardware pilot.
- Requires discipline to maintain planning-only posture under pressure.

## Compliance

- Satisfies NAP B01 (core governance baseline).
- Satisfies NAP B02 (change safety, rollback, traceability).
- Enforces the Class 3 risk floor and A2 autonomy ceiling from
  `Docs/alignment/kai_zen_nap_alignment.md`.
