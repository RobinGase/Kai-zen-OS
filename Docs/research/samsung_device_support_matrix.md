# Samsung Device Support Matrix (Planning)

## Scope

Planning guidance for S10+ -> S24+ expansion. This is not an execution guarantee.

## Matrix

| Family | Example models | Current planning status | Confidence | Notes |
|---|---|---|---|---|
| S10+ | SM-G975F / beyond2lte | Baseline target | High | Official Lineage install path exists for specific models. |
| S20 family | Exynos variants by codename (`x1s`, `y2s`, `z3s`, `r8s`) | Secondary candidate | Medium | Several official Lineage pages exist by codename; must verify exact SKU. |
| S21 family | region/carrier specific | Research-only | Low-Medium | Support is less uniform; often community-driven. |
| S22 family | region/carrier specific | Research-only | Low-Medium | Per-model unlock and custom ROM viability varies. |
| S23 family | region/carrier specific | Research-only | Low | Usually community-thread dependent; high variance. |
| S24+ family | region/carrier specific | Research-only / high risk | Low | Strong model/region constraints expected; keep out of pilot until validated. |

## Hard Rules

1. Never generalize by marketing name only.
2. Always bind support to exact model number + region + carrier + bootloader revision.
3. Mark unsupported as unsupported until exact evidence exists.

## Planning Gate for Moving a Model to Pilot

- Bootloader unlock path documented and repeatable for exact model.
- Recovery/flash path documented with rollback strategy.
- At least one known-good restore path to stock firmware.
- Emulator test suite pass for non-hardware logic.

## Sources

- https://wiki.lineageos.org/devices/
- https://wiki.lineageos.org/devices/beyond2lte/
- https://wiki.lineageos.org/devices/beyond2lte/install/
- https://raw.githubusercontent.com/Benjamin-Dobell/Heimdall/master/README.md
- https://xdaforums.com/f/samsung-galaxy-s23-ultra.12713/
- https://xdaforums.com/f/samsung-galaxy-s24-ultra.12819/
