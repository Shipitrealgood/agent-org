# Agent-Org Operating Principles

Five principles distilled from running a multi-agent engineering org on a production codebase: an organizing pass → a five-vein planning fan-out → converge → wave launches → cross-harness tests (the same boot images run on a non-Claude harness). They are the *why*. Boot-image handoffs: [`agent-handoff-prompting.md`](agent-handoff-prompting.md) + `/handoff-prompt`.

## 1. Ground-truth-first planning SHRINKS the work

Verification pays in scope, not just correctness. Stale beliefs inflate scope more than reality does: of five vein planning passes run against actual code, four came back *smaller* than the tracked plan believed (mechanisms already existed, prerequisites already solved, "greenfield" work already substrated). **Habit:** when a body of work feels big, the cheapest attack is a grounding pass — an hour of read-only agents routinely buys back days of imagined work.

## 2. Process narrows the capability gap — spend the strongest model only where it binds

A weaker model + the boot-image pattern + verified ground truth produced output at parity with the strongest model, because grounding and compiling are checklist-shaped, and checklists don't need genius. **Routing rule:** reserve top-tier models for genuinely open-ended judgment (design forks, adversarial review, rulings); let structure carry the structured work. Corollary: investment in patterns/skills/docs is capability you buy once and every model inherits.

## 3. Authority = provenance (universal trust rule, not just prompting)

Any artifact — brief, ruling, spec, report, prompt — earns execution-without-re-derivation only by being spot-checkably true: dense with citations (file:line, IDs, hashes) that a receiver can verify. Plausible-but-unverified specifics are worse than vagueness — they confidently mislead. **Habit:** before trusting any artifact from any agent, ask for the citations and check two. Before authoring one, verify every specific or label it UNVERIFIED. Never author from an ungrounded state.

## 4. The human's ruling bandwidth is the system's scaling limit — guard the patterns that protect it

Defaults-with-one-word rulings · decision digests batched at checkpoints · escalation classes defined narrowly (unratified product shape, marked decisions, irreversible actions) · everything else ruled by conductors method-first and recorded. These exist so thirty merges need eight words. **Watch-signal:** feeling like a queue means the fix is more checkpoint batching and clearer defaults — not more sessions asking less.

## 5. Keep the system self-describing — it decays one uncommitted decision at a time

The real product of an organizing pass is that every chat window could close and the operation reconstructs from committed docs + the tracker. That property is an invariant to *maintain*: every roadmap, ruling, and structural decision gets committed to the doc chain or the tracker the moment it's made — chat is where decisions happen, never where they live. **The practice is one question, asked constantly: "is this notated, or just typed here?"**
