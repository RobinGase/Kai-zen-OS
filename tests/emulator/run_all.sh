#!/bin/bash
# run_all.sh — Convenience runner for all 5 emulator test layers
# Usage: bash tests/emulator/run_all.sh
# Prerequisites: emulator booted at emulator-5554, ADB accessible

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TOTAL_PASS=0
TOTAL_FAIL=0
LAYER_RESULTS=()

run_layer() {
    local layer="$1"
    local script="$2"
    echo ""
    echo "############################################"
    echo "  Running $layer"
    echo "############################################"
    echo ""

    if bash "$SCRIPT_DIR/$script"; then
        LAYER_RESULTS+=("  PASS  $layer")
    else
        LAYER_RESULTS+=("  FAIL  $layer")
        TOTAL_FAIL=$((TOTAL_FAIL + 1))
    fi
    TOTAL_PASS=$((TOTAL_PASS + 1))
}

START=$(date +%s)

run_layer "Layer 1: Infrastructure"       "run_layer1.sh"
run_layer "Layer 2: Logic / Governance"   "run_layer2.sh"
run_layer "Layer 3: UI / Automation"      "run_layer3.sh"
run_layer "Layer 4: Fault / Resilience"   "run_layer4.sh"
run_layer "Layer 5: Evidence / Audit"     "run_layer5.sh"

END=$(date +%s)
ELAPSED=$((END - START))

echo ""
echo "============================================"
echo "  ALL LAYERS SUMMARY"
echo "  $(date +%Y-%m-%dT%H:%M:%S)  (${ELAPSED}s elapsed)"
echo "============================================"
for r in "${LAYER_RESULTS[@]}"; do
    echo "$r"
done
echo ""
echo "  Layers run: $TOTAL_PASS"
echo "  Layers failed: $TOTAL_FAIL"
echo "============================================"

if [ "$TOTAL_FAIL" -gt 0 ]; then
    echo "  OVERALL: SOME LAYERS FAILED"
    exit 1
else
    echo "  OVERALL: ALL LAYERS PASSED"
    exit 0
fi
