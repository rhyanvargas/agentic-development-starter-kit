import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { describe, expect, it } from "vitest";
import {
  buildOptionalPackArgv,
  buildSkillsAddArgv,
  buildSkillsUpdateArgv,
  quoteWindowsCmdArg,
  resolveNpmCliJs,
  resolveSkillsRunnerArgv,
  resolveSpawnInvocation,
  resolveSpawnSpec,
} from "../src/skills.js";

describe("resolveSpawnSpec", () => {
  it("marks npx/npm as needing a Windows .cmd shim (legacy helper)", () => {
    expect(resolveSpawnSpec("npx", "win32")).toEqual({
      command: "npx.cmd",
      shell: true,
    });
    expect(resolveSpawnSpec("npm", "win32")).toEqual({
      command: "npm.cmd",
      shell: true,
    });
  });

  it("keeps shell:false and bare commands on non-Windows", () => {
    expect(resolveSpawnSpec("npx", "darwin")).toEqual({
      command: "npx",
      shell: false,
    });
    expect(resolveSpawnSpec("npx", "linux")).toEqual({
      command: "npx",
      shell: false,
    });
  });

  it("does not rewrite unrelated win32 binaries to require a shell", () => {
    expect(resolveSpawnSpec("npx.cmd", "win32")).toEqual({
      command: "npx.cmd",
      shell: true,
    });
    expect(resolveSpawnSpec("node", "win32")).toEqual({
      command: "node",
      shell: false,
    });
  });
});

describe("resolveSpawnInvocation (DEP0190)", () => {
  it("never returns shell:true", () => {
    for (const platform of ["darwin", "linux", "win32"] as const) {
      const inv = resolveSpawnInvocation(
        ["npx", "--yes", "skills", "add", "kit"],
        platform,
        { ComSpec: "C:\\\\Windows\\\\system32\\\\cmd.exe" },
      );
      expect(inv.options.shell).toBe(false);
    }
  });

  it("uses argv array spawn on non-Windows", () => {
    const inv = resolveSpawnInvocation(
      ["npx", "--yes", "skills", "update", "-y", "-p"],
      "darwin",
    );
    expect(inv).toEqual({
      command: "npx",
      args: ["--yes", "skills", "update", "-y", "-p"],
      options: { shell: false },
    });
  });

  it("runs win32 npx via cmd.exe /d /s /c without shell:true", () => {
    const inv = resolveSpawnInvocation(
      ["npx", "--yes", "skills", "add", "owner/repo"],
      "win32",
      { ComSpec: "C:\\\\Windows\\\\system32\\\\cmd.exe" },
    );
    expect(inv.command).toBe("C:\\\\Windows\\\\system32\\\\cmd.exe");
    expect(inv.options.shell).toBe(false);
    expect(inv.options.windowsVerbatimArguments).toBe(true);
    expect(inv.args[0]).toBe("/d");
    expect(inv.args[1]).toBe("/s");
    expect(inv.args[2]).toBe("/c");
    expect(inv.args[3]).toContain("npx.cmd");
    expect(inv.args[3]).toContain("owner/repo");
  });

  it("quotes metacharacters so they stay literal on win32", () => {
    const evil = "x & calc.exe";
    const inv = resolveSpawnInvocation(
      ["npx", "--yes", "skills", "add", evil],
      "win32",
      { ComSpec: "cmd.exe" },
    );
    const line = inv.args[3]!;
    // Entire token is quoted/escaped — bare " & " must not appear as a shell operator join
    expect(line).toContain(quoteWindowsCmdArg(evil));
    expect(line).not.toMatch(/npx\.cmd[^^]* & /);
  });

  it("spawns node on win32 without cmd.exe", () => {
    const inv = resolveSpawnInvocation(["node", "--version"], "win32");
    expect(inv.command).toBe("node");
    expect(inv.args).toEqual(["--version"]);
    expect(inv.options.shell).toBe(false);
  });
});

describe("quoteWindowsCmdArg", () => {
  it("wraps spaces and escapes quotes", () => {
    expect(quoteWindowsCmdArg("hello world")).toMatch(/hello/);
    expect(quoteWindowsCmdArg('say "hi"')).toContain("hi");
  });
});

