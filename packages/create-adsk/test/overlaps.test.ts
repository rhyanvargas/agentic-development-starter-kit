import { mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { describe, expect, it } from "vitest";
import {
  buildDoNotAddIndex,
  formatOverlapReport,
  scanOverlaps,
  skillSlugFromExample,
} from "../src/overlaps.js";
import type { DoNotAddEntry } from "../src/types.js";
import { makeTempApp, snapshotRoot } from "./helpers/temp-app.js";

function plantSkill(app: string, name: string): void {
  const dir = join(app, ".agents", "skills", name);
  mkdirSync(dir, { recursive: true });
  writeFileSync(join(dir, "SKILL.md"), `# ${name}\n`);
}

describe("overlap helpers", () => {
  it("skillSlugFromExample parses org/repo@skill", () => {
    expect(
      skillSlugFromExample("softaworks/agent-toolkit@crafting-effective-readmes"),
    ).toBe("crafting-effective-readmes");
    expect(skillSlugFromExample("other generic packs")).toBeUndefined();
  });

  it("buildDoNotAddIndex indexes skill_names and examples", () => {
    const entries: DoNotAddEntry[] = [
      {
        id: "overlapping-readme",
        adsk_skill: "readme-authoring",
        skill_names: ["crafting-effective-readmes"],
        recommendation: "keep-adsk",
        reason: "test",
        examples: ["softaworks/agent-toolkit@crafting-effective-readmes"],
      },
    ];
    const idx = buildDoNotAddIndex(entries);
    expect(idx.get("crafting-effective-readmes")?.id).toBe("overlapping-readme");
  });
});

describe("scanOverlaps", () => {
  // REQ-013 / adopter incident
  it("flags crafting-effective-readmes vs readme-authoring", () => {
    const app = makeTempApp();
    plantSkill(app, "readme-authoring");
    plantSkill(app, "crafting-effective-readmes");
    writeFileSync(
      join(app, "skills-lock.json"),
      JSON.stringify({
        skills: {
          "crafting-effective-readmes": {
            source: "softaworks/agent-toolkit",
          },
          "readme-authoring": {
            source: "rhyanvargas/agentic-development-starter-kit",
          },
        },
      }),
    );

    const result = scanOverlaps({
      appRoot: app,
      snapshotRoot: snapshotRoot(),
      scope: "project",
      commands: "off",
      rules: "off",
    });

    const hit = result.findings.find(
      (f) => f.existing === "crafting-effective-readmes",
    );
    expect(hit).toBeDefined();
    expect(hit?.kind).toBe("known-overlap");
    expect(hit?.adsk).toBe("readme-authoring");
    expect(hit?.catalogId).toBe("overlapping-readme");
    expect(hit?.recommendation).toBe("keep-adsk");
    expect(hit?.source).toBe("softaworks/agent-toolkit");
    expect(formatOverlapReport(result)).toContain("crafting-effective-readmes");
    expect(formatOverlapReport(result)).toContain("Remove crafting-effective-readmes");
  });

  it("clean ADSK-only install has no known overlaps", () => {
    const app = makeTempApp();
    plantSkill(app, "spec-driven-workflow");
    plantSkill(app, "readme-authoring");

    const result = scanOverlaps({
      appRoot: app,
      snapshotRoot: snapshotRoot(),
      scope: "project",
      commands: "off",
      rules: "off",
    });

    expect(result.findings.filter((f) => f.kind === "known-overlap")).toEqual(
      [],
    );
    expect(result.extras).toEqual([]);
    expect(formatOverlapReport(result)).toContain("Overlaps: none");
  });

  it("lists unknown extras without flagging them as overlaps", () => {
    const app = makeTempApp();
    plantSkill(app, "spec-driven-workflow");
    plantSkill(app, "my-company-helper");

    const result = scanOverlaps({
      appRoot: app,
      snapshotRoot: snapshotRoot(),
      scope: "project",
      commands: "off",
      rules: "off",
    });

    expect(result.findings).toEqual([]);
    expect(result.extras).toEqual(["my-company-helper"]);
  });

  it("detects pre-sync command collision", () => {
    const app = makeTempApp();
    mkdirSync(join(app, ".cursor", "commands"), { recursive: true });
    writeFileSync(
      join(app, ".cursor", "commands", "draft-spec.md"),
      "# custom draft-spec\n",
    );

    const result = scanOverlaps({
      appRoot: app,
      snapshotRoot: snapshotRoot(),
      scope: "project",
      commands: "pre-sync",
      rules: "off",
    });

    const hit = result.findings.find(
      (f) => f.kind === "command-collision" && f.existing === "draft-spec.md",
    );
    expect(hit).toBeDefined();
    expect(hit?.recommendation).toBe("review");
  });

  it("flags name-collision when lock source is not ADSK kit", () => {
    const app = makeTempApp();
    plantSkill(app, "spec-driven-workflow");
    writeFileSync(
      join(app, "skills-lock.json"),
      JSON.stringify({
        skills: {
          "spec-driven-workflow": { source: "someone/other-sdd-pack" },
        },
      }),
    );

    const result = scanOverlaps({
      appRoot: app,
      snapshotRoot: snapshotRoot(),
      scope: "project",
      commands: "off",
      rules: "off",
    });

    expect(result.findings.some((f) => f.kind === "name-collision")).toBe(true);
  });
});
