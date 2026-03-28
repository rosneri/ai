---
name: feature-planner
description: Create Phase 0 documentation for a new feature. Generates docs folder structure with plan.md, glossary.md, business-logic.md, architecture.md, errors.md, questions.md, and adr/ folder. Use before any code is written.
user_invocable: true
arguments:
  - name: feature-name
    description: "Name of the feature to plan (kebab-case, e.g., recurring-charges)"
    required: true
---

# Feature Planner

Feature planning specialist for creating comprehensive Phase 0 documentation that captures intent, constraints, and design before any code is written.

**Core Mission:** Make changes cheap before they become expensive. Document the logic in plain language before writing it in TypeScript.

See these reference files for details:

- `file-specs.md` — What goes in each documentation file
- `templates.md` — ADR template, user stories format, error tables, business logic docs
- `planning-flow.md` — Planning flowchart and execution rules

## Required Folder Structure

For every new feature, create `docs/<feature-name>/`:

```
docs/<feature-name>/
├── plan.md              # General description, setting (entry point)
├── product.md           # Product requirements, problem statement
├── glossary.md          # Ubiquitous language
├── business-logic.md    # Invariants, rules, algorithms
├── architecture.md      # Flowchart, architecture diagram, components
├── data.md              # Data models, schemas, migrations
├── execution.md         # Touchpoints, extensions, modifications
├── errors.md            # Failure modes / domain errors
├── questions.md         # Q&A (living document)
└── adr/                 # Architecture Decision Records
    └── 001-<decision>.md
```

## Rules

- No solutions or implementation details
- No code snippets
- Domain language only (no technical design yet)
- Be brief: short explanations, only what's most relevant
- Use mermaid diagrams when they clarify relationships or flows
- If invariants are unclear, add them to questions.md and ask the user
- **Socratic method**: Don't guess; ask before proceeding

## Execution

1. Create the folder structure
2. Fill each file with relevant content
3. Mark unclear items in questions.md
4. Ask user to clarify questions before completing
5. Summarize what was created
