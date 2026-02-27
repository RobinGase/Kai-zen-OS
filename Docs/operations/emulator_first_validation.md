# Emulator-First Validation Strategy

> **Last updated**: 2026-02-27
> **Emulator**: Android Emulator v36.4.9 (QEMU-based)
> **AVD**: `boomies_api35` (API 35, Google APIs, x86_64)
> **ADB**: v36.0.2

## Goal

De-risk logic, orchestration, and automation before any physical device
interaction. All automated testing runs exclusively on the Android emulator.
**No commands are ever executed on real hardware from this repo.**

---

## Environment (Confirmed)

| Component | Value | Location |
|-----------|-------|----------|
| Android SDK | Scoop-installed | `%ANDROID_HOME%` (android-clt) |
| Emulator | v36.4.9 | `%ANDROID_HOME%/emulator/emulator.exe` |
| ADB | v36.0.2 | `%ANDROID_HOME%/platform-tools/adb.exe` |
| Platforms | android-34, android-35, android-36 | `%ANDROID_HOME%/platforms/` |
| System image | android-35/google_apis (x86_64) | `%ANDROID_HOME%/system-images/` |
| AVD name | `boomies_api35` | `~/.android/avd/boomies_api35.avd/` |
| AVD target | android-35 (API 35) | Confirmed via AVD ini |
| Host OS | Windows 10 (build 26200) | — |

### Boot command

```bash
emulator.exe -avd boomies_api35 -no-snapshot-load
```

### ADB connectivity test

```bash
adb devices         # Should list emulator-5554
adb shell getprop ro.build.version.sdk   # Should return 35
adb shell getprop ro.product.model       # Emulator model string
```

---

## What Emulator Validation Can Prove

| Category | Testable? | How |
|----------|----------|-----|
| ADB control and automation scripts | **Yes** | `adb shell`, `adb push/pull`, `adb install` |
| UI flow orchestration (Appium/Maestro) | **Yes** | Appium connects to emulator via ADB |
| Provider routing and decision logic | **Yes** | Mock LLM endpoints, test tier escalation |
| Auth flow simulation | **Yes** | Mock OAuth endpoints, test token handling |
| Artifact/logging pipeline | **Yes** | Write logs to emulator filesystem, verify |
| Filesystem layout validation | **Yes** | Verify directory structure, permissions |
| Service health checks | **Yes** | Start/stop services, verify status |
| Network connectivity | **Yes** | Emulator has network access via host |
| App install/uninstall lifecycle | **Yes** | `adb install`, `adb uninstall` |
| Logcat monitoring and parsing | **Yes** | `adb logcat` with filters |
| scrcpy screen mirroring | **Yes** | scrcpy connects to emulator via ADB |

## What Emulator Validation Cannot Prove

| Category | Why not | Impact on planning |
|----------|---------|-------------------|
| Samsung Download Mode | Emulator doesn't have Samsung firmware/bootloader | Flash procedure cannot be validated |
| Heimdall flash operations | No real bootloader to interact with | Flash command sequences are documentation-only |
| Knox counter/fuse behavior | No Knox hardware module in emulator | Knox implications are research-only |
| Knox Vault (S21+) | Hardware security module not emulated | Vault behavior is research-only |
| Real modem/radio behavior | Emulator uses virtual modem | Cellular functionality untestable |
| Vendor partition behavior | Emulator uses generic vendor image | Samsung-specific HAL untestable |
| Battery/thermal behavior | No physical sensors | Cannot validate pre-flash battery checks |
| USB/Heimdall connectivity | No USB passthrough to bootloader | Connection procedures are documentation-only |
| Actual flash timing/reliability | Emulator I/O != real eMMC/UFS | Performance characteristics differ |

---

## Test Taxonomy

### Layer 1: Infrastructure Tests

Validate that the development environment and emulator are functional.

