## Task: Review Skill Quality

Review the quality of all skill directories changed in this PR.

The changed files are provided below. Use those contents for your review.

Evaluate each changed skill against these dimensions:

| Dimension             | What to check                                                                                                                                                                                          |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Clarity**           | Is the description clear, specific, and written in third person? Does it include both what the skill does AND when to use it? Would another developer understand it at a glance?                       |
| **Completeness**      | Does the skill have sufficient instructions for Claude to follow? Are edge cases covered? Does it avoid over-explaining things Claude already knows?                                                   |
| **Specificity**       | Are instructions specific enough to avoid ambiguity? Are there concrete input/output examples? Does it set the right degree of freedom (high for flexible tasks, low for fragile/critical operations)? |
| **Safety**            | Does the skill avoid dangerous operations without user confirmation? Are there proper guardrails? Are destructive operations behind explicit checks?                                                   |
| **Structure**         | Are supporting files well-organized using progressive disclosure? Are files named descriptively (not `doc1.md`)? (Line count, nesting depth, and naming conventions are enforced by CI lint.)          |
| **Prompt Quality**    | Is the prompt engineering effective? Are instructions ordered by priority? Is terminology consistent throughout? Does it use templates/examples where helpful?                                         |
| **File Organization** | Should this skill be broken into multiple files (reference docs, examples, domain-specific guides)? Are there tasks that could be scripted instead of described in prose?                              |
| **Scriptability**     | Are there deterministic or repetitive operations described in prose that should be utility scripts instead? Scripts are more reliable, save tokens, and ensure consistency.                            |
| **Naming & Scoping**  | Is the name a good gerund form (e.g. `processing-pdfs`)? If the skill is specific to a squad or team workflow, does it have a squad prefix (e.g. `s3-...`)? (Format is enforced by CI lint.)           |

Rate each dimension as: PASS / NEEDS_IMPROVEMENT / FAIL

### Additional checks

**Squad-specific skills**: If a skill is tailored to a specific squad, team, or internal workflow that wouldn't be useful to all teams, flag it and recommend adding a squad prefix to the name (e.g. `s1-deploy-review`, `s3-mongo-migration`). This keeps the skill library organized and helps teams find their own skills.

**File decomposition**: If SKILL.md is longer than ~200 lines or covers multiple domains, recommend splitting into:

- `SKILL.md` — overview and navigation (table of contents)
- `reference/<domain>.md` — domain-specific details
- `examples.md` — input/output examples
- `scripts/` — utility scripts for deterministic operations

**Script opportunities**: Look for prose instructions that describe step-by-step CLI commands, data transformations, or validation checks. These should be scripts that Claude executes rather than instructions Claude interprets. Scripts are preferred because they are more reliable, save tokens, and ensure consistency.

**Description quality**: The description field is critical for skill discovery. It must:

- Include both what the skill does AND when to trigger it
- Mention specific keywords users might say
- (Third person and length limits are enforced by CI lint)

Post your review in this format:

### Quality Review

For each changed skill:

**Skill: <name>**

| Dimension         | Rating | Notes |
| ----------------- | ------ | ----- |
| Clarity           | ...    | ...   |
| Completeness      | ...    | ...   |
| Specificity       | ...    | ...   |
| Safety            | ...    | ...   |
| Structure         | ...    | ...   |
| Prompt Quality    | ...    | ...   |
| File Organization | ...    | ...   |
| Scriptability     | ...    | ...   |
| Naming & Scoping  | ...    | ...   |

**Overall**: APPROVED / CHANGES_REQUESTED
**Suggestions**: (specific, actionable improvements — include concrete file splits, script ideas, and naming changes)

---

## Changed Files

$SKILLS
