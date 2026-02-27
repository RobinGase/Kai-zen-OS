# Samsung Device Support Matrix (Planning)

> **Last updated**: 2026-02-27
> **Status**: Partial — S10 detailed, S20-S24 need variant expansion

## Scope

Planning guidance for S10+ → S24+ expansion. This is not an execution
guarantee. Every entry must be verified against official sources before
pilot.

---

## Critical: Exynos vs Snapdragon

This is the **single most important distinction** for Samsung custom
image viability:

- **Exynos** (international models, suffix F/FD/G): bootloader unlock
  is generally possible via OEM Unlock in Developer Settings + Heimdall
- **Snapdragon** (US/Canada models, suffix U/U1/W): most carriers
  permanently disable OEM Unlock in firmware. Even if the hardware
  supports it, the carrier lock prevents bootloader unlock.
- **Qualcomm modem models** (some regions): mixed — depends on carrier

**Rule**: Unless you have confirmed OEM Unlock availability on the
specific model/carrier combination, assume Snapdragon US variants are
**do-not-attempt**.

---

## S10 Family (2019) — Exynos 9820 / Snapdragon 855

### Baseline device: SM-G975F (S10+ Exynos International)

| Field | Value | Confidence | Source |
|-------|-------|------------|--------|
| SoC | Exynos 9820 | High | Device inspection |
| Codename | `beyond2lte` | High | LineageOS wiki |
| LineageOS status | Officially supported, active maintainer (Linux4) | High | https://wiki.lineageos.org/devices/beyond2lte/ |
| Bootloader unlock | Yes (OEM Unlock in Dev Settings) | High | Confirmed on device |
| Knox counter | Trips on custom image flash (0x0 → 0x1) | High | Samsung Knox docs |
| Heimdall support | Yes — primary flash tool | High | Heimdall README |
| Recovery | Lineage Recovery (current) | High | Device inspection |
| AVB | AVB 1.0, can be disabled with custom vbmeta | High | LineageOS install guide |

### S10 Family — Full Variant List

| Model | Name | SoC | Region | BL Unlock | LineageOS | Status |
|-------|------|-----|--------|-----------|-----------|--------|
| SM-G970F | S10e (Exynos) | Exynos 9820 | International | Yes | `beyond0lte` — Supported | Secondary candidate |
| SM-G970U | S10e (Snapdragon) | SD 855 | US | **No (carrier-locked)** | Not supported | **Do-not-attempt** |
| SM-G970N | S10e (Exynos) | Exynos 9820 | Korea | Likely yes | Check wiki | Research-only |
| SM-G973F | S10 (Exynos) | Exynos 9820 | International | Yes | `beyond1lte` — Supported | Secondary candidate |
| SM-G973U | S10 (Snapdragon) | SD 855 | US | **No (carrier-locked)** | Not supported | **Do-not-attempt** |
| SM-G975F | **S10+ (Exynos)** | Exynos 9820 | International | **Yes** | `beyond2lte` — **Supported** | **Baseline target** |
| SM-G975U | S10+ (Snapdragon) | SD 855 | US | **No (carrier-locked)** | Not supported | **Do-not-attempt** |
| SM-G975N | S10+ (Exynos) | Exynos 9820 | Korea | Likely yes | Check wiki | Research-only |
| SM-G977B | S10 5G (Exynos) | Exynos 9820 | International | Yes | `beyondx` — Check wiki | Research-only |
| SM-G977U | S10 5G (Snapdragon) | SD 855 | US | **No** | Not supported | **Do-not-attempt** |

---

## S20 Family (2020) — Exynos 990 / Snapdragon 865

### Knox changes: Knox 3.5, hardware attestation strengthened

| Model | Name | SoC | Codename | LineageOS | Status |
|-------|------|-----|----------|-----------|--------|
| SM-G980F | S20 (Exynos) | Exynos 990 | `x1s` | Officially supported | Secondary candidate |
| SM-G981U | S20 5G (SD) | SD 865 | — | Not supported | **Do-not-attempt** |
| SM-G985F | S20+ (Exynos) | Exynos 990 | `y2s` | Officially supported | Secondary candidate |
| SM-G986U | S20+ 5G (SD) | SD 865 | — | Not supported | **Do-not-attempt** |
| SM-G988B | S20 Ultra (Exynos) | Exynos 990 | `z3s` | Officially supported | Secondary candidate |
| SM-G988U | S20 Ultra (SD) | SD 865 | — | Not supported | **Do-not-attempt** |
| SM-G781B | S20 FE (Exynos) | Exynos 990 | `r8s` | Officially supported | Secondary candidate |
| SM-G781U | S20 FE (SD) | SD 865 | — | Check wiki | Research-only |

---

## S21 Family (2021) — Exynos 2100 / Snapdragon 888

### Critical changes:
- **Knox Vault introduced** — hardware security module for credential
  storage. Cannot be bypassed or reset.
- **AVB 2.0 enforced** — stricter verified boot chain
- **GKI (Generic Kernel Image)** transition begins — affects device tree
  structure

