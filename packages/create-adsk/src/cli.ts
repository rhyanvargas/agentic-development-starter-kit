#!/usr/bin/env node
import { createRequire } from "node:module";
import { Command, Help } from "commander";
import { renderHelpBanner, showLogo } from "./banner.js";
import { readConfig } from "./config.js";
import { HELP_DESCRIPTION } from "./help-copy.js";
import { runInit } from "./init.js";
import {
  defaultOverlapModes,
  reportOverlaps,
  type CommandsScanMode,
  type RulesScanMode,
} from "./overlaps.js";
import { getSnapshotRoot } from "./snapshot.js";
import { runStatus } from "./status.js";
import { runUpdate } from "./update.js";
import type { Scope } from "./types.js";

const require = createRequire(import.meta.url);
const { version: PACKAGE_VERSION } = require("../package.json") as {
  version: string;
};

const program = new Command();

/** Root `--help` uses the skills-style banner; subcommands keep default Help. */
class AdskHelp extends Help {
  formatHelp(cmd: Command, helper: Help): string {
    if (!cmd.parent) {
      return renderHelpBanner();
    }
    return super.formatHelp(cmd, helper);
  }
}

program.createHelp = () => new AdskHelp();

program
  .name("create-adsk")
  .description(HELP_DESCRIPTION)
  .version(PACKAGE_VERSION);

function parseScope(value: string): Scope {
  if (value !== "project" && value !== "global") {
    throw new Error(`Invalid --scope ${value} (expected project|global)`);
  }
  return value;
}

program
  .command("init", { isDefault: true })
  .description("Apply an ADSK profile (default command)")
  .option("--profile <id>", "Profile: core|delivery|maintainer|skills-only")
  .option("-y, --yes", "Non-interactive; default profile core if omitted", false)
  .option("--scope <scope>", "project|global", "project")
  .option("--target <dir>", "App root to adopt into", ".")
  .option("--dry-run", "Print actions without writing", false)
  .option("--force-rules", "Overwrite existing stock rules", false)
  .option(
    "--with-optional-packs",
    "Include all optional packs (product-value-loop, engineering-methods); default off with --yes",
    false,
  )
  .option(
    "--packs <ids>",
    "Comma-separated pack IDs (e.g. engineering-methods or product-value-loop,engineering-methods). Overrides --with-optional-packs",
  )
  .action(async (opts) => {
    try {
      const interactive = !opts.yes && process.stdout.isTTY;
      if (interactive) {
        showLogo();
      }
      await runInit({
        target: opts.target,
        profile: opts.profile,
        yes: Boolean(opts.yes),
        dryRun: Boolean(opts.dryRun),
        scope: parseScope(opts.scope),
        forceRules: Boolean(opts.forceRules),
        withOptionalPacks: Boolean(opts.withOptionalPacks),
        packsFlag: opts.packs,
      });
    } catch (err) {
      console.error(err instanceof Error ? err.message : err);
      process.exit(1);
    }
  });

program
  .command("update")
  .description("Refresh skills + Cursor from saved .adsk/config.json")
  .option("--target <dir>", "App root", ".")
  .option("--dry-run", "Print actions without writing", false)
  .option("--force-rules", "Overwrite existing stock rules", false)
  .action(async (opts) => {
    try {
      await runUpdate({
        target: opts.target,
        dryRun: Boolean(opts.dryRun),
        forceRules: Boolean(opts.forceRules),
      });
    } catch (err) {
      console.error(err instanceof Error ? err.message : err);
      process.exit(1);
    }
  });

program
  .command("status")
  .description("Show profile, kitRef, and drift (exit 1 if drift)")
  .option("--target <dir>", "App root", ".")
  .action((opts) => {
    try {
      const result = runStatus({ target: opts.target });
      process.exit(result.exitCode);
    } catch (err) {
      console.error(err instanceof Error ? err.message : err);
      process.exit(1);
    }
  });

program
  .command("overlaps")
  .description(
    "Scan for skills/commands/rules that collide with ADSK (advisory; never deletes)",
  )
  .option("--target <dir>", "App root", ".")
  .option(
    "--snapshot-root <dir>",
    "Kit snapshot or kit root with profiles.json + recommended-skills.json",
  )
  .option("--scope <scope>", "project|global")
  .option(
    "--commands <mode>",
    "pre-sync|post-sync|off (default: same as status when .adsk/config.json exists; else pre-sync)",
  )
  .option(
    "--rules <mode>",
    "post-sync|off (default: same as status when config exists; else off)",
  )
  .action((opts) => {
    try {
      const snapshotRoot = opts.snapshotRoot
        ? opts.snapshotRoot
        : getSnapshotRoot();
      const cfg = readConfig(opts.target);
      const defaults = defaultOverlapModes(cfg);
      const commands = (opts.commands ?? defaults.commands) as CommandsScanMode;
      const rules = (opts.rules ?? defaults.rules) as RulesScanMode;
      const scope = opts.scope
        ? parseScope(opts.scope)
        : (cfg?.scope ?? "project");
      if (!["pre-sync", "post-sync", "off"].includes(commands)) {
        throw new Error("--commands must be pre-sync|post-sync|off");
      }
      if (!["post-sync", "off"].includes(rules)) {
        throw new Error("--rules must be post-sync|off");
      }
      reportOverlaps({
        appRoot: opts.target,
        snapshotRoot,
        scope,
        commands,
        rules,
      });
    } catch (err) {
      console.error(err instanceof Error ? err.message : err);
      process.exit(1);
    }
  });

program.parseAsync(process.argv).catch((err) => {
  console.error(err instanceof Error ? err.message : err);
  process.exit(1);
});
