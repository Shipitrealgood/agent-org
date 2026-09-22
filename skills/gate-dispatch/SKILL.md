---
name: gate-dispatch
description: >
  Author a high-quality dispatch prompt for a verification gate (chuck) or any
  worker subagent. Use when dispatching a post-implementation review, re-gate,
  fix-in-lane, or executor lane and the dispatch should carry exactly the
  context that changes the agent's behavior. Derives the verification checklist
  mechanically from the unit's paper trail instead of improvising it. Triggers:
  "dispatch chuck", "write the chuck prompt", "gate dispatch", "dispatch the
  reviewer/executor for #NNNN".
metadata:
  short-description: "Derive a gate/worker dispatch from the unit's paper trail"
---

# /gate-dispatch — the dispatch is a derivation, not a composition

The dispatcher's only advantage over the subagent is context. The dispatch's job
is to transfer exactly the context that changes the agent's behavior — and
nothing else. Everything below is a transform over sources you already have;
if you find yourself inventing checklist items from imagination, stop and go
read the paper trail instead.

## The five-step derivation

**1 · Harvest the obligation inventory from CURRENT acceptance.** Read the
unit's ENTIRE paper trail — spec acceptance criteria, every recorded ruling
(always read comments; the thin card lies), amendments,
the executor's build report, prior gate rounds — and resolve superseded rulings
before you write a line. Each CURRENT acceptance line, and each claim a current
line depends on, becomes one verification obligation: *assess it independently;
the claim is not evidence.* Prior gate rounds, prior mutation runs and
intermediate reports are context, not obligations — verification scope comes
from what the unit must satisfy NOW, not from everything anyone ever checked. Attach provenance
to each point (comment id, spec §) so the gate can pull context itself. Completeness
check, both ways: an acceptance line with no obligation is a hole; an obligation
with no current acceptance line is busywork — drop it or raise it as a named
question.

**2 · Adversarialize each obligation.** For each claim ask: *how could this be
green but false?* Write that specific hunt into the dispatch, not just
"verify X":
- Hand-copied test matrix that goes stale → "the matrix must DERIVE from the
  real source set; enumerate it from code, not from the test file."
- Test that cannot fail → "prove non-vacuity with the cheapest discriminating
  control INSIDE the suite: a negative input the code must refuse, a real-DB
  constraint backstop, or an embedded comparator / two-sided pin (a non-default
  value a dropped carry cannot match)." An external source mutation or fault
  injection only for a NAMED risk no inline control reaches (e.g. a race that
  needs a forced interleaving), from a finite list in the dispatch, within the
  controls budget (<=2x the unit's acceptance items; more needs a recorded scope
  amendment naming the invariant), one owner per mutant (executor OR gate, never both).
- Vanishing coverage → "suite/test counts vs baseline; any DROP is a finding."
- Guarded invariant → "try to construct a bypass" (name the layers: schema,
  service, repository, DB).
- Mock where reality matters → "prove it on the real substrate" (real database
  constraint errors, real row-level security, real package install — never a
  lookalike).
This step sets the gate's quality. "Verify X" buys a re-run of the executor's
tests; naming the false-green shape buys a proof.

**3 · Fence the settled.** Every RULED/RATIFIED decision the gate could
plausibly trip over gets an explicit fence: "settled (comment NNNN), cite don't
re-litigate — if you believe the ruling is wrong, say so as a NAMED QUESTION
with evidence, not as a finding." Provisional rulings are the opposite: mark
them "confirm or refute — not settled." Fences save rework rounds and keep
authority = provenance.

**4 · Filter the trap store by touched surface.** Sweep project memory, the
current handoff's traps section, and your CLAUDE.md; keep every trap
whose trigger surface this unit touches. State each as *signature →
diagnosis*, e.g. "module-not-found / 0-tests-collected = environment diagnosis
FIRST, defect second", "a test runner that needs an env flag it wasn't given — environmental",
"a pruned worktree silently makes `git -C` operate on the main checkout." Pre-classify known-red gate records
(with their tracking IDs) so the gate doesn't burn a loop rediscovering
already-tracked defects — and draw the line: "anything beyond these is a new fact;
chase it."

**5 · Pin the mechanics** (the dispatch-six, `docs/agent-handoff-prompting.md`):
- **Role + scope + negative space** — what it is, what it reviews, what it
  must NOT do (merge, push, mutate the lane, touch live DBs, widen scope).
