import { existsSync, mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { describe, expect, it } from "vitest";
import { readConfig } from "../src/config.js";
import { runInit } from "../src/init.js";
import type { RunCommand } from "../src/skills.js";
import { makeTempApp, snapshotRoot } from "./helpers/temp-app.js";

/** Fake skills runner: records argv and plants SKILL.md stubs for profile skills. */
function fakeSkillsRunner(calls: string[][]): RunCommand {
	return async (argv, opts) => {
		calls.push(argv);
		if (opts.dryRun) return { code: 0, argv };
		// Plant skills named after --skill flags under .agents/skills
		for (let i = 0; i < argv.length; i++) {
			if (argv[i] === "--skill" && argv[i + 1]) {
				const name = argv[i + 1];
				const dir = join(opts.cwd, ".agents", "skills", name);
				mkdirSync(dir, { recursive: true });
				writeFileSync(join(dir, "SKILL.md"), `# ${name}\n`, "utf8");
			}
		}
		return { code: 0, argv };
	};
}

describe("init integration", () => {
	// REQ-001, REQ-003, REQ-004, REQ-007, REQ-011, REQ-012
	it("init --profile delivery --yes installs three skills + Cursor + config", async () => {
		const app = makeTempApp();
		const calls: string[][] = [];
		const cfg = await runInit({
			target: app,
			profile: "delivery",
			yes: true,
			dryRun: false,
			scope: "project",
			forceRules: false,
			withOptionalPacks: false,
			snapshotRoot: snapshotRoot(),
			run: fakeSkillsRunner(calls),
		});

		expect(cfg.profile).toBe("delivery");
		expect(calls.length).toBe(1);
		const argv = calls[0].join(" ");
		expect(argv).toContain("--skill spec-driven-workflow");
		expect(argv).toContain("--skill devops-strategy-facilitator");
		expect(argv).toContain("--skill release-automation");
		expect(argv).not.toMatch(/\bfind\b/);
		expect(argv).not.toMatch(/catalog/);

		expect(existsSync(join(app, ".cursor", "commands", "draft-spec.md"))).toBe(
			true,
		);
		expect(readConfig(app)?.profile).toBe("delivery");
	});

	it("dry-run logs plan and writes nothing", async () => {
		const app = makeTempApp();
		const logs: string[] = [];
		const orig = console.log;
		console.log = (...args: unknown[]) => {
			logs.push(args.map(String).join(" "));
		};
		try {
			await runInit({
				target: app,
				profile: "delivery",
				yes: true,
				dryRun: true,
				scope: "project",
				forceRules: false,
				withOptionalPacks: false,
				snapshotRoot: snapshotRoot(),
				run: fakeSkillsRunner([]),
			});
		} finally {
			console.log = orig;
		}
		const joined = logs.join("\n");
		expect(joined).toContain("[dry-run] profile=delivery");
		expect(joined).toContain("would run: npx --yes skills add");
		expect(joined).toContain("packs: none");
		expect(joined).toContain("no files written");
		expect(existsSync(join(app, ".adsk", "config.json"))).toBe(false);
		expect(existsSync(join(app, ".cursor", "commands"))).toBe(false);
	});

	it("init --packs engineering-methods installs Superpowers subset and records pack id", async () => {
		const app = makeTempApp();
		const calls: string[][] = [];
		const cfg = await runInit({
			target: app,
			profile: "core",
			yes: true,
			dryRun: false,
			scope: "project",
			forceRules: false,
			withOptionalPacks: false,
			packsFlag: "engineering-methods",
			snapshotRoot: snapshotRoot(),
			run: fakeSkillsRunner(calls),
		});

		expect(cfg.optionalPacks).toEqual(["engineering-methods"]);
		expect(calls.length).toBe(2);
		const packArgv = calls[1].join(" ");
		expect(packArgv).toContain("obra/superpowers");
		expect(packArgv).toContain("--skill writing-plans");
		expect(packArgv).toContain("--skill test-driven-development");
		expect(packArgv).toContain("--skill systematic-debugging");
		expect(existsSync(join(app, ".agents", "skills", "writing-plans"))).toBe(
			true,
		);
	});

	// REQ-006
	it("init --profile skills-only --yes does not create .cursor/commands", async () => {
		const app = makeTempApp();
		await runInit({
			target: app,
			profile: "skills-only",
			yes: true,
			dryRun: false,
			scope: "project",
			forceRules: false,
			withOptionalPacks: false,
			snapshotRoot: snapshotRoot(),
			run: fakeSkillsRunner([]),
		});
		expect(existsSync(join(app, ".cursor", "commands"))).toBe(false);
	});
});
