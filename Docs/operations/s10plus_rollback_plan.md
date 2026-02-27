# S10+ (SM-G975F) Rollback and Recovery Plan

> **Status**: Documentation only — no commands to be executed until Phase 4
> **Device**: Samsung Galaxy S10+ (SM-G975F, Exynos 9820, International)
> **Current state**: LineageOS (beyond2lte) with Lineage Recovery
> **NAP class**: Class 3 (irreversible device operations)
> **Last updated**: 2026-02-27

---

## Purpose

This document defines the rollback and recovery procedures for the S10+
baseline device. It exists so that **before any future flash operation**,
there is a documented, reviewed path back to a known-good state.

**This document is planning-only.** No commands in this file should be
executed until Phase 4 exit criteria are met and human approval is given.

---

## 1  Known-Good States

### State A: Current (LineageOS)

- **OS**: LineageOS (beyond2lte build)
- **Recovery**: Lineage Recovery
- **Bootloader**: Unlocked (OEM unlock enabled)
- **Knox counter**: Likely tripped (0x1) — verify before any operation
- **Services running**: Termux (ZeroClaw API), Kali proot (OpenWebUI)

### State B: Stock Samsung Firmware

- **OS**: Samsung One UI (stock Android)
- **Recovery**: Samsung stock recovery
- **Bootloader**: Can be re-locked (but Knox counter stays tripped)
- **Source**: sammobile.com or SamFW for official firmware files

---

## 2  Pre-Operation Checklist

Before ANY flash-related command (when Phase 4 is reached):

- [ ] Battery level ≥ 80%
- [ ] Full backup completed and verified (TWRP nandroid or adb backup)
- [ ] Backup stored on external device (not on phone being flashed)
- [ ] Current firmware version recorded: `adb shell getprop ro.build.display.id`
- [ ] Current baseband version recorded: `adb shell getprop gsm.version.baseband`
- [ ] Knox counter status recorded: visible in Download Mode or via `getprop`
- [ ] Bootloader unlock status confirmed: Download Mode shows "OEM Lock: OFF"
- [ ] ADB connectivity confirmed: `adb devices` shows device serial
- [ ] Heimdall connectivity confirmed (in Download Mode): `heimdall detect`
- [ ] Correct firmware file hashes verified against source (SHA-256)
- [ ] Recovery mode type confirmed (Lineage Recovery / TWRP / stock)
- [ ] USB cable confirmed data-capable (not charge-only)
- [ ] No pending OTA updates queued
- [ ] This rollback plan reviewed and approved by project owner

---

## 3  Rollback Scenarios

### Scenario A: Flash fails mid-operation (soft-brick)

**Symptoms**: Device stuck at boot logo, bootloop, or blank screen after
flash attempt.

**Recovery procedure**:

1. Power off device (hold Power + Volume Down for 10 seconds)
2. Enter Download Mode: hold Volume Down + Bixby + Power while
   connecting USB cable
3. Verify Heimdall detects device: `heimdall detect`
4. Flash known-good recovery image:
   ```bash
   # DOCUMENTATION ONLY — DO NOT EXECUTE
   heimdall flash --RECOVERY recovery.img
   ```
5. Boot into recovery and perform factory reset if needed
6. If recovery flash fails, proceed to Scenario C

### Scenario B: Flash succeeds but system is unstable

**Symptoms**: Device boots but has crashes, missing features, or
broken services.

**Recovery procedure**:

1. Boot into recovery mode (Power + Volume Up while booting)
2. Select "Factory Reset" / "Wipe data"
3. If still unstable, reflash known-good LineageOS build:
   ```bash
   # DOCUMENTATION ONLY — DO NOT EXECUTE
   adb sideload lineage-*-beyond2lte.zip
   ```
4. If sideload fails, use Heimdall to flash from Download Mode
5. Restore backup after confirmed stable boot

### Scenario C: Full restore to stock Samsung firmware

**When to use**: All custom ROM recovery fails, or decision to return
to stock Samsung firmware.

**Recovery procedure**:

1. Download correct stock firmware for SM-G975F from sammobile.com
   - **Verify exact model number** — SM-G975F, not SM-G975U or SM-G975N
   - **Verify region code** matches device's original region
   - **Verify SHA-256 hash** against source
