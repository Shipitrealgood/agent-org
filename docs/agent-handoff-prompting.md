# Agent Handoff Prompting — the conductor boot-image pattern

Distilled from the vein-session prompts of a multi-agent campaign and a cross-harness handoff to a non-Claude coding agent. Harness-agnostic: the pattern produced equivalent-quality prompts for Claude conductors and a different vendor's pipeline session by design, not luck.

## The theory: a handoff prompt is a boot image, not an instruction list

A fresh agent fails in exactly four ways. Every section of a good handoff loads the model that prevents one of them:

| Failure mode | What loads it correctly |
|---|---|
| **Wrong world model** — doesn't know the true state | Grounded pointer chain + "X = live truth" conflict rule |
| **Wrong authority model** — silently decides what it shouldn't, or stalls asking what it owns | Explicit decision calibration, defined by CLASS |
| **Wrong quality model** — its default bar isn't yours | The bar stated as mechanisms/gates, not adjectives |
| **Context decay** — loses the plot over a long arc | Goal + outcome shape (a self-check oracle) + trail requirements |

## The prime rule: authority = provenance

**A prompt's authority comes from being checkably true, not from confident prose.** Dense specifics — task IDs, comment citations, file paths, verified bug repros, the target harness's actual skill names — are compressed *verified claims*. The receiving agent spot-checks a few, finds them true, and executes the rest instead of re-deriving. The same prompt written from imagination, with plausible-but-unverified specifics, is WORSE than a vague one: it confidently misleads.

Therefore: **never author a handoff from an ungrounded state.** Ground first — reconcile against the code, the doc chain, your tracker if you have one, and the target's own harness — then compile the prompt from what you verified. If you don't have grounded context, the first deliverable is a grounding pass (fan out read-only agents to reconcile), not a prompt. The prompt-authoring session is doing *compilation*: verified context in, boot image out. This is why prompts written mid-organizing-session outperform prompts written cold.

Corollary: every specific in the prompt must be one you (or a verified sub-report) actually checked. An unverified claim gets labeled UNVERIFIED or cut.

## Anatomy (in order — each section earns its place)

1. **Role + ownership contract** (1–2 sentences). Who the agent is, what it owns, what it NEVER does ("you grade, gate, and merge — you never implement"). Negative space is as load-bearing as positive. For cross-harness pastes this includes **stopping conditions** — when the session ends (see the harness-disposition inventory below).
2. **Orientation pointer chain.** Ordered reading list, in dependency order of understanding (operating model → map → mission plan → current state). The prompt carries pointers, not payload — depth lives in durable committed docs so the prompt stays short and rot-resistant. Include the conflict rule: which source is live truth when sources disagree.
3. **Session goal + outcome shape.** What done looks like IN ARTIFACT TERMS ("three specs ratified-by-full-read, then four chuck-gated merges"; "the boundary brief produced and ENG-ratified"). This is the agent's self-check oracle for hour six.
4. **First act** — when one exists, name it and mark it non-negotiable ("full ratification reads BEFORE any dispatch"). The first act is where inherited-context failures concentrate.
5. **Queue with reasons.** Ordered work WITH the why per ordering constraint ("Lane A first and ALONE because CI config collides with everything"). Reasons let the agent re-derive correctly when ground shifts; bare orderings get cargo-culted or abandoned.
6. **Decision calibration.** What the agent rules itself (and how to record it — method-first: objective → reasoning → result), what escalates to the human, defined by CLASS not enumeration ("unratified product/domain shape") so novel cases route correctly. Include: "defaults/plans are proposals until ratified." Widen or narrow the class per mission and SAY so (the OSS-surface session got "the public surface IS product shape — everything about it escalates").
   **Merge/branch authority is never inherited.** Every charter states where work lands and who merges: the branch, the merge mechanics, and whether the agent merges or presents. A charter SILENT on merge authority defaults to: land each unit on its feature branch, gate it there, and present the merge-ready set with the session index — the owner (or named reviewer) merges. "Merge per repo convention" is not a grant; it is the silence this rule exists to catch.
7. **Watch items.** Only the verified traps and cross-boundary seams THIS mission will hit, each with its consequence ("green-against-old-trunk is not green"). Point-of-use stop markers for the sharpest hazards ("if ambiguous AT ALL, stop and raise") belong pinned on the work item itself, not only in the prompt — agents weight in-context markers heavily.
8. **Trail requirements.** What evidence the session must leave (records on tasks, merge records, honest artifacts) — this is what makes session N+1 and any grader/reviewer possible. For evaluation runs: "don't self-grade; make the trail honest." Calibrate artifact length to what each one has to carry: cover the substance, skip filler sections, redundant summaries, and boilerplate. A close doc or digest that reads long costs the next session the time it was written to save.

## The native-harness rule

