import { spawn, type SpawnOptions } from "node:child_process";
import type { Scope } from "./types.js";

export type RunCommand = (
  argv: string[],
  opts: { cwd: string; dryRun: boolean },
) => Promise<{ code: number; argv: string[] }>;

/** @deprecated Prefer resolveSpawnInvocation — kept for callers that only need the shim name. */
export type SpawnSpec = { command: string; shell: boolean };

export type SpawnInvocation = {
  command: string;
  args: string[];
  options: SpawnOptions & { shell: false };
};

/**
 * Windows spawn rules for npm/npx:
 * - Bare `npx` with `shell: false` → ENOENT (shim is `npx.cmd`)
 * - `npx.cmd` with `shell: false` (direct) → EINVAL (CVE-2024-27980 blocks .cmd/.bat)
 * So win32 must run `.cmd` via `cmd.exe /d /s /c` with shell:false (never args + shell:true — DEP0190).
 */
export function resolveSpawnSpec(
  cmd: string,
  platform: NodeJS.Platform = process.platform,
): SpawnSpec {
  if (platform !== "win32") {
    return { command: cmd, shell: false };
  }
  if (cmd === "npx" || cmd === "npm") {
    return { command: `${cmd}.cmd`, shell: true };
  }
  if (/\.(cmd|bat)$/i.test(cmd)) {
    return { command: cmd, shell: true };
  }
  // Real .exe / other binaries: no shell
  return { command: cmd, shell: false };
}

/**
 * Escape one argv token for cmd.exe when passed under `/d /s /c`.
 * Algorithm adapted from cross-spawn (MIT) / https://qntm.org/cmd — meta chars caret-escaped after quoting.
 */
export function quoteWindowsCmdArg(arg: string): string {
  let s = `${arg}`;
  // Backslashes before a double quote: double them and escape the quote
  s = s.replace(/(?=(\\+?)?)\1"/g, "$1$1\\\"");
  // Trailing backslashes (before the quote we add): double them
  s = s.replace(/(?=(\\+?)?)\1$/, "$1$1");
  s = `"${s}"`;
  // cmd.exe metacharacters
  s = s.replace(/([()\][%!^"`<>&|;, *?])/g, "^$1");
  return s;
}

function needsWindowsCmdShim(cmd: string): boolean {
  return cmd === "npx" || cmd === "npm" || /\.(cmd|bat)$/i.test(cmd);
}

/**
 * Build a spawn() invocation that never uses args + shell:true (DEP0190).
 */
export function resolveSpawnInvocation(
  argv: string[],
  platform: NodeJS.Platform = process.platform,
  env: NodeJS.ProcessEnv = process.env,
): SpawnInvocation {
  if (argv.length === 0) {
    throw new Error("resolveSpawnInvocation: empty argv");
  }
  const [cmd, ...rest] = argv;

  if (platform !== "win32" || !needsWindowsCmdShim(cmd)) {
    return {
      command: cmd,
      args: rest,
      options: { shell: false },
    };
  }

  const file = cmd === "npx" || cmd === "npm" ? `${cmd}.cmd` : cmd;
  const cmdline = [file, ...rest].map(quoteWindowsCmdArg).join(" ");
  return {
    command: env.ComSpec || "cmd.exe",
    args: ["/d", "/s", "/c", cmdline],
    options: {
      shell: false,
      windowsVerbatimArguments: true,
    },
  };
}

export function buildSkillsAddArgv(opts: {
  kitSource: string;
  skills: string[];
  scope: Scope;
  yes: boolean;
}): string[] {
  const argv = ["npx", "--yes", "skills", "add", opts.kitSource];
  for (const skill of opts.skills) {
    argv.push("--skill", skill);
  }
  if (opts.scope === "global") argv.push("-g");
  if (opts.yes) argv.push("-y");
  return argv;
}

export function buildSkillsUpdateArgv(opts: {
  scope: Scope;
  yes: boolean;
}): string[] {
  const argv = ["npx", "--yes", "skills", "update"];
  if (opts.yes) argv.push("-y");
  if (opts.scope === "global") argv.push("-g");
  else argv.push("-p");
  return argv;
}

/** Split an install command string into argv; ensure -y when yes. */
export function buildOptionalPackArgv(
  installCmd: string,
  scope: Scope,
  yes: boolean,
): string[] {
  const parts = installCmd.trim().split(/\s+/);
  let argv = [...parts];
  if (scope === "global" && !argv.includes("-g") && !argv.includes("--global")) {
    argv.push("-g");
  }
  if (scope === "project") {
    argv = argv.filter((a) => a !== "-g" && a !== "--global");
  }
  if (yes && !argv.includes("-y") && !argv.includes("--yes")) {
    argv.push("-y");
  }
  return argv;
}

export const defaultRunCommand: RunCommand = async (argv, opts) => {
  if (opts.dryRun) {
    return { code: 0, argv };
  }
  const inv = resolveSpawnInvocation(argv);
  const code = await new Promise<number>((resolve, reject) => {
    const child = spawn(inv.command, inv.args, {
      cwd: opts.cwd,
      stdio: "inherit",
      ...inv.options,
    });
    child.on("error", (err: NodeJS.ErrnoException) => {
      if (err.code === "ENOENT" || err.code === "EINVAL") {
        reject(
          new Error(
            `Failed to spawn '${inv.command}' (${err.code}). Ensure Node.js/npm are installed and on PATH` +
              (process.platform === "win32"
                ? " (Windows: create-adsk runs npx.cmd via cmd.exe /d /s /c, shell:false)."
                : ".") +
              ` Command was: ${argv.join(" ")}`,
          ),
        );
        return;
      }
      reject(err);
    });
    child.on("close", (c) => resolve(c ?? 1));
  });
  return { code, argv };
};

export async function runSkills(
  argv: string[],
  opts: { cwd: string; dryRun: boolean; run?: RunCommand },
): Promise<{ code: number; argv: string[] }> {
  const run = opts.run ?? defaultRunCommand;
  return run(argv, { cwd: opts.cwd, dryRun: opts.dryRun });
}
