/**
 * Terminal landing UX — same visual language as `npx skills`
 * (block logo + dim tagline + two-column commands + try/footer),
 * with ADSK brand accent #00aa6f.
 */
import { TWO_TOOL_BLURB } from "./help-copy.js";

const RESET = "\x1B[0m";
const DIM = "\x1B[38;5;102m";
const TEXT = "\x1B[38;5;145m";

/** Brand green (#00aa6f). */
export const BRAND_HEX = "#00aa6f";
const BRAND = "\x1B[38;2;0;170;111m";

function rgb(r: number, g: number, b: number): string {
  return `\x1B[38;2;${r};${g};${b}m`;
}

/** ANSI Shadow–style wordmark (matches skills CLI density). */
export const LOGO_LINES = [
  " █████╗ ██████╗ ███████╗██╗  ██╗",
  "██╔══██╗██╔══██╗██╔════╝██║ ██╔╝",
  "███████║██║  ██║███████╗█████╔╝ ",
  "██╔══██║██║  ██║╚════██║██╔═██╗ ",
  "██║  ██║██████╔╝███████║██║  ██╗",
  "╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝",
] as const;

/** Top→bottom brand gradient around #00aa6f. */
const LOGO_COLORS = [
  rgb(102, 214, 170),
  rgb(51, 196, 148),
  rgb(0, 170, 111),
  rgb(0, 145, 95),
  rgb(0, 120, 78),
  rgb(0, 95, 62),
] as const;

export const TAGLINE = "The Agentic Development Starter Kit";

/** One-sentence product pitch (no unexplained acronyms). */
export const PRODUCT_DESCRIPTION =
  "A ready-to-adopt kit for agentic, spec-driven development — workflow skills, Cursor slash commands, and a versioned profile for your team.";

export const DOCS_URL =
  "https://github.com/rhyanvargas/agentic-development-starter-kit";

type CmdRow = { cmd: string; args?: string; desc: string };

const PRIMARY_COMMANDS: CmdRow[] = [
  { cmd: "npx create-adsk", desc: "Apply a kit profile (default)" },
  {
    cmd: "npx create-adsk",
    args: "--profile <id> -y",
    desc: "Non-interactive adopt",
  },
  { cmd: "npx create-adsk update", desc: "Refresh skills + Cursor" },
  { cmd: "npx create-adsk status", desc: "Show profile, drift, overlaps" },
  { cmd: "npx create-adsk overlaps", desc: "Scan conflicting skills/commands" },
];

const OPTION_COMMANDS: CmdRow[] = [
  { cmd: "npx create-adsk", args: "--dry-run", desc: "Preview without writing" },
  {
    cmd: "npx create-adsk",
    args: "--scope global",
    desc: "Install skills globally",
  },
];

function visibleLen(s: string): number {
  return s.replace(/\x1B\[[0-9;]*m/g, "").length;
}

function formatRow(row: CmdRow, cmdWidth: number): string {
  const args = row.args ? ` ${DIM}${row.args}${RESET}` : "";
  const left = `${BRAND}$${RESET} ${TEXT}${row.cmd}${RESET}${args}`;
  const pad = Math.max(1, cmdWidth - visibleLen(left) + 2);
  return `  ${left}${" ".repeat(pad)}${DIM}${row.desc}${RESET}`;
}

function maxCmdWidth(rows: CmdRow[]): number {
  return Math.max(
    ...rows.map((r) => {
      const plain = `$ ${r.cmd}${r.args ? ` ${r.args}` : ""}`;
      return plain.length;
    }),
  );
}

function renderLogoLines(): string[] {
  return LOGO_LINES.map((line, i) => `${LOGO_COLORS[i]}${line}${RESET}`);
}

/** Plain + ANSI banner string (for --help and tests). */
export function renderHelpBanner(): string {
  const lines: string[] = ["", ...renderLogoLines()];

  lines.push("");
  lines.push(`${DIM}${TAGLINE}${RESET}`);
  lines.push("");
  lines.push(`${TEXT}${PRODUCT_DESCRIPTION}${RESET}`);
  lines.push("");

  const width = maxCmdWidth([...PRIMARY_COMMANDS, ...OPTION_COMMANDS]);
  for (const row of PRIMARY_COMMANDS) {
    lines.push(formatRow(row, width));
  }
  lines.push("");
  for (const row of OPTION_COMMANDS) {
    lines.push(formatRow(row, width));
  }

  lines.push("");
  lines.push(
    `${DIM}try:${RESET} ${BRAND}npx create-adsk --profile core --yes${RESET}`,
  );
  lines.push("");
  // Terminal copy: drop markdown backticks for a cleaner skills-style line.
  const blurb = TWO_TOOL_BLURB.replace(/`/g, "");
  lines.push(`${DIM}${blurb}${RESET}`);
  lines.push("");
  lines.push(`Learn more at ${BRAND}${DOCS_URL}${RESET}`);
  lines.push("");

  return lines.join("\n");
}

/** Logo + product name + one-line pitch (interactive init intro). */
export function showLogo(): void {
  console.log();
  for (const line of renderLogoLines()) {
    console.log(line);
  }
  console.log();
  console.log(`${DIM}${TAGLINE}${RESET}`);
  console.log();
  console.log(`${TEXT}${PRODUCT_DESCRIPTION}${RESET}`);
  console.log();
}

export function showHelpBanner(): void {
  process.stdout.write(renderHelpBanner());
}
