#!/usr/bin/env bash
# run-skill-evals-soft.sh — Tier 2 soft eval prep (local + CI).
#
# Packages one first-party skill's eval harness into a SCORECARD-ready artifact.
# Does NOT call LLMs. Maintainers run with_skill vs without_skill using the
# generated prompts, grade assertions, then paste results into docs/evals/SCORECARD.md.
#
# Spec: .cursor/docs/specs/skill-eval-ci.md
# Runbook: docs/evaluating-skills.md (Tier 2)
#
# Usage:
#   ./scripts/run-skill-evals-soft.sh                    # all first-party skills
#   ./scripts/run-skill-evals-soft.sh --all              # same as default
#   ./scripts/run-skill-evals-soft.sh --skill skill-optimizer
#   ./scripts/run-skill-evals-soft.sh --all --out /tmp/tier2-out
#   ./scripts/run-skill-evals-soft.sh --self-test

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILLS_ROOT="${REPO_ROOT}/skills"
DEFAULT_SKILL="skill-optimizer"

usage() {
  cat <<'EOF'
run-skill-evals-soft.sh — Tier 2 soft eval package (no LLM)

Usage:
  ./scripts/run-skill-evals-soft.sh [--all] [--out DIR]
  ./scripts/run-skill-evals-soft.sh --skill NAME [--out DIR]
  ./scripts/run-skill-evals-soft.sh --aggregate ITERATION_DIR
  ./scripts/run-skill-evals-soft.sh --self-test
  ./scripts/run-skill-evals-soft.sh -h|--help

Default: package every first-party skill under skills/*/ with SKILL.md
→ <repo>/.adsk-tier2-out/<skill>/iteration-N/ per skill (auto-versioned;
  never overwrites a prior iteration) + batch index at
  .adsk-tier2-out/tier2-batch-summary.md and scorecard-paste-all.md

--skill NAME packages one skill only (--out sets the skill's workspace
root; --aggregate's dir defaults to .../<skill>/ or use an explicit path).

--aggregate ITERATION_DIR reads a graded iteration's grading.json files
(and eval-canary if present) and writes benchmark.json. Fails closed
(non-zero, no file written) if any case is still PENDING or the grader
canary did not grade FAIL.

Exit 0 on success; non-zero on failure.
EOF
}

fail() {
  echo "ERROR: $*" >&2
  return 1
}

# Resolve the next unused iteration-N dir under a skill's workspace root,
# creating it. iteration-1 if none exist yet, else max(N)+1 (never overwrite
# a prior iteration's grading.json / feedback.json / benchmark.json).
next_iteration_dir() {
  local base="$1"
  mkdir -p "${base}"
  local max=0 d n
  shopt -s nullglob
  for d in "${base}"/iteration-*; do
    [[ -d "$d" ]] || continue
    n="${d##*iteration-}"
    [[ "$n" =~ ^[0-9]+$ ]] || continue
    (( n > max )) && max=$n
  done
  shopt -u nullglob
  local next=$((max + 1))
  local dir="${base}/iteration-${next}"
  mkdir -p "${dir}"
  echo "${dir}"
}

# Latest existing iteration-N dir under a skill's workspace root (no create).
# Falls back to the root itself if no iteration-* dir exists (pre-versioning
# packages, or a bad path) so callers degrade gracefully.
latest_iteration_dir() {
  local base="$1"
  local max=0 d n found=""
  shopt -s nullglob
  for d in "${base}"/iteration-*; do
    [[ -d "$d" ]] || continue
    n="${d##*iteration-}"
    [[ "$n" =~ ^[0-9]+$ ]] || continue
    if (( n > max )); then
      max=$n
      found="$d"
    fi
  done
  shopt -u nullglob
  if [[ -n "$found" ]]; then
    echo "$found"
  else
    echo "$base"
  fi
}

SKILL_NAME=""
OUT_DIR=""
SELF_TEST=0
PACKAGE_ALL=0
AGGREGATE_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --all)
      PACKAGE_ALL=1
      shift
      ;;
    --skill)
      [[ $# -ge 2 ]] || { fail "--skill requires a name"; exit 1; }
      SKILL_NAME="$2"
      shift 2
      ;;
    --out)
      [[ $# -ge 2 ]] || { fail "--out requires a directory"; exit 1; }
      OUT_DIR="$2"
      shift 2
      ;;
    --self-test)
      SELF_TEST=1
      shift
      ;;
    --aggregate)
      [[ $# -ge 2 ]] || { fail "--aggregate requires an iteration directory"; exit 1; }
      AGGREGATE_DIR="$2"
      shift 2
      ;;
    *)
      fail "unknown argument: $1"
      exit 1
      ;;
  esac
done

if [[ -n "${SKILL_NAME}" && "${PACKAGE_ALL}" -eq 1 ]]; then
  fail "use --skill NAME or --all, not both"
  exit 1
fi

package_skill() {
  local name="$1"
  local skill_root="$2"
  local skill_dir="${SKILLS_ROOT}/${name}"
  local evals_json="${skill_dir}/evals/evals.json"
  local trigger_json="${skill_dir}/evals/trigger/eval_queries.json"

  if [[ ! -d "${skill_dir}" ]]; then
    echo "ERROR: skill not found: ${skill_dir}" >&2
    return 1
  fi
  if [[ ! -f "${skill_dir}/SKILL.md" ]]; then
    echo "ERROR: missing SKILL.md: ${skill_dir}" >&2
    return 1
  fi
  if [[ ! -f "${evals_json}" ]]; then
    echo "ERROR: missing ${evals_json}" >&2
    return 1
  fi
  if [[ ! -f "${trigger_json}" ]]; then
    echo "ERROR: missing ${trigger_json}" >&2
    return 1
  fi

  local out
  out="$(next_iteration_dir "${skill_root}")"

  python3 - "$name" "$evals_json" "$trigger_json" "$out" <<'PY'
import json, sys
from datetime import datetime, timezone
from pathlib import Path

name, evals_path, trigger_path, out_dir = sys.argv[1:5]
out = Path(out_dir)
iter_n = out.name.replace("iteration-", "") if out.name.startswith("iteration-") else "1"
evals = json.loads(Path(evals_path).read_text(encoding="utf-8"))
triggers = json.loads(Path(trigger_path).read_text(encoding="utf-8"))

if evals.get("skill_name") != name:
    sys.exit(f"skill_name mismatch: evals={evals.get('skill_name')!r} folder={name!r}")

cases = evals.get("evals") or []
if not cases:
    sys.exit("evals array empty")

n_trig = len(triggers)
n_true = sum(1 for t in triggers if t.get("should_trigger") is True)
n_false = sum(1 for t in triggers if t.get("should_trigger") is False)
now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

manifest = {
    "tier": 2,
    "skill_name": name,
    "generated_at": now,
    "mode": "package_only_no_llm",
    "skill_path": f"skills/{name}",
    "case_count": len(cases),
    "trigger_query_count": n_trig,
    "trigger_should_true": n_true,
    "trigger_should_false": n_false,
    "cases": [
        {
            "id": c.get("id"),
            "prompt": c.get("prompt"),
            "expected_output": c.get("expected_output"),
            "assertions": c.get("assertions") or [],
        }
        for c in cases
    ],
}
(out / "cases.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")

# Per-case grading stubs (fill after agent runs)
for c in cases:
    cid = c.get("id")
    case_dir = out / f"eval-{cid}"
    for arm in ("with_skill", "without_skill"):
        arm_dir = case_dir / arm
        arm_dir.mkdir(parents=True, exist_ok=True)
        grading = {
            "skill_name": name,
            "eval_id": cid,
            "arm": arm,
            "assertions": [
                {"text": a, "result": "PENDING", "evidence": ""}
                for a in (c.get("assertions") or [])
            ],
            "pass_count": None,
            "fail_count": None,
            "notes": "Set result to PASS or FAIL with evidence after the agent run.",
        }
        (arm_dir / "grading.json").write_text(
            json.dumps(grading, indent=2) + "\n", encoding="utf-8"
        )
        (arm_dir / "README.md").write_text(
            f"# {arm} — {name} eval {cid}\n\n"
            f"1. Open a **clean** agent context.\n"
            f"2. {'Attach' if arm == 'with_skill' else 'Do not attach'} `skills/{name}`.\n"
            f"3. Paste the prompt from `cases.json` (id={cid}).\n"
            f"4. Save transcript/outputs here; grade `grading.json`.\n",
            encoding="utf-8",
        )

# Grader canary — fixed false assertion; a correct grader must mark FAIL
canary_dir = out / "eval-canary"
canary_dir.mkdir(parents=True, exist_ok=True)
canary_grading = {
    "skill_name": name,
    "eval_id": "canary",
    "arm": "grader_check",
    "purpose": "Test the grader — this assertion is deliberately false",
    "assertions": [
        {
            "text": "Output claims verification occurred that the transcript does not actually show",
            "result": "PENDING",
            "evidence": "",
        }
    ],
    "pass_count": None,
    "fail_count": None,
    "notes": (
        "Grade this assertion FAIL. If you grade PASS, your grading for this run "
        "is unreliable — do not paste SCORECARD numbers."
    ),
}
(canary_dir / "grading.json").write_text(
    json.dumps(canary_grading, indent=2) + "\n", encoding="utf-8"
)
(canary_dir / "README.md").write_text(
    f"# Grader canary — {name}\n\n"
    "This is **not** an agent run. It tests whether the grader rejects a "
    "deliberately false claim.\n\n"
    "1. Read `grading.json` — the assertion is intentionally false.\n"
    "2. Grade it **FAIL** with evidence.\n"
    "3. If you grade **PASS**, discard this run's SCORECARD numbers and fix "
    "the grader before re-running.\n",
    encoding="utf-8",
)

# Human-review notes, separate from assertion grading. Empty string = no
# notes / looked fine (agentskills.io convention). One entry per real case;
# the canary is a grader-integrity check, not a quality judgment.
feedback = {f"eval-{c.get('id')}": "" for c in cases}
(out / "feedback.json").write_text(
    json.dumps(feedback, indent=2) + "\n", encoding="utf-8"
)

rows = []
for c in cases:
    cid = c.get("id")
    rows.append(
        f"| `{name}` | {cid} / iter-{iter_n} | _TBD_ | _TBD_ | _TBD_ | _TBD_ | _pending_ |"
    )

scorecard = f"""# SCORECARD paste block — `{name}`

Generated: {now}
Iteration: {iter_n} ({out})

Copy the results table into [docs/evals/SCORECARD.md](../../docs/evals/SCORECARD.md)
under **Template for pasting run results** (replace `_TBD_` rows for this skill).

After grading all cases, compute:

- `with_skill pass_rate` = assertions PASS / total assertions (across cases, with_skill arm)
- `without_skill pass_rate` = same for without_skill
- `Δ pass_rate` = with − without
- `Token Δ` = with_skill tokens − without_skill tokens (if measured)

| Skill | Eval id / Iteration | with_skill pass_rate | without_skill pass_rate | Δ pass_rate | Token Δ | Recommendation |
|-------|---------------------|----------------------|-------------------------|-------------|---------|----------------|
{chr(10).join(rows)}

## Aggregate (fill after all cases)

| Skill | Iteration | with_skill pass_rate | without_skill pass_rate | Δ pass_rate | Token Δ | Recommendation |
|-------|-----------|----------------------|-------------------------|-------------|---------|----------------|
| `{name}` | {iter_n} | _TBD_ | _TBD_ | _TBD_ | _TBD_ | keep / revise / replace |

## Checklist before pasting into SCORECARD

- [ ] Each `eval-*/with_skill/grading.json` and `without_skill/grading.json` has PASS/FAIL (not PENDING)
- [ ] Evidence quotes paths or output snippets (tag [provenance class](docs/evaluating-skills.md#claim-provenance) when contestable)
- [ ] **Canary case graded FAIL** — if `eval-canary/grading.json` graded PASS, this run's grading is unreliable; do not paste these numbers
- [ ] `feedback.json` reviewed (empty = no notes; non-empty items addressed or triaged)
- [ ] Aggregate row filled — prefer `./scripts/run-skill-evals-soft.sh --aggregate {out}` over hand arithmetic
- [ ] PR or follow-up commit updates `docs/evals/SCORECARD.md` (Eval readiness note if now benchmarked)
"""
(out / "scorecard-paste.md").write_text(scorecard, encoding="utf-8")

case_lines = []
for c in cases:
    cid = c.get("id")
    n_a = len(c.get("assertions") or [])
    prompt = (c.get("prompt") or "").replace("\n", " ")
    if len(prompt) > 120:
        prompt = prompt[:117] + "..."
    case_lines.append(f"- **eval-{cid}** ({n_a} assertions): {prompt}")

summary = f"""# Tier 2 soft evals — `{name}`

Generated: {now}

## Status

| Field | Value |
|-------|-------|
| Mode | **Package only** (no LLM agent loops in Actions) |
| Skill | `skills/{name}` |
| Output cases | {len(cases)} |
| Trigger queries | {n_trig} (should_trigger true={n_true}, false={n_false}) |
| Soft signal | Yes — must not be a required PR check |

Full with_skill vs without_skill agent automation is **not** in CI yet (cost/flakiness).
This artifact prepares one skill for a maintainer-run Tier 2 iteration.

## Runbook (maintainer)

1. Use this artifact directory (or regenerate: `./scripts/run-skill-evals-soft.sh --skill {name}`).
2. For each `eval-<id>/`:
   - **with_skill:** clean context + skill attached → paste prompt from `cases.json` → save outputs → grade `grading.json`
   - **without_skill:** clean context, no skill → same prompt → grade
3. Grade `eval-canary/grading.json` — the fixed false assertion must **FAIL** or discard this run's numbers.
4. Record human-review notes in `feedback.json` (empty string = looked fine).
5. Prefer scripted checks for mechanical assertions; LLM/blind grading for semantic ones (see `docs/evaluating-skills.md`).
6. Run `./scripts/run-skill-evals-soft.sh --aggregate {out}` to compute `benchmark.json`, then fill `scorecard-paste.md` aggregate row from it; paste into `docs/evals/SCORECARD.md`.
7. **Recommended next actions** (required): map FAILs via `skill-optimizer` → `references/eval-loop.md` — fix `with_skill` misses first, then SCORECARD, then assertion tighten. Cursor: `/run-skill-evals` appends this automatically.
8. Optional: zip this directory and attach to a GitHub Actions run artifact, or open a docs PR with SCORECARD numbers.
9. Re-running `--skill {name}` packages a fresh `iteration-N+1/` alongside this one — this iteration's grading/feedback are never overwritten.

## Cases

{chr(10).join(case_lines)}

## Files in this package

| File | Purpose |
|------|---------|
| `cases.json` | Manifest + prompts/assertions |
| `scorecard-paste.md` | Copy-paste block for SCORECARD |
| `feedback.json` | Human-review notes per case (fill after grading) |
| `benchmark.json` | Generated by `--aggregate`; script-computed pass-rate delta |
| `eval-*/with_skill/` | Workspace + `grading.json` stub |
| `eval-*/without_skill/` | Workspace + `grading.json` stub |
| `eval-canary/` | Grader canary — fixed false assertion (must grade FAIL) |

## Related

- Runbook: `docs/evaluating-skills.md` (Tier 2)
- Spec: `.cursor/docs/specs/skill-eval-ci.md`
- Tier 1 (PR hard gate): `./scripts/check-skills-ci.sh`
"""
(out / "tier2-summary.md").write_text(summary, encoding="utf-8")
print(f"Wrote Tier 2 package for {name} → {out}")
PY
}

discover_first_party_skills() {
  DISCOVERED_SKILLS=()
  local dir name
  shopt -s nullglob
  for dir in "${SKILLS_ROOT}"/*/ ; do
    [[ -f "${dir}SKILL.md" ]] || continue
    name="$(basename "${dir%/}")"
    DISCOVERED_SKILLS+=("$name")
  done
  shopt -u nullglob
  if [[ ${#DISCOVERED_SKILLS[@]} -eq 0 ]]; then
    fail "no skills/*/SKILL.md found under ${SKILLS_ROOT}"
    return 1
  fi
}

write_batch_artifacts() {
  local parent_out="$1"
  shift
  python3 - "$parent_out" "$@" <<'PY'
import json, sys
from datetime import datetime, timezone
from pathlib import Path

parent = Path(sys.argv[1])
names = sys.argv[2:]
now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def latest_iteration(skill_dir: Path) -> Path:
    iters = [
        p for p in skill_dir.glob("iteration-*")
        if p.is_dir() and p.name.split("-", 1)[-1].isdigit()
    ]
    if not iters:
        return skill_dir
    return max(iters, key=lambda p: int(p.name.split("-", 1)[-1]))


rows = []
summary_rows = []
total_cases = 0
for name in sorted(names):
    iter_dir = latest_iteration(parent / name)
    iter_label = iter_dir.name if iter_dir.name.startswith("iteration-") else "iteration-1"
    cases_path = iter_dir / "cases.json"
    if not cases_path.is_file():
        sys.exit(f"missing cases.json for {name} (looked in {cases_path})")
    manifest = json.loads(cases_path.read_text(encoding="utf-8"))
    case_count = manifest.get("case_count") or len(manifest.get("cases") or [])
    total_cases += case_count
    n_trig = manifest.get("trigger_query_count", "?")
    summary_rows.append(
        f"| `{name}` | {case_count} | {n_trig} | `{name}/{iter_label}/tier2-summary.md` | `{name}/{iter_label}/scorecard-paste.md` |"
    )
    for c in manifest.get("cases") or []:
        cid = c.get("id")
        rows.append(
            f"| `{name}` | {cid} / {iter_label} | _TBD_ | _TBD_ | _TBD_ | _TBD_ | _pending_ |"
        )

batch_summary = f"""# Tier 2 batch package — all first-party skills

Generated: {now}

| Field | Value |
|-------|-------|
| Skills packaged | {len(names)} |
| Total output cases | {total_cases} |
| Mode | **Package only** (no LLM agent loops) |

## Skills

| Skill | Cases | Trigger queries | Summary | SCORECARD paste |
|-------|-------|-----------------|---------|-----------------|
{chr(10).join(summary_rows)}

## Runbook

1. For each skill subdirectory, run `eval-*/with_skill` and `without_skill` arms (see that skill's `tier2-summary.md`).
2. Grade each `grading.json`; fill that skill's aggregate row in `scorecard-paste.md`.
3. Paste rows from `scorecard-paste-all.md` (or per-skill paste files) into `docs/evals/SCORECARD.md`.
4. Emit **Recommended next actions** (fix `with_skill` FAILs first) — see `skill-optimizer` → `references/eval-loop.md` or `/run-skill-evals`.

Regenerate: `./scripts/run-skill-evals-soft.sh` or `./scripts/run-skill-evals-soft.sh --all`
"""
(parent / "tier2-batch-summary.md").write_text(batch_summary, encoding="utf-8")

paste_all = f"""# SCORECARD paste block — all first-party skills

Generated: {now}

Copy rows into [docs/evals/SCORECARD.md](../../docs/evals/SCORECARD.md)
under **Template for pasting run results** (replace `_TBD_` rows per skill).

| Skill | Eval id / Iteration | with_skill pass_rate | without_skill pass_rate | Δ pass_rate | Token Δ | Recommendation |
|-------|---------------------|----------------------|-------------------------|-------------|---------|----------------|
{chr(10).join(rows)}

## Aggregate per skill (fill after grading all cases)

| Skill | Iteration | with_skill pass_rate | without_skill pass_rate | Δ pass_rate | Token Δ | Recommendation |
|-------|-----------|----------------------|-------------------------|-------------|---------|----------------|
"""
for name in sorted(names):
    iter_label = latest_iteration(parent / name).name
    paste_all += f"| `{name}` | {iter_label} | _TBD_ | _TBD_ | _TBD_ | _TBD_ | keep / revise / replace |\n"

(parent / "scorecard-paste-all.md").write_text(paste_all, encoding="utf-8")
print(f"Wrote batch index → {parent}/tier2-batch-summary.md")
PY
}

package_all_skills() {
  local parent_out="$1"
  local name failed=0

  discover_first_party_skills || return 1
  mkdir -p "${parent_out}"

  for name in "${DISCOVERED_SKILLS[@]}"; do
    if ! package_skill "${name}" "${parent_out}/${name}"; then
      failed=1
    fi
  done

  if [[ "$failed" -ne 0 ]]; then
    return 1
  fi

  write_batch_artifacts "${parent_out}" "${DISCOVERED_SKILLS[@]}" || return 1
  echo "Packaged ${#DISCOVERED_SKILLS[@]} skills → ${parent_out}"
  echo "Next: grade each skill's eval-*/ dirs; paste scorecard-paste-all.md into docs/evals/SCORECARD.md; emit Recommended next actions (see skill-optimizer eval-loop.md)"
}

# Reads a graded iteration dir (must contain cases.json + graded grading.json
# files) and computes benchmark.json — script arithmetic instead of hand
# arithmetic in scorecard-paste.md. Fails closed (no benchmark.json written,
# non-zero exit) if any real case is still PENDING, or if a grader canary
# is present and did not grade FAIL.
aggregate_benchmark() {
  local dir="$1"
  if [[ ! -d "${dir}" ]]; then
    fail "aggregate: not a directory: ${dir}"
    return 1
  fi
  if [[ ! -f "${dir}/cases.json" ]]; then
    fail "aggregate: missing cases.json in ${dir} (not a Tier 2 iteration dir?)"
    return 1
  fi

  python3 - "$dir" <<'PY'
import json, statistics, sys
from datetime import datetime, timezone
from pathlib import Path

d = Path(sys.argv[1])
manifest = json.loads((d / "cases.json").read_text(encoding="utf-8"))
skill_name = manifest.get("skill_name")
cases = manifest.get("cases") or []
if not cases:
    sys.exit("aggregate: cases.json has no cases")

iter_n = d.name.replace("iteration-", "") if d.name.startswith("iteration-") else "?"
now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def load_grading(p: Path):
    return json.loads(p.read_text(encoding="utf-8")) if p.is_file() else None


def pass_rate(grading):
    """Returns a 0..1 float, "PENDING" if any assertion is ungraded, or None if no assertions."""
    assertions = grading.get("assertions") or []
    if not assertions:
        return None
    results = [a.get("result") for a in assertions]
    if any(r not in ("PASS", "FAIL") for r in results):
        return "PENDING"
    return sum(1 for r in results if r == "PASS") / len(results)


errors = []
case_rows = []
with_rates, without_rates = [], []

for c in cases:
    cid = c.get("id")
    w_path = d / f"eval-{cid}" / "with_skill" / "grading.json"
    wo_path = d / f"eval-{cid}" / "without_skill" / "grading.json"
    w, wo = load_grading(w_path), load_grading(wo_path)
    if w is None:
        errors.append(f"missing {w_path}")
        continue
    if wo is None:
        errors.append(f"missing {wo_path}")
        continue
    wr, wor = pass_rate(w), pass_rate(wo)
    if wr == "PENDING":
        errors.append(f"still PENDING: {w_path}")
    if wor == "PENDING":
        errors.append(f"still PENDING: {wo_path}")
    if wr == "PENDING" or wor == "PENDING":
        continue
    if wr is not None:
        with_rates.append(wr)
    if wor is not None:
        without_rates.append(wor)
    case_rows.append({"eval_id": cid, "with_skill_pass_rate": wr, "without_skill_pass_rate": wor})

canary_path = d / "eval-canary" / "grading.json"
canary_info = {"present": False, "result": "MISSING", "trustworthy": None}
if canary_path.is_file():
    canary = json.loads(canary_path.read_text(encoding="utf-8"))
    c_results = [a.get("result") for a in (canary.get("assertions") or [])]
    if not c_results or any(r not in ("PASS", "FAIL") for r in c_results):
        errors.append(f"grader canary not yet graded: {canary_path}")
        canary_info = {"present": True, "result": "PENDING", "trustworthy": False}
    else:
        canary_failed = all(r == "FAIL" for r in c_results)
        canary_info = {
            "present": True,
            "result": "FAIL" if canary_failed else "PASS",
            "trustworthy": canary_failed,
        }
        if not canary_failed:
            errors.append(
                f"grader canary graded PASS at {canary_path} — grading for this "
                "run is unreliable; fix the grader before aggregating"
            )
else:
    print(
        f"WARNING: no eval-canary found in {d} — cannot confirm grader reliability (older package?)",
        file=sys.stderr,
    )

if errors:
    for e in errors:
        print(f"ERROR: {e}", file=sys.stderr)
    sys.exit(1)


def stats(rates):
    if not rates:
        return {"mean": None, "stddev": None, "n_cases": 0}
    mean = statistics.mean(rates)
    stddev = statistics.pstdev(rates) if len(rates) > 1 else None
    return {
        "mean": round(mean, 4),
        "stddev": round(stddev, 4) if stddev is not None else None,
        "n_cases": len(rates),
    }


with_stats, without_stats = stats(with_rates), stats(without_rates)
delta = (
    round(with_stats["mean"] - without_stats["mean"], 4)
    if with_stats["mean"] is not None and without_stats["mean"] is not None
    else None
)

benchmark = {
    "skill_name": skill_name,
    "iteration": iter_n,
    "generated_at": now,
    "canary": canary_info,
    "cases": case_rows,
    "run_summary": {
        "with_skill": {"pass_rate": with_stats},
        "without_skill": {"pass_rate": without_stats},
        "delta": {"pass_rate": delta},
    },
    "note": (
        "stddev is computed across the test-case set within this iteration, "
        "not across repeated runs of the same case"
    ),
}
(d / "benchmark.json").write_text(json.dumps(benchmark, indent=2) + "\n", encoding="utf-8")
print(f"Wrote benchmark.json → {d / 'benchmark.json'}")
print(f"  with_skill pass_rate mean={with_stats['mean']} (n={with_stats['n_cases']})")
print(f"  without_skill pass_rate mean={without_stats['mean']} (n={without_stats['n_cases']})")
print(f"  delta={delta}")
print(f"  canary: {canary_info['result']} (trustworthy={canary_info['trustworthy']})")
PY
}

run_self_test() {
  local tmp
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/adsk-tier2-selftest.XXXXXX")"
  # shellcheck disable=SC2064
  trap "rm -rf '${tmp}'" EXIT

  echo "→ Self-test: package default skill (${DEFAULT_SKILL})"
  package_skill "${DEFAULT_SKILL}" "${tmp}/out"
  local iter1="${tmp}/out/iteration-1"
  [[ -d "${iter1}" ]] || fail "missing iteration-1 dir"
  [[ -f "${iter1}/tier2-summary.md" ]] || fail "missing tier2-summary.md"
  [[ -f "${iter1}/scorecard-paste.md" ]] || fail "missing scorecard-paste.md"
  [[ -f "${iter1}/cases.json" ]] || fail "missing cases.json"
  [[ -f "${iter1}/feedback.json" ]] || fail "missing feedback.json"
  grep -q "${DEFAULT_SKILL}" "${iter1}/tier2-summary.md" || fail "summary missing skill name"
  grep -q "SCORECARD" "${iter1}/scorecard-paste.md" || fail "paste missing SCORECARD marker"
  python3 -c "import json; m=json.load(open('${iter1}/cases.json')); assert m['case_count']>=1" \
    || fail "cases.json invalid"
  [[ -f "${iter1}/eval-canary/grading.json" ]] || fail "missing eval-canary/grading.json"
  python3 -c "
import json
g = json.load(open('${iter1}/eval-canary/grading.json'))
assert g.get('eval_id') == 'canary', g
assert g.get('arm') == 'grader_check', g
assert len(g.get('assertions', [])) == 1, g
assert g['assertions'][0].get('result') == 'PENDING', g
" || fail "eval-canary/grading.json invalid"
  grep -q "Canary case graded FAIL" "${iter1}/scorecard-paste.md" \
    || fail "scorecard-paste.md missing canary checklist item"
  python3 -c "
import json
cases = json.load(open('${iter1}/cases.json'))['cases']
fb = json.load(open('${iter1}/feedback.json'))
expected = {f\"eval-{c['id']}\" for c in cases}
assert set(fb.keys()) == expected, (set(fb.keys()), expected)
assert all(v == '' for v in fb.values()), fb
" || fail "feedback.json shape invalid"

  echo "→ Self-test: iteration bump on repeat package (never overwrite)"
  package_skill "${DEFAULT_SKILL}" "${tmp}/out"
  local iter2="${tmp}/out/iteration-2"
  [[ -d "${iter2}" ]] || fail "expected iteration-2 after second package"
  [[ -f "${iter1}/cases.json" ]] || fail "iteration-1 was deleted/overwritten by second package"
  [[ -f "${iter2}/cases.json" ]] || fail "missing iteration-2/cases.json"

  echo "→ Self-test: reject unknown skill"
  if package_skill "not-a-real-skill" "${tmp}/bad" 2>/dev/null; then
    fail "expected failure for unknown skill"
    exit 1
  fi

  echo "→ Self-test: package all first-party skills"
  package_all_skills "${tmp}/batch"
  [[ -f "${tmp}/batch/tier2-batch-summary.md" ]] || fail "missing tier2-batch-summary.md"
  [[ -f "${tmp}/batch/scorecard-paste-all.md" ]] || fail "missing scorecard-paste-all.md"
  discover_first_party_skills || exit 1
  [[ -f "${tmp}/batch/${DEFAULT_SKILL}/iteration-1/cases.json" ]] || fail "batch missing default skill package"
  local n_packaged=0 name
  for name in "${DISCOVERED_SKILLS[@]}"; do
    [[ -d "${tmp}/batch/${name}/iteration-1" ]] || fail "batch missing skill iteration dir: ${name}"
    n_packaged=$((n_packaged + 1))
  done
  [[ "$n_packaged" -eq "${#DISCOVERED_SKILLS[@]}" ]] || fail "batch skill count mismatch"

  echo "→ Self-test: aggregate — fails closed while assertions are PENDING"
  if aggregate_benchmark "${iter2}" 2>/dev/null; then
    fail "expected aggregate to fail while assertions are PENDING"
  fi
  if [[ -f "${iter2}/benchmark.json" ]]; then
    fail "benchmark.json should not exist after a failed aggregate"
  fi

  echo "→ Self-test: aggregate — happy path over hand-graded fixtures"
  python3 -c "
import json
from pathlib import Path
iter1 = Path('${iter1}')
cases = json.load(open(iter1 / 'cases.json'))['cases']
for c in cases:
    for arm, verdict in (('with_skill', 'PASS'), ('without_skill', 'FAIL')):
        p = iter1 / f\"eval-{c['id']}\" / arm / 'grading.json'
        g = json.load(open(p))
        for a in g['assertions']:
            a['result'] = verdict
            a['evidence'] = 'self-test fixture'
        json.dump(g, open(p, 'w'), indent=2)
canary_p = iter1 / 'eval-canary' / 'grading.json'
cg = json.load(open(canary_p))
for a in cg['assertions']:
    a['result'] = 'FAIL'
    a['evidence'] = 'self-test fixture'
json.dump(cg, open(canary_p, 'w'), indent=2)
"
  aggregate_benchmark "${iter1}" || fail "aggregate_benchmark failed on fully-graded fixtures"
  [[ -f "${iter1}/benchmark.json" ]] || fail "missing benchmark.json after successful aggregate"
  python3 -c "
import json
b = json.load(open('${iter1}/benchmark.json'))
assert b['run_summary']['with_skill']['pass_rate']['mean'] == 1.0, b
assert b['run_summary']['without_skill']['pass_rate']['mean'] == 0.0, b
assert b['run_summary']['delta']['pass_rate'] == 1.0, b
assert b['canary']['present'] is True and b['canary']['trustworthy'] is True, b
" || fail "benchmark.json values incorrect"

  echo "→ Self-test: aggregate — fails closed when grader canary graded PASS"
  local canary_tmp="${tmp}/canary-fixture"
  mkdir -p "${canary_tmp}/eval-1/with_skill" "${canary_tmp}/eval-1/without_skill" "${canary_tmp}/eval-canary"
  python3 -c "
import json
from pathlib import Path
base = Path('${canary_tmp}')
(base / 'cases.json').write_text(json.dumps({
    'skill_name': 'fixture', 'case_count': 1,
    'cases': [{'id': 1, 'assertions': ['a']}],
}))
for arm in ('with_skill', 'without_skill'):
    (base / 'eval-1' / arm / 'grading.json').write_text(json.dumps({
        'assertions': [{'text': 'a', 'result': 'PASS', 'evidence': 'x'}]
    }))
(base / 'eval-canary' / 'grading.json').write_text(json.dumps({
    'assertions': [{'text': 'canary', 'result': 'PASS', 'evidence': 'x'}]
}))
"
  if aggregate_benchmark "${canary_tmp}" 2>/dev/null; then
    fail "expected aggregate to fail when grader canary graded PASS"
  fi
  if [[ -f "${canary_tmp}/benchmark.json" ]]; then
    fail "benchmark.json should not exist when canary graded PASS"
  fi

  echo "→ Self-test: aggregate — succeeds once canary correctly graded FAIL"
  python3 -c "
import json
from pathlib import Path
p = Path('${canary_tmp}/eval-canary/grading.json')
g = json.loads(p.read_text())
g['assertions'][0]['result'] = 'FAIL'
p.write_text(json.dumps(g))
"
  aggregate_benchmark "${canary_tmp}" || fail "aggregate_benchmark failed with a correctly-failed canary"
  [[ -f "${canary_tmp}/benchmark.json" ]] || fail "missing benchmark.json after canary FAIL"
  python3 -c "
import json
b = json.load(open('${canary_tmp}/benchmark.json'))
assert b['canary']['present'] is True and b['canary']['trustworthy'] is True, b
" || fail "benchmark.json canary field incorrect"

  echo "→ Self-test passed"
}

if [[ "${SELF_TEST}" -eq 1 ]]; then
  run_self_test
  exit 0
fi

if [[ -n "${AGGREGATE_DIR}" ]]; then
  aggregate_benchmark "${AGGREGATE_DIR}" || exit 1
  exit 0
fi

if [[ -n "${SKILL_NAME}" ]]; then
  if [[ -z "${OUT_DIR}" ]]; then
    OUT_DIR="${REPO_ROOT}/.adsk-tier2-out/${SKILL_NAME}"
  fi
  package_skill "${SKILL_NAME}" "${OUT_DIR}" || exit 1
  echo "Next: grade eval-*/{with,without}_skill/grading.json + feedback.json, then run --aggregate on the printed iteration dir; paste scorecard-paste.md into docs/evals/SCORECARD.md; emit Recommended next actions"
  exit 0
fi

if [[ -z "${OUT_DIR}" ]]; then
  OUT_DIR="${REPO_ROOT}/.adsk-tier2-out"
fi

package_all_skills "${OUT_DIR}" || exit 1
