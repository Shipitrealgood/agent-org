---
name: post-audit
description: Adversarial review of recent code changes — find what's broken, what's fragile, what the implementer missed. Use after implementation completes, when the user says "review this change", "post-audit", "check what was just built", or provides a commit range, branch, or file path for review. Also trigger after /execute finishes. This is the evaluator — it assumes the implementer was focused on making things work and missed second-order effects.
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
---

# Post-Audit

Adversarial review of work that was just completed. The goal is not to confirm correctness — it's to find what's wrong, what's fragile, and what could be better. Assume the implementer (human or agent) was focused on making their change work and may have missed second-order effects.

## Scope

`$ARGUMENTS` determines what to review: commit range (`HEAD~3..HEAD`), branch name (diff against main), file path, or description. Default: last commit. Start with `git log` and `git diff --stat` to understand the shape before reading code.

## How to approach it

**Understand before judging.** Read the full diff, then read each changed file in full — not just the changed lines. Changes that look correct in isolation often break assumptions 50 lines away. Articulate the intent before hunting bugs: "this change does X because Y, touching files A, B, C."

**Verify contracts.** Every function has implicit contracts that callers depend on. For each changed function: find all callers (grep for imports, references). If signatures changed, do ALL callers handle the new shape? Trace a concrete value through the full transformation chain — DB → service → API → consumer. Does meaning survive every layer? This is where semantic bugs hide.

**Coverage posture.** Report every finding including low-confidence ones. Tag confidence and severity so downstream filters rank — narrow filtering at this stage drops real bugs. The skill's job is finding what the implementer missed; coverage is how that job gets done.

**Use parallel reads and grep liberally to verify cross-file assumptions.** When checking that a renamed function has no lingering references, grep across the whole codebase, not just the diff's neighborhood. When verifying a removed flag is truly removed, search test fixtures, docs, config files. The change you're auditing has a blast radius — trace it.

**Hunt what the implementer didn't think about.** Implementers focus on making things work; second-order effects get deprioritized in the moment. Semantic drift across layers, contracts callers depend on, default values that were correct before but wrong now — these are exactly what slips through. Investigate them explicitly, not just the happy path.

**Hunt for specific bug classes.** These are the patterns that most often survive code review:

- **Directionality and ordering** — is direction preserved through every layer? Is the ordering in a `.slice(0, N)` meaningful or accidental? If upstream ordering changed, the slice returns different items now.
- **Silent fallbacks** — every `?? default`, `|| fallback`, `catch` that returns a value instead of throwing. Was the fallback correct before the change? Is it still correct after? Default values that made sense for type A may be wrong when the function now sometimes returns type B.
- **Shared state and concurrency** — does the change assume sequential execution that isn't guaranteed? Could another concurrent operation see partially-updated state?
- **Type and shape mismatches** — if a data structure changed, are ALL producers and consumers updated? TypeScript types can lie when `as any` is involved.
- **Boundary conditions** — empty collections, null inputs, single-element arrays, zero values. Does the change handle the edges the happy path doesn't exercise?

**Assess quality beyond correctness.** This is where post-audit earns its breadth — not just "is it broken?" but "did it make the codebase better or worse?" The implementer was focused on making things work, which means quality concerns get deprioritized in the moment. Look for:

- **Divergent implementations** — does the change reimplement something that already exists elsewhere in the codebase? A new helper that duplicates an existing utility, a private function that diverges from a public one doing the same thing. These become consistency bugs over time.
- **Unnecessary abstraction** — wrappers that add no value, config for things that never change, patterns cargo-culted from a different context.
- **Mixed concerns** — business logic in a data access layer, rendering logic in a service, orchestration in a component.
- **Performance** — N+1 patterns, unbounded fetches, expensive operations in loops, widget rebuild patterns where mutation would work. Be proportionate — don't flag theoretical issues at scales that don't exist.
- **Naming accuracy** — did the change make existing names misleading? A function called `getUsers` that now also fetches permissions is a future bug for the next reader.
- **Test coverage gaps** — especially for the logic paths where bugs were found. If the audit surfaced bugs in dispatch logic, the absence of dispatch tests is a finding, not just a nice-to-have.

## Report

**Critical** — will cause incorrect behavior, data corruption, or user-facing bugs. Include: exact file and line, what the bug IS (concrete, not hypothetical), a traced example showing the failure, suggested fix.

