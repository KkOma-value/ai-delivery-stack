# Decision Matrix

Use the smallest workflow that protects correctness, reviewability, and traceability. Escalate only when the work has enough risk or scope to justify the extra process.

| Work type | Signals | Primary path | Add gstack when | Avoid |
| --- | --- | --- | --- | --- |
| Small fix | One file or one failing test, clear expected behavior, low user impact | Superpowers TDD + verification | The fix affects release readiness or needs browser QA | OpenSpec proposal overhead |
| Medium feature | 2-20 files, user-facing behavior, tests needed, scope is understandable in one plan | Superpowers brainstorming -> writing-plans -> execution -> review | Product framing, UX quality, code review, or QA needs a separate role | Starting implementation before plan approval |
| Large/audited change | Cross-module contract changes, migrations, compliance/audit needs, many tasks, multiple phases | OpenSpec proposal/design/tasks -> Superpowers plan/execution -> OpenSpec archive | CEO/product, engineering, design, security, QA, or release gates reduce risk | Treating gstack as the spec owner |
| Legacy modernization | Existing behavior must be preserved, unclear ownership, broad refactor | OpenSpec current-state/design/tasks -> Superpowers TDD by slice | Architecture review and release gating | Big-bang rewrites without acceptance criteria |
| Release/production QA | Branch is feature-complete, deploy or merge decision is near | Superpowers verification + gstack QA/ship review | Always, if user-facing or production-bound | Adding new scope during release review |

## Route Examples

- "修一个单文件 bug": Superpowers TDD. Write the failing test, implement the smallest fix, run targeted verification.
- "新增登录功能": Superpowers full flow. Clarify product behavior, write a plan, execute with TDD, then run role review if the UX or security surface matters.
- "做一次大模块重构并保留规格记录": OpenSpec first. Capture proposal, design, tasks, then execute task slices with Superpowers and use gstack engineering/release review before archive.

## Escalation Rules

- Escalate to OpenSpec when the user asks for specs, audit trail, change proposal, architecture record, or durable task history.
- Escalate to gstack when a distinct reviewer role would catch a different class of issue: product taste, UX, engineering design, security, QA, release, docs, or retro.
- De-escalate when the process would cost more than the change: typo fixes, local test fixes, one-off scripts, or explicitly throwaway prototypes.