| Test ID | Description | Command | Expected result |
|---------|-------------|---------|-----------------|
| T-001 | Emulator boots | `emulator -avd boomies_api35` | Boot completes, home screen visible |
| T-002 | ADB detects emulator | `adb devices` | `emulator-5554 device` listed |
| T-003 | ADB shell works | `adb shell echo "hello"` | Returns "hello" |
| T-004 | API level correct | `adb shell getprop ro.build.version.sdk` | Returns "35" |
| T-005 | Filesystem writable | `adb push test.txt /sdcard/` | File transferred |
| T-006 | App install works | `adb install sample.apk` | Success |
| T-007 | Logcat streams | `adb logcat -d -t 10` | Returns log entries |

### Layer 2: Logic Tests

Validate routing, configuration, and safety guard behavior.

| Test ID | Description | Method | Expected result |
|---------|-------------|--------|-----------------|
| T-010 | Task routing: M-FAST tag | Mock orchestrator input with `test` tag | Routes to M-FAST slot |
| T-011 | Task routing: M-KERNEL tag | Mock input with `kernel-patch` tag | Routes to M-KERNEL, flags human approval |
| T-012 | Confidence escalation | Mock M-FAST response with confidence 0.5 | Escalates to M-HEAVY |
| T-013 | Tier C dual verification | Mock Class 3 task | Both M-HEAVY and M-VERIFY invoked independently |
| T-014 | Safety boundary check | Mock destructive command request | Blocked by safety guard |
| T-015 | Budget alert | Mock token usage at 80% | Alert triggered |

### Layer 3: UI / Automation Tests

Validate interaction automation tools work with the emulator.

| Test ID | Description | Tool | Expected result |
|---------|-------------|------|-----------------|
| T-020 | scrcpy connects to emulator | scrcpy | Screen mirror visible |
| T-021 | Appium session starts | Appium + UiAutomator2 | Session created |
| T-022 | Appium can read screen | Appium findElement | Element found |
| T-023 | Maestro flow runs | Maestro test.yaml | Flow completes |

### Layer 4: Fault / Resilience Tests

Validate system handles failures gracefully.

| Test ID | Description | Method | Expected result |
|---------|-------------|--------|-----------------|
| T-030 | Network drop during API call | Disable emulator network | Retry or fail-closed |
| T-031 | Auth token expiry | Mock expired OAuth token | Re-auth or graceful error |
| T-032 | Model endpoint down | Mock 503 from Gemini API | Fail-closed, no auto-approval |
| T-033 | Invalid model response | Mock malformed JSON | Schema validation rejects, retry |

### Layer 5: Evidence / Audit Tests

Validate that logging and reporting work correctly.

| Test ID | Description | Method | Expected result |
|---------|-------------|--------|-----------------|
| T-040 | Task routing log generated | Run routing test | Log file contains task ID, slot, model |
| T-041 | Tier C decision log | Run Tier C mock | Both model outputs and arbitration logged |
| T-042 | Tier K approval log | Run Tier K mock | Human approval status logged |
| T-043 | Error log format | Trigger error condition | Structured error with timestamp and context |

---

## Exit Criteria to Enter Hardware Pilot (Phase 4)

All of the following must be true:

- [ ] All Layer 1 tests pass (infrastructure functional)
- [ ] All Layer 2 tests pass (routing logic correct)
- [ ] All Layer 3 tests pass (automation tools functional)
- [ ] All Layer 4 tests pass (fault handling correct)
- [ ] All Layer 5 tests pass (audit trail functional)
- [ ] All hardware-only behaviors explicitly listed and acknowledged
- [ ] Rollback/recovery plan approved for SM-G975F
- [ ] Human review of all test results completed
- [ ] NAP governance score computed and above approval threshold

---

## Test Execution Plan

1. **Immediate** (Phase 1): Run Layer 1 tests to validate environment
2. **Phase 2**: Run Layer 2 tests with mock orchestrator
3. **Phase 3**: Run Layers 3-5 with full test harness
4. **Phase 3 exit**: All tests pass, results documented

## Sources

- Android emulator docs: https://developer.android.com/studio/run/emulator-commandline
- ADB docs: https://developer.android.com/tools/adb
- scrcpy: https://github.com/Genymobile/scrcpy
- Appium: https://appium.io/docs/en/latest/
- Emulator container scripts: https://github.com/google/android-emulator-container-scripts