Before prompting a different agent/harness, READ its skills, subagent roster, and conventions — then map your intent onto ITS verbs. Invoke its skills by their real names; do not restate what its own skills already encode (the cross-harness handoff omitted the quality-bar prose because the target's own pipeline skill carries stage-separation natively — restating it would fight the harness and contaminate any evaluation of it). The handoff supplies mission, grounding, calibration, and trail requirements; the harness supplies method.

**The harness-disposition inventory (converse rule; the under-run class).** Your OWN harness also supplies things invisibly — session ownership and stopping conditions (work the queue until drained or blocked; a completed unit is not a stopping point; never ask "continue?"), autonomy grants, turn discipline — and a boot image authored from inside that harness inherits them without anyone writing them down. Porting the mission layer without the disposition layer is how the cross-harness session ran one excellent unit of a full-queue session and then stopped to ask: no layer — target harness, paste, or pointed doc — stated when the session ends (the operating model describes session *shape*, not session *ownership*). A cross-harness boot image is complete only when it is self-describing down to disposition: carry an explicit **Session ownership (stopping conditions)** paragraph, and audit the paste with "if this ran on a bare model with no system prompt, what load-bearing behavior would be undefined?" The target harness's own skills you still omit per the rule above — but never assume any harness supplies disposition. Corollary: the less the target model shares your harness's trained defaults, the more its output quality is a function of the paste — written process is the equalizer, so anything load-bearing that lives as disposition on your side must live as text in the handoff.

## The factoring rule

Split invariants from mission deltas: one COMMON BLOCK (role frame, loop, calibration, bar, tool mechanics, shared traps) + thin per-mission blocks. One maintainable source instead of N drifting copies. Commit prompts as versioned artifacts in the repo's doc chain — they are part of the system, not chat ephemera, and get re-issued/updated at converge checkpoints.

## The dispatch contract — the pattern at SUBAGENT scale (the "dispatch-six")

A subagent dispatch is the same boot problem with three flips: the author SURVIVES (so the conductor curates a verified slice instead of a pointer chain — inject only facts you checked; injecting beliefs is how an unverified premise becomes a subagent's ground truth), the RETURN is half the prompt (the conductor's gate is bounded by the return's verifiability — demand claims-with-citations), and VOLUME means the form must be internalized once, not performed per dispatch. Authority collapses to one rule: **subagents return questions, they don't resolve them.**

Every dispatch carries six things:
1. **Role + unit scope**, incl. negative space ("read-only; no tracker writes; no commits").
2. **Curated verified grounding slice** — pinned ABSOLUTE paths (the #1 failure: wrong checkout), the 2–4 docs/tasks to read, only dispatcher-verified facts; flag your own uncertainties AS questions ("verify whether X is already satisfied"), never as premises.
3. **Deliverable contract** — exact artifact/format/destination ("final text IS the report, sections A/B/C" / "write to <path>, no commits") + every claim cited (file:line, IDs) so the parent can spot-check.
4. **Constraints** the unit touches (no installs, worktree-only, forbidden resources).
5. **Escalation = return:** "anything not clearly resolvable comes back as a named open question with options — never a silent guess." This is the most-dropped line under load; never drop it.
6. **The 2–3 traps this unit will actually hit** — not the whole trap list.

Receiver-side defense (belt): subagent definitions open by restating scope/paths/deliverable as understood, state assumptions explicitly where the dispatch was silent, and return ambiguities unresolved. Assumption-statements in reports are the dispatch-quality telemetry.

## Style

Dense, complete sentences; every sentence load-bearing. Canonical IDs and names everywhere (never ranges — a "#43–#54" range once hid a completed task; explicit sets don't). One concept per clause. Bold the genuinely non-negotiable, sparingly. Consequences stated with mechanisms, not intensity ("a HALT is not self-clearing" beats "be very careful").

## Anti-patterns

- **Ungrounded authoring** — plausible specifics that weren't verified (the fatal one).
- **Payload stuffing** — pasting the knowledge into the prompt instead of pointing at committed docs; rots immediately and bloats the boot.
- **Unstated authority** — the agent either guesses your decisions (and writes the guess back as fact) or queues everything on you (stall).
- **Virtue prompting** — "be rigorous/careful/thorough" instead of mechanisms and gates.
- **Restating the target's own skills** — fights the harness; invalidates harness evaluation.
- **Orders without reasons** — cargo-culted until ground shifts, then wrongly abandoned.
- **Chat-ephemeral prompts** — uncommitted prompts can't be re-issued, versioned, or maintained.
- **No outcome shape** — the session can't tell drift from progress.

## Skeleton

```
You are <role> for <mission>. You own <X>; you never <Y>.
Orient in order: <doc 1> → <doc 2> → <mission plan> → <current-state source>. <Live-truth rule.>
Session goal: <outcome in artifact terms>.
FIRST ACT (<non-negotiable if so>): <the act + why>.
Queue: <ordered items with the why per constraint>.
Decisions: rule <class> yourself, method-first, recorded on <where>. Escalate exactly: <classes>. Defaults are proposals until ratified.
Watch: <verified traps + seams this mission hits, each with its consequence>.
Trail: <what evidence the session must leave>.
```