| Model | Name | SoC | LineageOS | Status | Notes |
|-------|------|-----|-----------|--------|-------|
| SM-G991B | S21 (Exynos) | Exynos 2100 | Community builds | Research-only | Knox Vault present |
| SM-G991U | S21 (SD) | SD 888 | Not supported | **Do-not-attempt** | |
| SM-G996B | S21+ (Exynos) | Exynos 2100 | Community builds | Research-only | |
| SM-G998B | S21 Ultra (Exynos) | Exynos 2100 | Community builds | Research-only | Most activity on XDA |

---

## S22 Family (2022) — Exynos 2200 / Snapdragon 8 Gen 1

### Critical changes:
- **Stronger AVB enforcement** — some variants check vbmeta more aggressively
- **Samsung added additional anti-rollback protections**
- **US models: Snapdragon only** — no Exynos variant for US market

| Model | Name | SoC | LineageOS | Status | Notes |
|-------|------|-----|-----------|--------|-------|
| SM-S901B | S22 (Exynos) | Exynos 2200 | Limited community | Research-only | Exynos 2200 GPU issues reported |
| SM-S901U | S22 (SD) | SD 8 Gen 1 | Not supported | **Do-not-attempt** | |
| SM-S908B | S22 Ultra (Exynos) | Exynos 2200 | Limited community | Research-only | |

---

## S23 Family (2023) — Snapdragon 8 Gen 2 (all regions)

### Critical changes:
- **All regions use Snapdragon** — Samsung dropped Exynos for S23 globally
- **Bootloader unlock**: depends entirely on regional/carrier firmware
- **Community ROM support**: limited, fragmented

| Model | Name | SoC | LineageOS | Status | Notes |
|-------|------|-----|-----------|--------|-------|
| SM-S911B | S23 | SD 8 Gen 2 | Very limited | Research-only | BL unlock varies by region |
| SM-S918B | S23 Ultra | SD 8 Gen 2 | XDA threads only | Research-only | Most community interest |

---

## S24 Family (2024) — Snapdragon 8 Gen 3 / Exynos 2400

### Critical changes:
- **Exynos returned** for some regions (S24/S24+, not S24 Ultra)
- **Even stricter Knox and AVB** — Galaxy AI features tied to Samsung firmware
- **Community ROM support**: minimal, very early

| Model | Name | SoC | LineageOS | Status | Notes |
|-------|------|-----|-----------|--------|-------|
| SM-S921B | S24 (Exynos) | Exynos 2400 | None found | Research-only / high risk | Too new for reliable custom ROM |
| SM-S928U | S24 Ultra (SD) | SD 8 Gen 3 | None found | **Do-not-attempt** | US SD, no BL unlock |
| SM-S928B | S24 Ultra (Exynos) | — | None found | Research-only / high risk | Region-dependent |

---

## Do-Not-Attempt List

All US Snapdragon variants across all families. Specifically:

- Any model ending in `U` or `U1` (US carrier)
- Any model ending in `W` (Canadian carrier)
- Any Snapdragon model where OEM Unlock is confirmed disabled

**Reason**: Carrier firmware permanently disables bootloader unlock.
No known bypass exists that doesn't void all warranties and risk
permanent device lockout.

---

## Hard Rules

1. **Never generalize by marketing name only.**
2. **Always bind support to exact model number + region + carrier + SoC.**
3. **Mark unsupported as unsupported** until exact evidence exists.
4. **Snapdragon US = do-not-attempt** unless proven otherwise for specific model.
5. **Knox Vault (S21+) = additional risk** — document vault implications per family.

## Planning Gate for Moving a Model to Pilot

Before any variant advances from "research-only" to "secondary candidate":

- [ ] Bootloader unlock path documented and repeatable for exact model
- [ ] Recovery/flash path documented with rollback strategy
- [ ] At least one known-good restore path to stock firmware
- [ ] Knox counter / Knox Vault implications documented
- [ ] AVB handling procedure documented (vbmeta patching if needed)
- [ ] Emulator test suite pass for non-hardware logic
- [ ] At least one community report of successful custom ROM on exact variant

## Sources

- LineageOS device list: https://wiki.lineageos.org/devices/
- LineageOS S10+ (beyond2lte): https://wiki.lineageos.org/devices/beyond2lte/
- LineageOS S10+ install guide: https://wiki.lineageos.org/devices/beyond2lte/install/
- Heimdall: https://raw.githubusercontent.com/Benjamin-Dobell/Heimdall/master/README.md
- Samsung Knox hardware security: https://docs.samsungknox.com/admin/fundamentals/whitepaper/samsung-knox-mobile-security/system-security/hw-backed-security/
- XDA S23 Ultra: https://xdaforums.com/f/samsung-galaxy-s23-ultra.12713/
- XDA S24 Ultra: https://xdaforums.com/f/samsung-galaxy-s24-ultra.12819/
- Samsung model number decoder: https://www.samsung.com/semiconductor/minisite/exynos/
