# Agents

Claude Code subagent definitions. Copy into `~/.claude/agents/` (user-wide) or `.claude/agents/` (per repo).

| Agent | Seat | Runs | Writes code? |
|---|---|---|---|
| `angelique` | Pre-implementation auditor + spec author | `/audit` → `/spec` (→ `/big-brain`) | No — produces audit + spec docs |
| `codeclaude` | Executor | preflight → audit → spec → execute → post-audit → brief | Yes, in an isolated worktree |
| `chuck` | Independent adversarial gate | `/post-audit` (→ `/big-brain`) | No — produces a post-audit doc + quality label |
| `bigbrain` | One hard ruling, max depth | first-principles derivation | No — read-only |

Every def opens with the same **Operating stance** fragment ([`docs/agent-stance-core.md`](../docs/agent-stance-core.md)) and closes with the same **dispatch defense** paragraph. The middle is the role.

## Design choices worth knowing

- **Agents never write to the tracker.** They return a distilled report shaped as an *index* (verdict, counts, the few findings that steer the next decision, artifact paths). The dispatching session rules and persists. One writer keeps the record coherent and keeps rulings attributable.
- **Judgment calls come back as a shape, not a choice**: situation · options with the real tradeoff · the default · recommendation + confidence. The dispatcher rules or escalates.
- **The executor's self-review is never the gate.** `chuck` is always dispatched independently, and ends with a machine-readable quality label the dispatcher records on the task.
- **Effort rides the def, not the dispatch.** Claude Code's Agent tool has no effort parameter, and a `model:` override on dispatch keeps the def's effort. If you want a cheaper/pricier seat, make a separate def.
- **Defs do not hot-reload.** Sessions started before you edit a def keep the old pins.

## Security-floor seats (optional)

We also run `fableangelique` / `fablechuck`: byte-identical prompts to `angelique` / `chuck` except the identity line, pinned to the strongest model. The dispatcher *routes* to them for units that touch auth, crypto, sensitive-data handling, row-level security, migrations, audit emission, or test integrity — and for specs other units will copy. The point is making the floor a routing rule the dispatcher applies mechanically, not a judgment it re-makes per dispatch. Clone `angelique.md` / `chuck.md`, change `name`, the identity line, and `model`, and write the routing rule down wherever your dispatcher reads its standing rules.
