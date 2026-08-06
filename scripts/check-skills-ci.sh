#!/usr/bin/env bash
# check-skills-ci.sh — Tier 1 skill quality gates (local + CI).
#
# Checks first-party skills under skills/*/ :
#   - skills-ref validate
#   - SKILL.md frontmatter name == folder name
#   - SKILL.md line budget (<500 lines)
#   - references/*.md have no same-skill reference-to-reference links
#   - evals/evals.json presence + shape
#   - evals/trigger/eval_queries.json presence + shape (n≥20, ~50/50)
#
# Usage:
#   ./scripts/check-skills-ci.sh
#   ./scripts/check-skills-ci.sh --self-test
#   ./scripts/check-skills-ci.sh path/to/skill-dir   # check one skill dir

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILLS_ROOT="${REPO_ROOT}/skills"
FIXTURE_VALID="${SCRIPT_DIR}/fixtures/skill-ci/valid-skill"
MIN_TRIGGER_QUERIES=20
MIN_CLASS_RATIO=40  # percent; neither true nor false may be under this
MAX_SKILL_LINES=500  # skill-optimizer body-size gate

usage() {
  cat <<'EOF'
check-skills-ci.sh — Tier 1 skill eval / harness gates

Usage:
  ./scripts/check-skills-ci.sh              Check all skills/*/ with SKILL.md
  ./scripts/check-skills-ci.sh DIR          Check a single skill directory
  ./scripts/check-skills-ci.sh --self-test  Fixture + mutation checks
  ./scripts/check-skills-ci.sh -h|--help

Exit 0 on success; non-zero on any failure.
EOF
}

fail() {
  echo "ERROR: $*" >&2
  return 1
}

# Extract YAML frontmatter `name:` (first scalar name key).
frontmatter_name() {
  local skill_md="$1"
  python3 - "$skill_md" <<'PY'
import re, sys
path = sys.argv[1]
text = open(path, encoding="utf-8").read()
if not text.startswith("---"):
    sys.exit("missing YAML frontmatter")
parts = text.split("---", 2)
if len(parts) < 3:
    sys.exit("unterminated YAML frontmatter")
fm = parts[1]
m = re.search(r"(?m)^name:\s*(.+?)\s*$", fm)
if not m:
    sys.exit("frontmatter missing name")
print(m.group(1).strip().strip("'\""))
PY
}

validate_evals_json() {
  local path="$1"
  local expect_name="$2"
  python3 - "$path" "$expect_name" <<'PY'
import json, sys
path, expect = sys.argv[1], sys.argv[2]
try:
    data = json.load(open(path, encoding="utf-8"))
except Exception as e:
    sys.exit(f"invalid JSON: {e}")
name = data.get("skill_name")
if not isinstance(name, str) or not name.strip():
    sys.exit("skill_name must be a non-empty string")
if name != expect:
    sys.exit(f"skill_name {name!r} != folder name {expect!r}")
evals = data.get("evals")
if not isinstance(evals, list) or len(evals) < 1:
    sys.exit("evals must be a non-empty array")
for i, case in enumerate(evals):
    if not isinstance(case, dict):
        sys.exit(f"evals[{i}] must be an object")
    if "id" not in case:
        sys.exit(f"evals[{i}] missing id")
    prompt = case.get("prompt")
    if not isinstance(prompt, str) or not prompt.strip():
        sys.exit(f"evals[{i}] prompt must be non-empty string")
    expected = case.get("expected_output")
    if not isinstance(expected, str) or not expected.strip():
        sys.exit(f"evals[{i}] expected_output must be non-empty string")
    assertions = case.get("assertions")
    if not isinstance(assertions, list) or len(assertions) < 1:
        sys.exit(f"evals[{i}] assertions must be a non-empty array")
    for j, a in enumerate(assertions):
        if not isinstance(a, str) or not a.strip():
            sys.exit(f"evals[{i}].assertions[{j}] must be a non-empty string")
print("ok")
PY
}

validate_trigger_json() {
  local path="$1"
  local min_n="$2"
  local min_ratio="$3"
  python3 - "$path" "$min_n" "$min_ratio" <<'PY'
import json, sys
path, min_n, min_ratio = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
try:
    data = json.load(open(path, encoding="utf-8"))
except Exception as e:
    sys.exit(f"invalid JSON: {e}")
if not isinstance(data, list):
    sys.exit("trigger file must be a JSON array")
if len(data) < min_n:
    sys.exit(f"need ≥{min_n} queries, got {len(data)}")
true_n = false_n = 0
for i, row in enumerate(data):
    if not isinstance(row, dict):
        sys.exit(f"entry[{i}] must be an object")
    q = row.get("query")
    if not isinstance(q, str) or not q.strip():
        sys.exit(f"entry[{i}].query must be a non-empty string")
    st = row.get("should_trigger")
    if not isinstance(st, bool):
        sys.exit(f"entry[{i}].should_trigger must be a boolean")
    if st:
        true_n += 1
    else:
        false_n += 1
if true_n == 0 or false_n == 0:
    sys.exit("need both should_trigger true and false entries")
n = len(data)
true_pct = 100.0 * true_n / n
false_pct = 100.0 * false_n / n
if true_pct < min_ratio or false_pct < min_ratio:
    sys.exit(
        f"class imbalance: true={true_pct:.1f}% false={false_pct:.1f}% "
        f"(each must be ≥{min_ratio}%)"
    )
print("ok")
PY
}

# SKILL.md line/token budget — mirrors skill-optimizer's "Body size" gate
# (<500 lines / ~5k tokens).
validate_line_budget() {
  local skill_md="$1"
  local max_lines="$2"
  local n
  n="$(wc -l < "$skill_md" | tr -d ' ')"
  if (( n > max_lines )); then
    echo "SKILL.md is ${n} lines (max ${max_lines})"
    return 1
  fi
  echo "ok (${n} lines)"
}

# Same-skill reference-to-reference link detector — flags the anti-pattern
# Anthropic's Agent Skills best-practices doc warns against: a references/*.md
# file linking directly to a sibling references/*.md file instead of routing
# back through SKILL.md's progressive-disclosure table.
validate_reference_depth() {
  local skill_dir="$1"
  local refs_dir="${skill_dir}/references"
  if [[ ! -d "$refs_dir" ]]; then
    echo "ok (no references/)"
    return 0
  fi
  python3 - "$refs_dir" <<'PY'
import os
import re
import sys

refs_dir = sys.argv[1]
sibling_names = {f for f in os.listdir(refs_dir) if f.endswith(".md")}
# Matches "file.md", "file.md#anchor", and "./file.md" alike — strip any
# trailing "#..." fragment before checking the .md basename.
link_re = re.compile(r"\]\(([^)]+?\.md(?:#[^)]*)?)\)")
violations = []
for fname in sorted(sibling_names):
    text = open(os.path.join(refs_dir, fname), encoding="utf-8").read()
    for m in link_re.finditer(text):
        target = m.group(1).split("#", 1)[0]
        base = os.path.basename(target)
        if base in sibling_names and base != fname:
            violations.append(f"{fname} -> {m.group(1)}")
if violations:
    sys.exit("reference-to-reference link(s) found: " + "; ".join(violations))
print("ok")
PY
}

check_skill_dir() {
  local skill_dir="$1"
  local name
  name="$(basename "$skill_dir")"
  local skill_md="${skill_dir}/SKILL.md"
  local err

  if [[ ! -f "$skill_md" ]]; then
    fail "${name}: missing SKILL.md"
    return 1
  fi

  echo "==> ${name}: skills-ref validate"
  if ! npx --yes skills-ref validate "$skill_dir"; then
    fail "${name}: skills-ref validate failed"
    return 1
  fi

  local fm_name
  if ! fm_name="$(frontmatter_name "$skill_md" 2>&1)"; then
    fail "${name}: frontmatter — ${fm_name}"
    return 1
  fi
  if [[ "$fm_name" != "$name" ]]; then
    fail "${name}: frontmatter name '${fm_name}' != folder name '${name}'"
    return 1
  fi

  echo "==> ${name}: line budget"
  if ! err="$(validate_line_budget "$skill_md" "$MAX_SKILL_LINES" 2>&1)"; then
    fail "${name}: line budget — ${err}"
    return 1
  fi

  echo "==> ${name}: reference depth"
  if ! err="$(validate_reference_depth "$skill_dir" 2>&1)"; then
    fail "${name}: reference depth — ${err}"
    return 1
  fi

  local evals_json="${skill_dir}/evals/evals.json"
  local trigger_json="${skill_dir}/evals/trigger/eval_queries.json"
  if [[ ! -f "$evals_json" ]]; then
    fail "${name}: missing evals/evals.json"
    return 1
  fi
  if [[ ! -f "$trigger_json" ]]; then
    fail "${name}: missing evals/trigger/eval_queries.json"
    return 1
  fi

  echo "==> ${name}: evals.json shape"
  if ! err="$(validate_evals_json "$evals_json" "$name" 2>&1)"; then
    fail "${name}: evals.json — ${err}"
    return 1
  fi

  echo "==> ${name}: trigger eval_queries.json shape"
  if ! err="$(validate_trigger_json "$trigger_json" "$MIN_TRIGGER_QUERIES" "$MIN_CLASS_RATIO" 2>&1)"; then
    fail "${name}: trigger queries — ${err}"
    return 1
  fi

  echo "OK ${name}"
}

check_all_skills() {
  local found=0
  local failed=0
  local dir
  shopt -s nullglob
  for dir in "${SKILLS_ROOT}"/*/ ; do
    [[ -f "${dir}SKILL.md" ]] || continue
    found=1
    if ! check_skill_dir "${dir%/}"; then
      failed=1
    fi
  done
  shopt -u nullglob
  if [[ "$found" -eq 0 ]]; then
    fail "no skills/*/SKILL.md found under ${SKILLS_ROOT}"
    return 1
  fi
  return "$failed"
}

