import {
  existsSync,
  readdirSync,
  readFileSync,
  statSync,
} from "node:fs";
import { homedir } from "node:os";
import { basename, join } from "node:path";
import {
  commandBasenames,
  listSkillNamesFromSnapshot,
  STOCK_RULES,
} from "./cursor-sync.js";
import { rewriteCommandBody } from "./path-rewrite.js";
import { loadRecommendedSkills } from "./profiles.js";
import type {
  DoNotAddEntry,
  OverlapRecommendation,
  Scope,
} from "./types.js";

export type OverlapKind =
  | "name-collision"
  | "known-overlap"
  | "command-collision"
  | "rule-collision";

export interface OverlapFinding {
  kind: OverlapKind;
  /** Installed artifact id (skill folder, command basename, rule dir). */
  existing: string;
  /** Provenance hint when known (skills-lock source, path). */
  source?: string;
  /** ADSK counterpart (skill, command, or rule name). */
  adsk: string;
  catalogId?: string;
  recommendation: OverlapRecommendation;
  why: string;
}

export interface OverlapScanResult {
  findings: OverlapFinding[];
  /** Installed skills that are neither first-party nor do_not_add. */
  extras: string[];
}

export interface ScanOverlapsOptions {
  appRoot: string;
  snapshotRoot: string;
  scope?: Scope;
  /** Override skills root (tests). */
  skillsRoot?: string;
  /**
   * pre-sync: any existing stock command basename is a collision (about to overwrite).
   * post-sync: only when body differs from stock rewrite (customized).
   * off: skip commands.
   */
  commands?: "pre-sync" | "post-sync" | "off";
  /**
   * post-sync: stock rule dir exists and differs from snapshot (or exists without matching snapshot).
   * off: skip rules.
   */
  rules?: "post-sync" | "off";
}

function skillsRootFor(opts: ScanOverlapsOptions): string {
  if (opts.skillsRoot) return opts.skillsRoot;
  if (opts.scope === "global") {
    return join(homedir(), ".agents", "skills");
  }
  return join(opts.appRoot, ".agents", "skills");
}

export function listInstalledSkillNames(skillsRoot: string): string[] {
  if (!existsSync(skillsRoot)) return [];
  return readdirSync(skillsRoot).filter((name) => {
    if (name.startsWith(".")) return false;
    const skillMd = join(skillsRoot, name, "SKILL.md");
    return existsSync(skillMd);
  });
}

/** Parse `org/repo@skill` or bare skill-ish tokens from do_not_add.examples. */
export function skillSlugFromExample(example: string): string | undefined {
  const trimmed = example.trim();
  if (!trimmed || /\s/.test(trimmed) || trimmed.startsWith("other ")) {
    return undefined;
  }
  const at = trimmed.lastIndexOf("@");
  if (at >= 0) {
    const slug = trimmed.slice(at + 1).trim();
    return slug || undefined;
  }
  const slash = trimmed.lastIndexOf("/");
  if (slash >= 0) {
    const slug = trimmed.slice(slash + 1).trim();
    return slug || undefined;
  }
  return trimmed;
}

export function buildDoNotAddIndex(
  entries: DoNotAddEntry[],
): Map<string, DoNotAddEntry> {
  const map = new Map<string, DoNotAddEntry>();
  for (const entry of entries) {
    for (const name of entry.skill_names ?? []) {
      map.set(name, entry);
    }
    for (const ex of entry.examples ?? []) {
      const slug = skillSlugFromExample(ex);
      if (slug) map.set(slug, entry);
    }
  }
  return map;
}

/** Best-effort skills-lock provenance: name → source string. */
export function readSkillsLockSources(
  appRoot: string,
): Map<string, string> {
  const out = new Map<string, string>();
  const lockPath = join(appRoot, "skills-lock.json");
  if (!existsSync(lockPath)) return out;
  try {
    const raw = JSON.parse(readFileSync(lockPath, "utf8")) as unknown;
    collectLockSources(raw, out);
  } catch {
    // ignore malformed lock
  }
  return out;
}

function collectLockSources(raw: unknown, out: Map<string, string>): void {
  if (!raw || typeof raw !== "object") return;
  const obj = raw as Record<string, unknown>;

  // Shape: { skills: { name: { source | sourceRepo | ... } } }
  if (obj.skills && typeof obj.skills === "object") {
    for (const [name, meta] of Object.entries(
      obj.skills as Record<string, unknown>,
    )) {
      const src = sourceFromMeta(meta);
      if (src) out.set(name, src);
    }
  }

  // Shape: array of { name, source } or { skill, source }
  if (Array.isArray(obj.skills)) {
    for (const item of obj.skills) {
      if (!item || typeof item !== "object") continue;
      const rec = item as Record<string, unknown>;
      const name = String(rec.name ?? rec.skill ?? "");
      const src = sourceFromMeta(rec);
      if (name && src) out.set(name, src);
    }
  }
}

