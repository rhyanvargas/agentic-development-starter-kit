---
name: pull-request-authoring
description: >-
  Open or refresh GitHub pull requests with Conventional Commits titles and
  bodies filled from branch commits (Summary, Changes, checklist). Use when
  creating a PR, /create-pr, “open a pull request”, “fill the PR description”,
  or fixing an empty template body. Do not use for release-please/changelog
  wiring (release-automation), Socket triage (supply-chain-gate), code review
  against specs (spec-driven-workflow /review), or commit-message-only asks.
---

# Pull Request Authoring

Fill PR title + body from **this branch’s commits**, then create or update via `gh`.
GitHub’s static PR template does **not** auto-fill from commits — this skill does.

## Defaults

- Base branch: `main` (or repo default if different)
- Title: Conventional Commits from the dominant change (`feat:`, `fix:`, `docs:`, …)
- Body: repo `.github/PULL_REQUEST_TEMPLATE.md` shape when present; else Summary / Changes / Test plan
- Tooling: `gh pr create` / `gh pr edit` (never open an empty template and stop)

## Procedure

### 1. Gather evidence (parallel)

```bash
git status -sb
git diff && git diff --staged
git rev-parse --abbrev-ref @{upstream} 2>/dev/null || true
git log --oneline <base>...HEAD
git diff <base>...HEAD
```

Use **all** commits on the branch (not only the tip). Prefer `origin/<base>` when available.

### 2. Draft title + body

1. Title = Conventional Commits summarizing the branch (dominant type + scope if clear).
2. **Summary** = why (1–3 bullets from commit messages + diff intent).
3. **Changes** = what (file/area bullets; no secrets).
4. Checklist = leave unchecked boxes from the repo template; do not invent fake completed items.
5. If the working tree has uncommitted work the user asked to include — stop and confirm before pushing.

Load `references/body-template.md` when the repo has no PR template or the body shape is unclear.

### 3. Publish

| State | Action |
|-------|--------|
| No PR for this head | Push `-u` if needed → `gh pr create --title … --body …` |
| PR exists, body empty/template-only | `gh pr edit <n> --title … --body …` (and fix title if branch-name style) |
| PR exists, body already substantive | Ask before overwriting |

Pass body via HEREDOC. Return the PR URL when done.

```bash
gh pr create --title "feat: …" --body "$(cat <<'EOF'
## Summary
…

## Changes
- …

## Checklist
…
EOF
)"
```

### 4. Out of scope (say so)

- **IDE / Diff-tab “Create PR”** — does not load this skill; prefer `/create-pr` or “create a PR” in Agent chat.
- Release automation, Socket triage, or spec review — hand off to those skills.

## Done checklist

- [ ] Title is Conventional Commits
- [ ] Body Summary + Changes derived from `git log <base>...HEAD` (+ diff)
- [ ] Claims in Summary/Changes trace to `git log`/`git diff` output actually gathered this run — not inferred from memory
- [ ] `gh pr create` or `gh pr edit` used (not an empty template dump)
- [ ] PR URL reported

## Progressive disclosure

| Reference | When to read |
|-----------|----------------|
| `references/body-template.md` | No `.github/PULL_REQUEST_TEMPLATE.md`, or need ADSK default sections |
| `references/edge-cases.md` | Existing PR, wrong base, fork, or push/auth failures |

`/create-pr` is a thin Cursor wrapper that invokes this skill.