2. Extract firmware files (AP, BL, CP, CSC, HOME_CSC)
3. Enter Download Mode on device
4. Option A — Heimdall:
   ```bash
   # DOCUMENTATION ONLY — DO NOT EXECUTE
   heimdall flash --BL bl_file.tar --AP ap_file.tar --CP cp_file.tar --CSC csc_file.tar
   ```
5. Option B — Odin (Windows):
   - Load BL, AP, CP, CSC into respective Odin slots
   - Verify "Auto Reboot" is checked
   - Click "Start"
6. Wait for flash to complete (5-15 minutes)
7. Device should boot into Samsung setup wizard
8. **Note**: Knox counter will remain tripped (0x1) even after stock restore.
   This is permanent and cannot be reversed.

### Scenario D: Hard brick (device unresponsive to all inputs)

**Symptoms**: No screen output, no Download Mode, no response to any
button combination.

**Recovery options** (listed by likelihood of success):

1. **Force reboot**: Hold Power + Volume Down for 30+ seconds
2. **Battery drain**: If device has sealed battery, wait 24-48 hours for
   full discharge, then try again
3. **USB Jig**: Samsung USB jig can force Download Mode on some models.
   These are available from Samsung repair channels.
4. **ISP (In-System Programming)**: Last resort. Requires disassembling
   device and connecting directly to eMMC test points. Professional
   repair only.
5. **Samsung service center**: Warranty likely voided (Knox tripped), but
   Samsung may still repair for a fee.

**Assessment**: Hard brick is extremely unlikely with correct firmware
and stable USB connection. Risk is elevated by: interrupted flash
(USB disconnect), wrong firmware version, wrong model firmware.

---

## 4  Backup Strategy

### What to back up

| Data | Method | Location |
|------|--------|----------|
| Full system (nandroid) | TWRP backup | External SD or USB OTG |
| User data | `adb backup -all` | Host PC |
| App list | `adb shell pm list packages` | Host PC (text file) |
| Internal storage | `adb pull /sdcard/ ./backup/` | Host PC |
| Boot/recovery images | `adb pull /dev/block/by-name/boot` | Host PC |
| Partition layout | `adb shell ls -la /dev/block/by-name/` | Host PC (text file) |
| Build properties | `adb shell getprop` | Host PC (text file) |

### Backup verification

- [ ] Nandroid backup file exists and is non-zero size
- [ ] ADB backup file exists and can be listed with `adb backup --list`
- [ ] Internal storage backup is complete (compare file counts)
- [ ] Boot image backup matches expected size for device

---

## 5  Risk Assessment for Rollback Operations

| Rollback type | Risk level | Time estimate | Success rate |
|--------------|-----------|---------------|-------------|
| Sideload LineageOS | Low | 5-10 min | >95% |
| Heimdall flash recovery | Low-Medium | 10-15 min | >90% |
| Full stock restore (Heimdall) | Medium | 15-30 min | >85% |
| Full stock restore (Odin) | Medium | 15-30 min | >85% |
| Hard brick recovery (USB Jig) | High | Hours | ~70% |
| Hard brick recovery (ISP) | Very High | Professional | ~50% |

---

## 6  Post-Rollback Validation

After any rollback operation:

- [ ] Device boots to home screen or setup wizard
- [ ] ADB connectivity restored: `adb devices` shows serial
- [ ] Correct firmware version confirmed: `adb shell getprop ro.build.display.id`
- [ ] No bootloop (observe 3 consecutive successful boots)
- [ ] Cellular radio functional (if returning to stock)
- [ ] Wi-Fi functional
- [ ] All backed-up data can be restored (if applicable)
- [ ] Knox counter status re-recorded

---

## Sources

- LineageOS S10+ install guide: https://wiki.lineageos.org/devices/beyond2lte/install/
- Heimdall: https://raw.githubusercontent.com/Benjamin-Dobell/Heimdall/master/README.md
- SamMobile firmware: https://www.sammobile.com/samsung/galaxy-s10-plus/firmware/
- Samsung Knox: https://docs.samsungknox.com/admin/fundamentals/whitepaper/samsung-knox-mobile-security/system-security/hw-backed-security/
