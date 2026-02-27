# Kai-zen Decision Router (NAP-Aligned)

Use this quick router before writing or approving any plan update.

## Step 1: Declare profile set

- Primary: `infrastructure_devops`
- Secondary: `ai_stack_training_inference`
- Secondary: `security_incident_response`

If your change does not fit this set, flag for profile review before proceeding.

## Step 2: Determine safety class

- Class 1-2: documentation-level, no device-impact path
- Class 3+: any operation that could impact boot chain, flash safety, auth trust, or irreversible device state

Default to Class 3 when uncertain.

## Step 3: Apply autonomy ceiling

- Maximum autonomy for this program: **A2**
- No fully autonomous destructive workflow planning

## Step 4: Evidence gate

For Class 3+ decisions, require:

1. At least two high-confidence sources
2. Explicit rollback/recovery path
3. Emulator-vs-hardware validation boundary callout

## Step 5: Publish artifact updates

- Update plan doc(s)
- Update risk register if risk posture changes
- Update ADR if decision authority or guardrails change
