/** Shared two-tool model copy for --help and README (REQ-014). */
export const TWO_TOOL_BLURB = [
  "Use `npx skills` to install skill folders.",
  "Use `npx create-adsk` when you want this kit’s workflow + Cursor",
  "adopted as a versioned profile in your repo — not a skills marketplace.",
].join(" ");

/**
 * Post-init tip: packs install upstream skills as authored (often no ADSK evals/).
 * Keep in sync with docs/using-adsk.md § Evaluating skills.
 */
export const POST_INSTALL_SKILL_LAYOUT_TIP = [
  "Note: first-party ADSK skills include evals/ (and usually references/).",
  "Optional packs install upstream skills as those authors ship them — often",
  "without an ADSK-style evals/ folder. That is expected, not a broken install.",
  "Trust docs/evals/SCORECARD.md for kit skills; add company evals only for",
  "skills you own under .agents/skills/.",
].join(" ");

/** Short description for Commander metadata (banner owns the landing UX). */
export const HELP_DESCRIPTION = [
  "Adopt the Agentic Development Starter Kit as a versioned profile.",
  TWO_TOOL_BLURB,
].join("\n\n");

/** Phrases that must not appear in create-adsk help (REQ-012). */
export const FORBIDDEN_HELP_PHRASES = [
  "browse skills",
  "skill catalog",
  "discover skills from GitHub",
] as const;
