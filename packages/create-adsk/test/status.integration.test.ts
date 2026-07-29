import { mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { describe, expect, it } from "vitest";
import { writeConfig } from "../src/config.js";
import { syncCursor } from "../src/cursor-sync.js";
import { runStatus } from "../src/status.js";
import { makeTempApp, snapshotRoot } from "./helpers/temp-app.js";

describe("status integration", () => {
  // REQ-009
  it("reports drift and exit 1 when a profile skill is missing", () => {
    const app = makeTempApp();
    writeConfig(app, {
      version: 1,
      profile: "core",
      cursor: "commands",
      rules: "none",
      scope: "project",
      kitRef: "test@ref",
      optionalPacks: [],
    });
    syncCursor({
      snapshotRoot: snapshotRoot(),
      appRoot: app,
      cursor: "commands",
      rules: "none",
      forceRules: false,
      dryRun: false,
    });
    // deliberately no .agents/skills/spec-driven-workflow
    const result = runStatus({ target: app, snapshotRoot: snapshotRoot() });
    expect(result.exitCode).toBe(1);
    expect(result.drift.some((d) => d.includes("spec-driven-workflow"))).toBe(
      true,
    );
  });

  it("exit 0 when skills and commands present", () => {
    const app = makeTempApp();
    writeConfig(app, {
      version: 1,
      profile: "core",
      cursor: "commands",
      rules: "none",
      scope: "project",
      kitRef: "test@ref",
      optionalPacks: [],
    });
    const skillDir = join(app, ".agents", "skills", "spec-driven-workflow");
    mkdirSync(skillDir, { recursive: true });
    writeFileSync(join(skillDir, "SKILL.md"), "# s\n");
    syncCursor({
      snapshotRoot: snapshotRoot(),
      appRoot: app,
      cursor: "commands",
      rules: "none",
      forceRules: false,
      dryRun: false,
    });
    const result = runStatus({ target: app, snapshotRoot: snapshotRoot() });
    expect(result.exitCode).toBe(0);
    expect(result.drift).toEqual([]);
  });

  // Issue #72: after stock sync, status must not report command collisions
  it("reports no command overlaps when stock commands match post-sync", () => {
    const app = makeTempApp();
    writeConfig(app, {
      version: 1,
      profile: "core",
      cursor: "commands",
      rules: "none",
      scope: "project",
      kitRef: "test@ref",
      optionalPacks: [],
    });
    const skillDir = join(app, ".agents", "skills", "spec-driven-workflow");
    mkdirSync(skillDir, { recursive: true });
    writeFileSync(join(skillDir, "SKILL.md"), "# s\n");
    const snap = snapshotRoot();
    syncCursor({
      snapshotRoot: snap,
      appRoot: app,
      cursor: "commands",
      rules: "none",
      forceRules: false,
      dryRun: false,
    });
    const result = runStatus({ target: app, snapshotRoot: snap });
    expect(result.exitCode).toBe(0);
    expect(
      result.overlaps.filter((f) => f.kind === "command-collision"),
    ).toEqual([]);
  });
});