function sourceFromMeta(meta: unknown): string | undefined {
  if (!meta || typeof meta !== "object") return undefined;
  const rec = meta as Record<string, unknown>;
  for (const key of ["source", "sourceRepo", "repository", "repo", "url"]) {
    const v = rec[key];
    if (typeof v === "string" && v.trim()) return v.trim();
  }
  return undefined;
}

function isAdskKitSource(source: string): boolean {
  return /agentic-development-starter-kit|rhyanvargas\/agentic/i.test(source);
}

function recommendationText(
  finding: OverlapFinding,
): string {
  if (finding.recommendation === "keep-adsk") {
    return `Remove ${finding.existing}; keep ${finding.adsk}`;
  }
  return `Review ${finding.existing} vs ${finding.adsk}`;
}

export function scanOverlaps(opts: ScanOverlapsOptions): OverlapScanResult {
  const firstParty = new Set(listSkillNamesFromSnapshot(opts.snapshotRoot));
  const recommended = loadRecommendedSkills(opts.snapshotRoot);
  const doNotAdd = recommended.do_not_add ?? [];
  const overlapIndex = buildDoNotAddIndex(doNotAdd);

  const skillsRoot = skillsRootFor(opts);
  const installed = listInstalledSkillNames(skillsRoot);
  const lockSources = readSkillsLockSources(opts.appRoot);

  const findings: OverlapFinding[] = [];
  const extras: string[] = [];
  const seenSkillFindings = new Set<string>();

  for (const name of installed) {
    const lockSrc = lockSources.get(name);
    const catalog = overlapIndex.get(name);

    if (catalog) {
      const key = `known:${name}`;
      if (!seenSkillFindings.has(key)) {
        seenSkillFindings.add(key);
        findings.push({
          kind: "known-overlap",
          existing: name,
          source: lockSrc,
          adsk: catalog.adsk_skill,
          catalogId: catalog.id,
          recommendation: catalog.recommendation,
          why: catalog.reason,
        });
      }
      continue;
    }

    if (firstParty.has(name)) {
      if (lockSrc && !isAdskKitSource(lockSrc)) {
        const key = `name:${name}`;
        if (!seenSkillFindings.has(key)) {
          seenSkillFindings.add(key);
          findings.push({
            kind: "name-collision",
            existing: name,
            source: lockSrc,
            adsk: name,
            recommendation: "keep-adsk",
            why: `Folder name matches first-party ADSK skill "${name}" but skills-lock source is ${lockSrc} (not the ADSK kit). Prefer the ADSK skill tree.`,
          });
        }
      }
      continue;
    }

    extras.push(name);
  }

  const cmdMode = opts.commands ?? "off";
  if (cmdMode !== "off") {
    findings.push(
      ...scanCommandCollisions(opts.appRoot, opts.snapshotRoot, cmdMode),
    );
  }

  const ruleMode = opts.rules ?? "off";
  if (ruleMode === "post-sync") {
    findings.push(...scanRuleCollisions(opts.appRoot, opts.snapshotRoot));
  }

  return { findings, extras: extras.sort() };
}

function scanCommandCollisions(
  appRoot: string,
  snapshotRoot: string,
  mode: "pre-sync" | "post-sync",
): OverlapFinding[] {
  const destCmds = join(appRoot, ".cursor", "commands");
  if (!existsSync(destCmds)) return [];

  const skillNames = listSkillNamesFromSnapshot(snapshotRoot);
  const srcCmds = join(snapshotRoot, ".cursor", "commands");
  const findings: OverlapFinding[] = [];

  for (const entry of commandBasenames(snapshotRoot)) {
    const dest = join(destCmds, entry);
    if (!existsSync(dest) || !statSync(dest).isFile()) continue;

    if (mode === "pre-sync") {
      findings.push({
        kind: "command-collision",
        existing: entry,
        source: dest,
        adsk: entry,
        recommendation: "review",
        why: `Existing .cursor/commands/${entry} will be overwritten by ADSK stock command on sync.`,
      });
      continue;
    }

    // post-sync: flag only if content diverges from what ADSK would write
    const src = join(srcCmds, entry);
    if (!existsSync(src)) continue;
    const expected = rewriteCommandBody(
      readFileSync(src, "utf8"),
      skillNames,
    );
    const actual = readFileSync(dest, "utf8");
    if (actual !== expected) {
      findings.push({
        kind: "command-collision",
        existing: entry,
        source: dest,
        adsk: entry,
        recommendation: "review",
        why: `Local .cursor/commands/${entry} differs from ADSK stock (customized or foreign). Re-sync overwrites on update; keep a copy if you need the custom version.`,
      });
    }
  }
  return findings;
}

