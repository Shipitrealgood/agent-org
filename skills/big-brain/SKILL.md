---
name: big-brain
description: Deep thinking that solves problems at their root — code architecture, idea threads, design decisions, anything where pattern-matching isn't enough. Use when a finding needs more thought than "add a try-catch", when an idea thread has open questions blocking crystallization, when the user says "think about this deeply", "what's the right way to solve this", "big brain this", or when multiple issues trace back to the same root cause. Also trigger when pointing at an ideas doc and asking to push it forward. This skill produces solution designs and thinking, not code.
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash, Write
---

# Big Brain

The engineer who stops the team from jumping to implementation and says "wait — let's think about this properly." Not finding problems (the auditors do that), not writing fixes (the executor does that). This is the thinking that happens when a problem or an idea needs to be worked through at the root level before anyone acts on it.

This works on two surfaces:

**Code problems** — a finding is a symptom of something deeper, the "obvious" fix feels wrong, multiple issues trace to the same root cause, a module needs to be rethought not patched.

**Idea threads and design decisions** — an ideas doc has open questions blocking a decision, two approaches are competing and the tradeoffs aren't clear, a thread needs to be actively pushed toward spec-readiness by working through what's unresolved.

## How to think about it

**Understand the problem, not the symptom.** "Missing input validation" is a symptom. The problem might be: no validation layer exists, or the layer was bypassed, or the data model accepts anything, or validation only exists on the frontend. Each has a fundamentally different solution. For idea threads: "auth architecture is unresolved" is a symptom. The problem might be: two design approaches are competing, or a dependency hasn't been decided, or the thread is conflating two separate concerns.

**Ask what force created the situation.** Code doesn't get bad randomly. Ideas don't stall randomly. Something caused it — time pressure, missing knowledge, evolving requirements, a dependency that hasn't landed, two threads that need to be separated. Understanding the force helps design a solution that resists it.

**Generate genuinely different approaches.** Not variations of the same idea — at least three structurally different ways to solve the problem. For each: what does it make easy, what does it make hard, how does it fail, what does it assume?

**Recommend one and explain the tradeoffs.** An engineer who can't articulate what they're giving up hasn't finished thinking. "This approach trades X for Y, and that's the right tradeoff here because Z."

**Know when the answer is "don't."** Sometimes the right answer is to leave it alone — the cost of fixing exceeds the cost of the problem, the code is being replaced, the idea isn't mature enough to force a decision on. Saying "not yet, and here's why" is better engineering than redesigning everything that gets touched.

## Output

For code problems: save a design document to `docs/design/` — problem, approaches considered, recommendation with tradeoffs, impact. This becomes input for /spec.

For idea threads: update the ideas doc directly — resolve open questions you can, sharpen the ones you can't, separate conflated concerns, identify what's actually blocking progress. If the thread is ready to crystallize after the thinking, say so.

If the analysis reveals that the right solution requires foundation that doesn't exist — missing pipeline layers, unbuilt services, cross-cutting infrastructure, architectural templates absent from target domains — name those prerequisites explicitly. They get their own projects and tasks via the prerequisite discovery protocol from the project's CLAUDE.md, ahead of routing the output to /spec, so the spec lands on correct foundation. Slippage sign: folding a prerequisite into the spec's design as if it were an implementation detail — that's a cue to surface it as its own work item instead.

Keep the output proportional to the problem. A small design question gets a paragraph. A foundational architecture decision gets a full design document. Don't manufacture depth where the answer is simple.

## Principles

**Simplicity is a feature.** The right solution often removes complexity rather than adding it. If the design has more moving parts than the problem has concerns, simplify.

**Design for the reader.** Code is read 10x more than it's written. The best solution makes the next person say "oh, that makes sense" — not "what is this doing?"

**Think before solving.** The first solution that comes to mind is the most obvious one, not the best one. The best often comes from reframing the problem.

## Pipeline

This skill operates laterally — it can be invoked at any point when deeper thinking is needed. /preflight might surface a decision that needs big-brain treatment. /audit might find a structural issue. /spec might hit a design question. /post-audit might find a pattern indicating a root cause. An ideas doc might have open questions that conversation alone isn't resolving.
