---
name: preflight
description: Check whether upstream decisions are resolved before writing or executing a spec. Reads your idea threads, design notes, and decision docs to surface unresolved dependencies. Use before /spec or /execute when the work touches concepts that might still be in motion. Also trigger when the user says "are we ready to build this", "what needs to be decided first", "preflight this", or expresses uncertainty about whether foundational thinking is done. This skill prevents building on sand.
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
---

# Preflight

Check whether the thinking is done before the building starts. Specs can be technically sound but premature — if the decisions they depend on are still developing ideas, executing them builds on assumptions that might shift.

This skill reads the idea and decision landscape and answers: are the upstream decisions this work depends on actually resolved, or are we about to build on something that's still in motion?

## Input

A spec, task, plan, or description of work being considered — in `$ARGUMENTS`, conversation context, or a file path. If nothing specific is provided, ask what work the user is considering.

## How it works

### 1. Understand what's being built

Read the spec or task. Identify the key concepts, architectural assumptions, and design decisions it depends on. A spec for "agent user profiles" implicitly depends on decisions about auth models, permission systems, agent lifecycle — even if it doesn't reference them by name.

### 2. Survey the decision landscape

Read the relevant parts of wherever your thinking lives (configure these paths for your setup — a notes vault, a `docs/decisions/` dir, an ideas repo) to check whether those upstream concepts are resolved:

- **Idea threads** — a running log of ideas with a maturity level each. A thread at "seed" or "developing" that's upstream of this spec is a flag.
- **Domain ideas** — forming ideas that overlap with the spec's assumptions.
- **Decision docs** — docs that have already resolved the question. An architecture doc marked "decided" is settled ground; one still accumulating notes is not.
- **Domain overviews** — current state and build sequence, checked for conflicts or gaps.

Don't read everything — trace from what the spec needs to what the folder says about those topics. Follow the connections.

### 3. Survey the code landscape

Decision-level preflight isn't enough: a spec can pass the decision check and still require workarounds because the codebase doesn't contain the infrastructure the spec assumes. Read the actual code for the surface the spec will touch.

- If the spec assumes specific services, pipeline layers, shared components, or cross-cutting hooks (audit logging, event emission, permission checks, transaction boundaries) — open the files at the integration points and verify they exist. Spec assumptions get verified against the code, not taken on faith.
- If the spec applies a pattern across domains (e.g., rolling an architectural template out to new modules), spot-check whether the target domains have absorbed the template. Domains that should have read services, event systems, or pipeline layers but don't are a **prerequisite gap** — treat them with the same weight as a decision gap.
- Prerequisite gaps at this layer block the spec the same way unresolved decisions do. Surface them in the same report.

### 4. Assess readiness

For each upstream dependency found (decision or code), classify it:

- **Resolved** — decision is made (or code exists), documented, and the spec aligns with it. No action needed.
- **Crystallizing** — the idea is close to ready but hasn't been committed to. The spec could proceed but should explicitly state which way it's betting, so it can be adjusted if the idea lands differently.
- **Unresolved (decision)** — the idea is still developing or seed-stage, and the spec builds on an assumption about how it'll land. This needs a decision before the spec is safe to execute.
- **Unresolved (code)** — the decision is made but the code infrastructure the spec assumes doesn't exist yet. The prerequisite work lands first via the project's CLAUDE.md prerequisite discovery protocol; the spec resumes once it's in place.

### 5. Report

**Clear** — upstream decisions are resolved. Proceed with /spec or /execute.

**Proceed with awareness** — some upstream ideas are crystallizing. List them, state what the spec assumes about each, and flag what would need to change if the idea lands differently. The user decides whether to proceed or wait.

**Blocked** — one or more foundational decisions haven't been made, or prerequisite code infrastructure the spec assumes doesn't exist. Either would force the spec to build on assumptions that could require significant rework. List what needs to be decided or built first, suggest an order (decisions before code, some decisions depend on others), point to where the thinking lives for decision gaps, and record prerequisite code work as tracked items (per the project's CLAUDE.md prerequisite protocol) for code gaps.

Keep the report tight. The value is the list of "decide this first" items with clear reasoning — not a comprehensive survey of every idea thread.

## What this skill is NOT

- **Not an audit.** It doesn't evaluate code quality. /audit does that.
- **Not a spec review.** It doesn't check whether the spec's approach is architecturally sound. /spec does that.
- **Not idea cultivation.** It doesn't advance or mature ideas — `/big-brain` can push a stuck thread forward.
- **It's the bridge between thinking and building** — making sure the thinking layer has done its job before the building layer takes over.

## Pipeline

**/preflight** (this skill) → **/spec** → **/execute** → **/post-audit**

Or when a spec already exists: **/preflight** → **/execute**
