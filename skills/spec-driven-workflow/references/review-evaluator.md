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

For bugfixes: **fail the review** if Unchanged/KEEP items were not checked.

## Anti-patterns

- “Looks good” without reading the spec or diff
- Treating implement-turn self-grade as `/review`
- Checking only the fix path and ignoring the KEEP fence
- Skipping verify because the review narrative sounded confident

## Output shape

Report findings by severity with actionable fixes. Offer to apply safe fixes when asked; then re-verify. Suggest merge only when checklist items that apply are satisfied (or explicitly waived by the human).
