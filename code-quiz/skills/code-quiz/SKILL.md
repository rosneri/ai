---
name: code-quiz
description: >
  Quiz the user on whether they actually understand a code change before it ships. Generates a
  short literate explainer of a diff, then administers five comprehension questions that test how
  the change works — not requirements, not trivia. Use before opening a PR, before merging, when
  reviewing someone else's PR, or when the user says "quiz me on this", "do I understand this
  change", "code quiz", "gate this PR", or wants to check comprehension of AI-written code.
user_invocable: true
arguments:
  - name: ref
    description: >
      What to quiz on. A git ref/range (e.g. "HEAD", "main...HEAD", "abc1234"), a GitHub PR
      (e.g. "#19270" or a PR URL), or omitted to default to the current branch's diff against its
      base (main/master). Also accepts "--self" to have the agent answer its own quiz (for testing
      question quality).
    required: false
---

# Code Quiz

Prove understanding before code ships. This is a **speed regulator**: it exists so the agent
loop can't run faster than your comprehension. The goal is not to verify correctness (the agent
can do that) — it's to keep you a real participant who can propose the next change. You do not
"pass" until you can explain how the change works.

Inspired by Geoffrey Litt's `explain-diff` quiz and usegater.app. The rule, from Litt: **don't
send code to others until you can pass the quiz** — and hold the same bar when reviewing others'.

## Step 1 — Get the diff

Resolve the argument to a unified diff:

| Input            | How to get it                                                                             |
| ---------------- | ----------------------------------------------------------------------------------------- |
| No argument      | `git diff $(git merge-base HEAD main 2>/dev/null \|\| git merge-base HEAD master)...HEAD` |
| Git ref / range  | `git diff <range>` or `git show <sha>`                                                    |
| `#123` or PR URL | `gh pr diff 123 --repo <owner/repo>` (infer repo from the URL or `gh repo view`)          |

Also gather context the diff alone doesn't show, so questions can be grounded and fair:

- The PR title / commit messages (the _stated intent_ — questions test whether reality matches it).
- For each changed function, read enough of the **surrounding file** to know what existed before
  and who calls it. Understanding is taught background-first; questions are asked the same way.
- If the diff is huge (say >800 lines or >20 files), tell the user you'll quiz on the **2–3
  highest-risk areas** rather than everything, and name which. Don't silently skip; say what's out.

## Step 2 — Orient, then write a short literate explainer

Open with a **quick orientation** before anything else, so the user knows what's happening and
what's under test. Three or four lines, no more:

- What this is: "I'm going to brief you on this change, then quiz you with five comprehension
  questions. You pass when you can explain how it works."
- What's under test: the current branch (`git branch --show-current`), the base it's diffed
  against, and the commit under quiz (`HEAD` short sha).
- The shape of the change: one line — N commits, N files, and the stated intent (PR title or
  commit subject).

Then give the user a tight briefing so the quiz tests _understanding_, not whether they happened
to read one line. Keep it to what's needed — intuition before details:

1. **Background** — what existed before this change and why (one or two sentences per touched area).
2. **The idea** — the goal of the change in plain language, before any code.
3. **Literate walkthrough** — the change in a sensible order (not file-alphabetical), with the
   key hunks inline and prose explaining _why_, not just _what_.

This mirrors the raw diff faithfully. Never invent behavior that isn't in the code. If something
in the diff is unclear to you, say so — an honest "I'm not sure why X" is better than a confident
wrong explainer, and it's a good quiz question.

## Step 3 — Generate five questions

Five questions. They must satisfy this bar — **a question that fails any of these is a bad
question, rewrite it**:

- **Answerable only by understanding THIS diff.** Not from the PR title, not from general
  knowledge, not by pattern-matching the framework. If a competent engineer who never saw the
  diff could answer it, cut it.
- **Tests how/why/consequence, not trivia.** Never "what line number", "what's the variable
  called", "how many files". Ask what breaks, why this approach, what changes for the caller.
- **Has a definite, checkable answer grounded in the code.** Not open-ended opinion. You must be
  able to state the correct answer from the diff.
- **Not guessable.** Avoid yes/no and true/false (50% free). Prefer "what happens when…", "why
  A instead of B", "which existing behavior changes".

