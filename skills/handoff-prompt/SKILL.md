---
name: handoff-prompt
description: >
  Author a boot-image handoff prompt for another agent session (conductor
  session, workstream session, pipeline handoff, dispatch prompt — any harness).
  Use when the user says "write me the prompt for X", "hand this off",
  "handoff prompt", "session prompt for...", "dispatch prompt", or is about
  to launch work in a fresh session and needs it primed. Produces a
  grounded, checkable prompt per the boot-image pattern — grounding FIRST
  if the current session isn't grounded on the mission.
metadata:
  short-description: "Author a grounded boot-image handoff prompt"
---

# /handoff-prompt — grounded boot-image authoring

Read the full pattern first: `docs/agent-handoff-prompting.md`. It is the authority; this skill is the procedure.

## Procedure

1. **Grounding check (the prime rule: authority = provenance).** Can you cite, from verified context in THIS session: the true state of the work (code/docs/tracker), the target's harness (its skills, agents, conventions — read them if the target isn't your own harness), and the decision landscape (what's ratified vs open)? If NO on any: **ground before authoring** — fan out 1–3 read-only agents to reconcile the mission's code/doc/tracker state, and read the target harness's skill files. An unverified specific is worse than a vague one; label anything unverifiable UNVERIFIED or cut it.

2. **Compile using the anatomy** (reference doc §Anatomy): role + ownership contract (incl. what the agent NEVER does) → **merge authority stated explicitly** (branch + who merges; silence defaults to stage-and-present, never primary-branch merge) → orientation pointer chain in dependency order + live-truth rule → session goal + outcome shape in artifact terms → first act (marked non-negotiable if it is) → queue with the WHY per ordering constraint → decision calibration by CLASS (self-rule vs escalate; "defaults are proposals until ratified"; widen/narrow per mission and say so) → watch items (only verified traps this mission hits, each with its consequence) → trail requirements.

3. **Apply the rules:** native-harness (map intent onto the target's own verbs; never restate what its skills already encode) · factoring (common block once + thin mission blocks when authoring a set) · style (dense complete sentences; explicit ID sets never ranges; mechanisms not intensity; pointers not payload).

4. **Point-of-use markers:** for the sharpest hazards, ALSO pin a stop-marker on the work item itself (a note on the task or at the top of the spec), not only in the prompt.

5. **Persist.** Commit the prompt into the project's doc chain (versioned artifact, re-issuable at checkpoints) unless the user wants it chat-only. State where it lives.

## Anti-pattern tripwires (from the reference — check your draft against them)

Ungrounded authoring · payload stuffing · unstated authority · virtue prompting ("be rigorous") · restating the target's skills · orders without reasons · chat-ephemeral prompts · no outcome shape.
