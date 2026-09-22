# agent-org

How we run a production codebase with a fleet of Claude Code agents — the principles, the boot-image pattern for handing work between sessions, the subagent definitions, and the skills they run.

This is working material, not a framework. Every rule in here was paid for by a specific failure. Take what fits. Nothing here needs a task tracker: every artifact is a file in your repo.

## How we run it

```
human (ENG)       sets the vision and the quality bar as gates; rules only on marked decisions
  │
  conductor       a session that grades, gates, merges, and records — never writes product code
  │                 boots from a grounded boot image (docs/agent-handoff-prompting.md)
  │
  per unit:       angelique   audit the code it builds on, write the spec
                  codeclaude  execute in an isolated worktree, commit, brief the reviewer
                  chuck       independent adversarial post-audit — the executor never grades itself
                  conductor   rules each finding: objective → reasoning → result, written down
```

Four rules carry most of the weight:

- **Authority = provenance.** An artifact gets acted on without re-derivation only if it's dense with checkable citations (file:line, SHAs, IDs). Unverified specifics are worse than vagueness.
- **Subagents return questions, they don't resolve them.** Anything ambiguous comes back as a named question with options and a default — never a silent guess.
- **The executor's self-review is never the gate.** Review is a separate agent, dispatched independently, working from the paper trail — not from the executor's summary.
- **Chat is where decisions happen, never where they live.** If every window closed right now, could the work be reconstructed from what's committed?

At larger scale we run this across many parallel sessions: read-only grounding fan-outs, deep planning per slice of the work, a convergence pass across the plans, and periodic checkpoints over what's landed. That orchestration layer isn't published yet — this repo is the part that works on any project, today, with a single session.

## Start here

1. [`docs/agent-org-principles.md`](docs/agent-org-principles.md) — five principles (short; read first)
2. [`docs/agent-handoff-prompting.md`](docs/agent-handoff-prompting.md) — the boot-image pattern for session handoffs, and the "dispatch-six" for subagent dispatches
3. [`agents/README.md`](agents/README.md) — the four agents and why they're shaped the way they are

## Layout

```
docs/
  agent-org-principles.md     why — five invariants
  agent-handoff-prompting.md  boot images + the subagent dispatch contract
  agent-stance-core.md        the six-line stance embedded in every agent
templates/
  CLAUDE.md.example           project CLAUDE.md: disposition, principles, prerequisite protocol
agents/                       Claude Code subagent defs: angelique · codeclaude · chuck · bigbrain
skills/
  handoff-prompt/             author a grounded boot-image prompt for a fresh session
  gate-dispatch/              derive a reviewer/executor dispatch from the unit's paper trail
  preflight/ audit/ spec/ execute/ post-audit/ brief/   the unit loop
  big-brain/                  first-principles reasoning on one hard problem
```

## Install

```bash
cp agents/*.md ~/.claude/agents/
cp -r skills/* ~/.claude/skills/
# Put docs/ somewhere your agents can read, and fix the docs/ paths in the skills if you move it.
# Adapt templates/CLAUDE.md.example into your repo's CLAUDE.md — the skills reference its
# "Engineering Principles" and "Prerequisite Discovery Protocol" sections by name.
```

The skills and agents are Claude Code formats; the docs are harness-agnostic — we've run the same boot images on other coding-agent harnesses.

## The smallest useful loop

For one change: `/audit` the code you're about to build on → `/spec` → `/execute` in a worktree → dispatch `chuck` to `/post-audit` it independently (`/gate-dispatch` writes that dispatch for you) → fix or record a ruling on every Medium-or-worse finding. That alone catches most of what single-agent coding ships.

## Vocabulary

**ENG** — the human owning vision and bar. **Conductor** — a session that grades, gates, merges, and records. **Unit** — one piece of work through the loop. **Vein** — a coherent slice of a larger body of work, owned by one conductor session (the principles mention them; the multi-vein layer isn't published yet). **Method-first** — every ruling recorded as objective → reasoning → result. **Dispatch-six** — the six things every subagent prompt carries (role + negative space, verified grounding with absolute paths, deliverable contract, constraints, escalate-as-question, the 2–3 traps this unit will hit).

## What's next

The orchestration layer — parallel sessions, planning convergence, checkpoints over landed work — is coming. Follow [@brycedelrio](https://x.com/brycedelrio) or watch this repo to hear when it ships.
