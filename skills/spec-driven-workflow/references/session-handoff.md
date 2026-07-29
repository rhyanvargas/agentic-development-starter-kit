# Session handoff / progress contract

Use for **Medium+** multi-session work. This is a **HITL multi-session delivery harness** contract — process across context resets, not more agent power, and **not** an AFK/Ralph product ([`docs/product/agent-autonomy.md`](../../../docs/product/agent-autonomy.md)).

## Where progress lives

Prefer **one living artifact**: add a `## Handoff / Progress` section on the active **plan** (Cursor `.cursor/plans/*.plan.md` or portable `docs/plans/`). If there is no plan (Small path that grew), put it on the living **spec**. Do **not** invent a `.kiro`-style triad or separate progress tree.

Keep Cursor Plan YAML `todos` statuses in sync when work advances (`cursor-adapter.md`).

## Session start (before coding)

1. Locate living **spec** + **plan** (`artifact-homes.md`).
2. Read the latest **Handoff / Progress** section (if any).
3. Confirm next item (`REQ-XXX` / plan `T#`) and whether the plan is stale — if REQs changed after the plan, **resync** (`/plan-impl`) before coding.
4. Honor **Clear**: durable findings are already in artifacts; do not reload the full prior exploration transcript as working context.
5. Then implement only the next bounded slice.

## Session end (when stopping or context is large)

Before ending a Medium+ session that leaves work incomplete (or when switching tasks):

1. Update plan/spec **Handoff / Progress** with:
   - **Done** — what landed this session (map to REQ/T# when possible)
   - **Files** — paths touched this session (created/modified/deleted)
   - **Now** — exact next `REQ-XXX` / `T#` (one primary next step)
   - **Watchouts** — open questions, blockers, risky areas
   - **Git** — clean working tree expected; if WIP remains, say whether it is committed, stashed, or intentionally dirty (and why)
2. Sync plan todo statuses (`pending` / `in_progress` / `completed`).
3. Do **not** declare the feature “done” here — that still requires fail-closed verify + `/review` (see `review-evaluator.md`).

### Progress section template

```markdown
## Handoff / Progress

- **Updated:** YYYY-MM-DD
- **Done:** …
- **Files:** path/a, path/b, …
- **Now:** REQ-00X / T# — …
- **Watchouts:** …
- **Git:** clean | committed on branch X | stash … | dirty (why: …)
```

## Boundaries

| Do | Do not |
|----|--------|
| Hand off across human-gated sessions | Ship a Ralph / Issues AFK loop skill |
| Bound each session to the next REQ/T# | One-shot the entire Medium+ plan in one context dump |
| Persist progress in the living plan/spec | Rely on chat memory alone after a reset |

Trivial/Small one-shot work may skip formal handoff; if the session grows to Medium+, start the contract immediately.
