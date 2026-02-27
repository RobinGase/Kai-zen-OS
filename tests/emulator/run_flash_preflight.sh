#!/bin/bash
# Phase 3.5: Emulator flash preflight safety gates
# Fail-closed checks before any flash-path trial in disposable AVD only.

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

EXIT_USAGE=2
EXIT_SAFETY=3
EXIT_READY=4
EXIT_ARTIFACT=5

SIMULATE_MODE="${PRECHECK_SIMULATE:-strict}"
ARTIFACTS_DIR="tests/emulator/artifacts"
TARGET_SERIAL=""
MANIFEST_PATH=""
APPROVAL_ID=""
ADB_FIXTURE=""

PASS=0

usage() {
    cat <<'EOF'
Usage:
  bash tests/emulator/run_flash_preflight.sh \
    --target-serial emulator-5554 \
    --image-manifest tests/emulator/flash/manifest.sha256 \
    --approval-id HC-2026-02-27-001 \
    [--artifacts-dir tests/emulator/artifacts] \
    [--simulate strict|off] \
    [--adb-devices-fixture tests/emulator/fixtures/adb_devices_single_emulator.txt]

Notes:
- strict mode uses a fixture for deterministic safe testing.
- off mode queries live ADB devices and enforces emulator-only targeting.
EOF
}

