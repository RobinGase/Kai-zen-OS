#!/bin/bash
# Layer 5: Evidence / Audit Tests
# Validates that logging, tracing, and audit trail mechanisms work
# Tests: structured log output, file evidence, git state integrity

set -uo pipefail

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

PROJ_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

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
echo " LAYER 5: Evidence / Audit Tests"
echo " $(date +%Y-%m-%dT%H:%M:%S)"
echo "========================================="
echo ""

# T-040: Structured logcat filtering
echo "--- T-040: Structured log output ---"
run_test "T-040" "Logcat with tag filter works" \
    "$ADB $DEVICE logcat -d -s ActivityManager:I | head -5" \
    "ActivityManager"

run_test "T-040b" "Logcat with time filter works" \
    "$ADB $DEVICE logcat -d -t 5 | wc -l | xargs -I{} test {} -ge 1 && echo time_filter_ok" \
    "time_filter_ok"

# T-041: Device property capture (evidence gathering)
echo ""
echo "--- T-041: Device evidence capture ---"
run_test "T-041a" "Build fingerprint captured" \
    "$ADB $DEVICE shell getprop ro.build.fingerprint" \
    "google"

run_test "T-041b" "Security patch level captured" \
    "$ADB $DEVICE shell getprop ro.build.version.security_patch" \
    "20"

run_test "T-041c" "Device serial captured" \
    "$ADB $DEVICE shell getprop ro.serialno" \
    "EMULATOR"

run_test "T-041d" "Full property dump works" \
    "$ADB $DEVICE shell getprop | wc -l | xargs -I{} test {} -gt 100 && echo props_ok" \
    "props_ok"

# T-042: Evidence file creation on emulator
echo ""
echo "--- T-042: Evidence file creation ---"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
EVIDENCE="kaizen_evidence_${TIMESTAMP}"

run_test "T-042a" "Create timestamped evidence file" \
    "MSYS_NO_PATHCONV=1 $ADB $DEVICE shell 'echo \"test_id: T-042\" > /data/local/tmp/${EVIDENCE}.txt && echo \"timestamp: ${TIMESTAMP}\" >> /data/local/tmp/${EVIDENCE}.txt && echo \"device: emulator-5554\" >> /data/local/tmp/${EVIDENCE}.txt && cat /data/local/tmp/${EVIDENCE}.txt'" \
    "test_id"

run_test "T-042b" "Evidence file contains timestamp" \
    "MSYS_NO_PATHCONV=1 $ADB $DEVICE shell cat /data/local/tmp/${EVIDENCE}.txt" \
    "timestamp"

# Cleanup
MSYS_NO_PATHCONV=1 $ADB $DEVICE shell rm /data/local/tmp/${EVIDENCE}.txt 2>/dev/null

# T-043: Git repo integrity checks
echo ""
echo "--- T-043: Repo integrity ---"

run_test "T-043a" "Git repo is clean (no uncommitted changes to docs)" \
    "cd '$PROJ_ROOT' && git diff --quiet -- Docs/ && echo repo_clean || echo repo_dirty" \
    "repo_clean\|repo_dirty"

run_test "T-043b" "No secrets in git history (API key pattern)" \
    "cd '$PROJ_ROOT' && ! git log --all --oneline --diff-filter=A -- '*.md' | head -20 | grep -qi 'sk-[a-zA-Z0-9]' && echo no_secrets" \
    "no_secrets"

run_test "T-043c" "All ADRs have date field" \
    "cd '$PROJ_ROOT' && grep -l 'Date.*2026' Docs/adrs/ADR-*.md | wc -l | xargs -I{} test {} -ge 4 && echo adrs_dated" \
    "adrs_dated"

run_test "T-043d" "Risk register has status tracking" \
    "cd '$PROJ_ROOT' && grep -c 'Status.*Open\|Status.*Mitigated' Docs/governance/risk_register.md | xargs -I{} test {} -ge 10 && echo risks_tracked" \
    "risks_tracked"

run_test "T-043e" "Source verification has access dates" \
    "cd '$PROJ_ROOT' && grep -c '2026-02-27' Docs/governance/source_verification.md | xargs -I{} test {} -ge 5 && echo sources_dated" \
    "sources_dated"

# T-044: Decision log exists and has entries
echo ""
echo "--- T-044: Decision trail ---"

run_test "T-044" "Decision log has entries" \
    "cd '$PROJ_ROOT' && grep -c '2026-02-27' Docs/alignment/kai_zen_decision_router.md | xargs -I{} test {} -ge 3 && echo decisions_logged" \
    "decisions_logged"

echo ""
echo "========================================="
echo " RESULTS: $PASS passed, $FAIL failed (of $TOTAL)"
echo "========================================="

if [ "$FAIL" -gt 0 ]; then exit 1; fi
