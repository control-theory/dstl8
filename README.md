# Dstl8

Dstl8 continuous runtime feedback distills, detects, correlates, and explains problems to keep you out of debug rabbit holes. Context streams back into Claude Code, Cursor, and your dev flow. Always-on monitoring surfaces patterns, anomalies, and incidents across your full deployment chain — Supabase, Vercel, Railway, AWS, Kubernetes, OpenTelemetry, and more. Powered by Möbius agents, MCP server, and the Dstl8 CLI.

Try the Dstl8 CLI and TUI for [Dstl8](https://dstl8.ai) continous runtime feedback loops. Get incidents, runtime context, log patterns, debug runtime issues, and connect AI agents to your infrastructure — all from the terminal.

## Install

```sh
# Homebrew (macOS / Linux)
brew install control-theory/dstl8/dstl8

# Shell script
curl -fsSL https://install.dstl8.ai/script/dstl8-cli | sh

# Nix
nix run github:control-theory/dstl8

# npm
npx dstl8
```

Or download a binary from the [releases page](https://github.com/control-theory/dstl8/releases).

## Get started

```sh
dstl8 login          # authenticate with your org
dstl8 tui            # launch the interactive TUI
dstl8 sources        # list connected sources
dstl8 logs tail      # stream logs in real time
dstl8 --help         # see all commands
```

## Claude integration

dstl8 includes a built-in [MCP](https://modelcontextprotocol.io) server that lets Claude query your observability data directly.

### Claude Desktop

Download [`dstl8.mcpb`](https://github.com/control-theory/dstl8/releases/latest) from the latest release and double-click to install. Requires the dstl8 CLI installed and authenticated (`dstl8 login`).

### Claude Code

```sh
claude mcp add dstl8 -- dstl8 mcp
```

### Other MCP clients

Add to your MCP client config:

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

The MCP server uses your local dstl8 credentials automatically — no additional configuration needed.

## Links

- [dstl8.ai](https://dstl8.ai) — Platform & docs
- [Releases](https://github.com/control-theory/dstl8/releases) — All versions and changelogs
- [Homebrew tap](https://github.com/control-theory/homebrew-dstl8) — Formula source
- [Issues](https://github.com/control-theory/dstl8/issues) — Bug reports and feature requests
