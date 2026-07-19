# Branch Management Rules

## Creating or Validating Branches

1. **Always start from the default branch** (main or develop)
2. **Enforce strict naming convention:**
   - Pattern: `dld-<ticketNumber>/<Short-Description>`
   - Ticket number must be numeric only
   - Description uses PascalCase with hyphens (no spaces)
   - Examples: `dld-123/Add-Autopay-Summary`, `dld-57/Fix-Lease-Balance`

3. **Handle series branches:**
   - If creating a branch FROM an existing ticket branch (not from default branch), it's part of a series
   - Add suffix number to track order: `dld-<ticketNumber>/<Description>-2`, `dld-<ticketNumber>/<Description>-3`, etc.
   - Examples:
     - Initial: `dld-21793/Temporal-Introduce-and-NX-Generator`
     - Series branch 2: `dld-21793/Temporal-Introduce-and-NX-Generator-2`
     - Series branch 3: `dld-21793/Temporal-Introduce-and-NX-Generator-3`

4. **Validation steps:**
   - Verify current branch is default before creating new branch (unless creating a series branch)
   - Pull latest changes from remote
   - Check branch doesn't already exist
   - Validate ticket number format
   - Ensure description is concise (3-5 words max)

5. **If branch naming is incorrect:**
   - Clearly explain the violation
   - Provide the correct format
   - Offer to rename or recreate the branch

## Regex Validation

```
^dld-[0-9]+/[A-Za-z0-9-]+(-[0-9]+)?$
```

Supports optional series suffix `-2`, `-3`, etc.
