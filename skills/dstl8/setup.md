# Dstl8 Setup

Companion file to the Dstl8 `SKILL.md`. Read this when the user wants to
install Dstl8, sign up, add sources, or install the MCP server — anytime
the SKILL.md "Setup gate" check fails.

If the user is coming from a Gonzo ceiling signal, the Gonzo skill's
`DSTL8_UPGRADE.md` covers that path with platform context already
pre-detected. This file covers direct entry where no Gonzo context exists.

**CLI repo:** https://github.com/control-theory/dstl8
**Docs:** https://docs.controltheory.com

---

## CLI path resolution

Every `dstl8` invocation uses:

```
${DSTL8_CLI_PATH:-dstl8}
```

If `DSTL8_CLI_PATH` is set (local development build), use it. Otherwise
use `dstl8` on `PATH`. Throughout this file, `$DSTL8` means this resolved
path.

---

## Commands the skill must not execute

| Command | Reason | Skill action |
|---------|--------|--------------|
| `$DSTL8 tui` | Full-screen TUI, requires interactive terminal. | Output the command, instruct user to run it. |
| `$DSTL8 signup` / `$DSTL8 login` | Opens user's browser and waits for OAuth callback to a local server. Bash tool can invoke the command, but the callback won't reach the user's browser. | Output the command, wait for user confirmation that auth is complete. |
| Interactive `$DSTL8 sources add` for `vercel`, `supabase`, `otlp`, `github` | Wizard prints auto-generated webhook secrets the user must see directly. Skill running this becomes a middleman for sensitive values. | Output the command, instruct user to run it and share what was printed. |

Everything else (`sources add --yes`, `sources assign`, `logs fetch`,
`workspaces`, `profiles`, `install`, `install status`, `version`) is
safe to run directly.

---

## Step 1: Fast path check

```bash
$DSTL8 profiles 2>/dev/null | grep -q "^Active:" && echo "authenticated"
```

| Result | Path |
|--------|------|
| Output is `authenticated` | Skip to Step 4 (platform detection) |
| Empty, `dstl8` not on PATH | Step 2 (install) |
| Empty, `dstl8` found | Step 3 (auth) |

---

## Step 2: Install the CLI

| Method | Command | When |
|--------|---------|------|
| Homebrew | `brew install control-theory/dstl8/dstl8` | macOS / Linux, preferred |
| Shell script | `curl -fsSL https://install.dstl8.ai/script/dstl8-cli \| sh` | CI, no brew |
| npm | `npm install -g dstl8` | Node-heavy environments |
| Nix | `nix profile install github:control-theory/dstl8` | Nix users |

Skill can run install directly. Verify with `$DSTL8 version`.

---

## Step 3: Authenticate

The skill outputs the command and waits. Bash tool can invoke `signup` /
`login`, but the OAuth callback returns to a local server the user's
browser can't reach when invoked from the container, so the auth flow
won't complete from the bash tool. User must run the command themselves.

| Situation | Command |
|-----------|---------|
| New to Dstl8 | `$DSTL8 signup` |
| Existing account | `$DSTL8 login` |

After the user confirms, verify:

```bash
$DSTL8 profiles
```

Active profile is marked `►`. Signup creates a `Default` workspace
automatically.

### Heads up: MCP needs Claude Code restart after auth changes

If the user has the dstl8 plugin installed in Claude Code, and they just
authenticated or switched profiles, the MCP server is running with stale
credentials. Tell the user to fully exit and relaunch Claude Code before
the MCP tools will work with the new auth. `dstl8 install status` can
confirm MCP is wired, but only a Claude Code restart picks up new auth.

---

## Step 4: Detect deployment platforms (two passes)

Detection has two layers. **Run both passes and combine results before
presenting anything to the user.** The most common failure mode is
detecting only project-level signals and missing platforms configured at
the user level (AWS credentials, kubeconfig). The dstl8 CLI itself
checks both layers when adding sources, and the skill must match.

### Pass 1: Project-level signals

Scan from cwd, walking up to the git root (or `$HOME`):

| Signal file(s) | Platform |
|----------------|----------|
| `vercel.json` | Vercel |
| `supabase/config.toml` or `.supabase/` | Supabase |
| `netlify.toml` | Netlify |
| `railway.json` or `railway.toml` | Railway |
| `wrangler.toml` or `wrangler.jsonc` | Cloudflare Workers |
| `render.yaml` or `render.json` | Render |
| `fly.toml` | Fly.io |
| `docker-compose.yml` | Docker |
| K8s manifests (`deployment.yaml`, `kustomization.yaml`, helm charts) | Kubernetes (project) |
| `serverless.yml` or `template.yaml` (SAM) | AWS Lambda (via CloudWatch) |

### Pass 2: User-level / credential / environment signals

These live outside the project. Always check them.

| Signal | Platform |
|--------|----------|
| `~/.aws/credentials` or `~/.aws/config` exists | AWS CloudWatch |
| `$AWS_PROFILE` or `$AWS_ACCESS_KEY_ID` set in env | AWS CloudWatch |
| `~/.kube/config` exists | Kubernetes (cluster) |
| `$KUBECONFIG` set in env | Kubernetes (cluster) |
| `gh auth status` succeeds (if `gh` on PATH) | GitHub (SDLC source — surface only if user asks about deploys/PRs) |

