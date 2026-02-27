# Remote Control and Automation Setup Plan

## Objective

Provide reliable remote operation and testing for Android devices while preserving safety and reproducibility.

## Control Layers

## Layer 1: Direct device control

- ADB over USB for stable primary control.
- Optional ADB-over-TCP for lab networking after USB pairing.

## Layer 2: Interactive mirroring

- `scrcpy` for low-latency screen/control.
- Use USB first, then optional TCP mode after trust established.

## Layer 3: Automated UI execution

- Appium (UiAutomator2) for deterministic automation.
- Optional Maestro flows for YAML-driven E2E flows.

## Layer 4: Session observability

- Capture command logs, screenshots, and test artifacts per run.
- Keep logs free of secrets and tokens.

## Operational Safety

- No unattended flashing operations in this phase.
- Require manual checkpoint before any destructive command class.
- Keep rollback package mapping documented per exact model.

## Minimal Runbook Template

1. Connect via USB and verify `adb devices`.
2. Start `scrcpy` for operator visibility.
3. Run automated smoke flow (Appium/Maestro).
4. Archive logs and screenshots with timestamped run id.
5. Mark run as `pass`, `partial`, or `blocked` with root cause.

## Sources

- https://raw.githubusercontent.com/LineageOS/android_packages_modules_adb/lineage-23.2/docs/user/adb.1.md
- https://github.com/Genymobile/scrcpy
- https://appium.io/docs/en/latest/
- https://maestro.mobile.dev/
