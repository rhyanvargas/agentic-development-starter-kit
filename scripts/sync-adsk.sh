#!/usr/bin/env bash
# sync-adsk.sh — Sync ADSK Cursor wiring and discovery links.
#
# Modes:
#   kit      Maintain .agents/skills + .cursor/skills symlinks in this repo
#   adopter  Sync Cursor commands/rules into an app; refresh skills via CLI
#
# Examples:
#   ./scripts/sync-adsk.sh kit
#   ./scripts/sync-adsk.sh adopter --from /path/to/agentic-development-starter-kit
#   ./scripts/sync-adsk.sh adopter --from https://github.com/rhyanvargas/agentic-development-starter-kit.git
#   ./scripts/sync-adsk.sh adopter --from /path/to/kit --dry-run
#   ./scripts/sync-adsk.sh adopter --from /path/to/kit --skip-skills
#   ./scripts/sync-adsk.sh adopter --from /path/to/kit --skills-from-path
#   ./scripts/sync-adsk.sh self-check

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT_DEFAULT="$(cd "${SCRIPT_DIR}/.." && pwd)"

MODE=""
FROM=""
REF="main"
TARGET="."
DRY_RUN=0
SKIP_SKILLS=0
SKILLS_FROM_PATH=0
FORCE_RULES=0
COMMANDS_ONLY=0
RULES_MODE="stock" # stock | all | none
REPO_SLUG="rhyanvargas/agentic-development-starter-kit"

# Stock rules safe for adopter apps (add-if-missing by default).
STOCK_RULES=(skill-authoring testing project-cmds)

usage() {
  cat <<'EOF'
sync-adsk.sh — Sync ADSK Cursor wiring and discovery links.

Modes:
  kit         Maintain .agents/skills + .cursor/skills symlinks in this repo
  adopter     Sync Cursor commands/rules into an app; refresh skills via CLI
  self-check  Smoke test kit + adopter translation

Examples:
  ./scripts/sync-adsk.sh kit
  ./scripts/sync-adsk.sh adopter --from /path/to/agentic-development-starter-kit
  ./scripts/sync-adsk.sh adopter --from https://github.com/rhyanvargas/agentic-development-starter-kit.git
  ./scripts/sync-adsk.sh adopter --from /path/to/kit --dry-run
  ./scripts/sync-adsk.sh self-check

Flags (adopter):
  --from PATH|URL   Kit source (required)
  --ref REF         Git ref when --from is a URL (default: main)
  --target DIR      App root to sync into (default: .)
  --dry-run         Print actions only
  --skip-skills     Do not run npx skills add/update
  --skills-from-path
                    Copy skills/ → .agents/skills/ from --from (offline)
  --force-rules     Overwrite existing rule directories
  --commands-only   Sync commands only (no rules, no skills)
  --rules MODE      stock (default) | all | none
EOF
}

log() { printf '%s\n' "$*"; }
info() { printf '→ %s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf 'dry-run: %s\n' "$*"
    return 0
  fi
  "$@"
}

