#!/bin/bash
# Deterministic self-tests for Phase 3.5 preflight gates.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PREFLIGHT_SCRIPT="$SCRIPT_DIR/run_flash_preflight.sh"

PASS=0
FAIL=0

TMP_DIR="$SCRIPT_DIR/fixtures/tmp_preflight"
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

ARTIFACTS_DIR="$SCRIPT_DIR/artifacts"
mkdir -p "$ARTIFACTS_DIR"

printf 'safe emulator flash trial file\n' > "$TMP_DIR/system.img"
GOOD_HASH="$(sha256sum "$TMP_DIR/system.img" | awk '{print $1}')"
BAD_HASH="0000000000000000000000000000000000000000000000000000000000000000"

cat > "$TMP_DIR/manifest_good.sha256" <<EOF
$GOOD_HASH  system.img
EOF

cat > "$TMP_DIR/manifest_bad_hash.sha256" <<EOF
$BAD_HASH  system.img
EOF

cat > "$TMP_DIR/manifest_bad_format.sha256" <<EOF
this-is-not-a-valid-manifest-line
EOF

run_case() {
    local id="$1"
    local desc="$2"
    local expected_rc="$3"
    shift 3

    set +e
    "$@" > "$ARTIFACTS_DIR/preflight_case_${id}.log" 2>&1
    rc=$?
    set -e

    if [ "$rc" -eq "$expected_rc" ]; then
        echo "  PASS  $id: $desc"
        PASS=$((PASS + 1))
    else
        echo "  FAIL  $id: $desc"
        echo "        Expected rc: $expected_rc"
        echo "        Actual rc:   $rc"
        echo "        Log:         $ARTIFACTS_DIR/preflight_case_${id}.log"
        FAIL=$((FAIL + 1))
    fi
}

echo "========================================="
echo " PHASE 3.5 PREFLIGHT SELF-TESTS"
echo " $(date +%Y-%m-%dT%H:%M:%S)"
echo "========================================="
echo ""

run_case "PFT-001" "Strict mode happy path passes" 0 \
    bash "$PREFLIGHT_SCRIPT" \
    --simulate strict \
    --target-serial emulator-5554 \
    --image-manifest "$TMP_DIR/manifest_good.sha256" \
    --approval-id HC-TEST-001 \
    --adb-devices-fixture tests/emulator/fixtures/adb_devices_single_emulator.txt \
    --artifacts-dir tests/emulator/artifacts

run_case "PFT-002" "Mixed emulator + phone is denied" 3 \
    bash "$PREFLIGHT_SCRIPT" \
    --simulate strict \
    --target-serial emulator-5554 \
    --image-manifest "$TMP_DIR/manifest_good.sha256" \
    --approval-id HC-TEST-002 \
    --adb-devices-fixture tests/emulator/fixtures/adb_devices_mixed_emulator_phone.txt \
    --artifacts-dir tests/emulator/artifacts

run_case "PFT-003" "Two active emulators is denied" 3 \
    bash "$PREFLIGHT_SCRIPT" \
    --simulate strict \
    --target-serial emulator-5554 \
    --image-manifest "$TMP_DIR/manifest_good.sha256" \
    --approval-id HC-TEST-003 \
    --adb-devices-fixture tests/emulator/fixtures/adb_devices_two_emulators.txt \
    --artifacts-dir tests/emulator/artifacts

run_case "PFT-004" "Missing target emulator is denied" 3 \
    bash "$PREFLIGHT_SCRIPT" \
    --simulate strict \
    --target-serial emulator-5554 \
    --image-manifest "$TMP_DIR/manifest_good.sha256" \
    --approval-id HC-TEST-004 \
    --adb-devices-fixture tests/emulator/fixtures/adb_devices_target_missing.txt \
    --artifacts-dir tests/emulator/artifacts

run_case "PFT-005" "Non-emulator serial argument is denied" 3 \
    bash "$PREFLIGHT_SCRIPT" \
    --simulate strict \
    --target-serial R58M689Q8JY \
    --image-manifest "$TMP_DIR/manifest_good.sha256" \
    --approval-id HC-TEST-005 \
    --adb-devices-fixture tests/emulator/fixtures/adb_devices_single_emulator.txt \
    --artifacts-dir tests/emulator/artifacts

run_case "PFT-006" "Missing approval id is usage error" 2 \
    bash "$PREFLIGHT_SCRIPT" \
    --simulate strict \
    --target-serial emulator-5554 \
    --image-manifest "$TMP_DIR/manifest_good.sha256" \
    --adb-devices-fixture tests/emulator/fixtures/adb_devices_single_emulator.txt \
    --artifacts-dir tests/emulator/artifacts

run_case "PFT-007" "Missing manifest is artifact failure" 5 \
    bash "$PREFLIGHT_SCRIPT" \
    --simulate strict \
    --target-serial emulator-5554 \
    --image-manifest "$TMP_DIR/missing_manifest.sha256" \
    --approval-id HC-TEST-007 \
    --adb-devices-fixture tests/emulator/fixtures/adb_devices_single_emulator.txt \
    --artifacts-dir tests/emulator/artifacts

run_case "PFT-008" "Manifest format errors are denied" 5 \
    bash "$PREFLIGHT_SCRIPT" \
    --simulate strict \
    --target-serial emulator-5554 \
    --image-manifest "$TMP_DIR/manifest_bad_format.sha256" \
    --approval-id HC-TEST-008 \
    --adb-devices-fixture tests/emulator/fixtures/adb_devices_single_emulator.txt \
    --artifacts-dir tests/emulator/artifacts

run_case "PFT-009" "Hash mismatch is denied" 5 \
    bash "$PREFLIGHT_SCRIPT" \
    --simulate strict \
    --target-serial emulator-5554 \
    --image-manifest "$TMP_DIR/manifest_bad_hash.sha256" \
    --approval-id HC-TEST-009 \
    --adb-devices-fixture tests/emulator/fixtures/adb_devices_single_emulator.txt \
    --artifacts-dir tests/emulator/artifacts

echo ""
echo "========================================="
echo " RESULTS: $PASS passed, $FAIL failed"
echo "========================================="

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
