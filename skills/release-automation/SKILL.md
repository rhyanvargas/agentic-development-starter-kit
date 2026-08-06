---
name: release-automation
description: >-
  Wire Conventional Commits–based version and changelog automation for a
  repo after confirming the DevOps platform (GitHub Actions, Azure DevOps,
  or other). Persists the choice in project-local skill context and installs
  matching pipeline/config. Use when setting up release-please, auto
  changelog, semver tags, /setup-releases, or “automate releases”. Do not use
  for full DevOps strategy design, writing app feature specs, or debugging a
  single unrelated CI failure.
---

# Release Automation

Automate **version bumps + changelog** from Conventional Commits — only after
the project’s DevOps platform is confirmed and recorded.

## Principles

- **Platform first** — never assume GitHub; confirm before writing workflows.
- **Persist locally** — write the choice into this skill’s project context so
  later sessions skip re-discovery.
- **One default per platform** — GitHub → release-please; Azure DevOps →
  pipeline + git-cliff (or agreed equivalent). Escape hatches in references.
- **Commits drive releases** — PR titles / commits must be Conventional Commits.

## Procedure

### 1. Resolve skill home

| Context | Skill directory |
|---------|-----------------|
| ADSK kit | `skills/release-automation/` |
| Adopter app | `.agents/skills/release-automation/` |

All project-local writes go under **that** directory (never invent a root `skills/` folder in adopter apps).

### 2. Load or confirm platform

1. If `references/project-context.md` exists, load it and treat values as current
   unless the user asks to change them.
2. Else gather evidence (do not invent):
   - Remotes: `git remote -v` (github.com vs dev.azure.com / visualstudio.com)
   - CI files: `.github/workflows/`, `azure-pipelines.yml`, `.azure-pipelines/`,
     `.ado/`, `Jenkinsfile`, `.gitlab-ci.yml`
   - Existing release tooling: `release-please-config.json`, `CHANGELOG.md`,
     `version.txt`, `package.json` `version`, GitVersion config
3. **Confirm with the user** when evidence is missing, mixed, or conflicts
   (e.g. Azure Pipelines building a GitHub repo). Ask one focused question:
   platform + default branch + package shape (`simple` / `node` / `python` / other).
4. Write or update `references/project-context.md` using
   `references/project-context.template.md` **before** installing automation.
5. Keep human docs in sync: create/update `docs/RELEASE.md` with the same
   platform decision (short; link to this skill).

### 3. Install automation for that platform

| Platform | Load |
|----------|------|
| GitHub (Actions) | `references/github-release-please.md` |
| Azure DevOps | `references/azure-devops-changelog.md` |
| Other / unsure | `references/platform-decision.md` — stop after a recommendation; do not invent YAML |

Follow the loaded guide’s checklist. Prefer additive, idempotent edits
(“create if missing”; don’t clobber a working pipeline without asking).

### 4. Contributor wiring (all platforms)

- PR template or CONTRIBUTING note: Conventional Commit **PR title**
  (`feat:`, `fix:`, `docs:`, `chore:`; breaking: `feat!:` or `BREAKING CHANGE:`).
- Prefer squash-merge so the PR title becomes the release commit subject.
- User-visible changes → `feat` / `fix` (not only `chore`) so they appear in
  the changelog.

### 5. Verify before done

- [ ] `references/project-context.md` records platform, branch, package type
- [ ] Platform/branch claims in `project-context.md` and `docs/RELEASE.md` cite the evidence gathered in step 2 (remotes/CI files), not assumption
- [ ] `docs/RELEASE.md` matches that context
- [ ] Platform checklist complete (permissions, first tag / bootstrap called out)
- [ ] No second competing release tool added without explicit user approval
- [ ] Report what was written and any manual org settings still required

## Progressive disclosure

| Reference | When to read |
|-----------|----------------|
| `references/project-context.template.md` | Creating or rewriting `project-context.md` |
| `references/platform-decision.md` | Ambiguous/mixed hosting, or non-GitHub/Azure platform |
| `references/github-release-please.md` | Confirmed GitHub Actions path |
| `references/azure-devops-changelog.md` | Confirmed Azure DevOps path |
| `references/conventional-commits.md` | PR/commit message rules or changelog section mapping |

`/setup-releases` is a thin Cursor wrapper that invokes this skill.

## Near-miss handoff

- Full branching / env promotion / secrets strategy → `devops-strategy-facilitator`
- Socket / supply-chain PR gates → `supply-chain-gate`
- README sync → `readme-authoring`
- Feature specs → `spec-driven-workflow`
