# Workflow

This runbook turns an idea into shipped code without letting OpenSpec, Superpowers, and gstack compete for control.

## 0. Environment Discovery

Run `scripts/check-environment.ps1` before relying on external tools. Treat missing `openspec` or `gstack` as a capability limit, not a blocker for smaller work. Codex and Claude Code can still use the documented workflow manually when the CLIs or slash commands are absent.

## 1. Intent Gate

Capture:

- Goal: what changes for the user or operator.
- Success criteria: observable behavior, tests, or release outcome.
- Scope: what is explicitly included and excluded.
- Risk: data, auth, payments, migrations, public UX, deployment, or compliance.

If any of these are unclear and cannot be discovered from the repo, ask before planning.

## 2. Spec Gate

Use OpenSpec when the change needs durable history:

- New capability or major behavior change.
- Cross-team or multi-agent handoff.
- Regulated, security-sensitive, billing, auth, data migration, or compatibility work.
- Legacy refactor where current behavior must be preserved.

Expected OpenSpec artifacts are proposal, design, tasks, and later archive. Do not make OpenSpec own code execution; its output becomes the source of truth for the implementation plan.

## 3. Plan Gate

Use Superpowers planning for work that will modify code:

- Brainstorm or clarify intent.
- Produce a written implementation plan with exact files, test steps, and acceptance criteria.
- Prefer task slices that can be independently reviewed.

If OpenSpec exists, convert its tasks into the Superpowers plan instead of creating a second conflicting task list.

## 4. Build Gate

Use Superpowers execution discipline:

- Create an isolated branch or worktree when appropriate.
- Follow TDD for feature and bug work.
- Run targeted tests after each slice.
- Keep task status updated in the single active task source.

Do not dispatch parallel implementers against overlapping files. Parallelism is safe only when tasks are independent and the host can isolate worktrees.

## 5. Review Gate

Use the cheapest review layer that catches the likely failure mode:

- Superpowers spec compliance: confirms the implementation matches the plan/spec.
- Superpowers code quality: catches maintainability, tests, and regression risk.
- gstack product/CEO review: challenges the product wedge and scope.
- gstack engineering review: challenges architecture, sequencing, and test strategy.
- gstack design review: challenges UX, visual quality, and interaction details.
- gstack security/CSO review: challenges auth, data, permissions, and threat model.

Review findings must be fixed or explicitly deferred before QA/release.

## 6. QA and Release Gate

Before shipping:

- Run the repo's relevant test, lint, typecheck, and build commands.
- Run browser or UI QA for user-facing flows.
- Check release notes, migration steps, feature flags, rollback, and monitoring where relevant.
- Use gstack QA/ship style checks for production-bound work.

## 7. Archive and Learn

After verified completion:

- Mark tasks complete in the single source of truth.
- Archive OpenSpec changes when used.
- Capture release documentation if the change affects users or operators.
- Run a short retro for large or risky work so the next plan improves.
