# Samsung Galaxy S10+ Current Setup (Sanitized)

This file captures the current known S10+ baseline without secrets.

## Device and ROM Baseline

- Device family: Galaxy S10+
- Confirmed model lineage in prior notes: `SM-G975F / lineage_beyond2lte`
- Android/Lineage package observed: `org.lineageos.jelly`

## Runtime Stack (Current)

- Android/LineageOS is the base OS layer.
- Kali environment runs as `kali-arm64` in proot (user-space), not as replacement kernel.
- `zeroclaw-api` runs in Termux services.
- `openwebui` runs inside Kali proot.

## Service Footprint (Observed)

- ZeroClaw API script path:
  - `/data/data/com.termux/files/home/.zeroclaw/api/server.py`
- OpenWebUI venv path:
  - `/root/.zeroclaw/openwebui-venv`
- OpenWebUI service port:
  - `8080`

## Provider/Auth State (Observed)

- Vault endpoint is configured and reachable (host redacted).
- Provider inventory has been observed as empty (`provider_count = 0`).
- OAuth/provider readiness has been observed as incomplete in prior checks.
- Notes from different sessions show token-state inconsistency; treat token status as re-validation required before implementation.

## Known Blockers

- No provider-backed live path confirmed as stable.
- Browser/OAuth flow instability remains unresolved.
- Provider count must be > 0 before live-response goals can pass.

## Pre-Implementation Re-Validation Checklist

- [ ] Confirm exact firmware/baseband and bootloader revision
- [ ] Confirm provider count and provider test endpoint pass
- [ ] Confirm OAuth/token continuity path
- [ ] Confirm app -> API -> provider end-to-end non-mock response
