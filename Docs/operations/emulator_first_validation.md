# Emulator-First Validation Strategy

## Goal

De-risk logic, orchestration, and automation before any physical flash operations.

## What Emulator Validation Can Prove

- ADB control and automation scripts behave correctly.
- UI flow orchestration (Appium/Maestro) is stable.
- Provider routing, retries, and decision logic work.
- Artifact/logging pipeline works end-to-end.

## What Emulator Validation Cannot Prove

- Samsung Download Mode behavior
- Heimdall interactions with real bootloader/partitions
- Knox fuse/rollback/warranty-bit side effects
- Real modem/radio/vendor partition behavior

## Test Layers

1. **Logic tests**: routing, config validation, safety guards.
2. **UI tests**: login, settings, provider flow, fallback behavior.
3. **Fault tests**: network drops, auth failures, retry policies.
4. **Evidence tests**: logs and reports generated consistently.

## Exit Criteria to Enter Hardware Pilot

- Emulator suite green for critical flows.
- All hardware-only checks explicitly listed and accepted.
- Rollback/recovery plan approved for target model.

## Sources

- https://github.com/google/android-emulator-container-scripts
- https://raw.githubusercontent.com/LineageOS/android_packages_modules_adb/lineage-23.2/docs/user/adb.1.md