- **Grounding slice** — absolute paths + SHAs, verified live before sending;
  which docs/comments to read, in what order. Note trunk movement since the
  lane branched and whose job the merge is.
- **Deliverable contract** — severity classes, file:line cites, concrete
  failure scenario per finding, incremental report (doc early, backfill
  numbers), pinned output path, model attestation at the end.
- **Constraints** — resource rules that bind here: the repo's canonical test script over
  hand-rolled runners, one heavy test run at a time, fresh DB substrate, env contract
  satisfied never weakened. Long-running test runs: launch DETACHED (setsid,
  log to disk), CONFIRM LIVENESS (first real batch line in the log, never just
  a START banner), then deliberately END YOUR TURN — the dispatcher watches the
  log and wakes you when the run exits. This is the designed handoff, not a fallback: detached
  children cannot wake a stopped agent, and "I'll poll" has failed three of
  three times in practice. The dispatcher owns a watchdog per run
  (tracked background loop on the log + a silent-death check on the process).
- **Escalation** — named question + options + recommendation; never a silent
  guess, never fix-while-in-there.
- **Traps** — the 2–3 from step 4 this unit will actually hit.

## Redispatch rule

A dispatch is a snapshot — on resume or re-gate, fold in everything that moved
since (new rulings, trunk movement, environment changes, newly tracked
defects) as an explicit "context updates, all binding" block. Never resend a
stale dispatch verbatim.

## Chuck-specific stance (verification gates)

- The executor's self-review is never input. Executor mutation or battery
  claims are ASSESSED, not re-run by default: check the receipt (applied-diff
  proof, RED against a green unmutated baseline, exact-restore hash, pin and
  environment continuity to the review pin); re-run only when the receipt fails
  that check or a current acceptance line cannot otherwise be discharged. Never
  re-run a superseded experiment to re-establish an old claim.
- Independence is a second mind on this commit, not a second full test
  campaign: the gate runs this unit's suites, the named static checks and the
  named mutation probes. Extra controls
  beyond the dispatch inventory come back as a named question with options — the
  gate never spends the controls budget itself.
- The gate's product is falsification attempts; findings get tested against
  the unit's OWN acceptance claim, not the executor's preference.
- Scoped re-gates are legitimate but must be offered as a proposition the gate
  may refuse: "if you disagree with this scoping, say so with reasoning
  instead of silently complying."

## Auditor/spec-dispatch variant (angelique)

Same skeleton; the sources shift. Step 1 harvests the DECISION inventory
instead of claims: every ratified ruling becomes a fence ("cite, never
re-litigate"), every carried default becomes "proceed on X unless your
findings contradict it — then raise, don't absorb." Grounding includes the
sibling units the spec builds on, with the instruction to verify their landed
shape IN CODE, not from their specs. Step 2 adversarializes the deliverable:
the spec must state an EXPLICIT invariant list (a gate cannot verify an
invariant the spec never states), mechanisms not aspirations ("specify the
enforcement and its proving test"), structural guarantees over trusted
conventions ("must be incapable of X, not trusted not to X"), and
ENG-DECISION markers with options + recommendation for anything genuinely the
human's. Pin the spec's output path and require a trunk-SHA header so drift
is detectable at execution time. MANDATORY (class-fixed after 3 strikes):
the spec enumerates the touched packages' STATIC-DECLARATION CHECKS — tests
that assert a hand-maintained list matches the code (every table has an access
policy, every sensitive field is on the redaction list, every route is in the
registry, generated artifacts match their source) — into its gate list; drift
against one of these was missed by executor AND spec three units running
before this rule existed.

## Executor-dispatch variant (codeclaude / fix-in-lane)

Same skeleton; steps 1–2 become: state the COMPLETE correct end-state (never
"minimal fix"), cite the ruling that chose this shape over its alternatives,
specify the proving test the change must satisfy, and name the negative space
precisely (files it must not touch, decisions it must not remake). Include the
convention source ("read the sibling rows first and mirror their shape").

## Send checklist (30 seconds, every time)

- [ ] Every verification point carries provenance; inventory diffed for holes.
- [ ] Every point names its false-green shape, not just its true shape.
- [ ] Settled fenced; provisional marked confirm-or-refute.
- [ ] Traps have signature → diagnosis; known-reds pre-classified with task #s.
- [ ] Escalation shape stated; negative space stated; output path pinned.
- [ ] Redispatch: "context updates since" block present and dated.
- [ ] Controls inventory finite: each external mutant names its risk; <=2x
      acceptance items; one owner per mutant (executor OR gate).
