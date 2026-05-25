---
name: ai-delivery-stack
description: Orchestrate OpenSpec, Superpowers, and gstack for AI-assisted engineering delivery. Use when the user asks to combine these tools, choose or enforce a workflow from requirement/spec through implementation/review/QA/release, build a governed AI coding process, or route a feature, bug fix, refactor, QA pass, or release across Codex and Claude Code.
---

# AI Delivery Stack

## Overview

Use this skill as the single controller for an AI engineering delivery loop. OpenSpec owns durable requirements and change artifacts, Superpowers owns implementation discipline, and gstack supplies role-based review, QA, and release pressure at phase boundaries.

## Core Rule

Keep exactly one controller active: this skill. Do not load OpenSpec, Superpowers, and gstack as competing process owners in the same step.

Route the work first, then invoke only the tools needed for the current phase:

- OpenSpec: durable proposal, design, task list, acceptance record, archive.
- Superpowers: brainstorm, written implementation plan, TDD, execution, verification.
- gstack: founder/product review, engineering review, design review, code review, browser QA, ship/retro.

## Quick Routing

- Single-file fix or narrow bug: use Superpowers TDD plus verification. Skip OpenSpec and gstack unless the user needs audit history.
- Medium feature touching several files: use Superpowers brainstorming, writing-plans, execution, and review. Add gstack plan/code review when product, UX, or release risk is meaningful.
- Large feature, cross-module refactor, regulated/audited change, or legacy modernization: create or update OpenSpec artifacts first, convert tasks into a Superpowers implementation plan, and use gstack gates before build and before release.
- Release, production QA, or user-facing validation: use gstack QA/ship style checks after implementation and before archive.

If the route is unclear, read `references/decision-matrix.md` and choose the smallest workflow that preserves correctness and traceability.

## Phase Gates

1. Intent gate: restate goal, success criteria, scope, constraints, and risk level.
2. Spec gate: use OpenSpec only when durable change records are needed.
3. Plan gate: use Superpowers to create a testable implementation plan before code changes.
4. Build gate: execute with TDD and keep tasks small enough to review.
5. Review gate: run spec compliance, code quality, and gstack role reviews as needed.
6. QA/release gate: verify tests, browser/user workflows, deployment readiness, and rollback notes.
7. Archive gate: update OpenSpec archive or release notes only after implementation and verification are complete.

For the full runbook, read `references/workflow.md`.

## Host Mapping

Before using external tools on a machine, run:

```powershell
.\scripts\check-environment.ps1
```

Use `references/host-mapping.md` when installing or translating between Codex skills, Claude Code slash commands, OpenSpec CLI commands, and gstack roles.

Install this skill into a host only when the user asks for it. The setup script defaults to dry-run:

```powershell
.\scripts\setup-host.ps1 -Host both -DryRun
```

Use `-Apply` for an actual copy/link operation.

## Examples

- "Fix a failing parser test" -> Superpowers TDD, no OpenSpec, no gstack unless requested.
- "Add login with email verification" -> Superpowers brainstorm/plan/TDD; gstack product and code review if user-facing.
- "Refactor billing permissions and keep an audit trail" -> OpenSpec proposal/design/tasks, Superpowers implementation, gstack engineering/security/release review.

## Resources

- `references/decision-matrix.md`: route selection and scale thresholds.
- `references/workflow.md`: end-to-end delivery process.
- `references/host-mapping.md`: Codex, Claude Code, OpenSpec, Superpowers, and gstack mapping.
- `scripts/check-environment.ps1`: local dependency and skill path check.
- `scripts/setup-host.ps1`: dry-run-first host installation helper.

Do not vendor or duplicate the full OpenSpec, Superpowers, or gstack skill trees into this skill. This package is an orchestrator and compatibility guide.
