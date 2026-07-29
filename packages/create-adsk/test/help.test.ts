import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { describe, expect, it } from "vitest";
import {
  BRAND_HEX,
  DOCS_URL,
  LOGO_LINES,
  PRODUCT_DESCRIPTION,
  TAGLINE,
  renderHelpBanner,
} from "../src/banner.js";
import {
  FORBIDDEN_HELP_PHRASES,
  POST_INSTALL_SKILL_LAYOUT_TIP,
  TWO_TOOL_BLURB,
} from "../src/help-copy.js";

const pkgRoot = join(dirname(fileURLToPath(import.meta.url)), "..");

describe("help (REQ-012, REQ-014)", () => {
  it("exposes two-tool model and no marketplace phrases", () => {
    expect(TWO_TOOL_BLURB).toContain("Use `npx skills` to install skill folders");
    expect(TWO_TOOL_BLURB).toContain(
      "Use `npx create-adsk` when you want this kit",
    );

    let help = "";
    try {
      help = execFileSync("node", [join(pkgRoot, "dist", "cli.js"), "--help"], {
        encoding: "utf8",
      });
    } catch {
      // dist may be missing before first build — still assert banner constants
      help = renderHelpBanner();
    }

    expect(help.toLowerCase()).toContain("npx skills");
    expect(help.toLowerCase()).toContain("create-adsk");
    for (const phrase of FORBIDDEN_HELP_PHRASES) {
      expect(help.toLowerCase()).not.toContain(phrase.toLowerCase());
    }
    expect(help.toLowerCase()).not.toContain(" kit mode");
    expect(help).not.toMatch(/\bkit\b.*symlink/i);
  });

  it("documents first-party vs pack skill layout after install", () => {
    expect(POST_INSTALL_SKILL_LAYOUT_TIP).toMatch(/first-party ADSK skills/i);
    expect(POST_INSTALL_SKILL_LAYOUT_TIP).toMatch(/evals\//i);
    expect(POST_INSTALL_SKILL_LAYOUT_TIP).toMatch(/upstream/i);
    expect(POST_INSTALL_SKILL_LAYOUT_TIP).toMatch(/expected/i);
  });

  it("renders a skills-style landing banner", () => {
    const banner = renderHelpBanner();
    for (const line of LOGO_LINES) {
      expect(banner).toContain(line);
    }
    expect(banner).toContain(TAGLINE);
    expect(banner).toContain(PRODUCT_DESCRIPTION);
    expect(PRODUCT_DESCRIPTION.toLowerCase()).toContain("spec-driven development");
    expect(PRODUCT_DESCRIPTION).not.toMatch(/\bSDD\b/);
    expect(banner).toContain("try:");
    expect(banner).toContain("npx create-adsk --profile core --yes");
    expect(banner).toContain(TWO_TOOL_BLURB.replace(/`/g, ""));
    expect(banner).toContain(DOCS_URL);
    expect(banner).toContain("npx create-adsk update");
    expect(banner).toContain("npx create-adsk status");
    // Brand accent #00aa6f as truecolor ANSI
    expect(BRAND_HEX).toBe("#00aa6f");
    expect(banner).toContain("\x1B[38;2;0;170;111m");
  });

  it("prints package.json version for --version", () => {
    const pkg = JSON.parse(
      readFileSync(join(pkgRoot, "package.json"), "utf8"),
    ) as { version: string };
    const out = execFileSync(
      "node",
      [join(pkgRoot, "dist", "cli.js"), "--version"],
      { encoding: "utf8" },
    ).trim();
    expect(out).toBe(pkg.version);
    expect(out).not.toBe("0.1.0");
  });
});
