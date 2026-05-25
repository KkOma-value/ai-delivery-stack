# Host Mapping

Use this reference when translating the workflow between Codex, Claude Code, OpenSpec, Superpowers, and gstack.

## Paths

| Host/tool | Typical Windows path | Typical Unix path | Notes |
| --- | --- | --- | --- |
| Codex skills | `%USERPROFILE%\.codex\skills` | `~/.codex/skills` | Copy this skill here for Codex discovery. |
| Codex Superpowers | `%USERPROFILE%\.codex\superpowers\skills` | `~/.codex/superpowers/skills` | Some installs also mirror skills under `.codex/skills`. |
| Claude Code skills | `%USERPROFILE%\.claude\skills` | `~/.claude/skills` | gstack commonly installs here for Claude Code. |
| OpenSpec project files | `<repo>\openspec` | `<repo>/openspec` | Created and managed by the OpenSpec CLI. |
| gstack skill pack | `%USERPROFILE%\.claude\skills\gstack` or `%USERPROFILE%\.codex\skills\gstack` | `~/.claude/skills/gstack` or `~/.codex/skills/gstack` | Use the upstream setup for host registration. |

## Codex Mapping

- Use this skill as the controller.
- Use available Superpowers skills directly when they are present, for example `brainstorming`, `writing-plans`, `test-driven-development`, `subagent-driven-development`, `executing-plans`, and `verification-before-completion`.
- If OpenSpec skills are installed but the `openspec` CLI is missing, explain the missing CLI and fall back to a normal spec/plan document.
- Do not paste Claude Code slash commands as if Codex can execute them. Translate `/review`, `/qa`, and `/ship` into equivalent review, browser QA, and release-check tasks.

## Claude Code Mapping

- Use OpenSpec slash commands or `openspec` CLI where installed.
- Use Superpowers skills for brainstorming, planning, TDD, execution, and verification.
- Use gstack slash commands at gates:
  - `/office-hours`: sharpen ambiguous product intent.
  - `/plan-ceo-review`: challenge product wedge and scope.
  - `/plan-eng-review`: challenge architecture and execution plan.
  - `/plan-design-review` or `/design-review`: challenge UI/UX.
  - `/review`: code review.
  - `/qa` or `/qa-only`: browser/user workflow QA.
  - `/ship` or `/land-and-deploy`: release readiness.
  - `/retro`: post-delivery learning.

## OpenSpec Mapping

- Proposal/design/tasks are the durable source of truth for large or audited work.
- `openspec new change "<name>"` creates a change when the CLI is available.
- `openspec status --change "<name>" --json` discovers artifact state.
- `openspec instructions <artifact> --change "<name>" --json` retrieves artifact-specific guidance.
- `openspec instructions apply --change "<name>" --json` retrieves implementation context and task status.

## Installation Policy

This skill never installs third-party tools by default. Use `scripts/setup-host.ps1 -DryRun` first, then `-Apply` only after the user asks for host installation.

Suggested upstream installs, when requested:

```bash
git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git ~/.codex/skills/gstack
cd ~/.codex/skills/gstack && ./setup --host codex
```

For Claude Code, use the upstream gstack setup instructions for `~/.claude/skills/gstack`.
