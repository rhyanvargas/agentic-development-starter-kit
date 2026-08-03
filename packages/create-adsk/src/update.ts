import { readConfig, writeConfig } from "./config.js";
import { syncCursor } from "./cursor-sync.js";
import { reportOverlaps } from "./overlaps.js";
import { getSnapshotRoot, readKitRef } from "./snapshot.js";
import {
  buildSkillsUpdateArgv,
  resolveSkillsRunnerArgv,
  runSkills,
  type RunCommand,
} from "./skills.js";
import type { AdskConfig } from "./types.js";

export interface UpdateOptions {
  target: string;
  dryRun: boolean;
  forceRules: boolean;
  snapshotRoot?: string;
  run?: RunCommand;
}

export async function runUpdate(opts: UpdateOptions): Promise<AdskConfig> {
  const existing = readConfig(opts.target);
  if (!existing) {
    throw new Error(
      "No .adsk/config.json found. Run `npx create-adsk init` first.",
    );
  }

  const snapshotRoot = getSnapshotRoot(opts.snapshotRoot);
  const kitRef = readKitRef(snapshotRoot);

  const updateArgv = resolveSkillsRunnerArgv(
    buildSkillsUpdateArgv({
      scope: existing.scope,
      yes: true,
    }),
  );
  if (opts.dryRun) {
    console.log(`[dry-run] profile=${existing.profile} kitRef→${kitRef}`);
    console.log(`[dry-run] would run: ${updateArgv.join(" ")}`);
  }
  const result = await runSkills(updateArgv, {
    cwd: opts.target,
    dryRun: opts.dryRun,
    run: opts.run,
  });
  if (result.code !== 0) {
    throw new Error(`skills update failed (exit ${result.code})`);
  }

  if (!opts.dryRun) {
    reportOverlaps({
      appRoot: opts.target,
      snapshotRoot,
      scope: existing.scope,
      commands: existing.cursor === "commands" ? "pre-sync" : "off",
      rules: "off",
    });
  }

  const syncResult = syncCursor({
    snapshotRoot,
    appRoot: opts.target,
    cursor: existing.cursor,
    rules: existing.rules,
    forceRules: opts.forceRules,
    dryRun: opts.dryRun,
  });
  if (opts.dryRun) {
    if (existing.cursor === "none") {
      console.log("[dry-run] Cursor sync: skipped (cursor=none)");
    } else {
      console.log(
        `[dry-run] would sync ${syncResult.commandsWritten.length} command(s)`,
      );
    }
    console.log("[dry-run] no files written");
  }

  const next: AdskConfig = { ...existing, kitRef };
  if (!opts.dryRun) {
    writeConfig(opts.target, next);
  }
  return next;
}
