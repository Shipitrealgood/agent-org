# Brief Template — Execute-Side (Build Sequence)

Use this template when handing off to an **execution** agent (implementing a spec, running fixes, applying changes). The framing is procedural — the reader's job is to build, not to critique. Escalation triggers replace adversarial watchpoints.

Target length: 60–150 lines. Execute briefs are typically tighter than review briefs because the spec carries the detail.

*The examples below use a fictional billing service (`billing-svc`) to show shape; replace every one with your own specifics.*

## Header

```markdown
# Execute scope: {subject} (task #{id})

**Date requested:** YYYY-MM-DD
**Requester:** @name
**Assigned to:** @next-agent
**Related tasks:** #{related-ids}
```

Example: `# Execute scope: invoice-rounding audit fixes (task #57)`

---

## Section 1 — Where the work lives

**Purpose:** Let the next agent get oriented in one copy-paste. Same as review briefs.

````markdown
**Worktree:** `/srv/work/billing-svc-rounding/`
**Branch:** `invoice-rounding` (NOT `main`)

```bash
cd /srv/work/billing-svc-rounding
git status   # should show {expected state}
```
````

If the branch is a deliberate exception to a convention, note it:
> The rounding worktree is a deliberate exception to the trunk-only convention — separate branch because it's the sweeping money-type migration.

---

## Section 2 — What's in the working tree right now

**Purpose:** Execution briefs often dispatch against in-flight state, not a clean commit baseline. Account for it explicitly so the executor doesn't accidentally sweep in unrelated changes.

List each category of in-tree state:

```markdown
- **F12 test work** (uncommitted, 9 modified test files + new `test/invoice-totals.test.ts`) — already audited, results in `docs/audits/post-audit/56-invoice-rounding-f12.md`
- **Audit doc** (untracked) — `docs/audits/post-audit/56-invoice-rounding-f12.md`
- **Brief for the audit** (untracked) — `docs/briefs/56-post-audit-invoice-rounding-f12.md`
- **Spec for this task** (untracked) — `docs/specs/invoice-rounding-audit-fixes.md`
- **This brief** (untracked)
- Other untracked work in `docs/specs/ledger-split.md` etc. — leave alone, separate stream
```

The "leave alone, separate stream" callouts are critical — they prevent the executor from staging unrelated files.

If the working tree is clean, say so: `Working tree is clean at {commit SHA}.`

---

## Section 3 — Sequence

**Purpose:** Numbered steps with explicit commit boundaries. This is the section that distinguishes execute briefs from review briefs.

Each step is a concrete action the executor takes. Commit boundaries are suggested, not forced — the executor can consolidate if a group is small, but shouldn't combine across conceptual lines.

````markdown
### Step 1: Commit F12 first (as-is)

The audit was performed against the F12 working-tree diff. To make the audit
historically reviewable against an actual commit, commit F12 first as a baseline.

```bash
cd /srv/work/billing-svc-rounding
git status                     # confirm 9 modified + 1 new test file
git diff --stat test/          # sanity check
git add test/
git add docs/specs/invoice-rounding.md  # F12 status update
git commit -m "test: F12 — ..."
```

Do NOT include the audit/brief/spec docs in this commit — they describe
follow-up work and should land with their respective work.

### Step 2: Execute the spec

Spec: `docs/specs/invoice-rounding-audit-fixes.md` — 18 fixes in four groups.

Use the `/execute` skill. The spec has its own ordering (F1–F18) with explicit
`Depends on:` lines.

### Step 3: Commit fix-ups in logical batches

Suggested commit boundaries:

1. **Group A (F1–F5)** — code changes only. `feat:` or `fix:` prefix per fix.
2. **F15 alone** — `chore: typecheck test/ — fix surfaced fixture drift`. Standalone because the tsconfig change has independent value.
3. **Group B (F6–F14)** — test tightening. Goes after Group A so each test flip-to-strict has the matching code change behind it.
4. **Group D (F16–F18)** — cleanups. Small final commit.
````

### Rules

- Each step has ONE primary action (commit, execute, verify). Don't fold multiple actions into one step.
- When a step runs a shell command, include the exact command block so the executor can copy-paste.
- Commit boundaries carry rationale — why this boundary and not another.
- If the sequence depends on another spec/doc, cite its path (`docs/specs/...`).

---

## Section 4 — Pre-flight

**Purpose:** Sanity gates. If these don't hold, don't start — something is wrong upstream.

```markdown
- [ ] `cd /srv/work/billing-svc-rounding && git status` shows expected unstaged + untracked
- [ ] `npm run typecheck` clean
- [ ] `npm test` shows **869 passing / 21 suites**
- [ ] Read `docs/specs/invoice-rounding-audit-fixes.md` end-to-end
- [ ] Read this brief end-to-end
- [ ] Skim `docs/audits/post-audit/56-invoice-rounding-f12.md` for context on each fix's "why"
```

