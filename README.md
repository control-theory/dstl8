# dstl8

Dstl8 continuous runtime feedback distills, detects, correlates, and explains problems to keep you out of debug rabbit holes. Context streams back into Claude Code, Cursor, and your dev flow. Always-on monitoring surfaces patterns, anomalies, and incidents across your full deployment chain: Supabase, Vercel, Railway, AWS, Kubernetes, OpenTelemetry, and more. Powered by Möbius agents, MCP server, and the Dstl8 CLI.

Try the Dstl8 CLI and TUI for __[Dstl8](https://dstl8.ai/)__ continuous runtime feedback loops. Get incidents, runtime context, log patterns, debug runtime issues, and connect AI agents to your infrastructure, all from the terminal.

## Quick start

The flow: sign up, sign in, add sources, install MCP.

```bash
# 1. Install the CLI
brew install control-theory/dstl8/dstl8

# 2. Create a Dstl8 account (or `dstl8 login` if you already have one)
dstl8 signup

# 3. Add a source so logs flow in
dstl8 sources add vercel

# 4. Connect your AI agent
dstl8 install claude-code
```

Once MCP is connected, your AI agent can investigate incidents, query logs, and analyze patterns through Dstl8 directly.

## Install

Pick the option that matches your environment. Each installs the same `dstl8` binary.

| Method | Command |
|--------|---------|
| Homebrew (macOS / Linux) | `brew install control-theory/dstl8/dstl8` |
| Shell installer | `curl -fsSL https://install.dstl8.ai/script/dstl8-cli \| sh` |
| npm | `npm install -g dstl8` (or `npx dstl8`) |
| Nix | `nix profile install github:control-theory/dstl8` |
| Manual | Download from [GitHub Releases](https://github.com/control-theory/dstl8/releases) |

The shell installer accepts `DSTL8_VERSION=0.2.0` to pin a version and `DSTL8_INSTALL_DIR=~/.local/bin` for a custom location. Uninstall with:

```bash
curl -fsSL https://install.dstl8.ai/script/dstl8-cli | sh -s -- --uninstall
```

Verify with `dstl8 version`.

### Claude Desktop (MCP extension)

Download `dstl8.mcpb` from the [latest release](https://github.com/control-theory/dstl8/releases/latest) and double-click to install. Requires the dstl8 CLI installed and authenticated.

### Claude Code plugin and skill

This repo ships a Claude Code plugin with a guided setup and investigation skill. To install:

```
/plugin marketplace add control-theory/dstl8
/plugin install dstl8@dstl8
```

The plugin auto-registers the MCP server. The skill walks Claude through CLI install, source configuration, and investigation flows. See `skills/dstl8/` for the skill content.

## Sign up and sign in

```bash
dstl8 signup            # new account; creates a Default workspace
dstl8 login             # existing account or new device
dstl8 profiles          # list profiles; ► marks the active one
dstl8 switch <profile>  # change the active profile
dstl8 logout            # log out of the current profile
```

On first run the CLI exchanges the browser session for a long-lived API token (365 days) stored under `~/.config/dstl8/`. Multiple profiles for different organizations are supported.

## Add sources

`dstl8 sources add` is an interactive wizard for every source type. It auto-detects local config (`~/.aws/credentials`, `~/.kube/config`, `vercel.json`, `supabase/config.toml`, `.git/config`) and pre-fills sensible defaults.

```bash
dstl8 sources add kubernetes
dstl8 sources add cloudwatch
dstl8 sources add vercel
dstl8 sources add supabase
dstl8 sources add otlp
dstl8 sources add github
```

For pull-based sources (`kubernetes`, `cloudwatch`), the CLI verifies the connection before exiting. For webhook-based sources (`vercel`, `supabase`, `otlp`, `github`), the wizard prints a webhook URL and any auto-generated tokens. Paste those into the upstream provider to complete the setup.

For scripted setups, pass `--yes` with the relevant flags to skip prompts:

```bash
dstl8 sources add cloudwatch --yes \
  --name prod-cw \
  --aws-access-key-id AKIA... \
  --aws-secret-access-key ... \
  --aws-region us-east-1

dstl8 sources add kubernetes --yes \
  --name prod-k8s \
  --cluster-name my-cluster \
  --environment production
```

Confirm logs are flowing:

```bash
dstl8 sources           # source listed and ingesting
dstl8 logs fetch -n 5   # recent log lines
```

Type aliases: `cloudwatch`/`aws` → `aws_cloudwatch`, `k8s` → `kubernetes`, `gh` → `github`, `opentelemetry` → `otlp`.

## Connect AI agents (MCP)

`dstl8 install` auto-detects MCP-compatible clients on your machine and configures them. The MCP server uses your local dstl8 credentials automatically. No additional configuration is needed.

```bash
dstl8 install                         # interactive picker
dstl8 install --all                   # install to every detected client
dstl8 install claude-code             # install to a specific client
dstl8 install status                  # see what's installed where
dstl8 install --dry-run               # preview without writing
dstl8 install --project               # project-scoped instead of user-scoped
dstl8 install --include-experimental  # include cursor, windsurf
```

Supported clients:

| Client | Install command |
|--------|-----------------|
| Claude Code | `dstl8 install claude-code` |
| Claude Desktop | `dstl8 install claude-desktop` (or download `dstl8.mcpb`) |
| Codex | `dstl8 install codex` |
| LM Studio | `dstl8 install lm-studio` |
| Cursor | `dstl8 install --include-experimental cursor` |
| Windsurf | `dstl8 install --include-experimental windsurf` |

Restart your AI client after installing so it picks up the new MCP server.

To configure a client manually, add this to its MCP config:

```json
{
  "mcpServers": {
    "dstl8": {
      "command": "dstl8",
      "args": ["mcp"]
    }
  }
}
```

Or run the server directly with `dstl8 mcp`.

## Terminal UI

`dstl8 tui` opens an interactive terminal UI for browsing your data without leaving the shell. Most investigation work runs through your AI client once MCP is set up. The TUI is useful for quick visual checks and one-off navigation.

```bash
dstl8 tui                    # launch the TUI
dstl8 tui -w myworkspace     # scoped to a workspace
dstl8 dashboard              # alias for tui
```

### Navigation

| Key | Action |
|-----|--------|
| `←` `→` | Switch tabs |
| `Tab` / `Shift+Tab` | Cycle through sections |
| `↑` `↓` / `j` `k` | Navigate lists |
| `Enter` | Drill in / view detail |
| `Esc` | Back / exit drill-down |
| `1`–`6` | Jump to tab by number |
| `s` | Sort incidents |
| `f` | Cycle incident filter |
| `w` | Change heatmap time window |
| `g` | Change heatmap grouping |
| `v` | View all logs for a source (from streams view) |
| `a` | Add source/stream to a workspace |
| `n` | Create a new workspace |
| `c` | Copy log body to clipboard (in log modal) |
| `Ctrl+C` | Quit |

### Sources

The org-level Sources tab lists every source connected to your organization. Press `Enter` to drill into streams, then `Enter` again on a stream to see its logs. Press `a` on any source or stream to assign it to a workspace.

![Sources view](docs/images/tui-sources.png)

### Workspace dashboard

Each workspace has a Dashboard with a Möbius AI summary at the top, a list of active incidents, and the sources feeding the workspace. Press `Enter` on the Möbius summary for a full analysis.

![Workspace dashboard](docs/images/tui-dashboard.png)

### Incidents

The Incidents tab is a sortable, filterable table (Open, Resolved, Closed, All). Press `s` to change the sort, `f` to cycle filters, and `Enter` on a row to open the incident detail view.

![Incidents table](docs/images/tui-incidents.png)

The detail view renders Möbius's full analysis: summary, description, evidence, and recommended actions, alongside the impacted resources and event timeline.

![Incident detail](docs/images/tui-incident-detail.png)

### Heatmap

The Heatmap plots sentiment over time by stream, namespace, or service. Anomalies surface as red dots on the affected row. Press `w` to change the time window, `g` to change the grouping, and `Enter` on a row to view the filtered logs for that group.

![Sentiment heatmap](docs/images/tui-heatmap.png)

### Log Viewer

The Log Viewer combines a stacked severity bar chart (1-minute buckets) with a scrollable log table. Press `Enter` on a log line to open a detail modal with full metadata. `c` copies the body to your clipboard.

![Log viewer](docs/images/tui-logs.png)

## CLI commands

A handful of commands are useful outside the TUI, especially in scripts, CI pipelines, and AI agent prompts.

### Tail and fetch logs

`dstl8 logs tail` streams logs to stdout in real time, like `tail -f`:

```bash
dstl8 logs tail                                       # all logs
dstl8 logs tail --source Prod -s error                # one source, errors only
dstl8 logs tail --stream-name api --search "timeout"
dstl8 logs tail -w myworkspace                        # scoped to a workspace
dstl8 logs tail -n 100                                # show last 100 first
dstl8 logs tail -f=false                              # print and exit
```

`dstl8 logs fetch` pulls a time range and exits. Useful for scripts and AI agents:

```bash
dstl8 logs fetch --start 24h -n 500 --json
dstl8 logs fetch --start 7d --end 24h --source Prod -s error
dstl8 logs fetch --start 2024-01-15
```

Time arguments accept relative (`30m`, `1h`, `24h`, `7d`) or absolute (`2024-01-15`, `2024-01-15T09:30:00`) values. `--json` produces NDJSON for piping. Filters (`--source`, `--stream-type`, `--stream-name`, `--severity`, `--search`) run server-side.

### Sources

```bash
dstl8 sources                                       # list with stats
dstl8 sources streams <name-or-id>                  # list streams for a source
dstl8 sources tail <source>                         # tail logs from a source
dstl8 sources fetch <source> --start 24h --json     # time-bounded fetch
dstl8 sources assign <source> <workspace>           # add all streams to a workspace
dstl8 sources streams assign <src> <stream> <ws>    # add a single stream
dstl8 sources delete <id> --yes                     # delete (skip confirmation)
```

### MCP server

Run the MCP server directly (instead of via `dstl8 install`):

```bash
dstl8 mcp                  # stdio MCP server using the active profile
dstl8 mcp --profile work
```

### Profiles and workspaces

```bash
dstl8 profiles                                            # list configured profiles
dstl8 profiles remove <name>                              # remove a profile and its tokens
dstl8 switch <profile>                                    # change the active profile
dstl8 workspaces                                          # list workspaces
dstl8 workspaces create <name> --description "Production monitoring"
```

Workspace names are case-sensitive. The default workspace created at signup is `Default` (capital D). When passing a workspace name to `dstl8 sources assign` or other commands, copy it exactly as `dstl8 workspaces` prints it.

### Other

```bash
dstl8 version              # version, commit, build time
dstl8 --help               # full command reference
```

## Configuration

Configuration lives in `~/.config/dstl8/`:

| File | Contents |
|------|----------|
| `profiles.toml` | Profile definitions (org ID, org name, API URL) |
| `auth.json` | Authentication tokens (per org, auto-refreshed) |
| `config.toml` | App settings |

Use `--profile <name>` on any command to run it against a specific profile without switching, or set `DSTL8_PROFILE` to override the default profile for the shell session.

## Links

- [dstl8.ai](https://dstl8.ai)
- [Documentation](https://docs.controltheory.com/controltheory-documentation/dstl8-docs)
- [Releases](https://github.com/control-theory/dstl8/releases)
- [Homebrew tap](https://github.com/control-theory/homebrew-dstl8)
- [Issues](https://github.com/control-theory/dstl8/issues)

## License

The installer scripts and packaging in this repository are MIT licensed (see [LICENSE](LICENSE)).
The dstl8 binary itself is proprietary, owned by ControlTheory, Inc., and governed by the
[ControlTheory Terms of Service](https://www.controltheory.com/terms-of-service/).
