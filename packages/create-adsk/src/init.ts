import * as p from "@clack/prompts";
import { writeConfig } from "./config.js";
import { syncCursor } from "./cursor-sync.js";
import { POST_INSTALL_SKILL_LAYOUT_TIP } from "./help-copy.js";
import {
	expandPackIdsToEntryIds,
	findOptionalPack,
	getProfile,
	isProfileId,
	listOptionalPackIds,
	listProfileIds,
	loadProfiles,
	loadRecommendedSkills,
	parsePackIdsFlag,
	resolvePackSelection,
} from "./profiles.js";
import { reportOverlaps } from "./overlaps.js";
import { getSnapshotRoot, readKitRef } from "./snapshot.js";
import {
	buildOptionalPackArgv,
	buildSkillsAddArgv,
	runSkills,
	type RunCommand,
} from "./skills.js";
import type { AdskConfig, ProfileId, Scope } from "./types.js";

export interface InitOptions {
	target: string;
	profile?: string;
	yes: boolean;
	dryRun: boolean;
	scope: Scope;
	forceRules: boolean;
	withOptionalPacks: boolean;
	/** Raw `--packs` flag value (comma-separated). */
	packsFlag?: string;
	snapshotRoot?: string;
	run?: RunCommand;
}

export async function runInit(opts: InitOptions): Promise<AdskConfig> {
	const snapshotRoot = getSnapshotRoot(opts.snapshotRoot);
	const profiles = loadProfiles(snapshotRoot);
	const kitRef = readKitRef(snapshotRoot);

	const profileId = await resolveProfile(opts, profiles);
	const profile = getProfile(profiles, profileId);

	const optionalPacks = await resolveOptionalPacks(opts, profiles);

	if (opts.dryRun) {
		console.log(
			`[dry-run] profile=${profileId} scope=${opts.scope} kitRef=${kitRef}`,
		);
		if (optionalPacks.length > 0) {
			console.log(`[dry-run] packs=${optionalPacks.join(",")}`);
		}
	}

	const skillsArgv = buildSkillsAddArgv({
		kitSource: profiles.kit_source,
		skills: profile.skills,
		scope: opts.scope,
		yes: true,
	});

	if (opts.dryRun) {
		console.log(`[dry-run] would run: ${skillsArgv.join(" ")}`);
	}

	const skillResult = await runSkills(skillsArgv, {
		cwd: opts.target,
		dryRun: opts.dryRun,
		run: opts.run,
	});
	if (skillResult.code !== 0) {
		throw new Error(
			`skills add failed (exit ${skillResult.code}). Check skills CLI flags/network.`,
		);
	}

	const entryIds = expandPackIdsToEntryIds(profiles, optionalPacks);
	if (entryIds.length > 0) {
		const recommended = loadRecommendedSkills(snapshotRoot);
		for (const entryId of entryIds) {
			const entry = findOptionalPack(recommended, entryId);
			if (!entry) {
				throw new Error(`Unknown optional pack entry: ${entryId}`);
			}
			const installCmd =
				opts.scope === "global"
					? (entry.install_global ?? entry.install)
					: (entry.install ?? entry.install_global);
			if (!installCmd) {
				throw new Error(
					`Optional pack entry ${entryId} has no install command`,
				);
			}
			const packArgv = buildOptionalPackArgv(installCmd, opts.scope, true);
			if (opts.dryRun) {
				console.log(
					`[dry-run] would run pack entry ${entryId}: ${packArgv.join(" ")}`,
				);
			}
			const packResult = await runSkills(packArgv, {
				cwd: opts.target,
				dryRun: opts.dryRun,
				run: opts.run,
			});
			if (packResult.code !== 0) {
				throw new Error(`optional pack install failed: ${entryId}`);
			}
		}
	} else if (opts.dryRun) {
		console.log("[dry-run] packs: none");
	}

	// Overlaps before Cursor sync so pre-existing commands are visible (REQ-005/008).
	if (!opts.dryRun) {
		reportOverlaps({
			appRoot: opts.target,
			snapshotRoot,
			scope: opts.scope,
			commands: profile.cursor === "commands" ? "pre-sync" : "off",
			rules: "off",
		});
	}

	const syncResult = syncCursor({
		snapshotRoot,
		appRoot: opts.target,
		cursor: profile.cursor,
		rules: profile.rules,
		forceRules: opts.forceRules,
		dryRun: opts.dryRun,
	});

	if (opts.dryRun) {
		if (profile.cursor === "none") {
			console.log("[dry-run] Cursor sync: skipped (cursor=none)");
		} else {
			console.log(
				`[dry-run] would sync ${syncResult.commandsWritten.length} command(s)` +
					(profile.rules === "stock"
						? `, ${syncResult.rulesWritten.length} stock rule(s)`
						: ""),
			);
		}
	}

	const cfg: AdskConfig = {
		version: 1,
		profile: profileId,
		cursor: profile.cursor,
		rules: profile.rules,
		scope: opts.scope,
		kitRef,
		optionalPacks,
	};

	if (opts.dryRun) {
		console.log(`[dry-run] would write ${opts.target}/.adsk/config.json`);
		console.log("[dry-run] no files written");
	} else {
		writeConfig(opts.target, cfg);
		console.log(`\n${POST_INSTALL_SKILL_LAYOUT_TIP}`);
		if (profile.cursor === "commands") {
			console.log("\nNext: open Cursor and try /quick-start\n");
		} else {
			console.log();
		}
	}

	return cfg;
}

async function resolveProfile(
	opts: InitOptions,
	profiles: ReturnType<typeof loadProfiles>,
): Promise<ProfileId> {
	if (opts.profile) {
		if (!isProfileId(opts.profile)) {
			throw new Error(
				`Unknown profile "${opts.profile}". Expected: ${listProfileIds().join(", ")}`,
			);
		}
		return opts.profile;
	}
	if (opts.yes) {
		return "core";
	}

	const choice = await p.select({
		message: "Select profile (kit depth)",
		options: listProfileIds().map((id) => ({
			value: id,
			label: id,
			hint: profiles.profiles[id].description,
		})),
	});
	if (p.isCancel(choice)) {
		p.cancel("Cancelled");
		process.exit(1);
	}
	return choice as ProfileId;
}

async function resolveOptionalPacks(
	opts: InitOptions,
	profiles: ReturnType<typeof loadProfiles>,
): Promise<string[]> {
	let packsFromFlag: string[] | undefined;
	if (opts.packsFlag !== undefined) {
		packsFromFlag = parsePackIdsFlag(opts.packsFlag, profiles);
	}

	if (opts.yes || packsFromFlag !== undefined || opts.withOptionalPacks) {
		return resolvePackSelection(
			{
				yes: opts.yes,
				withOptionalPacks: opts.withOptionalPacks,
				packs: packsFromFlag,
			},
			profiles,
		);
	}

	const packDefs = profiles.optional_packs.packs;
	if (packDefs.length === 0) return [];

	const selected = await p.multiselect({
		message:
			"Select optional packs (methodology contracts — not a skill picker)",
		options: packDefs.map((pack) => ({
			value: pack.id,
			label: pack.id,
			hint: pack.description,
		})),
		required: false,
		initialValues: packDefs.filter((p) => p.prompt_default).map((p) => p.id),
	});
	if (p.isCancel(selected)) {
		p.cancel("Cancelled");
		process.exit(1);
	}
	const ids = selected as string[];
	const known = new Set(listOptionalPackIds(profiles));
	return ids.filter((id) => known.has(id));
}
