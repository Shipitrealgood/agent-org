# Brief Template — Review-Side (7-Section Structure)

Use this template when handing off to a **review** agent (post-audit, audit, spec review, human reviewer). The framing is adversarial — the reader's job is to find problems, not confirm correctness.

Target length: 80–200 lines total. Longer is fine when the work has many watchpoints; don't pad.

*The examples below use a fictional billing service (`billing-svc`) whose 2,500-line `src/ledger.ts` was split into `src/ledger/` modules. Replace every one with your own specifics.*

## Header

```markdown
# {Job} scope: {subject} (task #{id})

**Date requested:** YYYY-MM-DD
**Requester:** @name
**Assigned to:** @next-agent
**Related task:** #{id}
```

Example: `# Post-audit scope: ledger-module-split (task #42)`

---

## Section 1 — Where the work lives

**Purpose:** Let the next agent get oriented in one copy-paste.

Include:
- Worktree path (or working directory if not a worktree)
- Branch name, with an explicit note if it differs from `main`/`master`
- Commit range (base SHA..HEAD SHA) with a commit count — OR "uncommitted working-tree edits" if work hasn't committed yet
- One-line `cd + git log` or `git diff` command the next agent can copy-paste

````markdown
**Worktree:** `/srv/work/billing-svc-ledger/`
**Branch:** `ledger-split` (NOT `main`)
**Commit range to audit:** `abc123..def456` (14 commits, F1–F14)

```bash
cd /srv/work/billing-svc-ledger
git log --oneline abc123..HEAD
```
````

If the work spans multiple repos, name each with its own path+branch.

---

## Section 2 — What landed

**Purpose:** One short paragraph, plain language, describing what the next agent is looking at. Written BEFORE you tell them what to do.

