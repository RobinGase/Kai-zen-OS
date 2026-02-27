# ADR-0001: Safety Boundary

## Status

Accepted

## Decision

This repository remains planning-only until explicit transition approval.

- No production flashing code
- No unattended destructive commands
- Emulator-first test requirement
- No credentials/secrets in repository

## Rationale

Samsung bootloader/rollback/tamper pathways can be irreversible on mistakes.

## Consequences

- Slower initial progress, higher safety and auditability.
- Better confidence before hardware pilot.