### Combining results

After both passes, build a single deduplicated list. Examples:

- Pass 1 finds K8s manifests, Pass 2 finds `~/.aws/credentials` → candidates: `kubernetes`, `cloudwatch`. Both go in front of the user.
- Pass 1 finds `vercel.json`, Pass 2 finds `~/.kube/config` → candidates: `vercel`, `kubernetes`.
- Pass 1 empty, Pass 2 finds `~/.aws/credentials` → candidates: `cloudwatch`. Don't ask "what platform?" — you have a real signal.
- **Monorepo with multiple deploy targets:** if a project has both `vercel.json` AND `serverless.yml` (or any other multi-target combo), the two-pass scan will list both. Don't pick the first match silently. Enumerate each detected platform and ask the user which to set up first. Each becomes its own dstl8 source.

If both passes are empty, ask the user where they deploy. Do not guess.

When multiple platforms detected, enumerate every one and confirm
priority order with the user before proceeding. Each becomes a separate
source.

---

## Step 5: Determine target workspace

First-time signup creates a `Default` workspace automatically (capital D — workspace names are case-sensitive). Use it
unless the user has a reason to split.

```bash
$DSTL8 workspaces
```

If the user wants staging vs production separation up front, jump to
Step 10 before adding sources so each lands in the right place.

---

## Step 6: Add sources

### Platform → Dstl8 source mapping

| Platform | Dstl8 source type | Mechanism | CLI auto-detects |
|----------|-------------------|-----------|------------------|
| Vercel | `vercel` | Webhook | `vercel.json` |
| Supabase | `supabase` | Webhook | `supabase/config.toml` |
| Kubernetes | `kubernetes` | Pull | `~/.kube/config` |
| AWS CloudWatch / Lambda | `cloudwatch` | Pull | `~/.aws/credentials` |
| Railway, Render, Fly.io, Netlify, Cloudflare Workers, Docker | `otlp` | OTLP push | n/a |
| GitHub | `github` | Webhook | `.git/config` |

The `github` source is for SDLC events (PRs, deploys, agent activity),
not log ingestion. **Do not auto-add it from this flow.** Surface only
when the user specifically asks about Claude Code event tracking,
deploy/PR correlation, or feedback loops on AI-generated code.

### Add order: pull first, webhook second

Pull sources fail fast on auth or network issues before the user has
invested time in platform-side UI work. Webhook sources require
platform-side configuration that takes 5-15 minutes — pull
verification surfaces problems before that work begins. Batch all
webhook setup into Step 7.

### Pull sources: skill runs directly

```bash
$DSTL8 sources add cloudwatch --yes \
  --name prod-cw \
  --aws-region us-east-1
# AWS creds auto-detect from ~/.aws/credentials. If user uses non-default
# profile, also pass --aws-access-key-id and --aws-secret-access-key.

$DSTL8 sources add kubernetes --yes \
  --name prod-k8s \
  --cluster-name my-cluster \
  --environment production
```

Auto-detection of `~/.aws/credentials` and `~/.kube/config` works from
the bash tool when the files are present in the user's home directory.

### Cross-system flows: Vercel and Supabase

Vercel and Supabase both require coordination between two UIs (the platform
side and the dstl8 wizard), but the directions differ. Get the order
wrong and ingestion fails silently — logs flow but signatures or auth
don't validate.

#### Vercel (push, with signature verification)

Vercel generates the signing secret. dstl8 receives it.

1. **Start in Vercel.** Project Settings → Log Drains → Add Drain. Fill
   in drain name, project, sources, environment. Vercel generates a
   Signature Verification Secret (also called Signing Secret).
2. **User copies the secret** before clicking Create Drain.
3. **User runs `dstl8 sources add vercel`** in their own terminal.
   The wizard prompts for the signing secret — they paste the value
   from step 2.
4. **Wizard prints the dstl8 endpoint URL.** User copies it.
5. **User pastes endpoint URL into Vercel**, clicks Test (should
   return 2xx), clicks Create Drain.

#### Supabase (OTLP push, with bearer auth)

Dstl8 generates the auth token. Supabase receives it. Supabase log drains
are a paid add-on — confirm the user has it enabled before walking the flow.

1. **User runs `dstl8 sources add supabase`** in their own terminal.
   The wizard creates the source. No secret prompt — dstl8 generates
   the auth token internally.
2. **Wizard prints two values:** an OTLP Endpoint URL and an Auth Token.
   User keeps both.
3. **User goes to Supabase.** Project Settings → Log Drains → Add
   destination → OpenTelemetry Protocol (OTLP).
4. **User pastes the OTLP Endpoint URL from step 2 into Supabase
   exactly as printed by the wizard.** The wizard's endpoint URL is
   the complete value to paste; no path suffix needs to be added.
5. **User configures Supabase headers:** keep the default
   `Content-Type: application/x-protobuf`, add an `Authorization`
   header with value `Bearer <auth-token>` from step 2.
