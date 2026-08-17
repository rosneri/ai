---
name: tdd
description: >
  Drive a change test-first with a human approval gate. Enumerates the test cases as a
  plain-language list before any code is written, stops for the user to confirm or edit them and
  asks about anything uncertain, then writes the test bodies, runs them to prove RED, implements
  the task, and runs again to prove GREEN. Use when the user asks for TDD, "test first", "red
  green", "write the tests first", or wants a change built with tests leading the implementation.
user_invocable: true
arguments:
  - name: task
    description: "What to build, fix, or change (e.g. 'add retry with backoff to the fetch client')"
    required: false
---

# TDD

Tests lead. Implementation follows. The user approves the test list before a single line of test
or production code is written.

**The gate is the point.** An agent that writes tests and implementation in one breath is not
doing TDD — it is writing tests that describe whatever it happened to build. Stopping at the
case list is what keeps the user's intent in front of the code.

Six phases, in order. Never skip, never reorder, never merge two into one turn.

## Phase 1 — Understand the task

Read enough to write honest test cases and no more.

- Resolve the task from the argument, or from the conversation if none was given.
- Find where the behavior lives (or should live) and how this project already writes tests:
  runner, file naming, directory layout, assertion style, fixture and mocking conventions.
  Read one or two neighbouring test files — match them, do not invent a house style.
- Identify the exact command that runs the relevant subset of tests. You will run it twice.

Do **not** write or modify any file in this phase.

## Phase 2 — Propose the test cases (no code)

Write the list of cases in plain language. This is the deliverable of this phase — nothing else.

Present it as a table or numbered list. For each case give:

| Field  | Content                                                |
| ------ | ------------------------------------------------------ |
| Case   | One sentence, behavioral: "returns 429 body unchanged" |
| Given  | The starting state or input                            |
| Expect | The observable outcome that makes it pass              |

Also state, above the list:

- The test file path(s) you intend to create or extend
- The command you will use to run them
- Anything you are treating as an assumption

Cover the happy path, the boundaries, the error paths, and any invariant the task implies.
Prefer few sharp cases over many overlapping ones. Every case must be able to fail — if you
cannot describe an implementation that breaks it, drop it.

**No test code, no implementation, no scaffolding files in this phase.**

### Ask about anything uncertain

If a case depends on a decision you cannot make from the codebase — error semantics, boundary
inclusivity, return shape, what "invalid" means here — use `AskUserQuestion` with concrete
options rather than guessing and burying the guess in an assertion. Ask before presenting the
list when the answer changes the list; ask alongside it when it only changes one case.

Ask about real forks in the road. Do not ask about things the neighbouring code already answers.

## Phase 3 — Gate: wait for approval

Hand the list to the user and **stop**. Say plainly that nothing will be written until they
approve, and that they can add, remove, reword, or split any case.

- Approved → Phase 4.
- Edited → apply the edits, re-present the revised list, wait again.
- Questioned → answer, revise if needed, wait again.

Do not start writing tests "while waiting". Ending the turn here is correct.

## Phase 4 — Write the test bodies

Now write the tests — **exactly the approved cases**, one test per case, in the order agreed.

- Name each test after its approved case so the list and the file read the same.
- Assert the observable behavior, not the internals you are about to write.
- Write against the API you wish existed; do not soften a case to make it easier to satisfy.
- Add no case that was not approved. If writing the bodies reveals a missing case, say so and
  get it approved before including it.

Production code stays untouched. Adding a stub only when the test file cannot otherwise load
(an empty function, a bare export) is acceptable — it must contain no logic and must leave every
test failing.

## Phase 5 — Run for RED

Run the tests. Show the user the actual failure output.

Every new test must fail, and **fail for the right reason** — a wrong value, a missing behavior,
a not-yet-existing function. A failure from a typo, a bad import, or a broken fixture is a broken
test, not a red test: fix it and run again.

If a new test passes here, treat it as a defect in the test. Either the behavior already exists
(say so and drop the case) or the assertion is too weak (tighten it and re-run). Never continue
past a green Phase 5.

State the red result explicitly — which tests failed and with what message — before moving on.

## Phase 6 — Implement, then run for GREEN

Write the simplest implementation that satisfies the approved cases. Then run the same command.

The bar for finishing:

- Every new test passes.
- The wider suite still passes — run it, and report any pre-existing failures as pre-existing.
- The tests are unchanged since Phase 5, apart from fixes the user explicitly approved.

If a test will not pass, fix the implementation. **Do not edit the test to match the code.** When
a test turns out to be genuinely wrong, stop, explain why, and get the change approved — the
approved list is the contract.

Refactor only after green, and re-run after refactoring.

Close by reporting: the red output, the green output, what was implemented, and any case that
changed along the way and why.

## Rules

- The user approves the case list before any code exists. No exceptions.
- No production code before a red test covering it.
- No test written after the code it tests.
- A test that has never failed proves nothing.
- Tests are not edited to fit the implementation.
- Ask when uncertain; never encode a guess as an assertion.
- Every phase reports what it actually ran, with real output — never a claimed result.
