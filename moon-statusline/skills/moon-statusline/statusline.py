#!/usr/bin/env python3
"""Two-line Claude Code status line for moon monorepos.

Line 1 is identity: model, moon project, worktree, git, PR.
Line 2 is budget: context bar, cost, lines changed, rate limits, prompt cache.

Reads the status line JSON payload on stdin. See
https://code.claude.com/docs/en/statusline for the schema.

Optional environment variables:
  STATUSLINE_GUARD_FILE     path relative to the project root, checked only in
                            worktree sessions
  STATUSLINE_GUARD_PATTERN  regex the file must match to be considered safe
  STATUSLINE_GUARD_LABEL    label shown when the guard is unsatisfied
  STATUSLINE_BAR_WIDTH      context bar width in characters (default 12)
"""

import json
import os
import re
import subprocess
import sys
import time

DIM, CYAN, GRN, YEL, RED, MAG, RESET = (
    "\033[2m",
    "\033[36m",
    "\033[32m",
    "\033[33m",
    "\033[31m",
    "\033[35m",
    "\033[0m",
)

# tag -> short badge appended to the project name, telling you what :deploy targets
DEPLOY_TARGETS = {
    "modal": "modal",
    "cloud-run": "run",
    "cloud-functions": "fn",
    "firebase-hosting": "hosting",
}

GIT_CACHE_SECONDS = 5


def read_payload():
    return json.load(sys.stdin)


def field(data, path, default=None):
    """Read a dotted path, treating null and missing alike."""
    node = data
    for key in path.split("."):
        if not isinstance(node, dict) or node.get(key) is None:
            return default
        node = node[key]
    return node


def short_model_name(display_name, model_id):
    """"Opus 5 (1M context)" -> "Opus 5 1M"."""
    name = re.sub(
        r"\s*\(\s*([\d.]+)\s*([MK])\s*context\s*\)", r" \1\2", display_name, flags=re.I
    )
    if not re.search(r"\d+[MK]$", name):
        # some names omit the window but the id carries it, e.g. claude-opus-5[1m]
        tagged = re.search(r"\[\s*([\d.]+)\s*([mk])\s*\]", model_id, re.I)
        if tagged:
            name += f" {tagged.group(1)}{tagged.group(2).upper()}"
    return name


def moon_project(cwd, root):
    """Nearest moon.pkl walking up, honouring a declared `id`, plus its deploy target."""
    path = cwd
    while path and path != "/":
        manifest = os.path.join(path, "moon.pkl")
        if os.path.isfile(manifest):
            try:
                source = open(manifest, encoding="utf-8").read()
            except OSError:
                source = ""
            declared = re.search(r'^\s*id\s*=\s*"([^"]+)"', source, re.M)
            name = declared.group(1) if declared else os.path.basename(path)
            target = None
            tags = re.search(r"tags\s*=\s*(?:\n\s*)?List\(([^)]*)\)", source)
            if tags:
                found = re.findall(r'"([^"]+)"', tags.group(1))
                target = next((DEPLOY_TARGETS[t] for t in found if t in DEPLOY_TARGETS), None)
            return name, target
        if path == root:
            break
        path = os.path.dirname(path)
    return os.path.basename(cwd), None


def git_state(cwd, session_id):
    """Branch plus staged and dirty counts, cached briefly so large repos stay fast."""
    cache = os.path.join(os.environ.get("TMPDIR", "/tmp"), f"moon-statusline-{session_id}")
    try:
        fresh = time.time() - os.path.getmtime(cache) <= GIT_CACHE_SECONDS
    except OSError:
        fresh = False
    if not fresh:
        try:
            branch = subprocess.run(
                ["git", "-C", cwd, "branch", "--show-current"],
                capture_output=True,
                text=True,
                timeout=2,
            ).stdout.strip()
            porcelain = subprocess.run(
                ["git", "-C", cwd, "status", "--porcelain"],
                capture_output=True,
                text=True,
                timeout=2,
            ).stdout.splitlines()
            staged = sum(1 for line in porcelain if line[:1] not in (" ", "?", ""))
            dirty = sum(
                1 for line in porcelain if line[1:2] in ("M", "D") or line.startswith("??")
            )
            record = f"{branch}|{staged}|{dirty}"
        except Exception:
            record = "||"
        try:
            with open(cache, "w") as handle:
                handle.write(record)
        except OSError:
            return record.split("|")
    try:
        return (open(cache).read().strip() + "||").split("|")[:3]
    except OSError:
        return ["", "0", "0"]


