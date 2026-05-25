# AI Delivery Stack

AI Delivery Stack is a lightweight orchestration skill that combines OpenSpec, Superpowers, and gstack into one governed AI engineering workflow.

It does not vendor or replace those tools. It acts as the controller that decides when each tool should be used, so requirement writing, implementation discipline, review, QA, and release checks do not compete inside the same agent context.

## Why This Exists

OpenSpec, Superpowers, and gstack solve different problems:

| Tool | Owns | Best for |
| --- | --- | --- |
| OpenSpec | Durable requirements, proposals, design notes, task records, archive | Large changes, audited work, legacy refactors, multi-agent handoff |
| Superpowers | Engineering discipline: brainstorm, plan, TDD, execution, verification | Day-to-day implementation and code quality |
| gstack | Role-based pressure: product, engineering, design, security, QA, release | Review gates, browser QA, release readiness, retrospectives |

The core rule is simple: **one controller, many phase tools**. AI Delivery Stack is the controller; OpenSpec, Superpowers, and gstack are invoked only at the right phase boundary.

## Workflow Shape

```text
Intent
  -> OpenSpec when durable spec history is needed
  -> Superpowers plan and TDD execution
  -> gstack role reviews, QA, and release gates
  -> OpenSpec archive or release notes when complete
```

Small work should stay small. A one-file bug fix does not need a full OpenSpec change. A billing refactor that affects permissions and migrations should not be done from a vague prompt.

## Routing Matrix

| Work type | Recommended path |
| --- | --- |
| Single-file bug or narrow fix | Superpowers TDD + verification |
| Medium feature touching several files | Superpowers brainstorm -> plan -> execution -> review |
| Large feature or audited change | OpenSpec proposal/design/tasks -> Superpowers implementation -> gstack review/QA -> OpenSpec archive |
| Legacy modernization | OpenSpec current-state/design/tasks -> Superpowers slice-by-slice TDD -> gstack engineering/release review |
| Production QA or release | Superpowers verification + gstack QA/ship checks |

## Repository Layout

```text
ai-delivery-stack/
|-- SKILL.md
|-- agents/
|   `-- openai.yaml
|-- references/
|   |-- decision-matrix.md
|   |-- host-mapping.md
|   `-- workflow.md
`-- scripts/
    |-- check-environment.ps1
    |-- check-environment.sh
    |-- setup-host.ps1
    `-- setup-host.sh
```

## Install

Clone this repository:

```powershell
git clone https://github.com/KkOma-value/ai-delivery-stack.git D:\skills_together\ai-delivery-stack
```

Check local tool availability:

```powershell
D:\skills_together\ai-delivery-stack\scripts\check-environment.ps1
```

Dry-run installation into Codex and Claude Code skill folders:

```powershell
D:\skills_together\ai-delivery-stack\scripts\setup-host.ps1 -Host both -DryRun
```

Apply the installation after reviewing the dry run:

```powershell
D:\skills_together\ai-delivery-stack\scripts\setup-host.ps1 -Host both -Apply
```

For macOS/Linux or Git Bash:

```bash
./scripts/check-environment.sh
./scripts/setup-host.sh --host both --dry-run
./scripts/setup-host.sh --host both --apply
```

## Example Prompts

Use the skill as a workflow router:

```text
Use $ai-delivery-stack to decide the right workflow for fixing this failing parser test.
```

```text
Use $ai-delivery-stack to plan a login feature with email verification and browser QA.
```

```text
Use $ai-delivery-stack to run a spec-first refactor of billing permissions with OpenSpec history.
```

## Host Notes

- Codex: use this skill as the controller, then invoke Superpowers skills and local scripts as needed.
- Claude Code: use this skill as the controller, then call OpenSpec CLI, Superpowers skills, and gstack slash commands at phase gates.
- OpenSpec and gstack are not installed automatically. The environment checker reports whether they are present.

## Design Principles

- Keep one source of process control.
- Use the smallest workflow that preserves correctness.
- Escalate to OpenSpec for durable specs and audit trails.
- Escalate to gstack when a distinct reviewer role would catch a real class of risk.
- Use Superpowers for implementation discipline and verification.
- Do not duplicate the full upstream tool prompts inside this skill.

## Validation

The skill structure can be validated with Codex's skill creator validator:

```powershell
python C:\Users\82628\.codex\skills\.system\skill-creator\scripts\quick_validate.py D:\skills_together\ai-delivery-stack
```

The included environment scripts are non-destructive by default and are safe to run before installing anything.
