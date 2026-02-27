#!/bin/bash
# Layer 4: Fault / Resilience Tests
# Validates that the emulator and ADB handle failure conditions gracefully
# Tests: network disruption, invalid commands, process recovery

set -euo pipefail

if [ -d "/c/Users/Robin/scoop/apps/android-clt/current" ]; then
    SDK="/c/Users/Robin/scoop/apps/android-clt/current"
elif [ -n "${ANDROID_HOME:-}" ]; then
    SDK="$ANDROID_HOME"
else
    echo "FATAL: Cannot find Android SDK"; exit 1
fi
ADB="${SDK}/platform-tools/adb.exe"
DEVICE="-s emulator-5554"
PASS=0
FAIL=0
TOTAL=0

run_test() {
    local id="$1"; local desc="$2"; local cmd="$3"; local expected="$4"; local exit_mode="${5:-zero}"
    local result exit_code pattern_ok=0 exit_ok=0

    TOTAL=$((TOTAL + 1))

    set +e
    result=$(eval "$cmd" 2>&1)
    exit_code=$?
    set -e

    if echo "$result" | grep -qiE "$expected"; then
        pattern_ok=1
    fi

    case "$exit_mode" in
        zero)
            if [ "$exit_code" -eq 0 ]; then exit_ok=1; fi
            ;;
        nonzero)
            if [ "$exit_code" -ne 0 ]; then exit_ok=1; fi
            ;;
        any)
            exit_ok=1
            ;;
        *)
            echo "FATAL: Unknown exit mode: $exit_mode"
            exit 1
            ;;
    esac

    if [ "$pattern_ok" -eq 1 ] && [ "$exit_ok" -eq 1 ]; then
        echo "  PASS  $id: $desc"
        PASS=$((PASS + 1))
    else
        echo "  FAIL  $id: $desc"
        echo "        Expected pattern: $expected"
        echo "        Expected exit:    $exit_mode"
        echo "        Actual exit:      $exit_code"
        echo "        Got:              $(echo "$result" | head -3)"
        FAIL=$((FAIL + 1))
    fi
}

echo "========================================="
echo " LAYER 4: Fault / Resilience Tests"
echo " $(date +%Y-%m-%dT%H:%M:%S)"
echo "========================================="
echo ""

# T-030: Invalid ADB command handled gracefully
echo "--- T-030: Invalid command handling ---"
run_test "T-030" "Invalid shell command returns error" \
    "$ADB $DEVICE shell /nonexistent/binary" \
    "not found|No such file|inaccessible" \
    "nonzero"

run_test "T-030b" "ADB still responsive after bad command" \
    "$ADB $DEVICE shell echo still_alive" \
    "still_alive"

# T-031: Write to read-only filesystem rejected
echo ""
echo "--- T-031: Permission enforcement ---"
run_test "T-031" "Write to /system rejected" \
    "$ADB $DEVICE shell 'echo test > /system/test.txt'" \
    "denied|Read-only|Permission" \
    "nonzero"

run_test "T-031b" "Write to /data/local/tmp still works after rejection" \
    "$ADB $DEVICE shell 'echo ok > /data/local/tmp/resilience_test.txt && cat /data/local/tmp/resilience_test.txt && rm /data/local/tmp/resilience_test.txt'" \
    "ok"

# T-032: Install invalid APK fails gracefully
echo ""
echo "--- T-032: Invalid package handling ---"
run_test "T-032" "Install non-existent APK fails" \
    "$ADB $DEVICE install /nonexistent.apk" \
    "Failure|No such file|cannot stat|INSTALL_FAILED" \
    "nonzero"

run_test "T-032b" "Package manager still works after failed install" \
    "$ADB $DEVICE shell pm list packages | head -1" \
    "package:"

# T-033: Network disruption simulation via connectivity service
echo ""
echo "--- T-033: Network disruption simulation ---"
run_test "T-033a" "Enable airplane mode via cmd" \
    "$ADB $DEVICE shell cmd connectivity airplane-mode enable 2>&1; $ADB $DEVICE shell settings get global airplane_mode_on" \
    "1"

sleep 1

run_test "T-033b" "ADB still works in airplane mode" \
    "$ADB $DEVICE shell echo adb_ok_in_airplane" \
    "adb_ok_in_airplane"

run_test "T-033c" "Disable airplane mode via cmd" \
    "$ADB $DEVICE shell cmd connectivity airplane-mode disable 2>&1; $ADB $DEVICE shell settings get global airplane_mode_on" \
    "0"

# T-034: Rapid sequential commands don't crash ADB
echo ""
echo "--- T-034: ADB stability under load ---"
run_test "T-034" "10 rapid sequential commands" \
    "for i in 1 2 3 4 5 6 7 8 9 10; do $ADB $DEVICE shell echo \$i > /dev/null; done && echo rapid_ok" \
    "rapid_ok"

# T-035: Large logcat output doesn't hang
echo ""
echo "--- T-035: Large output handling ---"
run_test "T-035" "Logcat 1000 lines doesn't hang" \
    "timeout 10 $ADB $DEVICE logcat -d -t 1000 | wc -l | xargs -I{} test {} -gt 50 && echo logcat_large_ok" \
    "logcat_large_ok"

echo ""
echo "========================================="
echo " RESULTS: $PASS passed, $FAIL failed (of $TOTAL)"
echo "========================================="

if [ "$FAIL" -gt 0 ]; then exit 1; fi
