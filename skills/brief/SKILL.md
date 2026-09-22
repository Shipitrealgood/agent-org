---
name: brief
description: >
  Produce a handoff brief that directs the next agent's attention when finishing
  cross-agent work. Use when wrapping up /spec, /execute, /audit, /post-audit, or any
  session that hands off to another agent. Also trigger when the user says "write a brief",
  "brief the next agent", "hand this off", or provides a task ID with a named next step.
  Outputs docs/briefs/{task-id}-{slug}.md covering where work lives, what landed, what
  to look at (or what to build), what NOT to chase, and deviations + why.
allowed-tools: Read Write Bash(git:*) Glob Grep
---

# Brief — Handoff artifact for the next agent

When you finish cross-agent work, the next agent has to reconstruct your context from commit messages and diffs — and misses things. A brief directs their attention at the spots that matter.

A brief is **agent-scoped and task-scoped** — written by whoever just did the adjacent thing, read by whoever does the next thing. It is NOT:

- A **spec** (forward-looking design doc: what should be built)
- An **execution record** (backward-looking: what I did)
- A **commit message** (change-scoped: what this one commit does)

The value comes from directing attention — pre-loading the next agent on deviations, watchpoints (for review work), or sequence/escalation-triggers (for build work) they couldn't derive from the spec + diffs alone.

## When to use