Cover a spread of categories — pick the 5 most load-bearing for _this_ change. The base round pulls
**only from** [references/gating-categories.md](references/gating-categories.md) (mechanism,
blast-radius, design-tradeoff, edge-case, failure-mode, invariant, guard-intent, behavior-delta,
contract-compat, money-correctness, security-access, …). Open that file and choose; don't hardcode
the same six every time. The deepening categories are for Step 7 — they never gate.

Rank the five hardest-hitting first. A change about money, concurrency, migrations, access
control, or deletion **must** include at least one failure-mode or invariant question.

**Line count is not comprehension surface.** A 3-line index or config change can carry the
hardest question in the batch (why the planner can't use the existing index; what the rollout
does to a 1.7M-doc collection); a 1000-line rename can carry none. Quiz the _understanding the
change demands_, never its size.

### Two diff shapes that need special handling

- **Mechanical diff** (pure rename/move/import-rewrite, no behavior change). Do **not** manufacture
  five questions — that produces exactly the trivia this skill forbids ("what's the new import
  path"). Ask only the real judgment calls: _why_ was it done (the boundary/ownership decision) and
  _how do you know behavior is truly unchanged_ (what in the diff proves no name/signature/emission
  moved). Then say plainly the rest is mechanical and there's nothing more to understand. One or two
  honest questions beats five fake ones.
- **"refactor" / "chore" label** (the diff claims structure-only). The highest-value questions hunt
  **behavior smuggled in under the label** — a clamp, a new guard, a flag-eval that gained context,
  a default that changed. Diff the _behavior_, not the moves, and make the user name what actually
  changed versus what only moved. A reviewer skims a "refactor"; that's where bugs ship.

## Step 4 — Administer, one question at a time, via the AskUserQuestion tool

Ask each question through the **AskUserQuestion** tool (the interactive question UI), **one call
per question** — never batch them, because you must grade and teach between questions.

- One question per `AskUserQuestion` call. Give it **three** options: exactly one correct, two
  **strong distractors** — near-misses a shallow reader would pick (right mechanism, wrong detail;
  a plausible-but-absent behavior; the reverse of the real cause). Weak/silly options make it
  guessable and waste the question. The tool always adds "Other" so a user who actually understands
  can type their own answer in their words — that's the real-comprehension path, reward it.
- **No length tell.** Distractors must match the correct option's length and specificity — a
  correct answer that's the longest, most detailed option is pickable without reading the diff.
  Either trim the correct option or fatten the distractors until they're indistinguishable by
  form alone.
- **Randomize the correct option's position** — do not default it to first (that's a tell; a user
  learns to pick option 1 and stops thinking). Ignore the tool's "recommended option first"
  convention here — a quiz has no recommendation. For question `N` (1–5), place the correct option
  at slot `(hex(N) mod 3) + 1`, where `hex(N)` = the decimal value (0–15) of the `N`th-from-last
  hex character of the full `HEAD` sha. Each question's slot comes from a different sha character,
  so slots don't follow a pattern across questions and vary per commit — spotting one answer's
  position reveals nothing about the next. Fill the other two slots with the distractors in any
  order.
- After they answer, grade: **correct / partial / missed**. Say which, give the real answer and
  _why it matters_. Strict grader — a distractor that's "close" is still missed. A free-typed
  "Other" answer that's vague on a load-bearing point is partial at best.
- Picking a distractor or "I don't know" is an honest miss; teach it and move to the next call.
- Keep a `header` per question naming the category (e.g. "Mechanism", "Blast radius").
- Then ask the next question. Repeat for all five.

## Step 5 — Verdict

Score it. **Pass = at least 4 of 5 correct AND no missed question on a critical mechanism**
(money / concurrency / access control / data-loss path). Anything less is **not yet** — and that's
the point, not a failure.

- **Pass:** say so plainly. They understand it; ship it. Then **open the PR gate** — write the
  pass-marker for the exact commit under test so the PreToolUse hook lets the PR through:

  ```bash
  git_dir=$(git rev-parse --absolute-git-dir)
  rm -f "$git_dir"/code-quiz-passed-*   # stale markers from earlier commits
  : > "$git_dir/code-quiz-passed-$(git rev-parse HEAD)"
  ```

  Only write it after a genuine pass. The marker is commit-specific — new commits re-lock the gate,
  which is correct: the quiz must match the code being shipped. Never write it to skip the quiz.