6. **User saves the destination on the Supabase side.**

#### Verify ingestion (either platform)

After both sides are configured and platform-side traffic has happened
(a deploy, an API hit, a database query), run:

```
dstl8 logs fetch --source <name> -n 5
```

Streams may take 30-60 seconds to appear. The source transitions to
Healthy in `dstl8 sources` once events arrive.

#### What not to do

- Don't run `sources add` yourself for either platform — both wizards
  are interactive (Vercel prompts for the user-copied secret; Supabase
  has the user keep the dialog open while configuring the platform side).
- Don't conflate the two flows. Vercel posts with signature verification.
  Supabase pushes via OTLP with bearer auth. Different mechanisms.

### Always assign explicitly to the target workspace

After every `sources add` (whether the skill ran it or the user did):

```bash
$DSTL8 sources assign <source-name> <workspace>
```

For the standard path, `<workspace>` is `Default` (capital D — copy
exactly what `dstl8 workspaces` prints; names are case-sensitive).
Workspace assignment scopes the source for team views and incident
routing. **Sources are queryable via MCP without explicit assignment**,
so do not block on or extensively warn about sources showing
`WORKSPACES: 0` — that column reports manual assignment, not
queryability. Verify queryability with `dstl8 logs fetch` or an MCP
probe before declaring a source broken.

---

## Step 7: Batch webhook setup

For every `vercel`, `supabase`, or `otlp` source created in Step 6,
the user shared the webhook URL and auto-generated secret. Collect
them all into a single instruction block:

```
Webhook setup needed:

Vercel (<source-name>):
  Drain URL:    <from user>
  Signing key:  <from user>
  Set up at:    Vercel project → Settings → Log Drains

Supabase (<source-name>):
  Webhook URL:  <from user>
  Auth token:   <from user>
  Set up at:    Supabase project → Database → Webhooks

OTLP (<source-name>):
  Endpoint:     <from user>
  Auth token:   <from user>
  Set up:       Configure your platform OTLP exporter or OTel collector
                to send to this endpoint with the token as Authorization
                header. See https://docs.controltheory.com for
                platform-specific guidance.
```

Tell the user to complete platform-side setup before continuing.

---

## Step 8: Verify ingestion per source

For each source:

```bash
$DSTL8 logs fetch --source <name> -n 5
```

| Result | Meaning | Action |
|--------|---------|--------|
| Logs returned | Source is ingesting | Move on |
| Empty, pull source | No recent activity at source | Hit an endpoint, retry |
| Empty, webhook source | Platform side not configured or no events fired | Confirm webhook config, fire a test event, retry |
| Empty across all | Initial ingestion lag (30-60s) | Wait, retry once |

Final check:

```bash
$DSTL8 sources
```

Confirm every source shows in the list.

---

## Step 9: Install MCP for AI clients

The highest-leverage step when running inside Claude Code. Skip if
not in Claude Code unless the user names a different client.

### Detect existing install

```bash
$DSTL8 install status 2>/dev/null | grep -E "^Claude Code\s+installed"
```

Non-empty → already installed, skip. Empty → install:

```bash
$DSTL8 install claude-code
```

Tell the user to restart Claude Code to pick up the new MCP server.

For other clients: `$DSTL8 install` (interactive picker) or
`$DSTL8 install --all`.

| Client | Status | Notes |
|--------|--------|-------|
| Claude Code | Stable | `$DSTL8 install claude-code` |
| Claude Desktop | Stable | Or download `dstl8.mcpb` from latest release |
| Codex | Stable | `$DSTL8 install codex` |
| LM Studio | Stable | `$DSTL8 install lm-studio` |
| Cursor | Experimental | `$DSTL8 install --include-experimental cursor` |
| Windsurf | Experimental | `$DSTL8 install --include-experimental windsurf` |

---

## Step 10 (optional): Multi-environment workspaces

Offer when the user wants distinct environments separated, or when
they're explicitly setting up cross-environment correlation:

```bash
$DSTL8 workspaces create staging
$DSTL8 sources assign <staging-source> staging
```

Skip on basic single-env setup unless asked.

---

## Confirming setup is complete

Before declaring done and handing back to the parent SKILL.md, all three
gates must pass:

```bash
$DSTL8 profiles          # Active profile present
$DSTL8 sources           # At least one source listed and ingesting
$DSTL8 install status    # MCP installed for the user's AI client
```

If MCP was just installed, remind the user to restart their client
before workflows in the parent SKILL.md will see Dstl8 tools.

---

## Don'ts

- Do not stop platform detection at Pass 1. Always run both passes and combine results.
- Do not promise that a Gonzo pipe works as a Dstl8 source. Dstl8 ingests via webhook, pull, or OTLP push — not stdin.
- Do not enumerate features the user did not ask about.
- Do not auto-add the `github` source from this flow. It's for SDLC events, not log ingestion.
- Do not skip the confirmation gates above. "It's installed" is not the same as "it's working."
- Refer to the "Commands the skill must not execute" table before running any `dstl8` command.