function scanRuleCollisions(
  appRoot: string,
  snapshotRoot: string,
): OverlapFinding[] {
  const destRules = join(appRoot, ".cursor", "rules");
  if (!existsSync(destRules)) return [];

  const findings: OverlapFinding[] = [];
  for (const name of STOCK_RULES) {
    if (name.startsWith("org-")) continue;
    const destDir = join(destRules, name);
    const srcDir = join(snapshotRoot, ".cursor", "rules", name);
    if (!existsSync(destDir) || !statSync(destDir).isDirectory()) continue;
    if (!existsSync(srcDir)) {
      findings.push({
        kind: "rule-collision",
        existing: name,
        source: destDir,
        adsk: name,
        recommendation: "review",
        why: `Local .cursor/rules/${name} uses a stock ADSK rule name but snapshot has no matching rule.`,
      });
      continue;
    }
    if (!ruleTreesEqual(srcDir, destDir)) {
      findings.push({
        kind: "rule-collision",
        existing: name,
        source: destDir,
        adsk: name,
        recommendation: "review",
        why: `Local .cursor/rules/${name} differs from ADSK stock. Preserved unless --force-rules; review before overwriting.`,
      });
    }
  }
  return findings;
}

function ruleTreesEqual(a: string, b: string): boolean {
  try {
    return dirFingerprint(a) === dirFingerprint(b);
  } catch {
    return false;
  }
}

function dirFingerprint(dir: string): string {
  const parts: string[] = [];
  const walk = (d: string, prefix: string) => {
    for (const name of readdirSync(d).sort()) {
      const p = join(d, name);
      const rel = prefix ? `${prefix}/${name}` : name;
      if (statSync(p).isDirectory()) {
        walk(p, rel);
      } else {
        parts.push(`${rel}:${readFileSync(p, "utf8")}`);
      }
    }
  };
  walk(dir, "");
  return parts.join("\n");
}

export function formatOverlapReport(result: OverlapScanResult): string {
  const lines: string[] = [];
  const n = result.findings.length;

  if (n === 0 && result.extras.length === 0) {
    lines.push("Overlaps: none");
    return lines.join("\n");
  }

  if (n > 0) {
    lines.push(`⚠ Overlaps detected (${n})`);
    lines.push("");
    for (const f of result.findings) {
      const label =
        f.kind === "known-overlap" || f.kind === "name-collision"
          ? "Skill"
          : f.kind === "command-collision"
            ? "Command"
            : "Rule";
      lines.push(`${label}  ${f.existing}`);
      if (f.source) lines.push(`  Source:   ${f.source}`);
      lines.push(`  Collides: ${f.adsk} (ADSK)`);
      lines.push(
        `  Kind:     ${f.kind}${f.catalogId ? ` (${f.catalogId})` : ""}`,
      );
      lines.push(`  Rec:      ${recommendationText(f)}`);
      lines.push(`  Why:      ${truncateWhy(f.why)}`);
      lines.push("");
    }
  } else {
    lines.push("Overlaps: none");
    lines.push("");
  }

  if (result.extras.length > 0) {
    lines.push("Extras not in ADSK profile (no known overlap):");
    for (const e of result.extras) {
      lines.push(`  - ${e}`);
    }
  }

  return lines.join("\n").trimEnd();
}

function truncateWhy(why: string, max = 220): string {
  if (why.length <= max) return why;
  return `${why.slice(0, max - 1)}…`;
}

export function printOverlapReport(result: OverlapScanResult): void {
  console.log("");
  console.log(formatOverlapReport(result));
  console.log("");
  if (result.findings.length > 0) {
    console.log(
      "No files were removed. Confirm with your team before deleting conflicting skills/commands/rules.",
    );
    console.log("");
  }
}

/** Run scan + print for init/update/status/sync-script. */
export function reportOverlaps(opts: ScanOverlapsOptions): OverlapScanResult {
  const result = scanOverlaps(opts);
  printOverlapReport(result);
  return result;
}

/** Resolve command basename without extension for display helpers. */
export function commandId(filename: string): string {
  return basename(filename, ".md");
}
