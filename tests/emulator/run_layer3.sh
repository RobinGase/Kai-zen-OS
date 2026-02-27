#!/bin/bash
# Layer 3: UI / Automation Tests
# Validates scrcpy, ADB UI interaction, and screen capture work with emulator
# Appium/Maestro tests are deferred — require separate server install

set -uo pipefail

SCRCPY="/c/Users/Robin/scoop/shims/scrcpy.exe"
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
    local id="$1"; local desc="$2"; local cmd="$3"; local expected="$4"
    TOTAL=$((TOTAL + 1))
    result=$(eval "$cmd" 2>&1 || echo "COMMAND_FAILED")
    if echo "$result" | grep -qi "$expected"; then
        echo "  PASS  $id: $desc"
        PASS=$((PASS + 1))
    else
        echo "  FAIL  $id: $desc"
        echo "        Expected: $expected"
        echo "        Got:      $(echo "$result" | head -3)"
        FAIL=$((FAIL + 1))
    fi
}

echo "========================================="
echo " LAYER 3: UI / Automation Tests"
echo " $(date +%Y-%m-%dT%H:%M:%S)"
echo "========================================="
echo ""

# T-020: scrcpy connects to emulator
echo "--- T-020: scrcpy connectivity ---"
run_test "T-020" "scrcpy connects to emulator" \
    "'$SCRCPY' $DEVICE --no-playback --no-window 2>&1 & SPID=\$!; sleep 3; kill \$SPID 2>/dev/null; wait \$SPID 2>/dev/null; echo done" \
    "device"

# T-021: scrcpy screenshot via ADB screencap
echo ""
echo "--- T-021: Screen capture ---"
run_test "T-021" "ADB screencap works" \
    "$ADB $DEVICE shell screencap -p > /dev/null && echo screencap_ok" \
    "screencap_ok"

# T-022: ADB can read UI elements via dumpsys
echo ""
echo "--- T-022: UI element inspection ---"
run_test "T-022" "dumpsys window visible" \
    "$ADB $DEVICE shell dumpsys window displays | head -5" \
    "Display"

run_test "T-022b" "dumpsys activity top activity" \
    "$ADB $DEVICE shell dumpsys activity top | head -3" \
    "TASK"

# T-023: ADB input simulation (tap, swipe, keyevent)
echo ""
echo "--- T-023: Input simulation ---"
run_test "T-023a" "ADB input tap" \
    "$ADB $DEVICE shell input tap 540 1200 && echo tap_ok" \
    "tap_ok"

run_test "T-023b" "ADB input swipe" \
    "$ADB $DEVICE shell input swipe 540 1800 540 600 300 && echo swipe_ok" \
    "swipe_ok"

run_test "T-023c" "ADB keyevent HOME" \
    "$ADB $DEVICE shell input keyevent KEYCODE_HOME && echo home_ok" \
    "home_ok"

run_test "T-023d" "ADB keyevent BACK" \
    "$ADB $DEVICE shell input keyevent KEYCODE_BACK && echo back_ok" \
    "back_ok"

# T-024: ADB activity launch
echo ""
echo "--- T-024: Activity launch ---"
run_test "T-024" "Launch Settings app" \
    "$ADB $DEVICE shell am start -n com.android.settings/.Settings 2>&1" \
    "Starting"

sleep 1

run_test "T-024b" "Settings is foreground" \
    "$ADB $DEVICE shell dumpsys activity top | grep -i 'settings'" \
    "settings"

# Return to home
$ADB $DEVICE shell input keyevent KEYCODE_HOME 2>/dev/null

echo ""
echo "========================================="
echo " RESULTS: $PASS passed, $FAIL failed (of $TOTAL)"
echo "========================================="

if [ "$FAIL" -gt 0 ]; then exit 1; fi