- Finishing `/spec` → brief for the executor (use **execute template**)
- Finishing `/execute` → brief for the auditor, merger, or human reviewer (use **review template**)
- Finishing `/audit` or `/post-audit` → brief for the next spec/execute round, or follow-up triage (use **review template** — the next agent is reviewing findings disposition — OR **execute template** if you're briefing an executor to apply the findings)
- Any session that hands off work to another agent

**Skip when** the work stays in the same agent/session, or the handoff is trivially small (single-line fix, no deviations, no spec drift).

## Required input

- **Task ID** — the tracking task for the work being briefed about
- **Next agent's job** — one phrase naming who reads this (e.g., "post-audit reviewer", "merge executor", "spec author for next iteration", "executor implementing the spec")

If either is missing, ask the calling agent before proceeding. Don't guess.

## Pick the template

Briefs come in two shapes — pick based on what the next agent is doing, not what YOU just did.

1. **Is the next agent REVIEWING** (post-audit, audit, spec review, human review)?
   → Use `references/template-review.md`. 7-section shape. Adversarial framing. Watchpoints with file:line probes.

2. **Is the next agent BUILDING** (executing a spec, applying fixes, implementing)?
   → Use `references/template-execute.md`. Sequence-driven shape. Procedural framing. Escalation triggers.

Default when unclear: ask the calling agent. Don't guess — the templates differ structurally and a mis-picked template loses half the signal.

`references/template-review.md` §Why this shape works lists the properties that made real review briefs produce high-signal audits.

## Layer-aware authoring

Briefs carry **case-specific direction** layered on top of the skill's posture. The skill (`/execute`, `/audit`, etc.) already steers methodology; the brief adds only what's specific to THIS dispatch.

What belongs in the brief:
- File:line citations specific to this work
- Carry-forward concerns from prior pipeline steps (audit findings, predecessor execution decisions)
- Case-specific watchpoints / escalation triggers
- Scope statements: what's in scope, what's adjacent and out-of-scope
- Overrides of skill defaults when this case warrants them (e.g., "this is destructive schema work — think carefully before the migration block")

What lives elsewhere (and gets read at that layer, not restated here):
- Skill methodology — carried by the skill itself; the executor will already have it loaded
- Generic execution discipline like "commit incrementally" — codified in the skill
- Codebase conventions like "tests live in test/" — codified in CLAUDE.md
- Identity reminders like "you are codeclaude" — codified in the agent profile

The brief is the **routing layer** that directs attention to the case-specific shape of THIS dispatch. Lean is good. If you find yourself restating the skill, the skill needs the addition, not the brief.

## Workflow

1. **Recognize you hold the fresh context.** You are the agent that just did the work. The sections that carry the most value — deviations, watchpoints, "flag back" triggers, what NOT to chase — are in your head right now and nowhere else. Write from that held context; a brief composed by replaying commits loses the signal you uniquely have.

2. **Gather structural data** (for the factual sections) — the task, any recorded rulings, and the linked spec, plus:

   ```bash
   git log --oneline <base>..HEAD       # commits on this branch (if committed)
   git status                           # working tree state
   git diff --stat                      # change surface (if uncommitted)
   git branch --show-current            # current branch
   pwd                                  # worktree path
   ```

3. **Compose the brief** using the selected template. Every section in the template serves a different purpose — fill all of them. If a section genuinely has nothing, write it explicitly (e.g., "No deviations from the spec," "No specific flag-backs anticipated"). An empty-but-present section is signal; a missing section is a gap.

4. **Extract the fresh-eyes content** (critical — applies to both templates):

   **For review briefs:**
   - "Specifically look for" watchpoints — 5–7 numbered areas, each with concrete **Probe:** sub-bullets. Name files, line numbers, specific patterns. Specificity is the signal the brief carries.
   - "Spec deviations" — every non-trivial decision you made at implementation time that wasn't in the spec, with reasoning, asking for independent judgment.
   - "Special instruction" (optional but high-value) — confess where YOU felt uncertain. This is the single highest-leverage directive.

   **For execute briefs:**
   - "Things to flag back before powering through" — named escalation triggers that should halt execution and report.
   - "What NOT to do" — negative constraints specific to this work.
   - "Sequence commit boundaries" — why this grouping, not another.

   If you find yourself writing generic content ("verify the build", "make sure tests pass") — stop. That's a checklist, not a brief. Briefs carry signal unique to THIS work.

5. **Write the file** to `docs/briefs/{task-id}-{slug}.md` where `{slug}` is a short lowercase-hyphenated phrase naming the handoff.

   Conventions from existing briefs:
   - `{id}-post-audit-{subject}` (review of completed work)
   - `{id}-execute-{subject}` (execution of a spec)
   - `{id}-{subject}-spec` (handoff FROM spec TO executor)

6. **Link the brief to the task** — name the brief path in your report so whoever tracks the work can link it.

7. **Commit the brief** (if in a git context) with a message like `docs: brief for #{task-id} {job}`. The brief travels with the code.

## Cross-brief chain

Briefs form a paper trail across pipeline stages. If the work being briefed has sibling briefs (the audit before this execute, the execute before this post-audit), reference them in the brief — usually in the pre-flight section or in "what's in the working tree."

Each brief is a node in a chain. Make the chain navigable.

## Quality check before returning

Before declaring done, re-read the brief and ask:

- Could the next agent skip the spec and still do their job well from this brief? If no, add the missing context.
- Are the watchpoints / flag-backs **unique to this work**, or generic? Generic means the brief hasn't done its job.
- Are the deviations (review) or sequence steps (execute) **specific calls with reasoning**, or vague? Vague means the next agent can't evaluate or act.
- Is "what NOT to chase" / "what NOT to do" present and concrete? A brief without out-of-scope carve-outs invites attention drift and scope creep.
- Did I cite file:line for every code reference, or did I hand-wave? Citations are the default, not a preference.
- **Did the work absorb any workarounds where foundation was missing?** (Response-level shims for a missing service-level hook, conditional paths for domains that haven't absorbed the reference pattern, inline substitutes for infrastructure that should have existed.) When the answer is yes, flag it explicitly — this is the highest-value signal a brief can carry. Downstream work would inherit the same gap, and the correct fix lives upstream; naming it points the next agent at the foundation work instead of the symptom.
- **Are scope statements positive where possible?** Positive: "limited to files A, B, C." Negative: "do NOT touch D, E, F." Models take negative instructions literally; positive scope reads cleanly and is more precise. Section names like "What NOT to chase" are fine as headers — the bullet content underneath is where positive framing matters.
- **Does this case warrant any override of skill defaults?** Common overrides: an explicit "think carefully before the destructive step" for migrations or schema changes; explicit "use parallel reads across N files" when the skill's contextual judgment isn't enough; explicit subagent guidance when fan-out is non-default. State the override in the brief when warranted; trust the skill when it isn't.
- **Did you avoid restating skill methodology?** The executor will already have the skill loaded. Restatement bloats the brief and dilutes the case-specific signal that makes briefs valuable.

If any answer is "no" or "weak," revise before returning.
