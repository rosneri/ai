# rosneri

A Claude Code plugin marketplace. Each plugin ships one or more skills — a `SKILL.md` that teaches
Claude a workflow, a domain, or a set of conventions.

## Install

### Claude Code

```
/plugin marketplace add rosneri/ai
/plugin install <plugin-name>@rosneri
```

### Prime Agent

The repo doubles as a [Prime Agent](https://github.com/PrimeIntellect-ai/prime-agent) capability
package: the root `package.json` maps `./*/skills` into `pi.skills`, so every plugin's skill loads.

```bash
prime-agent package install git:github.com/rosneri/ai
prime-agent package install git:github.com/rosneri/ai@v1   # pin a tag
prime-agent -e git:github.com/rosneri/ai                   # try it for one run
```

Two things to know. Prime Agent has no per-subdirectory install — one repo is one package, so you
get all the skills and narrow them afterwards with `prime-agent config` or a settings filter:

```json
{
  "packages": [{ "source": "git:github.com/rosneri/ai", "skills": ["tdd/skills/**"] }]
}
```

And a skill of the same name already in `~/.agents/skills/` or `~/.prime/agent/skills/` **wins** over
the package copy, which is then dropped with a collision warning. Keep each skill in one place.

## Skills

| Skill                                                          | Plugin             | What it does                                                                                                                                                        |
| -------------------------------------------------------------- | ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [bruno](./bruno/skills/bruno)                                  | `bruno`            | Bruno API client — `.bru` file format, JavaScript API reference, authentication patterns, testing with Chai.js, and Git-first collection management.                |
| [claudehead](./claudehead/skills/claudehead)                   | `claudehead`       | Run Claude Code through the Headroom compression proxy, but only when a real health probe says the proxy is ready — otherwise plain `claude`.                       |
| [code-quiz](./code-quiz/skills/code-quiz)                      | `code-quiz`        | Prove you understand a diff before it ships. Generates a literate explainer, then five comprehension questions. A speed regulator on agent-written code.            |
| [ddd-architecture](./ddd-architecture/skills/ddd-architecture) | `ddd-architecture` | Review feature code against DDD and hexagonal architecture principles — entities, value objects, use cases, adapters, folder structure, test placement.             |
| [evolve](./evolve/skills/evolve)                               | `evolve`           | Self-evolving skills: a per-skill instructions file is injected on every invocation, and Claude appends durable lessons to it. You and Claude both edit it.         |
| [feature-planner](./feature-planner/skills/feature-planner)    | `feature-planner`  | Create Phase 0 documentation for a new feature: plan, glossary, business logic, architecture, errors, questions, and ADRs. Use before any code exists.              |
| [git-operations](./git-operations/skills/git-operations)       | `git-operations`   | Git operations enforcer — branches, commits, and pull requests with strict naming conventions and quality gates.                                                    |
| [guide-writer](./guide-writer/skills/guide-writer)             | `guide-writer`     | Write clear, minimal guides — how-tos, tutorials, runbooks — with verified steps, annotated screenshots, and Mermaid diagrams. One reader, one goal, one path.      |
| [helix-teacher](./helix-teacher/skills/helix-teacher)          | `helix-teacher`    | Teaches Helix by reading your actual config — keybindings, LSP setup, themes — and answering questions about it.                                                    |
| [moon-statusline](./moon-statusline/skills/moon-statusline)    | `moon-statusline`  | Two-line status line for moon monorepos: model, project and deploy target, worktree, git, PR; context bar, cost, lines changed, rate limits, cache.                 |
| [neovim-teacher](./neovim-teacher/skills/neovim-teacher)       | `neovim-teacher`   | Teaches Neovim by reading your actual config — installed plugins, keymaps, LSP setup — and answering questions about it.                                            |
| [node-debug](./node-debug/skills/node-debug)                   | `node-debug`       | Debug a running Node.js process over CDP. Breakpoints, stepping, variable inspection, expression evaluation — headless, no GUI.                                     |
| [n-order-consequences](./thinking/skills/n-order-consequences) | `thinking`         | Trace second-, third-, and nth-order effects of a decision so you don't stop at first-order thinking.                                                               |
| [primehead](./primehead/skills/primehead)                      | `primehead`        | Run Prime Agent through the Headroom compression proxy behind the same health gate, routed by a per-run extension because Prime Agent ignores `ANTHROPIC_BASE_URL`. |
| [tdd](./tdd/skills/tdd)                                        | `tdd`              | Test-driven development with a human gate: propose the test cases, wait for approval, write the bodies, run for RED, implement, run for GREEN.                      |
| [watch-ci](./watch-ci/skills/watch-ci)                         | `watch-ci`         | Poll CI checks on a PR until they finish, reporting progress along the way.                                                                                         |

## Repository layout

```
<plugin>/
├── .claude-plugin/
│   └── plugin.json           # plugin manifest
└── skills/
    └── <skill>/
        └── SKILL.md          # the skill itself (max 200 lines)
```

Plugins are registered in [`.claude-plugin/marketplace.json`](./.claude-plugin/marketplace.json).

## Contributing

Every changed skill is validated by [`.github/workflows/validate-skills.yml`](./.github/workflows/validate-skills.yml):

- **Structure** — `SKILL.md` exists, has YAML frontmatter with `name` and `description`, and a body
- **Lint** — max 200 lines, lowercase-hyphen directory name, description under 1024 chars and in
  third person, no nested subdirectories beyond one level
- **README** — every changed skill is listed in the table above
- **Format** — `oxfmt`, `oxlint`, and `secretlint` across the repo
- **AI review** — duplicate check and quality review (only when `ANTHROPIC_API_KEY` is set)

To run the checks locally:

```bash
cd .ci && bun install
bun run fmt:check
bun run lint
bun run lint:skills <plugin>/skills/<skill>
```
