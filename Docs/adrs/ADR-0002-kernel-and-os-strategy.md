# ADR-0002: Kernel and OS Strategy

## Metadata

- **Date**: 2026-02-27
- **Status**: Accepted
- **Deciders**: RobinGase (owner), Claude orchestrator (advisory)
- **Review date**: Re-evaluate if Redox reaches ARM64 device-tree maturity
- **Related risks**: R-06 (stale assumptions)
- **Related research**: `Docs/research/redox_microkernel_assessment.md`

## Context

The project initially explored Redox OS as a potential kernel for Samsung
phone images, combined with Kali Linux userland. Research revealed:

1. **Redox is in alpha state**. The kernel is functional on limited x86_64
   hardware but has no ARM/AArch64 support, no Android HAL compatibility,
   no cellular baseband integration, and no Samsung-specific driver stack.

2. **Samsung phones require the Linux kernel** (or a Linux-compatible
   kernel) to function. Android's HAL, cellular stack, GPU drivers,
   camera ISP drivers, and display drivers all assume a Linux kernel
   with specific Samsung vendor patches.

3. **Running Kali Linux desktop directly on Redox kernel** is not
   practical. Kali tools are Linux userland programs that depend on
   Linux syscalls, `/proc`, `/sys`, and Linux kernel modules.

4. **Redox has valuable architectural properties** — capability-based
   security, microkernel message-passing, memory-safe Rust
   implementation — that are worth studying for design inspiration.

## Decision

Use **Android/Samsung-compatible Linux kernel** strategy for all phone
targets.

- Redox remains an R&D workstream for microkernel design pattern study.
- Redox is **not** the deployment kernel for Samsung phone targets.
- Kali-on-Redox-kernel is **not** a current implementation target.
- Kali runs via proot in Termux on the Android/Linux kernel (current
  S10+ setup).

## Alternatives Considered

1. **Redox as primary kernel with Android compatibility layer**:
   Rejected — the engineering effort to add ARM64 support, Android HAL,
   cellular baseband, and Samsung-specific drivers to Redox would be
   measured in person-years and is far beyond project scope.

2. **Fuchsia/Zircon microkernel**:
   Not evaluated in depth. Fuchsia has Google backing and ARM64 support
   but no Samsung device trees and no path to Samsung phone deployment.
   Could be a future R&D comparison target.

3. **seL4 formally-verified microkernel**:
   Not evaluated. seL4 has ARM64 support and formal verification proofs
   but same lack of Android HAL and Samsung driver ecosystem.

4. **Standard LineageOS (Android + Linux kernel)**:
   Adopted — this is the proven, community-supported path for Samsung
   custom images with active maintainers for S10+.

## Consequences

### Positive
- Aligns with proven community tooling (LineageOS, Heimdall).
- Leverages existing S10+ device tree and kernel source.
- Avoids dead-end execution work against unsupported assumptions.
- Redox design patterns can still inform security architecture.

### Negative
- No microkernel-level isolation benefits on phone targets.
- Depends on community-maintained LineageOS kernel patches.
- If LineageOS drops S10+ support, we inherit that risk (see R-14).

## Design Patterns to Extract from Redox (R&D stream)

These Redox concepts may inform future Kai-zen-OS architecture without
requiring Redox as the actual kernel:

1. **Capability-based security model** — inform SELinux/SEAndroid policy
   design with capability-based thinking.
2. **Microkernel message-passing** — inform inter-process communication
   patterns in the orchestration layer.
3. **Memory-safe systems language (Rust)** — the orchestration framework
   (Rig) is already Rust-based, continuing this alignment.
