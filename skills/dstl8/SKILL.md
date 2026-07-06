---
name: dstl8
description: >
  Set up and use Dstl8 for observability. Triggers: install or configure
  Dstl8 (CLI, sources, MCP); incident triage and investigation; root
  cause analysis; checking whether a deploy fixed an issue; alerting on
  recurring patterns; cross-environment correlation; pre-coding context
  on past incidents and recent issues.
---

# Dstl8 — AI-Native Observability Skill

Dstl8 distills logs across dev, staging, and production into root cause
analysis, impact assessment, and fix recommendations. All environments
queryable via the Dstl8 MCP server using the same tools.

**Repo:** https://github.com/control-theory/dstl8
**Docs:** https://docs.controltheory.com

---

## Setup gate

Before running any workflow below, verify Dstl8 is set up:

1. CLI installed and authenticated (`dstl8 profiles` shows an active profile)
2. At least one source connected and ingesting (`dstl8 sources` lists it)
3. MCP server installed and the AI client restarted (`dstl8 install status`)

If any of these are missing, **read `setup.md` from this skill directory
and complete setup first.** Do not attempt setup from memory. `setup.md`
covers both onboarding paths: the guided one-command `dstl8 setup` (which
the user runs themselves) and the skill-driven step-by-step flow.

If Dstl8 tools aren't visible even after setup is reportedly complete:
> "I don't see a Dstl8 MCP server connected. Check `dstl8 install status`,
> restart your AI client, or re-run setup. See `setup.md`."

---

## Tool surface preference

This skill exposes Dstl8 functionality through two surfaces. Default
correctly between them; the wrong choice wastes turns and produces
worse answers.

**MCP tools** (`query_log_samples`, `list_incidents`, `query_patterns`,
`get_sentiment_heatmap`, `query_insights_params`, `search_nodes`, etc.)
are the right surface for **investigation, queries, incident triage,
and any run-time use of the data**. These are the high-leverage tools
the user installed Dstl8 to get. Default here for any question shaped
like "show me X", "what happened with Y", "why is Z broken",
"investigate W", "did my deploy fix it", "what's going on in prod".

**CLI via bash** (`dstl8 profiles`, `dstl8 sources`, `dstl8 install`,
`dstl8 logs fetch`, etc.) is for **setup, configuration, source
management, and installation**. Rare, admin-flavored actions.

