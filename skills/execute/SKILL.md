---
name: execute
description: Implement an approved plan fix-by-fix with investigation, verification, and incremental commits. Use after a plan is approved, or when the user says "execute this", "implement this", "let's build it", "code this up", "start implementing". Also trigger when a reviewed spec or plan exists in context and the user gives the go-ahead. This is the skill that turns plans into working code.
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash, Edit, Write
---

# Execute

Implement an approved plan with engineering discipline. The plan says *what* to change; this skill is about *how* to change it safely — investigating before acting, verifying at each step, and committing incrementally so rollback is always possible.

## Input

An approved implementation plan — file path in `$ARGUMENTS`, or in conversation context. If none exists, suggest /spec first.

Before starting, present a quick summary: which fixes, what order, how many files. In an interactive session, get the go-ahead — it's the last gate before code changes begin. On a dispatched task, the approved spec plus the brief is your go-ahead: state the summary in your report and proceed.

## Per-Fix Cycle

For each fix in execution order: investigate, implement, verify, commit. The order matters because each step catches problems the next one can't.

### 1. Investigate

Read the actual code at referenced locations and compare against the plan's assumptions. Plans are written at a point in time — code changes between planning and execution, and an assumption that was true yesterday might not be true now.

**Counteract reason-don't-tool instinct.** The default disposition is to reason from what's already read rather than read more. For refactor work that spans many call sites, that's how under-investigation happens. When the change touches a function used in many places, grep for callers explicitly. When the change depends on assumptions about adjacent files, open those files. Verifying an assumption costs less than fixing the bug it would create.

**Use parallel tool calls for independent reads.** When reading 5 files that don't depend on each other, run them in parallel. Sequential reads are for cases where one read informs the next.

If reality differs from the plan:
- **Minor** (shifted lines, renames, formatting): adapt and note it. No need to pause.
- **Moderate** (new parameters, new callers, refactored structure): the plan's intent is probably still right, but the mechanics need adjusting. In session, report the discrepancy and get a quick sign-off. Dispatched, adapt with judgment and record the deviation — in your report plus the brief's deviations section — so the reviewer can independently judge the call.
- **Major** (code deleted, already fixed differently, significant rewrite): stop. Improvising a fix for code the plan didn't anticipate is how subtle bugs get introduced. Present options to the user.
- **Foundational** (the spec assumes infrastructure, services, or pipeline layers that don't exist): this isn't a discrepancy in the code — it's a prerequisite the spec missed. Follow the prerequisite discovery protocol from the project's CLAUDE.md: record the missing foundation as its own tracked work, park this fix as blocked, report what you found. Slippage signs — sketching a middleware shim, building a workaround layer, dropping an inline substitute to keep the fix moving — are cues you've slipped off this path.

### 2. Implement

Apply the fix. The reason to change only what the fix specifies — no adjacent cleanup, no bonus improvements — is that unplanned changes haven't been investigated or reviewed. They introduce risk that nothing in the pipeline accounts for. Note anything tempting for the handoff instead.

### 3. Verify

Write and run specified tests. If a test fails:
- Implementation bug → fix and re-run
- Test spec seems wrong → report to user, don't silently adjust (the test came from the approved plan, so changing it is a plan change)
- Failure in surrounding code → note as out-of-scope finding

### 4. Commit

One commit per fix or logical group. Include implementation + tests together. Incremental commits mean any individual fix can be reverted without unwinding everything.

Each commit is a natural checkpoint. On long fix stacks, the commit boundary is the right place to consider whether the next fix should land in the same dispatch or a fresh one. If your harness can resume a session, exiting cleanly at a commit boundary beats racing a time box on a multi-fix run.

## Guardrails

These aren't arbitrary rules — they address the specific failure modes that come up most often during implementation.

**The plan is a guide, not a script.** Adapt to what the code actually looks like. But when reality diverges from the plan, raise it rather than quietly improvising — a 30-second conversation is cheaper than undoing a wrong change.

**Stay in scope — but distinguish scope creep from prerequisite discovery.** Scope creep (adding unplanned features, bonus refactors, adjacent cleanup) is how "2-hour tasks" become "2-day tasks" — capture those for the handoff. Prerequisite discovery (finding that the plan assumed infrastructure that doesn't exist) routes through the Foundational discrepancy path above. Slippage sign: classifying a missing prerequisite as "adjacent" and improvising a workaround to stay in scope — that's a cue to stop and route it as a prerequisite instead.

**Fail loudly.** Silent workarounds are the #1 source of bugs that survive implementation. If something unexpected happens — a test fails in a surprising way, a function doesn't exist where expected, a dependency behaves differently — stop and report. The impulse to "just make it work" is strong but dangerous.

**Commit and move forward.** Once you've chosen an approach for a fix, see it through. Revisit decisions when new information directly contradicts your reasoning, and otherwise let the choice ride — reconsidering mid-implementation is how 30-minute fixes turn into 3-hour spirals.

**Track progress.** Create a task per fix at the start, update as they land. This survives context compression and gives visibility into what's done vs. what's remaining — especially valuable in long sessions.

## After All Fixes Land

- Run the full relevant test suite — a fix that passes its own test but breaks something else isn't done
- Done means gates run, green, and cited. A gate you couldn't run (missing env, sandbox limits) is reported not-run — never green — with which gate and why
- Present summary: what was implemented, discrepancies found, deferred items
- List commit range and any out-of-scope findings
- Suggest /post-audit on the changes

## Pipeline

**/audit** → **/spec** → **/execute** (this skill) → **/post-audit**