expect_fail() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    fail "self-test: expected failure for ${label}, but check passed"
    return 1
  fi
  echo "OK self-test: ${label} fails as expected"
}

run_self_test() {
  if [[ ! -d "$FIXTURE_VALID" ]]; then
    fail "missing fixture: ${FIXTURE_VALID}"
    return 1
  fi

  echo "==> self-test: valid fixture passes"
  check_skill_dir "$FIXTURE_VALID"

  local tmp
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/skill-ci-selftest.XXXXXX")"
  # shellcheck disable=SC2064
  trap "rm -rf '$tmp'" RETURN

  # Mutation: missing evals.json
  rm -rf "${tmp}/missing-evals"
  cp -R "$FIXTURE_VALID" "${tmp}/missing-evals"
  rm -f "${tmp}/missing-evals/evals/evals.json"
  expect_fail "missing evals.json" check_skill_dir "${tmp}/missing-evals"

  # Mutation: empty assertions
  rm -rf "${tmp}/empty-assertions"
  cp -R "$FIXTURE_VALID" "${tmp}/empty-assertions"
  python3 - "${tmp}/empty-assertions/evals/evals.json" <<'PY'
import json, sys
p = sys.argv[1]
data = json.load(open(p, encoding="utf-8"))
data["evals"][0]["assertions"] = []
json.dump(data, open(p, "w", encoding="utf-8"), indent=2)
PY
  expect_fail "empty assertions" check_skill_dir "${tmp}/empty-assertions"

  # Mutation: trigger class imbalance (all true)
  rm -rf "${tmp}/bad-balance"
  cp -R "$FIXTURE_VALID" "${tmp}/bad-balance"
  python3 - "${tmp}/bad-balance/evals/trigger/eval_queries.json" <<'PY'
import json, sys
p = sys.argv[1]
data = json.load(open(p, encoding="utf-8"))
for row in data:
    row["should_trigger"] = True
json.dump(data, open(p, "w", encoding="utf-8"), indent=2)
PY
  expect_fail "trigger imbalance" check_skill_dir "${tmp}/bad-balance"

  # Mutation: frontmatter name mismatch
  rm -rf "${tmp}/wrong-name"
  cp -R "$FIXTURE_VALID" "${tmp}/wrong-name"
  python3 - "${tmp}/wrong-name/SKILL.md" <<'PY'
import re, sys
p = sys.argv[1]
text = open(p, encoding="utf-8").read()
text = re.sub(r"(?m)^name:\s*.+$", "name: other-name", text, count=1)
open(p, "w", encoding="utf-8").write(text)
PY
  expect_fail "frontmatter name mismatch" check_skill_dir "${tmp}/wrong-name"

  # Mutation: SKILL.md exceeds line budget
  rm -rf "${tmp}/oversized-skill"
  cp -R "$FIXTURE_VALID" "${tmp}/oversized-skill"
  python3 - "${tmp}/oversized-skill/SKILL.md" "$MAX_SKILL_LINES" <<'PY'
import sys
p, max_lines = sys.argv[1], int(sys.argv[2])
with open(p, "a", encoding="utf-8") as f:
    f.write("\n" + "\n".join(f"padding line {i}" for i in range(max_lines + 10)))
PY
  expect_fail "oversized SKILL.md" check_skill_dir "${tmp}/oversized-skill"

  # Mutation: reference-to-reference link (same-skill anti-pattern)
  rm -rf "${tmp}/nested-refs"
  cp -R "$FIXTURE_VALID" "${tmp}/nested-refs"
  mkdir -p "${tmp}/nested-refs/references"
  printf '# One\n\nSee [Two](two.md) for more.\n' > "${tmp}/nested-refs/references/one.md"
  printf '# Two\n\nFixture only.\n' > "${tmp}/nested-refs/references/two.md"
  expect_fail "reference-to-reference link" check_skill_dir "${tmp}/nested-refs"

  # Mutation: reference-to-reference link with an anchor fragment
  rm -rf "${tmp}/nested-refs-anchor"
  cp -R "$FIXTURE_VALID" "${tmp}/nested-refs-anchor"
  mkdir -p "${tmp}/nested-refs-anchor/references"
  printf '# One\n\nSee [Two](two.md#section) for more.\n' > "${tmp}/nested-refs-anchor/references/one.md"
  printf '# Two\n\n## Section\n\nFixture only.\n' > "${tmp}/nested-refs-anchor/references/two.md"
  expect_fail "reference-to-reference link with anchor" check_skill_dir "${tmp}/nested-refs-anchor"

  # Mutation: skills-ref validate failure (missing description)
  rm -rf "${tmp}/no-description"
  cp -R "$FIXTURE_VALID" "${tmp}/no-description"
  python3 - "${tmp}/no-description/SKILL.md" <<'PY'
import re, sys
p = sys.argv[1]
text = open(p, encoding="utf-8").read()
text = re.sub(r"(?m)^description:\s*.+(?:\n(?:\s+.+)*)?", "", text, count=1)
open(p, "w", encoding="utf-8").write(text)
PY
  expect_fail "skills-ref validate (no description)" check_skill_dir "${tmp}/no-description"

  echo "OK self-test: all cases"
}

main() {
  case "${1:-}" in
    -h|--help)
      usage
      exit 0
      ;;
    --self-test)
      run_self_test
      ;;
    "")
      check_all_skills
      ;;
    *)
      if [[ ! -d "$1" ]]; then
        fail "not a directory: $1"
        exit 1
      fi
      check_skill_dir "$(cd "$1" && pwd)"
      ;;
  esac
}

main "$@"