- **Not yet:** name exactly which concepts they didn't have. Offer to walk through those parts of
  the code, then re-quiz on the weak areas. Don't just re-ask the same five. Do **not** write the
  marker.

Report honestly. If they passed, say ship it. If they didn't, say so — the whole value is that
the gate means something.

## Step 6 — Offer next steps (via AskUserQuestion)

After the verdict, present choices through the **AskUserQuestion** tool so the user drives what
happens next. Tailor the options to the result:

**On "not yet":**

- **Walk through the gaps** _(recommended)_ — teach the exact concepts they missed against the real
  code, then re-quiz on just those (fresh questions, not the same ones). Does not open the gate.
- **Re-quiz now** — five fresh questions on the whole change, no walk-through first.
- **Bypass and open the PR anyway** — the user consciously overrides the gate. Only they may choose
  this; never pick it for them. On this choice, write the pass-marker (that's what unblocks the
  hook) and say plainly in the PR/summary that the quiz was bypassed, so the override is on record.
- **Stop here** — leave the gate locked, come back later. Nothing is written.

**On "pass":**

- **Open the PR now** _(recommended)_ — the marker is written; proceed to `gh pr create` / the MCP
  create.
- **Deepen my knowledge** — run a Step 7 learning round (5 questions on architecture, theory, why
  the work exists). Doesn't affect the gate — the user already passed.
- **Review the weakest answer** — revisit the one question they were shakiest on before shipping.
- **Not yet** — hold off; the marker stays (they passed) but they choose not to open the PR now.

Always include a **Deepen my knowledge** option on both results (on "not yet" phrase it "learn
anyway" — it teaches without unlocking the gate). Add other options if the situation calls for it
(e.g. "quiz a teammate on this same diff", "regenerate the explainer as a doc"). Keep the
recommended action first. The bypass option must always be an explicit, labeled user choice — the
gate is a discipline tool the human can override, but the override must be deliberate and recorded,
never silent.

## Step 7 — Deepen rounds (learning, never gates)

When the user asks to deepen, run a learning round that reaches past the diff into the reasons and
theory behind it. This is the "participate, not just verify" half — it builds the mental model that
lets them propose the next change. It **never** touches the pass-marker or the gate.

- Pull 5 subjects from [references/deepening-categories.md](references/deepening-categories.md) —
  the ones that actually **fit this change**, not a generic set. A tiny index change → cs-concept
  (index selectivity), scaling-ceiling, cost-of-inaction. A gate-removal bug fix → origin-pain,
  domain-invariant's history, rejected-alternative. Don't force categories that don't apply here.
- Skip subjects already covered — by the base round and by any earlier deepen round this session.
  Each round should open _new_ ground; track what's been asked.
- Administer the same way as Step 4: one `AskUserQuestion` call per question, three options with
  strong distractors, randomized correct slot, grade and teach after each. Deeper questions lean
  more on the "Other" free-response path — reward a well-argued answer even if it's not the option.
- These are open-ended by nature (design judgment, tradeoffs). Grade on _reasoning quality_, not a
  single canonical answer — there's often more than one defensible take. Teach the one the code/
  authors actually chose and why.

**End every deepen round with a run-again offer (via AskUserQuestion):**

- **Run again — 5 more, new topics** _(recommended)_ — another round from still-unused deepening
  categories, on subjects the earlier rounds didn't reach.
- **Open the PR / finish** — done learning; proceed (or stop).

When the deepening categories that fit this change are exhausted, say so plainly instead of
repeating — "we've covered the angles that apply to this change" — and don't offer another round.

### The PR gate (how this ties to opening PRs)

This plugin ships a `PreToolUse` hook that blocks opening a PR — via CLI (`gh pr create` /
`gh pr ready`) or MCP (`*create_pull_request`) — unless the pass-marker exists for the current
`HEAD`. When the hook denies a PR-open, that's the signal to run this skill first. The marker is
the only thing that opens the gate, and only a real pass earns it.

## `--self` mode (question-quality test)

When invoked with `--self`, the agent both writes the quiz and answers it, then critiques its own
questions against the Step 3 bar (are any answerable without the diff? guessable? trivia?). Use
this to validate or improve the question set for a given diff — not as a substitute for a human
taking the real quiz. `--self` **never writes the pass-marker** — only a human passing (or an
explicit, recorded bypass) opens the gate.
