# Dependency intake

**When to read:** Adding or bumping an npm dependency (especially production).

## Before merge

1. Prefer **no new dependency** if a few lines of local code suffice.
2. Check Socket / health signals (Socket.dev page, PR comment, or a Socket MCP server if configured): supply chain, vulns, license, install scripts.
3. Reject if: install scripts, known malware signals, git/http deps, unclear license for the org.
4. For **`create-adsk` production deps**: use **exact** versions (no `^` / `~`).
5. Run `npm ci && npm audit --audit-level=high`.
6. Summarize in the PR: why needed, Socket stance, pin strategy.

## After merge

Dependabot (see recommended `dependabot` skill) keeps versions patched; do not disable it to silence noise — group updates instead.