Keep to 4–7 items. "Stop before you start" gates only — not a full checklist of every command the executor might run.

---

## Section 5 — Things to flag back before powering through

**Purpose:** Named escalation triggers. "Pause and report rather than work around" — protects against the executor papering over unexpected state.

```markdown
These were noted in the spec hand-off — pause and report rather than work around:

1. **F6 API harness.** Spec assumes `test/api.test.ts` already has a pattern for end-to-end request invocation. Read the file first. If no harness exists, F6 grows to "build the harness" — flag back before proceeding.
2. **F15 blast radius.** Adding `test/**` to typecheck may surface >10 errors across multiple files. If so, pause and report — could indicate a separate cleanup spec is warranted.
3. **F1 transaction timestamp.** Two UPDATEs in one transaction may stamp slightly different `now()` values depending on the database. Acceptable but worth confirming behavior.
```

### Rules

- Each item names a specific condition that should halt execution.
- Each item gives the executor a clear "report back" framing — not just "be careful."
- If there are no escalation triggers worth naming, write "No specific flag-backs anticipated. Apply the spec as written." An absent section is a gap; an explicit "none" is signal.

---

## Section 5.5 (optional) — Override skill defaults

**Purpose:** Include only when the skill's default posture isn't sufficient for THIS case. Most briefs skip this section entirely — that's by design.

Examples of when to include:

- **Destructive action awareness:** "F9 includes a migration that drops a column. Think carefully before generating the migration SQL — this is the first destructive commit in the chain."
- **Cross-file fan-out:** "This refactor touches 30+ call sites across `src/` and `test/`. Use grep liberally to verify; consider subagent fan-out for the parallel reads."
- **Non-default tool use:** "This audit needs aggressive web fetch — verify each external claim against current docs."

Format: 1-3 sentences per override. Include only when the case genuinely warrants overriding the skill default — including this section out of habit dilutes the cases where the override is real.

---

## Section 6 — What NOT to do

**Purpose:** Define scope boundaries explicitly. Frame items as positive scope statements where possible — models take negative instructions literally, and positive scope is more precise. The section header stays ("What NOT to do") because it's a human-readable scope-statement header; the bullet content underneath is where positive framing matters.

```markdown
- **Migration is out of scope** — the production data backfill is tracked separately at #N.
- **Source touches limited to**: `invoices.ts`, `line-items.ts`, `money.ts`, `validation.ts`, `tax.ts`, `api.ts`. Other service files are adjacent work, separate stream.
- **Branching**: stay flat on the existing `invoice-rounding` branch.
- **Untracked unrelated files** (`docs/specs/ledger-split.md`, etc.) — separate stream, leave alone.
```

Always present, always specific. A brief without explicit scope invites scope creep.

---

## Section 7 — Done criteria

**Purpose:** Objective completion state. The executor can check these and know they're done, independent of judgment.

```markdown
- All 18 fixes in spec are addressed (or explicitly flagged back with reasoning if blocked)
- `npm run typecheck` clean (with `test/**` now in scope)
- `npm test` green
- All commits land on `invoice-rounding`
- Report back with a one-line commit reference summary so the dispatcher can close #57
```

### Rules

- Each criterion is verifiable with a command or a concrete check.
- "Pass CI" is not done criteria — CI is an indicator, not a scope definition.
- If a criterion requires judgment (e.g., "code quality is good"), it doesn't belong here — it belongs in a review brief for the next agent.

---

## Cross-brief chain

Execute briefs typically reference upstream audit docs and downstream review briefs. Call them out explicitly:

- "Audit being resolved:" `docs/audits/post-audit/56-invoice-rounding-f12.md`
- "Spec being executed:" `docs/specs/invoice-rounding-audit-fixes.md`
- "Next step after execution:" post-audit on commit range (will be briefed separately in `docs/briefs/58-*`)

Each brief is a node in a chain. Make the chain navigable.

---

## Tone

- Write as the outgoing agent (auditor, spec author) handing off to the executor.
- Imperative voice where possible ("Commit F12 first", not "F12 should be committed first").
- Name the executor's temptations and head them off with positive scope ("This is out of scope; tracked at #N" beats "Do NOT touch this"). Executors under time pressure skip gates; the brief is your chance to keep them honest.
- Trust the executor to run standard commands — don't explain what `npm run typecheck` does or how `git commit` works.

## Length

Target 60–150 lines. If the sequence has many steps, move detail into the spec — the brief shouldn't duplicate the spec. The brief is the **routing layer** that tells the executor WHERE to look in the spec and HOW to commit, not WHAT each fix does.
