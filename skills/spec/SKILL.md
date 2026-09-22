---
name: spec
description: Turn audit findings or a task into an executable implementation spec with built-in design review. Use after an audit completes, when the user has a task and wants to start coding, or when someone says "write a spec", "spec this out", "create a plan", "let's plan this", "how should we implement this". Also trigger when audit findings exist and the next logical step is structuring the work. This combines planning and architectural review in one pass — no need for separate review.
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
---

# Spec

Turn findings or a task description into an implementation spec that can be executed safely — then put on your reviewer hat and pressure-test it before presenting.

## Inputs

- **Audit findings** (preferred) — output from /audit, or findings in conversation context
- **Task description** — a clear statement of what needs to be built or fixed

If the work is non-trivial and no audit exists, suggest /audit first — planning on assumptions about code you haven't read is how rework happens.

## Preflight is the drift gate

Specs that quietly diverge from where thinking is already moving are expensive to recover from — especially codebase-born specs, where the author may not have visibility into where the product thinking is heading. The rule:

- If the work touches concepts in motion — crystallizing idea threads, recent decisions, upstream design docs — run `/preflight` first.
- Self-contained work (localized fix, isolated bug, scoped feature with no upstream entanglement) can skip, but declare the skip explicitly in the spec preamble.

Preflight names the relevant upstream landscape — what's resolved, what's still in motion, what blocks. `Sources:` distills that into the inputs that actually shaped the spec. Same reading, different outputs — no double work.

## Core Principle: Consistency Does Not Mean Conformity

This is the most important judgment call in the plan. Match existing patterns when they're sound — consistency has real value for the next person reading the code. But blindly matching bad patterns makes the codebase worse with every feature.

Watch for:
- **Accidental patterns** — done that way because the author was in a rush or didn't know better, then cargo-culted forward
- **Outdated patterns** — the codebase evolved past them; newer code reflects better thinking

When existing code is problematic, the plan should implement the right approach and note the divergence explicitly. This prevents someone later "fixing" it back to match the bad pattern — they'll see the reasoning.

## Core Principle: Foundation-First Reasoning

Treat the code as a primitive that scales. When weighing approaches, reason about whether the engineering is in the sweet-spot — correct primitives that can be built on, sound mechanics that earn their keep. Surface what would compound (foundational decisions worth getting right) vs what's surface-level (cosmetic improvements that don't matter long-term).

Some decisions are matter-of-opinion architecture calls. Surface these explicitly to the user for collaborative judgment rather than committing silently. Naming "this is a judgment call worth your input" is more valuable than picking arbitrarily — the user has context the spec doesn't, and the right call often depends on it.

## Process

The general shape is: organize → order → write fixes → self-review → present. Adapt this to what's actually in front of you — a 2-fix plan doesn't need the same ceremony as a 12-fix one.

### 1. Organize

List findings with severity, category, and dependencies between them. Flag any design decisions that need user input — these are the spots where your judgment isn't enough. Present the organization for confirmation before writing the full plan.

Sort findings into three categories — the distinction matters for sequencing:

- **In-scope fixes** — what this spec addresses.
- **Foundational prerequisites** — things that must exist before this spec can land cleanly (missing services, unbuilt layers, infrastructure the spec assumes). When these emerge, the right move is to follow the prerequisite discovery protocol from the project's CLAUDE.md: record the prerequisite work as tracked items, park this spec as blocked, and report. Slippage signs — bucketing a prerequisite into "out of scope," sketching a shim or middleware layer to keep the spec moving, treating it as a follow-up — are cues you've slipped off this path.
- **Adjacent observations** — genuine codebase health issues unrelated to this spec's foundations. These get noted for a future cycle.

### 2. Order