- 3–5 sentences max
- Link the source spec if there is one (`**Source spec:** docs/specs/...`)
- Name the scope boundary concretely (what changed, what didn't)
- Call out state they need to know (e.g., "all commits typecheck-clean individually", "test baseline: 12 failures / 608 passes unchanged")

For larger changes, a small table (`| File | Change |`) can carry more signal than prose — use when there are 5+ distinct files or modules touched.

Avoid: restating the task title, explaining WHY the work was done (that's in the spec), previewing your job section.

---

## Section 3 — Your job

**Purpose:** Name the specific skill or action, framed adversarially.

Examples that work:
- "Execute the `/post-audit` skill against the commit range. Find what the executor missed, glossed over, or got wrong. Don't rubber-stamp."
- "Review `/spec` for task #45. Check the landed decisions against the open questions in `docs/decisions/refund-policy.md`. Flag any spec that skipped an open question without naming the call."

Make the default verb **doubt**, not **confirm**. The framing shapes how the next agent engages.

### Special instruction (optional but high-value)

If there's a meta-concern about YOUR work that the next agent should know going in, include it as a `**Special instruction:**` block after the main framing. Examples:

> **Special instruction:** Pay careful attention to places where tests may have been *shaped to pass* — i.e., assertions adjusted to match current code behavior when the code itself might be wrong and deserves review.

> **Special instruction:** This execution flipped a *lot* of tests back to strict to cover behavior changes. Pay careful attention to places where **code and test were changed together in the same commit** — those are exactly where "adjust the test to match new behavior" can be indistinguishable from "adjust the test to match a bug."

This is you confessing where you felt uncertain — and it's the single highest-leverage directive you can give. The next agent focuses their adversarial attention where your confidence was lowest.

Skip this block if no such meta-concern exists. An absent block is better than a fabricated one.

---

## Section 4 — Specifically look for

**Purpose:** 5–7 numbered watchpoints drawn from YOUR fresh session context. Each watchpoint names a specific file/function/pattern and poses questions.

Structure as numbered subsections, grouped by concern. Under each watchpoint, use **Probe:** sub-bullets for concrete investigation actions the next agent should take.

```markdown
### 1. Correctness of the split mechanics
- Did every function move to the right module?
- Any function accidentally left in both places, or quietly deleted?
- Every write still emits the audit-log row it used to?
- Every transaction boundary identical to pre-split — nothing leaked outside a transaction?

### 2. Specific fix under scrutiny (src/ledger/entries.ts ↔ test/entries.test.ts:168-180)

Code adds a second `UPDATE entries SET updated_at = ...` in the reversal branch. Test asserts `updated.updated_at !== null`.

**Probe:**
- Does the two-UPDATE transaction actually stamp the expected timestamp? `now()` semantics differ by database — two UPDATEs may stamp different values. Worth an explicit read.
- Is there a test that exercises the *no-op* path (`if (changes.length === 0) return current;`)? The executor kept the short-circuit but didn't add a regression test.
- Mixed path (reversal + adjustment in one call) — does the assertion catch a bug where only one side writes?
```

### Rules

- **Each watchpoint names a specific file, function, or pattern.** Generic concerns ("check the code quality") carry no signal.
- **File:line citations are the default, not a preference.** If you reference code, cite it: `src/ledger/entries.ts:304-369`, `test/entries.test.ts:118-136`.
- **Watchpoints are questions, Probes are investigation actions.** The question names the concern; the Probe tells the next agent what to actually do.
- **Drop any watchpoint that's generic** ("verify tests pass"). That's a checklist, not signal.

---

## Section 5 — Spec deviations

**Purpose:** Surface every non-trivial decision you made at implementation time that wasn't in the spec, with reasoning, and ask for independent judgment.

Format each entry:

```markdown
- **{what you did}** — {why in one line}. Did I pick the right call, or is there a better option?
```

Examples:
- **`applyPagination` inlined in 3 modules** instead of "private in entries" — because `accounts.ts` and `statements.ts` both use it. Should a shared helpers module have been created instead?
- **`getBalance` moved to `accounts.ts`** instead of `entries.ts` — to avoid an import cycle. Does the reasoning still hold in the shipped code?

If there were **no deviations**, write that explicitly:

> No deviations from the spec.

An empty-but-present section is signal; a missing section is a gap.

If deviations overlap heavily with watchpoints (e.g. the "shape-to-pass" points carry both roles), merge them — list the deviation under the relevant watchpoint's Probe and note in Section 5 "deviations folded into Section 4 watchpoints."

---

## Section 5.5 (optional) — Override skill defaults

**Purpose:** Include only when the skill's default posture isn't sufficient for THIS case. Most briefs skip this section entirely — that's by design.

Examples of when to include:

- **Destructive action awareness:** "This audit covers a migration that drops a column. Read the migration code carefully; the rollback path is the part most likely to silently break."
- **Cross-file fan-out:** "The change touches 30+ call sites across `src/` and `test/`. Use grep liberally to verify no caller was missed."
- **Coverage emphasis:** "This is the first pass after a major refactor — include low-confidence findings; downstream filtering will rank."

Format: 1-3 sentences per override. Include only when the case genuinely warrants overriding the skill default — most briefs skip this and trust the skill posture.

---

## Section 6 — What NOT to audit / chase

**Purpose:** Define scope boundaries explicitly. The section header stays ("What NOT to audit / chase") because it's a human-readable scope-statement header; bullet content underneath uses positive scope statements where possible — models take negative instructions literally, and positive scope is more precise.

Name:
- **Tracked-elsewhere concerns with task IDs** (e.g., "12 pre-existing test failures — tracked at task #23, not this split")
- **Out-of-scope surfaces** (e.g., "HTTP handlers, webhooks, CLI — unchanged by this refactor; out of scope")
- **Known-deferred items** (e.g., "Production backfill — tracked separately; out of scope here")
- **Adjacent work that looks related but isn't** (e.g., "Follow-up tasks #28/#29/#30 — owned by @angelique, separate stream")

A brief without explicit scope invites the next agent to wander. Always present, always specific.

---

## Section 7 — Deliverables + pre-flight

**Purpose:** Close the loop — name the output shape and give a sanity-check list.

```markdown
## Deliverables

Write your post-audit findings per the `/post-audit` skill's "Report path" section (default: `./docs/audits/post-audit/<task-id>-<slug>.md` relative to the repo root). Group findings by severity.
If the split is genuinely clean, say so directly — don't pad with low-severity
items to seem thorough. Return the index-shaped report to the dispatcher, who closes the task.

## Pre-flight

- [ ] `cd /srv/work/billing-svc-ledger && git status` clean on the right branch
- [ ] `npm run typecheck` passes
- [ ] `npm test` shows baseline (N failures / M passes)
- [ ] Read the spec at `docs/specs/{name}.md` before starting
- [ ] Read this brief end-to-end before starting
```

Keep pre-flight to 3–6 items. They're the "stop before you start if these don't hold" gates.

---

## Cross-brief chain

Briefs form a paper trail across pipeline stages. When the work being briefed has sibling briefs (the post-audit before the execute, the execute before the current post-audit), reference them in Section 2 or in the pre-flight:

```markdown
- [ ] Read `docs/audits/post-audit/40-ledger-f12.md` end-to-end (what the executor was resolving)
- [ ] Read `docs/specs/ledger-split-audit-fixes.md` end-to-end (what the executor was executing)
- [ ] Read `docs/briefs/41-execute-audit-fixes.md` end-to-end (how the executor was instructed)
- [ ] Read this brief end-to-end
```

Each brief is a node in a chain. Make the chain navigable.

---

## Why this shape works

The properties that made real review briefs produce fast, high-signal audits:

1. **Worktree path + branch + commit range up front** — the reviewer runs the copy-paste immediately; no wrong-branch confusion.
2. **"What landed" states scope concretely** — "every external import path is preserved — zero test or API changes" tells the reviewer what's in scope AND what to skip.
3. **Adversarial framing** — "find what I missed. Don't rubber-stamp." sets the posture.
4. **Watchpoints specific to this change** — renames, transaction boundaries, dependency tiers, named functions. None of it generic.
5. **Deviations named concretely** — each with its reason, each asking for judgment, so the reviewer can evaluate them independently.
6. **Explicit out-of-scope carve-outs** — pre-empts the reviewer burning cycles on known, separately tracked concerns.
7. **Pre-flight baselines** — telling the reviewer to expect "12 failures / 608 passes" lets them tell a real regression from pre-existing state.

---

## Tone

- Write as the outgoing agent who just did the work, not as a distant reviewer.
- Prefer "I did X because Y" over passive voice.
- Trust the next agent's capability — don't explain what `/post-audit` does, what a typecheck is, or how git works.
- Cite evidence (file paths, line numbers, commit SHAs) over opinions.
- If you coin a domain-specific term that focuses attention (e.g., "shape-to-pass" for test assertions adjusted to match buggy behavior), explain it once and reuse — coined terms work because they compress a pattern.

## Length

Target 80–200 lines. Longer is fine when watchpoints are rich. If it feels bloated, check for: generic watchpoints (drop them), prose that could be a table (convert), or scope that should be split into two briefs (split).