resolve_path() {
    local p="$1"
    if [[ "$p" == /* ]]; then
        printf '%s\n' "$p"
    else
        printf '%s\n' "$REPO_ROOT/$p"
    fi
}

pass_gate() {
    local id="$1"
    local msg="$2"
    echo "  PASS  $id: $msg"
    PASS=$((PASS + 1))
}

fail_gate() {
    local code="$1"
    local id="$2"
    local msg="$3"
    echo "  FAIL  $id: $msg"
    echo ""
    echo "RESULT: FAIL ($id)"
    exit "$code"
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --target-serial)
            TARGET_SERIAL="${2:-}"
            shift 2
            ;;
        --image-manifest)
            MANIFEST_PATH="${2:-}"
            shift 2
            ;;
        --approval-id)
            APPROVAL_ID="${2:-}"
            shift 2
            ;;
        --artifacts-dir)
            ARTIFACTS_DIR="${2:-}"
            shift 2
            ;;
        --simulate)
            SIMULATE_MODE="${2:-}"
            shift 2
            ;;
        --adb-devices-fixture)
            ADB_FIXTURE="${2:-}"
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $1"
            usage
            exit "$EXIT_USAGE"
            ;;
    esac
done

if [ -z "$TARGET_SERIAL" ] || [ -z "$MANIFEST_PATH" ] || [ -z "$APPROVAL_ID" ]; then
    echo "Missing required arguments."
    usage
    exit "$EXIT_USAGE"
fi

if [ "$SIMULATE_MODE" != "strict" ] && [ "$SIMULATE_MODE" != "off" ]; then
    fail_gate "$EXIT_USAGE" "PF-000" "--simulate must be strict or off"
fi

ARTIFACTS_ABS="$(resolve_path "$ARTIFACTS_DIR")"
mkdir -p "$ARTIFACTS_ABS"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$ARTIFACTS_ABS/flash_preflight_${TIMESTAMP}.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "========================================="
echo " PHASE 3.5: FLASH PREFLIGHT"
echo " $(date +%Y-%m-%dT%H:%M:%S)"
echo "========================================="
echo "mode=$SIMULATE_MODE"
echo "target_serial=$TARGET_SERIAL"
echo "approval_id=$APPROVAL_ID"
echo "manifest=$MANIFEST_PATH"
echo "log_file=$LOG_FILE"
echo ""

MANIFEST_ABS="$(resolve_path "$MANIFEST_PATH")"
MANIFEST_DIR="$(cd "$(dirname "$MANIFEST_ABS")" && pwd)"

if [ -d "/c/Users/Robin/scoop/apps/android-clt/current" ]; then
    SDK="/c/Users/Robin/scoop/apps/android-clt/current"
elif [ -n "${ANDROID_HOME:-}" ] && [ -d "$ANDROID_HOME" ]; then
    SDK="$ANDROID_HOME"
else
    SDK=""
fi

ADB=""
if [ -n "$SDK" ] && [ -f "$SDK/platform-tools/adb.exe" ]; then
    ADB="$SDK/platform-tools/adb.exe"
fi

# PF-001: Tooling checks
if [ "$SIMULATE_MODE" = "off" ]; then
    if [ -z "$ADB" ]; then
        fail_gate "$EXIT_READY" "PF-001" "ADB not found (SDK missing or invalid)"
    fi
    pass_gate "PF-001" "ADB resolved"
else
    pass_gate "PF-001" "ADB live check skipped in strict simulation"
fi

if ! command -v sha256sum >/dev/null 2>&1; then
    fail_gate "$EXIT_ARTIFACT" "PF-001b" "sha256sum not available"
fi
pass_gate "PF-001b" "sha256sum available"

# PF-002: Input checks
if [[ "$TARGET_SERIAL" =~ [[:cntrl:]] ]] || [[ "$APPROVAL_ID" =~ [[:cntrl:]] ]]; then
    fail_gate "$EXIT_USAGE" "PF-002" "Control characters in input"
fi
pass_gate "PF-002" "Required inputs are present and sane"

# PF-003: Target must be emulator serial
if ! [[ "$TARGET_SERIAL" =~ ^emulator-[0-9]+$ ]]; then
    fail_gate "$EXIT_SAFETY" "PF-003" "Target serial must match emulator-*"
fi
pass_gate "PF-003" "Target serial format accepted"

# Gather device topology from fixture or live adb
RAW_DEVICES=""
if [ "$SIMULATE_MODE" = "strict" ]; then
    if [ -z "$ADB_FIXTURE" ]; then
        fail_gate "$EXIT_USAGE" "PF-004" "strict mode requires --adb-devices-fixture"
    fi
    FIXTURE_ABS="$(resolve_path "$ADB_FIXTURE")"
    if [ ! -f "$FIXTURE_ABS" ]; then
        fail_gate "$EXIT_USAGE" "PF-004" "fixture not found: $ADB_FIXTURE"
    fi
    RAW_DEVICES="$(<"$FIXTURE_ABS")"
else
    RAW_DEVICES="$($ADB devices -l)"
fi

SERIALS=()
STATES=()
while IFS= read -r line; do
    [ -z "$line" ] && continue
    [[ "$line" == "List of devices attached"* ]] && continue
    [[ "$line" == '*'* ]] && continue

    serial="$(printf '%s\n' "$line" | awk '{print $1}')"
    state="$(printf '%s\n' "$line" | awk '{print $2}')"

    if [ -z "$serial" ] || [ -z "$state" ]; then
        fail_gate "$EXIT_SAFETY" "PF-004" "Malformed devices line: $line"
    fi

    SERIALS+=("$serial")
    STATES+=("$state")
done <<< "$RAW_DEVICES"

TARGET_FOUND=0
EMULATOR_COUNT=0
for i in "${!SERIALS[@]}"; do
    s="${SERIALS[$i]}"
    st="${STATES[$i]}"

    if [[ "$s" =~ ^emulator-[0-9]+$ ]] && [ "$st" = "device" ]; then
        EMULATOR_COUNT=$((EMULATOR_COUNT + 1))
    fi

    if [ "$s" = "$TARGET_SERIAL" ] && [ "$st" = "device" ]; then
        TARGET_FOUND=1
    fi

    if ! [[ "$s" =~ ^emulator-[0-9]+$ ]]; then
        case "$st" in
            device|offline|unauthorized|recovery|sideload)
                fail_gate "$EXIT_SAFETY" "PF-005" "Non-emulator attached: $s ($st)"
                ;;
        esac
    fi
done

if [ "$TARGET_FOUND" -ne 1 ]; then
    fail_gate "$EXIT_SAFETY" "PF-004" "Target emulator not attached as device"
fi
pass_gate "PF-004" "Target emulator is attached"
pass_gate "PF-005" "No non-emulator devices attached"

if [ "$EMULATOR_COUNT" -ne 1 ]; then
    fail_gate "$EXIT_SAFETY" "PF-006" "Expected exactly 1 active emulator, found $EMULATOR_COUNT"
fi
pass_gate "PF-006" "Exactly one active emulator"

if [ "$SIMULATE_MODE" = "off" ]; then
    qemu_prop="$($ADB -s "$TARGET_SERIAL" shell getprop ro.kernel.qemu | tr -d '\r')"
    if [ "$qemu_prop" != "1" ]; then
        fail_gate "$EXIT_READY" "PF-007" "ro.kernel.qemu is not 1"
    fi
    pass_gate "PF-007" "ro.kernel.qemu confirms emulator"

    boot_completed="$($ADB -s "$TARGET_SERIAL" shell getprop sys.boot_completed | tr -d '\r')"
    state="$($ADB -s "$TARGET_SERIAL" get-state | tr -d '\r')"
    if [ "$boot_completed" != "1" ] || [ "$state" != "device" ]; then
        fail_gate "$EXIT_READY" "PF-008" "Emulator not fully booted"
    fi
    pass_gate "PF-008" "Emulator boot complete and online"
else
    pass_gate "PF-007" "Live emulator property check skipped in strict simulation"
    pass_gate "PF-008" "Live boot-complete check skipped in strict simulation"
fi

if [ -z "$APPROVAL_ID" ]; then
    fail_gate "$EXIT_USAGE" "PF-009" "approval id is required"
fi
pass_gate "PF-009" "Human checkpoint token recorded"

if [ ! -f "$MANIFEST_ABS" ]; then
    fail_gate "$EXIT_ARTIFACT" "PF-010" "Manifest not found: $MANIFEST_PATH"
fi

LINE_COUNT=0
while IFS= read -r line; do
    [ -z "$line" ] && continue
    LINE_COUNT=$((LINE_COUNT + 1))

    if ! [[ "$line" =~ ^([0-9a-fA-F]{64})[[:space:]]{2}(.+)$ ]]; then
        fail_gate "$EXIT_ARTIFACT" "PF-010" "Malformed manifest line: $line"
    fi

    rel_file="${BASH_REMATCH[2]}"
    file_abs="$MANIFEST_DIR/$rel_file"
    if [ ! -f "$file_abs" ]; then
        fail_gate "$EXIT_ARTIFACT" "PF-011" "Missing image artifact: $rel_file"
    fi
done < "$MANIFEST_ABS"

if [ "$LINE_COUNT" -lt 1 ]; then
    fail_gate "$EXIT_ARTIFACT" "PF-010" "Manifest is empty"
fi

pass_gate "PF-010" "Manifest format validated"
pass_gate "PF-011" "All manifest artifacts present"

set +e
CHECK_OUT="$(cd "$MANIFEST_DIR" && sha256sum -c "$(basename "$MANIFEST_ABS")" 2>&1)"
CHECK_CODE=$?
set -e

if [ "$CHECK_CODE" -ne 0 ]; then
    echo "$CHECK_OUT"
    fail_gate "$EXIT_ARTIFACT" "PF-012" "Hash verification failed"
fi
pass_gate "PF-012" "Hash verification passed"

echo ""
echo "========================================="
echo " RESULTS: $PASS passed, 0 failed"
echo "========================================="
echo "RESULT: PASS"
