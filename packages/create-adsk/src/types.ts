export type ProfileId = "core" | "delivery" | "maintainer" | "skills-only";
export type CursorMode = "commands" | "none";
export type RulesMode = "stock" | "none";
export type Scope = "project" | "global";

export interface ProfileDef {
  description: string;
  skills: string[];
  cursor: CursorMode;
  rules: RulesMode;
}

/** Named workflow pack (methodology contract) — not a skill picker. */
export interface OptionalPackDef {
  id: string;
  description: string;
  prompt_default: boolean;
  /** IDs in recommended-skills.json (optional/recommended pools). */
  entry_ids: string[];
  docs: string;
}

export interface ProfilesFile {
  version: number;
  product: string;
  kit_source: string;
  profiles: Record<ProfileId, ProfileDef>;
  optional_packs: {
    source_file: string;
    packs: OptionalPackDef[];
  };
  config_marker: {
    path: string;
    fields: string[];
  };
}

export interface AdskConfig {
  version: 1;
  profile: ProfileId;
  cursor: CursorMode;
  rules: RulesMode;
  scope: Scope;
  kitRef: string;
  /** Selected pack IDs from profiles.json optional_packs.packs[].id */
  optionalPacks: string[];
}

export interface RecommendedSkillEntry {
  id: string;
  install?: string;
  install_global?: string;
}

export type OverlapRecommendation = "keep-adsk" | "review";

/** Curated known conflicts with first-party ADSK skills (machine-matchable). */
export interface DoNotAddEntry {
  id: string;
  adsk_skill: string;
  adsk_commands?: string[];
  skill_names: string[];
  recommendation: OverlapRecommendation;
  reason: string;
  examples?: string[];
  notes?: string[];
  absorbed_patterns?: string[];
}

export interface RecommendedSkillsFile {
  optional?: RecommendedSkillEntry[];
  recommended?: RecommendedSkillEntry[];
  do_not_add?: DoNotAddEntry[];
}
