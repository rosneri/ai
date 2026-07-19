# Planning Flow

## Flowchart

```mermaid
flowchart TD
    Start([New Feature Request]) --> Problem[Define Problem Statement]
    Problem --> Language[Establish Ubiquitous Language]
    Language --> Invariants[Document Invariants & Rules]
    Invariants --> BusinessLogic[Document Business Logic]
    BusinessLogic --> ADR[Document Architecture Decisions]
    ADR --> Classification{Command or Query?}

    Classification --> Hexagonal[Define Ports & Adapters]
    Hexagonal --> UseCases[Identify Use Cases]
    UseCases --> Errors[Map Failure Modes]

    Errors --> Brownfield{Touches Existing Code?}
    Brownfield -->|Yes| TouchPoints[Analyze Touch Points]
    TouchPoints --> Extensions[Identify Extensions]
    Extensions --> Modifications[Document Modifications]
    Modifications --> Scope
    Brownfield -->|No| Scope[Define Out of Scope]

    Scope --> Questions{Unclear Items?}
    Questions -->|Yes| QA[Add to Q&A Section]
    QA --> AskUser([Ask User for Answers])
    AskUser --> Questions
    Questions -->|No| Ready([Phase 0 Complete])
```

## Rules

1. **No solutions or implementation details** — domain language only
2. **No code snippets** — plain language descriptions
3. **Be brief** — short explanations, only what's most relevant
4. **Use mermaid diagrams** when they clarify relationships or flows
5. **Socratic method** — don't guess, ask before proceeding
6. **If invariants are unclear** — add to questions.md and ask the user