describe("resolveSkillsRunnerArgv (issue #81 nested npx)", () => {
  const npmCli = "/usr/lib/node_modules/npm/bin/npm-cli.js";
  const nodeBin = "/usr/bin/node";

  it("rewrites npx skills … to node npm-cli.js exec when npm_execpath is set", () => {
    const argv = resolveSkillsRunnerArgv(
      ["npx", "--yes", "skills", "update", "-y", "-p"],
      { npm_execpath: npmCli },
      nodeBin,
    );
    expect(argv).toEqual([
      nodeBin,
      npmCli,
      "exec",
      "--yes",
      "--",
      "skills",
      "update",
      "-y",
      "-p",
    ]);
  });

  it("rewrites skills add the same way", () => {
    const argv = resolveSkillsRunnerArgv(
      ["npx", "--yes", "skills", "add", "owner/kit", "--skill", "x", "-y"],
      { npm_execpath: npmCli },
      nodeBin,
    );
    expect(argv[0]).toBe(nodeBin);
    expect(argv).toContain("exec");
    expect(argv.indexOf("--")).toBeLessThan(argv.indexOf("skills"));
    expect(argv).toContain("add");
    expect(argv).toContain("owner/kit");
  });

  it("leaves npx argv unchanged when npm_execpath is unset", () => {
    const input = ["npx", "--yes", "skills", "update", "-y", "-p"];
    expect(resolveSkillsRunnerArgv(input, {}, nodeBin)).toEqual(input);
  });

  it("does not rewrite non-npx argv", () => {
    const input = [nodeBin, "--version"];
    expect(
      resolveSkillsRunnerArgv(input, { npm_execpath: npmCli }, nodeBin),
    ).toEqual(input);
  });

  it("maps npx-cli.js to sibling npm-cli.js when the sibling exists", () => {
    const dir = mkdtempSync(join(tmpdir(), "adsk-npm-cli-"));
    try {
      const npmCliPath = join(dir, "npm-cli.js");
      const npxCli = join(dir, "npx-cli.js");
      writeFileSync(npmCliPath, "// npm\n");
      writeFileSync(npxCli, "// npx\n");
      expect(resolveNpmCliJs({ npm_execpath: npxCli })).toBe(npmCliPath);
      const argv = resolveSkillsRunnerArgv(
        ["npx", "--yes", "skills", "update", "-p"],
        { npm_execpath: npxCli },
        nodeBin,
      );
      expect(argv[1]).toBe(npmCliPath);
    } finally {
      rmSync(dir, { recursive: true, force: true });
    }
  });

  it("falls back to raw npx-cli.js path when sibling npm-cli.js is missing", () => {
    const npxCli = "/tmp/does-not-exist-npm/bin/npx-cli.js";
    expect(resolveNpmCliJs({ npm_execpath: npxCli })).toBe(npxCli);
  });

  it("is idempotent when argv is already node+npm exec", () => {
    const once = resolveSkillsRunnerArgv(
      ["npx", "--yes", "skills", "update", "-y", "-p"],
      { npm_execpath: npmCli },
      nodeBin,
    );
    expect(resolveSkillsRunnerArgv(once, { npm_execpath: npmCli }, nodeBin)).toEqual(
      once,
    );
  });
});

describe("skills argv builders", () => {
  it("builds project skills add with --skill per skill and -y", () => {
    const argv = buildSkillsAddArgv({
      kitSource: "rhyanvargas/agentic-development-starter-kit",
      skills: [
        "spec-driven-workflow",
        "devops-strategy-facilitator",
        "release-automation",
      ],
      scope: "project",
      yes: true,
    });
    expect(argv).toEqual([
      "npx",
      "--yes",
      "skills",
      "add",
      "rhyanvargas/agentic-development-starter-kit",
      "--skill",
      "spec-driven-workflow",
      "--skill",
      "devops-strategy-facilitator",
      "--skill",
      "release-automation",
      "-y",
    ]);
    expect(argv.join(" ")).not.toMatch(/\bfind\b/);
    expect(argv.join(" ")).not.toMatch(/catalog/);
  });

  it("adds -g for global scope", () => {
    const argv = buildSkillsAddArgv({
      kitSource: "kit",
      skills: ["spec-driven-workflow"],
      scope: "global",
      yes: true,
    });
    expect(argv).toContain("-g");
  });

  it("builds skills update with -p for project", () => {
    expect(buildSkillsUpdateArgv({ scope: "project", yes: true })).toEqual([
      "npx",
      "--yes",
      "skills",
      "update",
      "-y",
      "-p",
    ]);
  });

  it("builds skills update with -g for global", () => {
    expect(buildSkillsUpdateArgv({ scope: "global", yes: true })).toEqual([
      "npx",
      "--yes",
      "skills",
      "update",
      "-y",
      "-g",
    ]);
  });

  it("ensures -y on optional pack install and strips -g for project", () => {
    const argv = buildOptionalPackArgv(
      "npx skills add wondelai/skills --skill mom-test -g",
      "project",
      true,
    );
    expect(argv).not.toContain("-g");
    expect(argv).toContain("-y");
  });
});
