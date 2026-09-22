---
name: audit
description: Assess code health before new work begins. Use when a spec, plan, or task is about to be worked on, or when the user asks to "audit this code", "check code quality", "what's the state of this module", "review the codebase", or anything that suggests evaluating existing code before building on it. Even if the user doesn't say "audit" explicitly, trigger this when they're about to start implementation on unfamiliar code. Produces severity-classified findings that feed the /spec skill.
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
---

# Audit

Assess a section of code before new work begins. The goal is an honest picture of what's solid, what's fragile, and what's dangerous — so that whatever comes next (planning, implementation, review) starts from reality, not assumptions.

## How to scope it

The skill works in two modes depending on what's available:

**Spec-driven:** A spec or task is provided. Figure out which files and systems the work will touch, then audit that surface area.

**Directory-driven:** Specific files or directories are given. Audit what's there.

Either way, don't just look at the files pointed at — trace the execution pipeline. A file is only as reliable as what calls it and what it calls. Follow upstream (callers, middleware, hooks), downstream (imports, external calls, data stores), and shared dependencies (utilities, config) until you hit stable boundaries like well-tested libraries or clearly unrelated code.

If the scope grows past ~15-20 files, that's usually a coupling signal worth noting on its own. Prioritize the riskiest paths and show the user the full map so they can confirm where to go deep versus where to note and skip.

**Show the scope map before diving in.** A quick "here's what I found in the pipeline, here's what I plan to audit" avoids wasted effort if the user's mental model of the codebase is different from yours.

## What to look for

Read each file fully — don't infer from names or skim. Evaluate across security, error handling, architecture, data integrity, performance, testing, code quality, and dependencies. Not every dimension matters equally for every file, so spend your depth where the risk is. A utility function needs different scrutiny than an auth middleware.

## Coverage and depth posture

These shape how the rest of the skill operates.

**Report every finding worth surfacing**, including low-confidence and low-severity ones. Tag confidence and severity so downstream filtering can rank — coverage gives the user the full picture. The cost of a false-positive flag the user dismisses is low; the cost of a real bug you didn't surface because it felt minor is high.

**Investigate broadly before judging scope.** Trace every changed function's callers and every called function's contract. Use grep liberally to verify claims hold across call sites — reading one file in isolation misses second-order effects. Pre-filtering on what feels important is how real findings get cut at the wrong stage.

**Reason from the foundation.** This audit informs work that builds on the audited code. Surface what would compound (good primitives to build on) vs what would create debt (patterns to avoid replicating). Sweet-spot engineering matters more than passing tests — a module that passes tests but is brittle to extend is information the next /spec author needs.

**Use parallel tool calls for independent reads.** When fanning across 5 files that don't depend on each other, run them in parallel. Sequential reads are for cases where one read informs the next.

## Classifying findings

**Severity:** Critical (actively dangerous) / High (significant risk) / Medium (maintenance burden) / Low (cleanup)

**Category:** `security` / `error-handling` / `performance` / `architecture` / `data-integrity` / `testing` / `code-quality` / `dependency`

## Report path

Write findings to a path relative to the repo root (your cwd at dispatch time):

- **If a draft spec exists** for the work being audited — i.e., you're verifying spec assumptions against current code (a "spec-review" or "frontrun" audit) — write to `./docs/audits/spec-review/<task-id>-<slug>.md`.
- **Otherwise** (investigative audit, post-merge fresh look, bug-report scoping, discovery for future spec) — write to `./docs/audits/pre-audit/<task-id>-<slug>.md`.

Create the parent folder if it doesn't exist: `mkdir -p $(dirname <path>)`.

A dispatch brief may override this path; if it does, follow the brief.

## Output

**Executive Summary** — 3-5 sentences answering "is this code healthy to build on?" with severity counts.

**Findings** — Ordered by severity, then relevance to the spec if there is one. Each finding:

```
### [SEVERITY] Short description
- **Location:** file, function, line range
- **Category:** one of the above
- **What's wrong:** Concrete, referencing actual code — not abstract concepts
- **Why it matters:** What breaks or degrades if this isn't addressed
- **Recommended fix:** Specific enough that someone can act on it without re-reading the whole file
- **Effort:** small (<1hr) / medium (1-4hr) / large (4hr+)
```

If there are more than ~10 findings, detail the critical/high items and summarize the rest as patterns with representative examples. A 30-item list where most are medium/low dilutes the important stuff.

**Exception:** findings that reveal missing foundation or prerequisite gaps (services that should exist but don't, pipeline layers the upcoming work assumes, architectural templates absent from domains that need them) always get detailed regardless of count or severity classification. These affect sequencing decisions, not just code quality — they can turn a planned spec into a prerequisite chain, so they get their own finding entries with full detail so /spec can route them through the prerequisite protocol.

**Patterns Assessment** — This section matters a lot for downstream work. It answers "when someone builds on this code, which patterns should they follow and which should they break from?"

- **Worth following:** Name the pattern, point to a good example, explain why it's sound
- **Avoid replicating:** What's wrong with the pattern, what to do instead
- **Missing:** What the codebase should have but doesn't

If the code is genuinely healthy, say so directly. A short report that says "this area is well-maintained, here are two things to be aware of" is more useful than padding with low-severity findings to seem thorough.

## Pipeline

This skill feeds → **/spec** → **/execute** → **/post-audit**