**Structural** — the implementation works but is built on a workaround, shim, or alternative approach because the correct foundation didn't exist. Examples: response-level middleware instead of service-layer hooks; inline substitutes for a service that should have been built first; conditional branches papering over a domain that never got the reference implementation. These aren't bugs in the current code — they're sequencing signals. Include: location, what the workaround is, what the correct foundation would be, and why the fix belongs upstream. Route through the project's CLAUDE.md prerequisite discovery protocol so the foundation lands first and the workaround unwinds as a follow-up.

**Important** — degrades quality, performance, or maintainability but doesn't cause immediate failures. Include: location, what's wrong, the better approach.

**Minor** — tech debt worth tracking. Brief description is sufficient.

**What's done well** — genuine strengths, not filler. Recognizing good patterns helps them propagate.

### Residual disposition table (mandatory for ≥ Medium/Important)

Every finding ≥ Medium/Important (Critical / High / Important / Medium / Structural / Blocker) must carry an explicit ruling marker **on a declaration line of that finding** — its heading, or a residual/routing-table row whose first cell is its id:

- a tracked work item: `#NNNN` or `rides #NNNN` (issue ID, or an entry in your backlog doc), **or**
- explicit ruling: `won't-fix` · `withdrawn` · `fix in lane` / `fix-in-lane` (fixed on the branch before merge) · `landed` · `closed` (these are **rulings, past tense** — write them only when true; "to be landed later" is not a ruling and must not appear on a declaration line).

**Declaration vs reference:** a finding is DECLARED by a heading/bullet/bold line whose content **starts** with the id token (`M-1 (Medium) — …`; `**`/`~~` decoration, a `[severity]` bracket tag, or the word `Finding` before the id are fine), or by a table row whose **first cell** is the id. Mentioning an id mid-sentence, in a verdict line, a gate-result row, or a counts summary is a REFERENCE — references are never scanned and never satisfy. The disposition may live on ANY declaration line of the finding (heading-declared + table-dispositioned is the normal shape); prose-only dispositions (`project-task`, `fast-follow`, `board it`) remain **invalid**.
**Ids:** give findings severity-bearing ids (`C-1`, `H-2`, `M-3`) so a lint can tell a ≥Medium finding from a Minor one without reading prose. Reserve a separate prefix (e.g. `MUT-n`) for mutation probes so they're never mistaken for findings.
Enforce this with a doc-lint test over `docs/audits/post-audit/` that REDs any bare ≥M finding (grandfather docs dated before you adopted it — do not rewrite history). The precise declaration rule above exists so the lint can be mechanical. Safe without markers: flowing prose, fenced blocks, inline-code quotes, and references as defined above. Give the lint a `(no-finding)` escape for genuine over-matches, but a conformant doc should not need it — treat writing one as a signal to check your finding's shape. Body finding rows rule; quality-footer C/H/M/L counts are not authoritative.

## Report path

Write findings to `./docs/audits/post-audit/<task-id>-<slug>.md` — relative to the repo root (your cwd at dispatch time). Post-audits commit with the branch they audit, so they travel through merge and live in the repo's history alongside the code.

Create the parent folder if it doesn't exist: `mkdir -p ./docs/audits/post-audit`.

A dispatch brief may override this path; if it does, follow the brief.

## Rules

**Be skeptical of clean reports.** If you're about to file zero findings, double-check coverage: re-read the diff, verify you traced callers, confirm boundary cases were considered, grep for the modified function across the codebase. A genuinely clean change deserves a short positive report — and that report carries weight only when it lands after honest coverage.

**Evidence over opinion.** Every finding must reference specific code, trace a concrete example, or cite a violated pattern. "This could be a problem" without evidence is noise.

**Proportionality.** Scale depth to the blast radius of the change. A 5-line fix doesn't need the same scrutiny as a 500-line feature.

**Check assumptions before reporting.** Verify the bug is real — read the code, grep for the function, confirm the caller actually calls this code. False positives erode trust.

## Pipeline

**/audit** → **/spec** → **/execute** → **/post-audit** (this skill)

Critical findings go to immediate remediation. Structural findings trigger prerequisite discovery — record the missing foundation as blocking work, and mark the original work for revisit once the foundation lands. Important and Minor findings feed the next /audit cycle.