Sequence by: dependencies first (if B needs A's changes, A goes first), then low-risk warmups (build confidence, reduce noise), then independent fixes (note these as parallelizable), then conditional fixes after their prerequisites.

### 3. Write Fixes

For each in-scope finding, read the actual code at the relevant locations and produce:

```
## Fix [ID]: [Short title]
- **Severity:** [from audit] | **File:** [path:lines]
- **Problem:** [1-2 sentences referencing actual code]
- **Fix:** [What to change and why. Reference patterns to follow if applicable]
- **Depends on:** [other fix IDs, or "none"]
- **Verify:** [Specific test case with expected values]
- **Watch for:** [Non-obvious things to check before changing]
```

Keep fixes compact. The executor will read the actual code — duplicating it here just creates a stale snapshot that drifts the moment anything changes.

Ground every Problem statement in what you measured or read — a performance claim carries the number, a behavior claim carries the file:line. Where you're inferring rather than verifying, tag it as an assumption the executor should check. Measured, not estimated, is the bar for claims the fixes stand on.

### 4. Self-Review

Before presenting, switch mindsets and critically evaluate your own plan. The reason this matters: it's much cheaper to catch an architectural issue in a plan than in a half-implemented PR.

- **Architecture:** Does it fit the codebase's sound patterns? Introduce unnecessary abstractions?
- **Foundational prerequisites:** Does any fix in this spec require a workaround, middleware shim, or alternative approach because the target domain/layer hasn't been built yet? If yes, that's a prerequisite — route it through the prerequisite protocol so the spec lands on correct foundation rather than absorbing the gap.
- **Edge cases:** Empty inputs, concurrent requests, partial failures, rollback paths?
- **Scale claims:** Resolved with a number and a verification gate, not reassurance — if the spec asserts something holds at N, name N and the test that proves it.
- **Backwards compatibility:** Does this break existing consumers?
- **Scope:** Is each fix tightly scoped, or is scope creeping?
- **Missing requirements:** What does the plan not say that could hide bugs?

Fix what you find. Adjacent codebase health issues (not foundational) get listed separately — they're real findings, just not this plan's job.

Reason about whether the spec is ready to ship vs needs another pass. Specs that ship with unresolved foundational questions cost more downstream than specs that take an extra reasoning loop upfront. The right amount of depth is the minimum that lands a foundation worth building on. When you deliberately stop short — because the next increment of certainty has to come from data, review, or execution rather than more thinking — record the un-chased design questions in the spec with an explicit pickup trigger. Stopping is then a decision, not forgetting.

### 5. Present

Show the complete plan. Highlight: design decisions needing input, execution order rationale, scope boundaries (what's explicitly excluded and why), anything surprising from code reads.

## Output Structure

- **Preamble** — every spec opens with a structured header block:
  - **Sources:** bulleted list of upstream inputs that shaped this spec — ideation paths, prior audits or spec-reviews, previous spec versions, decision docs. E.g. `ideas/<thread>.md`, `docs/audits/pre-audit/<id>-<slug>.md`, `docs/specs/<earlier-spec>.md`, `docs/decisions/<doc>.md`. `none` is a valid declaration for self-contained work — the explicit opt-out is the signal.
  - **Preflight:** `ran` or `skipped-self-contained`.
  - Additional context lines as existing conventions call for: status, date, related audits, decision docs, commit at spec time.

  The preamble exists so provenance stays visible: future readers trace the spec back to the ideation that shaped it, and grep across specs shows what work was born from each thread.
- **Scope summary** — what this plan accomplishes and what it explicitly does NOT do
- **Files modified** — table: file, fix IDs, brief description
- **Execution order** — numbered with dependency reasoning
- **Fixes** — compact format above
- **Adjacent observations** — codebase health issues surfaced during spec writing that aren't this spec's job; feed into future /audit cycles
- **Foundational prerequisites** — if any surfaced, they should already have been recorded as tracked work per the prerequisite protocol; list them here for visibility along with their blocking relationship to this spec

## Pipeline

**/audit** → **/spec** (this skill) → **/execute** → **/post-audit**
