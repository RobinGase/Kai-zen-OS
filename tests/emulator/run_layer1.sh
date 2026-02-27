#!/bin/bash
# Layer 1: Infrastructure Tests
# Validates emulator environment is functional
# Target: boomies_api35 AVD via emulator-5554

set -uo pipefail

# Resolve ANDROID_HOME — handle Windows paths in Git Bash
if [ -d "/c/Users/Robin/scoop/apps/android-clt/current" ]; then
    SDK="/c/Users/Robin/scoop/apps/android-clt/current"
elif [ -n "${ANDROID_HOME:-}" ]; then
    SDK="$ANDROID_HOME"
else
    echo "FATAL: Cannot find Android SDK"
    exit 1
fi

ADB="${SDK}/platform-tools/adb.exe"
DEVICE="-s emulator-5554"

# Verify ADB exists
if [ ! -f "$ADB" ]; then
    echo "FATAL: adb not found at $ADB"
    exit 1
fi
PASS=0
FAIL=0
TOTAL=0

run_test() {
    local id="$1"
    local desc="$2"
    local cmd="$3"
    local expected="$4"
    TOTAL=$((TOTAL + 1))

    result=$(eval "$cmd" 2>/dev/null || echo "COMMAND_FAILED")

    if echo "$result" | grep -q "$expected"; then
        echo "  PASS  $id: $desc"
        PASS=$((PASS + 1))
    else
        echo "  FAIL  $id: $desc"
        echo "        Expected: $expected"
        echo "        Got:      $result"
        FAIL=$((FAIL + 1))
    fi
}

echo "========================================="
echo " LAYER 1: Infrastructure Tests"
echo " $(date +%Y-%m-%dT%H:%M:%S)"
echo "========================================="
echo ""

run_test "T-001" "Emulator boot completed" \
    "$ADB $DEVICE shell getprop sys.boot_completed" "1"

run_test "T-002" "ADB detects emulator" \
    "$ADB devices" "emulator-5554"

run_test "T-003" "ADB shell works" \
    "$ADB $DEVICE shell echo hello_kaizen" "hello_kaizen"

run_test "T-004" "API level is 35" \
    "$ADB $DEVICE shell getprop ro.build.version.sdk" "35"

run_test "T-005" "Filesystem writable" \
    "$ADB $DEVICE shell 'echo kz_test > /data/local/tmp/kz.txt && cat /data/local/tmp/kz.txt && rm /data/local/tmp/kz.txt'" "kz_test"

run_test "T-006" "Package manager works" \
    "$ADB $DEVICE shell pm list packages | head -1" "package:"

run_test "T-007" "Logcat streams" \
    "$ADB $DEVICE logcat -d -t 1" "beginning of"

echo ""
echo "========================================="
echo " RESULTS: $PASS passed, $FAIL failed (of $TOTAL)"
echo "========================================="

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
