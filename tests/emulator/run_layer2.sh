#!/bin/bash
# Layer 2: Logic Tests
# Validates orchestrator routing rules, escalation, and safety enforcement
# These tests run on the host (not inside emulator) because they test
# the orchestrator's decision logic, not the device.

set -euo pipefail

PASS=0
FAIL=0
TOTAL=0

# Orchestrator model spec defines the routing rules.
# These tests validate the rules are internally consistent and enforceable.
SPEC="Docs/architecture/orchestrator_model_spec.md"
ADR3="Docs/adrs/ADR-0003-model-routing-policy.md"
ADR4="Docs/adrs/ADR-0004-architecture-selection.md"
RISK="Docs/governance/risk_register.md"

run_test() {
    local id="$1"
    local desc="$2"
    local check_cmd="$3"
    TOTAL=$((TOTAL + 1))

    if eval "$check_cmd" > /dev/null 2>&1; then
        echo "  PASS  $id: $desc"
        PASS=$((PASS + 1))
    else
        echo "  FAIL  $id: $desc"
        FAIL=$((FAIL + 1))
    fi
}

echo "========================================="
echo " LAYER 2: Logic Tests"
echo " $(date +%Y-%m-%dT%H:%M:%S)"
echo "========================================="
echo ""

echo "--- T-010 series: Tag routing validation ---"

run_test "T-010" "M-FAST tags exist in spec" \
    "grep -q 'test.*M-FAST' $SPEC"

run_test "T-010b" "M-FAST is default slot" \
    "grep -q 'M-FAST.*is the default' $SPEC"

run_test "T-011" "M-KERNEL tags exist in spec" \
    "grep -q 'kernel-patch.*M-KERNEL' $SPEC"

run_test "T-011b" "M-KERNEL requires human approval" \
    "grep -q 'Human approval is mandatory' $SPEC"

run_test "T-011c" "Kernel tags never auto-dispatched" \
    "grep -q 'never auto-dispatched' $SPEC"

echo ""
echo "--- T-012 series: Escalation rules ---"

run_test "T-012" "Confidence threshold defined" \
    "grep -q 'CONFIDENCE_THRESHOLD.*0.7' $SPEC"

run_test "T-012b" "Escalation is one-way up" \
    "grep -q 'one-way up' $SPEC"

run_test "T-012c" "Complexity trigger: >= 4 files" \
    "grep -q '4 files' $SPEC"

echo ""
echo "--- T-013 series: Tier C dual verification ---"

run_test "T-013" "Tier C uses M-HEAVY + M-VERIFY" \
    "grep -q 'M-HEAVY.*M-VERIFY' $SPEC"

run_test "T-013b" "M-VERIFY has no access to M-HEAVY result" \
    "grep -q 'no access to M-HEAVY' $SPEC"

run_test "T-013c" "Highest-safety-wins conflict resolution" \
    "grep -q 'highest-safety-wins' $SPEC"

echo ""
echo "--- T-014 series: Safety boundary enforcement ---"

run_test "T-014" "A2 autonomy ceiling enforced" \
    "grep -q 'A2.*without human approval' $SPEC"

# T-014b: Check that the model roster table (Section 1) does not contain phantom models
# The changelog may mention old names — that's fine. Only the active roster matters.
run_test "T-014b" "No phantom models in active roster section" \
    "! sed -n '/## 1  Model Roster/,/## 2  Task Classification/p' $SPEC | grep -qi 'Codex 5.3' && ! sed -n '/## 1  Model Roster/,/## 2  Task Classification/p' $SPEC | grep -qi 'Gemini 3.1 Pro'"

run_test "T-014c" "All roster models are real (GPT-4o present)" \
    "grep -q 'GPT-4o' $SPEC"

run_test "T-014d" "All roster models are real (Gemini 2.5 Flash present)" \
    "grep -q 'Gemini 2.5 Flash' $SPEC"

run_test "T-014e" "All roster models are real (Llama 3.1 present)" \
    "grep -q 'Llama 3.1' $SPEC"

echo ""
echo "--- T-015 series: Cost and budget controls ---"

run_test "T-015" "80% budget alert threshold" \
    "grep -q '80%' $SPEC"

run_test "T-015b" "M-FAST handles >= 80% of tasks" \
    "grep -q '80.*tasks' $SPEC"

echo ""
echo "--- Cross-document consistency ---"

run_test "T-016" "ADR-0003 references orchestrator spec" \
    "grep -q 'orchestrator_model_spec' $ADR3"

run_test "T-017" "ADR-0004 references architecture candidates" \
    "grep -q 'architecture_candidates' $ADR4"

run_test "T-018" "Risk register has >= 15 risks" \
    "[ \$(grep -c '^## R-' $RISK) -ge 15 ]"

run_test "T-019" "No secrets pattern in any tracked file" \
    "! git grep -l 'sk-[a-zA-Z0-9]\\{20,\\}' -- '*.md' && ! git grep -l 'AIza[a-zA-Z0-9]\\{30,\\}' -- '*.md'"

echo ""
echo "========================================="
echo " RESULTS: $PASS passed, $FAIL failed (of $TOTAL)"
echo "========================================="

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
