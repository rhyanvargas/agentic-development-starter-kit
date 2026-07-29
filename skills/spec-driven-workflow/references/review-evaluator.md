# Review evaluator split (generator ≠ evaluator)

Use for **Medium+** post-implement quality review (`/review` and the skill Review phase). Implements the harness rule: the agent that **generated** the change must not be the sole judge that it is done.

Aligned with fail-closed verify (`project-cmds`) — review **adds** a refute pass; it does not replace verify.

## Posture

1. Run review as a **separate evaluate pass** after implement (prefer a fresh chat / explicit `/review`, not a one-line “LGTM” at the end of the implement turn).
2. Be **refute-minded**: try to falsify “done” against the living spec, plan, and Unchanged fence.
3. Do **not** claim Medium+ work complete from the implement session’s self-check alone — even if tests were written in that session.
4. After fixes from review findings, re-run verify; re-review if changes were material.

## Minimum checklist

| Check | Pass when |
|-------|-----------|
| Spec / REQ compliance | Implemented behavior matches stated REQs (or documented intentional delta) |
| Regression fence | Bugfix **Unchanged / KEEP** items still hold (`bugfix-workflow.md`) |
| Security-sensitive paths | Auth, secrets, money, PII, destructive ops reviewed when in scope |
| Tests vs REQs | Automated checks map to REQs, or an explicit non-behavioral justification exists |
| Fail-closed verify | `project-cmds` / project verify ran green; if missing, refuse “done” and point to `/quick-start` |
| Docs / README drift | If the diff changes **user-facing surface** (CLI flags/commands, install path, public profiles/packs, Quick Start claims), README/`docs/` match or the gap is flagged; see handoff below. N/A when surface unchanged |

For bugfixes: **fail the review** if Unchanged/KEEP items were not checked.

### Docs / README handoff (not full sync)

When user-facing surface changed and docs look stale:

1. **Flag** as a medium (or higher) finding — do not silently pass.
2. **Hand off** to `/update-readme` (skill: `readme-authoring`) when that skill is installed; otherwise tell the user to sync README/`docs/` manually or adopt a profile that includes `readme-authoring`.
3. Do **not** run a full README rewrite inside `/review` unless the user explicitly asks — keep the evaluate pass lean.

## Anti-patterns

- “Looks good” without reading the spec or diff
- Treating implement-turn self-grade as `/review`
- Checking only the fix path and ignoring the KEEP fence
- Skipping verify because the review narrative sounded confident
- Rewriting README/`docs/` on every review when surface did not change
- Ignoring stale Quick Start / CLI docs after a user-facing change

## Output shape

Report findings by severity with actionable fixes. Offer to apply safe fixes when asked; then re-verify. For docs drift, prefer suggesting `/update-readme` over expanding review scope. Suggest merge only when checklist items that apply are satisfied (or explicitly waived by the human).