def guard_satisfied(root):
    """True when the configured guard file exists at the root and matches its pattern."""
    name = os.environ.get("STATUSLINE_GUARD_FILE")
    pattern = os.environ.get("STATUSLINE_GUARD_PATTERN")
    if not name or not pattern:
        return True
    target = os.path.join(root, name)
    if not os.path.isfile(target):
        return False
    try:
        return bool(re.search(pattern, open(target, encoding="utf-8").read(), re.S))
    except OSError:
        return False


def identity_line(data):
    cwd = field(data, "workspace.current_dir", "")
    root = field(data, "workspace.project_dir", "")
    project, target = moon_project(cwd, root)
    branch, staged, dirty = git_state(cwd, field(data, "session_id", "unknown"))

    model = f"{CYAN}{short_model_name(field(data, 'model.display_name', '?'), field(data, 'model.id', ''))}{RESET}"
    if field(data, "effort.level"):
        model += f"{DIM}·{field(data, 'effort.level')}{RESET}"
    if field(data, "fast_mode"):
        model += f" {YEL}⚡{RESET}"
    segments = [model]

    segments.append(f"{MAG}{project}{RESET}" + (f"{DIM}:{target}{RESET}" if target else ""))

    worktree = field(data, "worktree.name") or field(data, "workspace.git_worktree")
    if worktree:
        segments.append(f"{DIM}⑂ {worktree}{RESET}")
        if not guard_satisfied(root):
            segments.append(f"{YEL}{os.environ.get('STATUSLINE_GUARD_LABEL', 'unguarded')}{RESET}")

    if branch:
        git = f"{DIM}on{RESET} {branch}"
        if int(staged or 0):
            git += f" {GRN}+{staged}{RESET}"
        if int(dirty or 0):
            git += f" {YEL}~{dirty}{RESET}"
        segments.append(git)

    if field(data, "pr.number"):
        colour = {"approved": GRN, "changes_requested": RED}.get(
            field(data, "pr.review_state", ""), DIM
        )
        segments.append(f"{colour}#{field(data, 'pr.number')}{RESET}")

    return f" {DIM}·{RESET} ".join(segments)


def budget_line(data):
    used = int(field(data, "context_window.used_percentage", 0) or 0)
    size = field(data, "context_window.context_window_size", 0) or 0
    width = int(os.environ.get("STATUSLINE_BAR_WIDTH", "12"))
    filled = used * width // 100
    colour = RED if used >= 90 else YEL if used >= 70 else GRN

    context = f"{colour}{'█' * filled}{'░' * (width - filled)}{RESET} {used}%"
    if size:
        context += f"{DIM}/{size // 1000}k{RESET}"
    segments = [context]

    cost = field(data, "cost.total_cost_usd", 0) or 0
    elapsed = field(data, "cost.total_duration_ms", 0) or 0
    segments.append(
        f"{YEL}${cost:.2f}{RESET} {DIM}{elapsed // 60000}m{(elapsed % 60000) // 1000:02d}s{RESET}"
    )

    added = field(data, "cost.total_lines_added", 0)
    removed = field(data, "cost.total_lines_removed", 0)
    if added or removed:
        segments.append(f"{GRN}+{added or 0}{RESET}/{RED}-{removed or 0}{RESET}")

    limits = []
    for key, label in (("five_hour", "5h"), ("seven_day", "7d"), ("spend_limit", "$")):
        value = field(data, f"rate_limits.{key}.used_percentage")
        if value is not None:
            colour = RED if value >= 85 else YEL if value >= 60 else DIM
            limits.append(f"{colour}{label} {value:.0f}%{RESET}")
    if limits:
        segments.append(" ".join(limits))

    if field(data, "prompt_cache") is not None:
        warm = field(data, "prompt_cache.warm")
        ratio = field(data, "prompt_cache.hit_ratio")
        cache = f"{GRN if warm else DIM}cache {'warm' if warm else 'cold'}{RESET}"
        if ratio is not None:
            cache += f"{DIM} {ratio * 100:.0f}%{RESET}"
        segments.append(cache)

    return f" {DIM}│{RESET} ".join(segments)


def main():
    data = read_payload()
    print(identity_line(data))
    print(budget_line(data))


if __name__ == "__main__":
    main()
