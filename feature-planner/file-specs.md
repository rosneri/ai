# File Specifications

## `plan.md` (Entry Point)

- **General description**: High-level overview in 2-3 sentences
- **Setting**:
  - Part of which epic / ticket
  - Who's working on it
  - Stakeholders
  - Deadline
- **Out of scope items**: Explicit boundaries

## `product.md`

- **Problem statement**: What triggered the work, why it matters
- **User stories**: Grouped by category (see templates)
- **Product requirements**: What the feature must do from user/business perspective
- **Acceptance criteria**: How we know the feature is complete
- **KPIs**: Metrics to measure success

## `execution.md`

- **Touchpoints**: Which existing modules and DB collections are needed
- **Extensions**: What existing code/interfaces can be extended without modification
- **Modifications**: What must be modified (try to avoid; if unavoidable, document why)

## `glossary.md`

- Domain terms with definitions
- Verbs (actions the system performs)
- States (entity lifecycle states)
- Keep definitions concise and unambiguous

## `business-logic.md`

- **Explicit invariants**: Non-negotiable rules that must always hold
- **Algorithms and calculations**: Step-by-step in plain language
- **Formulas**: e.g., "late fee = daily rate x days overdue x balance"
- **Decision logic**: How the system decides between outcomes
- No code, just plain language

## `architecture.md`

- **Feature flowchart** (mermaid): Entry points, decision points, operations, exits
- **Architecture diagram** (mermaid): Components, layers, dependencies
- **Command vs Query classification**
- **Hexagonal architecture**: Ports, adapters, services to define
- **Clean architecture**: Use cases to implement
- **Design patterns**: Specific patterns (Strategy, Factory, Repository)

## `data.md`

- **Data models**: Entities, collections, relationships
- **Schema changes**: New fields, indexes, constraints
- **Migrations**: Required data migrations or backfills
- **Data flow**: How data moves through the system

## `errors.md`

Document as tables grouped by category. Each error: name, description, handling.

## `questions.md`

- For anything unclear or missing information
- Format: Question, then space for answer
- Answers become permanent record
- Update as answers are discovered

## `adr/` Folder

One file per decision: `001-<decision-title>.md`
