# Templates

## ADR Template

```markdown
# ADR-XXX: [Decision Title]

**Status**: Proposed | Accepted | Deprecated | Superseded
**Date**: YYYY-MM-DD
**Deciders**: [Names/roles]

## Context

[Why this decision is needed. What problem are we solving?]

**Requirements**:

- [List specific requirements]

## Options Considered

### Option 1: [Name]

[Description]

**Pros**: [List]
**Cons**: [List]

### Option 2: [Name]

[Repeat structure]

## Decision

**Option X: [Name]** - [brief summary]

## Rationale

| Factor   | Weight          | Option 1 | Option 2 |
| -------- | --------------- | -------- | -------- |
| [Factor] | High/Medium/Low | [Rating] | [Rating] |

**Primary factors favoring chosen option**: [Reasons]
**Acknowledged trade-offs**: [What we're giving up]
**When alternative would be better**: [Conditions]

## Consequences

### Positive

- [Benefits]

### Negative

- [Drawbacks]

### Mitigations

- [How we address negatives]

## Risks

| Risk   | Probability     | Impact          | Mitigation |
| ------ | --------------- | --------------- | ---------- |
| [Risk] | Low/Medium/High | Low/Medium/High | [Action]   |

## Future Considerations

**Revisit if**: [Conditions]
**Migration path**: [How to change direction]
```

**Important**: Be objective. Present all options fairly. If the chosen option wasn't ideal, document that honestly.

## User Stories Format

```markdown
## User Stories Index

1. [Category Name] (US-001 to US-004) - Brief description
2. [Category Name] (US-005 to US-007) - Brief description

## Stories

### 1. [Category Name]

#### US-001: [Title]

As a [role], I want [goal], so that [benefit].

**Acceptance criteria**:

- [ ] [Criterion 1]
- [ ] [Criterion 2]
```

## Errors Table Format

```markdown
### Critical Errors (Block Processing)

| Error                   | Description                      | Handling                 |
| ----------------------- | -------------------------------- | ------------------------ |
| `MerchantNotFoundError` | Merchant with given ID not found | Log error, skip merchant |

### Validation Errors

| Error                | Description                         | Handling                   |
| -------------------- | ----------------------------------- | -------------------------- |
| `InvalidAmountError` | Transfer amount is negative or zero | Log warning, skip transfer |
```

## Business Logic Format

```markdown
## Late Fee Calculation

**Formula**: late_fee = daily_rate x days_overdue x outstanding_balance

**Steps**:

1. Determine days overdue: current_date - due_date
2. If days_overdue <= grace_period, no fee
3. Calculate daily rate from annual rate: annual_rate / 365
4. Apply cap: late_fee cannot exceed max_fee_amount

**Edge cases**:

- Partial payments reduce outstanding_balance before calculation
- Weekends/holidays do not pause the count
```

## Data Models Format

```markdown
## Collections

### BalanceRecord

**Collection**: `balanceRecords`

| Field       | Type     | Description                |
| ----------- | -------- | -------------------------- |
| merchantId  | ObjectId | Reference to merchant      |
| processedAt | Date     | When balance was processed |

**Indexes**:

- `{ merchantId: 1, processedAt: -1 }` - Query by merchant, latest first

**Schema changes**:

- Add `reversalAmount` field (Number, default 0)
```