If a user explicitly asks for the CLI ("run dstl8 sources" / "use the
CLI to..."), use bash. Otherwise, when both surfaces could serve the
question, prefer MCP. `dstl8 logs fetch` via bash is a fallback for
when MCP is unavailable, not a default.

**When MCP isn't loaded, prefer asking the user to restart over substituting via CLI.** If the user asks an investigation question and MCP tools aren't available in the session (e.g., they just signed up and Claude Code hasn't been restarted yet), tell them directly: "MCP tools aren't loaded in this session — restart Claude Code and ask again." Don't paper over it with parallel `dstl8 logs fetch` calls. That produces a degraded answer and burns turns. CLI fallback is fine for setup verification (e.g., `dstl8 logs fetch -n 5` to confirm ingestion), but not for investigation flows.

---

## Starting moves

Most workflows start with one of these:

| Start with | When |
|------------|------|
| `query_insights_params` | You need to discover available environments, services, or time ranges. Good default first call. |
| `list_incidents` | "What's going on?" — get active incidents |
| `get_sentiment_heatmap` | Quick health pulse across services |
| `query_log_samples` + severity filter | "Why is X broken?" — find specific errors |

## Entry patterns

### "What's going on?" — Situational awareness
`query_insights_params` → `list_incidents` (active, filtered by environment if specified) →
`get_sentiment_heatmap` by service. Present active incidents + health across environments.
When the user names a specific environment, pass it as a filter — don't return all incidents
and let them sort through it.

### "Why is X broken?" — Targeted investigation
`query_log_samples` (service + keyword + error) → `query_patterns` (recurring?) →
`list_incidents` (already tracked?). Then cross-environment: does the same pattern
appear in other environments? Same error in local + staging + prod = systematic.
Only in prod = environment-specific. Present: root cause → impact → fix.

### "Check staging" / "Check production" / "Check <env>" — Environment-specific
`query_insights_params` → `query_log_samples` for that environment →
`query_patterns` → `get_anomalies`. Compare against production baseline.
New pattern in staging not in prod = flag before promoting. Pattern in a dev
environment matching a known prod incident = good signal, developer is
reproducing it. Present with "safe to promote" or "flag before promoting" verdict.

### "Did my deploy fix it?" — Verification
`get_current_time` to anchor windows → `query_severity_data` before vs after →
`query_sentiment_data` same windows → `get_anomalies`. If deployed to staging,
compare staging post-deploy vs production — are they converging? Clear verdict.

### "I'm about to make changes" — Pre-coding context (Loop 1)
`search_nodes` for the service → `list_incidents` across all environments →
`query_patterns` for recent issues. Surface what the developer should know
before writing code.

## Defensive patterns

- **Several tools require `group_by`.** `query_patterns`, `query_summary`, `query_severity_data`, `query_sentiment_data`, `get_sentiment_heatmap` all need a `group_by` parameter (typically `service` or `environment`). They'll fail without it.
- **CRITICAL: `list_incident_events` MUST include a state or time range filter.** Unfiltered calls return 10-15k tokens and blow up context. NEVER call without passing `state` (e.g. `state: "open"`) or `start`/`end` timestamps. If the filtered response is still large (>5k tokens), use a narrower time window or pipe the response through a local script to extract what you need rather than re-fetching.
- **Discover, don't guess.** Call `query_insights_params` when unsure about environment or service names.
- **CLI time flag is `--start`, not `--since`.** `dstl8 logs fetch` and `dstl8 logs tail` accept `--start <duration>` (e.g., `--start 1h`, `--start 24h`, `--start 7d`) and `--end <duration>`. Don't use `--since`, `--from`, or other common variants — they don't exist on this CLI and will error.
- **Respect environment scope.** When the user specifies an environment ("in brewhaus", "check staging"), filter queries to that environment. Cross-environment data is supplementary context, not the main answer. When no environment is specified, infer from git branch, repo name, or conversation context. Only ask if you can't determine it.
- **Always think cross-environment.** When investigating one environment, check if the same pattern exists in others. But respect the user's scope — if they ask about a specific environment, lead with that environment's data and present cross-environment findings as secondary context, not the primary answer.
- **Persist findings.** After triage reaching root cause, write to the knowledge graph. This feeds future sessions.
- **Verify after fixing.** Proactively offer before/after comparison post-deploy.
- **Check before creating.** Search for existing incidents/entities before creating — Möbius may have already created them. Ask the user before creating incidents.
- **Convert timestamps.** Always present human-readable times, not raw Unix.

## Incident status mapping

| Code | Label |
|------|-------|
| 0 | Open |
| 1 | Investigating |
| 2 | Active |
| 3 | Resolved |
| 4 | Closed |

## Output conventions

Present investigation results as: **Summary** (one sentence) → **Root cause**
→ **Impact** (quantified) → **Recommended fix** (concrete) → **Confidence level**.

**Default to roughly 250 words.** Expand to a longer post-mortem format only
when the user explicitly asks for one ("write up a full post-mortem," "give
me the long version"). For routine investigation queries, brevity beats
thoroughness — the user is iterating, not archiving.

For post-mortems add: timeline table, action items with owner/priority.

## Feedback loops

Three loops drive compounding value:

- **Loop 1 (Intent):** Before coding — surface past incidents and patterns via knowledge graph. Only works if Loop 3 persisted findings.
- **Loop 2 (Iteration):** During dev — validate in dev environments and staging before promoting to production. Cross-environment comparison catches regressions.
- **Loop 3 (Production intelligence):** After deploy — triage → fix → verify → persist to graph for Loop 1.