is_url() {
  [[ "$1" =~ ^https?:// ]] || [[ "$1" =~ ^git@ ]]
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

resolve_kit_source() {
  local src="$1"
  if is_url "$src"; then
    require_cmd git
    local tmp
    tmp="$(mktemp -d "${TMPDIR:-/tmp}/adsk-sync.XXXXXX")"
    CLEANUP_DIRS+=("$tmp")
    info "Cloning ${src} (${REF}) → ${tmp}"
    if [[ "$DRY_RUN" -eq 1 ]]; then
      # Still need a real tree for review/dry-run of local paths when URL given —
      # clone shallow for accurate listing.
      git clone --depth 1 --branch "$REF" "$src" "$tmp/kit" >/dev/null 2>&1 \
        || git clone --depth 1 "$src" "$tmp/kit" >/dev/null 2>&1 \
        || die "failed to clone ${src}"
      printf '%s\n' "$tmp/kit"
      return 0
    fi
    git clone --depth 1 --branch "$REF" "$src" "$tmp/kit" >/dev/null 2>&1 \
      || git clone --depth 1 "$src" "$tmp/kit" >/dev/null 2>&1 \
      || die "failed to clone ${src}"
    printf '%s\n' "$tmp/kit"
    return 0
  fi

  [[ -d "$src" ]] || die "kit source not found: ${src}"
  # Resolve to absolute path
  (cd "$src" && pwd)
}

CLEANUP_DIRS=()
cleanup() {
  local d
  for d in "${CLEANUP_DIRS[@]:-}"; do
    [[ -n "$d" && -d "$d" ]] && rm -rf "$d"
  done
}
trap cleanup EXIT

list_skill_names() {
  local root="$1"
  local d
  [[ -d "${root}/skills" ]] || return 0
  for d in "${root}/skills"/*; do
    [[ -d "$d" && -f "${d}/SKILL.md" ]] || continue
    basename "$d"
  done | sort
}

review_cursor_artifacts() {
  local root="$1"
  info "Reviewing Cursor artifacts in ${root}"
  if [[ -d "${root}/.cursor/commands" ]]; then
    log "  commands:"
    find "${root}/.cursor/commands" -maxdepth 1 -type f -name '*.md' -print | sort | sed 's|^|    |'
  else
    warn "no .cursor/commands in kit source"
  fi
  if [[ -d "${root}/.cursor/rules" ]]; then
    log "  rules:"
    find "${root}/.cursor/rules" -mindepth 1 -maxdepth 1 -type d -print | sort | sed 's|^|    |'
  else
    warn "no .cursor/rules in kit source"
  fi
  log "  first-party skills:"
  local names
  names="$(list_skill_names "$root")"
  if [[ -z "$names" ]]; then
    warn "    (none found under skills/)"
  else
    printf '%s\n' "$names" | sed 's|^|    |'
  fi
}

translate_command_body() {
  # stdin → stdout: rewrite kit skill paths for adopter layout.
  # Avoid matching the "skills/<name>" substring inside ".agents/skills/<name>".
  local skill_names_file="$1"
  local sed_script=""
  local name
  while IFS= read -r name; do
    [[ -z "$name" ]] && continue
    # Use # delimiters so | can mean alternation (BSD/GNU sed -E).
    # Skip when already under .agents/ (char before "skills" is /).
    sed_script+="s#(^|[^/])skills/${name}#\\1.agents/skills/${name}#g;"
  done < "$skill_names_file"
  sed_script+='s# \(or \.agents/skills/skill-optimizer in adopter apps\)##g'
  sed -E "$sed_script"
}

sync_commands() {
  local kit="$1"
  local dest="$2"
  local src_cmds="${kit}/.cursor/commands"
  local dest_cmds="${dest}/.cursor/commands"
  [[ -d "$src_cmds" ]] || die "missing ${src_cmds}"

  local names_file
  names_file="$(mktemp)"
  list_skill_names "$kit" >"$names_file"

  run mkdir -p "$dest_cmds"

  local f base out tmp_out
  for f in "${src_cmds}"/*.md; do
    [[ -f "$f" ]] || continue
    base="$(basename "$f")"
    out="${dest_cmds}/${base}"
    tmp_out="$(mktemp)"
    translate_command_body "$names_file" <"$f" >"$tmp_out"
    if [[ "$DRY_RUN" -eq 1 ]]; then
      if [[ -f "$out" ]]; then
        info "Would update command ${base} (translated paths → .agents/skills/)"
      else
        info "Would add command ${base} (translated paths → .agents/skills/)"
      fi
      # Show a quick diff hint if destination exists
      if [[ -f "$out" ]] && ! cmp -s "$tmp_out" "$out"; then
        log "    (content differs from existing)"
      fi
      rm -f "$tmp_out"
    else
      mv "$tmp_out" "$out"
      info "Synced command ${base}"
    fi
  done
  rm -f "$names_file"
}

rule_is_stock() {
  local name="$1"
  local r
  for r in "${STOCK_RULES[@]}"; do
    [[ "$r" == "$name" ]] && return 0
  done
  return 1
}

sync_rules() {
  local kit="$1"
  local dest="$2"
  local src_rules="${kit}/.cursor/rules"
  local dest_rules="${dest}/.cursor/rules"

  [[ "$RULES_MODE" == "none" ]] && { info "Skipping rules (--rules=none)"; return 0; }
  [[ -d "$src_rules" ]] || { warn "missing ${src_rules}"; return 0; }

  run mkdir -p "$dest_rules"

  local d name dest_dir
  for d in "${src_rules}"/*; do
    [[ -d "$d" ]] || continue
    name="$(basename "$d")"
    if [[ "$RULES_MODE" == "stock" ]] && ! rule_is_stock "$name"; then
      info "Skipping kit-only rule ${name} (use --rules=all to include)"
      continue
    fi
    dest_dir="${dest_rules}/${name}"
    if [[ -e "$dest_dir" && "$FORCE_RULES" -eq 0 ]]; then
      info "Keeping existing rule ${name} (pass --force-rules to overwrite)"
      continue
    fi
    if [[ "$DRY_RUN" -eq 1 ]]; then
      info "Would sync rule ${name}"
    else
      rm -rf "$dest_dir"
      mkdir -p "$dest_dir"
      # Copy rule tree (RULE.md and any siblings)
      cp -R "${d}/." "${dest_dir}/"
      info "Synced rule ${name}"
    fi
  done

  # Ensure empty Cursor artifact homes exist (never copy kit specs/plans content)
  run mkdir -p "${dest}/.cursor/docs/specs" "${dest}/.cursor/plans"
}

ensure_skills_cli() {
  local dest="$1"
  local kit="$2"

  if [[ "$SKILLS_FROM_PATH" -eq 1 ]]; then
    info "Copying skills from kit path → .agents/skills/"
    run mkdir -p "${dest}/.agents/skills"
    local name
    while IFS= read -r name; do
      [[ -z "$name" ]] && continue
      if [[ "$DRY_RUN" -eq 1 ]]; then
        info "Would copy skills/${name} → .agents/skills/${name}"
      else
        rm -rf "${dest}/.agents/skills/${name}"
        cp -R "${kit}/skills/${name}" "${dest}/.agents/skills/${name}"
        info "Copied skill ${name}"
      fi
    done < <(list_skill_names "$kit")
    return 0
  fi

  require_cmd npx
  (
    cd "$dest"
    if [[ -d .agents/skills ]] && compgen -G '.agents/skills/*/SKILL.md' >/dev/null 2>&1; then
      info "Refreshing skills via: npx skills update"
      if [[ "$DRY_RUN" -eq 1 ]]; then
        info "Would run: npx skills update (choose Project scope for this app)"
      else
        # Non-interactive where supported; fall back to interactive.
        if npx --yes skills update --help 2>/dev/null | grep -q -- '--scope'; then
          npx --yes skills update --scope project || npx --yes skills update
        else
          warn "skills CLI may prompt for Update scope — choose Project for this app"
          npx --yes skills update
        fi
      fi
    else
      info "Installing skills via: npx skills add ${REPO_SLUG}"
      if [[ "$DRY_RUN" -eq 1 ]]; then
        info "Would run: npx skills add ${REPO_SLUG}"
      else
        npx --yes skills add "$REPO_SLUG"
      fi
    fi
  )
}

mode_kit() {
  local root="${1:-$KIT_ROOT_DEFAULT}"
  [[ -d "${root}/skills" ]] || die "not a kit root (missing skills/): ${root}"

  info "Kit mode — syncing discovery symlinks in ${root}"
  review_cursor_artifacts "$root"

  run mkdir -p "${root}/.agents/skills" "${root}/.cursor/skills"

  local name
  while IFS= read -r name; do
    [[ -z "$name" ]] && continue
    if [[ "$DRY_RUN" -eq 1 ]]; then
      info "Would link .agents/skills/${name} → ../../skills/${name}"
      info "Would link .cursor/skills/${name} → ../../skills/${name}"
    else
      ln -sfn "../../skills/${name}" "${root}/.agents/skills/${name}"
      ln -sfn "../../skills/${name}" "${root}/.cursor/skills/${name}"
      info "Linked ${name}"
    fi
  done < <(list_skill_names "$root")

  # Report stale discovery links and non-symlink vendored trees
  local link
  for link in "${root}/.agents/skills"/* "${root}/.cursor/skills"/*; do
    [[ -e "$link" || -L "$link" ]] || continue
    if [[ -L "$link" && ! -e "$link" ]]; then
      warn "stale symlink: ${link}"
      if [[ "$DRY_RUN" -eq 0 ]]; then
        rm -f "$link"
        info "Removed stale symlink $(basename "$link")"
      fi
    elif [[ ! -L "$link" ]]; then
      warn "non-symlink discovery entry (do not commit; install upstream in adopter apps only): ${link}"
    fi
  done

  if [[ -f "${root}/skills-lock.json" ]]; then
    warn "skills-lock.json present — kit repo should not vendor CLI lockfiles (gitignore + delete)"
  fi

  info "Kit sync complete"
}

mode_adopter() {
  [[ -n "$FROM" ]] || die "adopter mode requires --from PATH|URL"
  local kit
  kit="$(resolve_kit_source "$FROM")"
  local dest
  dest="$(cd "$TARGET" && pwd)"

  [[ -d "${kit}/.cursor/commands" || -d "${kit}/skills" ]] \
    || die "source does not look like ADSK: ${kit}"

  info "Adopter mode — sync into ${dest}"
  review_cursor_artifacts "$kit"

  sync_commands "$kit" "$dest"

  if [[ "$COMMANDS_ONLY" -eq 0 ]]; then
    sync_rules "$kit" "$dest"
    if [[ "$SKIP_SKILLS" -eq 0 ]]; then
      ensure_skills_cli "$dest" "$kit"
    else
      info "Skipping skills (--skip-skills)"
    fi
  else
    info "Skipping rules and skills (--commands-only)"
  fi

  report_adopter_overlaps "$dest" "$kit"

  info "Adopter sync complete"
  log ""
  log "Next: open the project in Cursor and try /quick-start"
  log "Specs/plans were not modified. Custom rules were preserved unless --force-rules."
}

# REQ-009: surface known skill/command/rule overlaps (advisory; never deletes).
report_adopter_overlaps() {
  local dest="$1"
  local kit="$2"
  local snap="$kit"
  if [[ ! -f "${snap}/recommended-skills.json" || ! -f "${snap}/profiles.json" ]]; then
    snap="${kit}/packages/create-adsk/kit-snapshot"
  fi
  if [[ ! -f "${snap}/recommended-skills.json" ]]; then
    warn "overlap scan skipped (no recommended-skills.json in kit source)"
    return 0
  fi

  local cli="${kit}/packages/create-adsk/dist/cli.js"
  if [[ -f "$cli" ]]; then
    info "Scanning for overlapping skills/commands/rules…"
    if ! node "$cli" overlaps --target "$dest" --snapshot-root "$snap" \
      --commands post-sync --rules post-sync --scope project; then
      warn "overlap scan failed (create-adsk overlaps)"
    fi
    return 0
  fi

  # Fallback when create-adsk is not built: skill_names only via python3
  if command -v python3 >/dev/null 2>&1; then
    info "Scanning for known overlapping skills (python fallback)…"
    python3 - "$dest" "$snap" <<'PY' || warn "overlap scan fallback failed"
import json, os, sys
dest, snap = sys.argv[1], sys.argv[2]
skills_root = os.path.join(dest, ".agents", "skills")
rec_path = os.path.join(snap, "recommended-skills.json")
with open(rec_path, encoding="utf-8") as f:
    rec = json.load(f)
index = {}
for entry in rec.get("do_not_add") or []:
    for name in entry.get("skill_names") or []:
        index[name] = entry
    for ex in entry.get("examples") or []:
        if "@" in ex and not ex.startswith("other "):
            index[ex.rsplit("@", 1)[-1]] = entry
        elif "/" in ex and " " not in ex:
            index[ex.rsplit("/", 1)[-1]] = entry
installed = []
if os.path.isdir(skills_root):
    for name in sorted(os.listdir(skills_root)):
        if os.path.isfile(os.path.join(skills_root, name, "SKILL.md")):
            installed.append(name)
findings = []
extras = []
# first-party from profiles
fp = set()
try:
    with open(os.path.join(snap, "profiles.json"), encoding="utf-8") as f:
        profiles = json.load(f)
    for p in (profiles.get("profiles") or {}).values():
        fp.update(p.get("skills") or [])
except OSError:
    pass
for name in installed:
    if name in index:
        findings.append((name, index[name]))
    elif name not in fp:
        extras.append(name)
if not findings and not extras:
    print("Overlaps: none")
    sys.exit(0)
if findings:
    print(f"⚠ Overlaps detected ({len(findings)})\n")
    for name, entry in findings:
        adsk = entry.get("adsk_skill", "?")
        why = (entry.get("reason") or "")[:220]
        print(f"Skill  {name}")
        print(f"  Collides: {adsk} (ADSK)")
        print(f"  Kind:     known-overlap ({entry.get('id', '')})")
        print(f"  Rec:      Remove {name}; keep {adsk}")
        print(f"  Why:      {why}")
        print()
    print("No files were removed. Confirm before deleting conflicting skills.")
else:
    print("Overlaps: none")
if extras:
    print("\nExtras not in ADSK profile (no known overlap):")
    for e in extras:
        print(f"  - {e}")
PY
  else
    warn "overlap scan skipped (create-adsk dist missing and no python3)"
  fi
}

mode_self_check() {
  local kit="$KIT_ROOT_DEFAULT"
  local tmp
  # Prefer a workspace-local temp so sandboxed CI can write.
  tmp="$(mktemp -d "${kit}/.adsk-self-check.XXXXXX")"
  CLEANUP_DIRS+=("$tmp")

  info "Self-check: kit dry-run"
  DRY_RUN=1
  mode_kit "$kit"

  info "Self-check: adopter sync into temp dir (commands only)"
  mkdir -p "$tmp/app"
  FROM="$kit"
  TARGET="$tmp/app"
  SKIP_SKILLS=1
  DRY_RUN=0
  COMMANDS_ONLY=1
  mode_adopter

  local sample="${tmp}/app/.cursor/commands/draft-spec.md"
  [[ -f "$sample" ]] || die "self-check failed: draft-spec.md not written"
  # Fail only on bare skills/<name> (not the .agents/skills/<name> form).
  if grep -E '(^|[^/])skills/spec-driven-workflow' "$sample" >/dev/null; then
    die "self-check failed: untranslated skills/ path remains in draft-spec.md"
  fi
  grep -q '\.agents/skills/spec-driven-workflow' "$sample" \
    || die "self-check failed: expected .agents/skills/ path in draft-spec.md"

  local opt="${tmp}/app/.cursor/commands/optimize-skill.md"
  if grep -q 'or \.agents/skills/skill-optimizer in adopter apps' "$opt"; then
    die "self-check failed: redundant adopter parenthetical not stripped"
  fi

  # kit mode should be idempotent
  DRY_RUN=0
  mode_kit "$kit"

  info "Self-check passed"
}

# --- parse args ---
[[ $# -ge 1 ]] || { usage; exit 1; }
MODE="$1"
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --from) FROM="${2:-}"; shift 2 ;;
    --ref) REF="${2:-}"; shift 2 ;;
    --target) TARGET="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --skip-skills) SKIP_SKILLS=1; shift ;;
    --skills-from-path) SKILLS_FROM_PATH=1; shift ;;
    --force-rules) FORCE_RULES=1; shift ;;
    --commands-only) COMMANDS_ONLY=1; shift ;;
    --rules)
      RULES_MODE="${2:-}"
      [[ "$RULES_MODE" =~ ^(stock|all|none)$ ]] || die "--rules must be stock|all|none"
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
done

case "$MODE" in
  kit) mode_kit "$KIT_ROOT_DEFAULT" ;;
  adopter) mode_adopter ;;
  self-check) mode_self_check ;;
  -h|--help) usage; exit 0 ;;
  *) die "unknown mode: ${MODE} (expected kit|adopter|self-check)" ;;
esac
