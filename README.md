# Xhakala — AI Senior Product Manager Agent

**Xhakala** is an AI agent persona acting as a Senior Product Manager with 15+ years of cross-industry experience (fintech, logistics, e-commerce, SaaS, B2B/B2C), strong on both the business and technology side. This repo contains 1 primary agent (Xhakala) plus 9 specialist subagents that together cover the full working scope of a Senior PM.

## Structure

```
agent/
  xhakala.md                  # Primary agent — orchestrator & main persona
  market-research.md          # Market research & competitive analysis
  user-research.md            # Discovery, JTBD, personas, interview synthesis
  prd-writer.md               # PRD writing & review (uses the user's `prd` skill)
  pbi-writer.md                # PRD -> Azure DevOps work items (uses `azure-devops-ticket-skill`)
  roadmap-prioritization.md   # RICE/Kano/MoSCoW, quarterly roadmap
  metrics-okr.md              # North Star Metric, OKRs, A/B experiment design
  stakeholder-comms.md        # Executive updates, decision docs, RACI
  gtm-launch.md                # Go-to-market, launch plan, positioning
  tech-feasibility.md         # Technical feasibility from a PM perspective
.claude/agents/
  xhakala.md                  # Example adaptation to Claude Code sub-agent format
opencode.json.example          # Example agent registration for OpenCode
```

## Skill dependencies (required for PRD & PBI)

`prd-writer` and `pbi-writer` **do not carry their own templates** — both are designed to always load and follow your external skills:

- **PRD**: [`sirizqi/product-requirement-documents`](https://github.com/sirizqi/product-requirement-documents) — skill `prd`, invoked via `/prd`
- **PBI/Azure DevOps ticket**: [`sirizqi/azure-devops-ticket-skill`](https://github.com/sirizqi/azure-devops-ticket-skill) — skill `azure-devops-ticket-skill`, invoked via `/azure-devops-ticket-skill`

If these skills are not installed, both subagents can still work with a generic fallback, but the output **will not follow your official standard/template** — install them first before relying on this for real work.

### Install on Hermes

```bash
git clone https://github.com/sirizqi/product-requirement-documents.git ~/.hermes/skills/product-management/prd
git clone https://github.com/sirizqi/azure-devops-ticket-skill.git ~/.hermes/skills/product-management/azure-devops-ticket-skill
hermes skills list   # verify both appear
```

### Install on OpenCode

OpenCode has native skill discovery (same format as the Agent Skills spec) and also automatically reads the `.claude/skills/` folder, so a single install can serve both OpenCode and Claude Code at once:

```bash
# Global — applies to all projects
git clone https://github.com/sirizqi/product-requirement-documents.git ~/.config/opencode/skills/prd
git clone https://github.com/sirizqi/azure-devops-ticket-skill.git ~/.config/opencode/skills/azure-devops-ticket-skill

# Or per-project
git clone https://github.com/sirizqi/product-requirement-documents.git .opencode/skills/prd
git clone https://github.com/sirizqi/azure-devops-ticket-skill.git .opencode/skills/azure-devops-ticket-skill
```

After cloning, make sure `SKILL.md` sits directly inside that folder (e.g. `~/.config/opencode/skills/prd/SKILL.md`) — rename the folder if it doesn't. The `prd-writer`/`pbi-writer` agents in this repo already have `permission.skill: allow` scoped to skills named exactly `prd` and `azure-devops-ticket-skill`, so the folder name must match.

### Install on Claude Code

```bash
git clone https://github.com/sirizqi/product-requirement-documents.git ~/.claude/skills/prd
git clone https://github.com/sirizqi/azure-devops-ticket-skill.git ~/.claude/skills/azure-devops-ticket-skill
```

(OpenCode will also automatically pick this up since it's compatible with the `.claude/skills/` layout.)

---

## Install — OpenCode

1. Copy the `agent/` folder into one of the following locations:
   - Global: `~/.config/opencode/agent/`
   - Per-project: `.opencode/agent/` (at the root of your project repo)
2. (Optional) Copy the contents of `opencode.json.example` into your project's `opencode.json`, or let OpenCode auto-detect agents from the markdown filenames (filename = agent name).
3. Run `opencode`, then:
   - Switch to the `xhakala` agent as your primary agent.
   - Call a subagent directly with `@market-research`, `@prd-writer`, etc.
4. Verify registration: `opencode agent list`.

## Install — Claude Code

1. Copy `.claude/agents/xhakala.md` into the `.claude/agents/` folder of your project (or `~/.claude/agents/` for a global install).
2. For the other subagents, create a new file per subagent using the same frontmatter pattern (`name`, `description`, `tools`, `model`) — the body/system prompt can be copied as-is from the matching file in the `agent/` folder (OpenCode format), no changes needed.
3. Claude Code will automatically surface this agent based on its `description`, or you can call it explicitly with `@xhakala`.

### Frontmatter mapping table (OpenCode → Claude Code)

| OpenCode | Claude Code | Note |
|---|---|---|
| filename (`xhakala.md`) | `name: xhakala` | Claude Code requires an explicit `name` field |
| `description` | `description` | Identical, can be copied directly |
| `mode: primary` | (no equivalent field) | Claude Code doesn't distinguish primary/subagent explicitly in frontmatter |
| `mode: subagent` | (every file in `.claude/agents/` is automatically treated as a callable subagent) | |
| `permission.edit/bash/webfetch/...` | `tools: Read, Write, Edit, Grep, Glob, Bash, WebFetch, WebSearch` | An explicit tool list, rather than per-action permissions |
| `model` | `model` | Can be `inherit` in Claude Code to follow the parent session's model |
| markdown body (system prompt) | markdown body (system prompt) | **Identical**, just copy-paste |

## Install — Hermes / other agentic tools

Since every agent runtime has its own configuration schema, use this pattern:

1. Take the **markdown body** (the part after the `---` frontmatter) from the desired agent file in the `agent/` folder — this is a pure system prompt, portable to any tool.
2. Paste it as the system prompt/persona in that tool.
3. Adjust the tool/permission control fields to match that tool's own schema (see that tool's docs) — each file's `description` field can be used as the agent's description/trigger.
4. For multi-agent orchestration (primary calling subagents), adapt to that tool's own delegation mechanism (e.g. tool-calling, routing, or a multi-agent graph) — the "How you work with subagents" section in `xhakala.md` can serve as a reference for the routing logic.

## How to use (example workflow)

```
User -> @xhakala: "I want to launch a real-time shipment tracking feature.
                    Help me go from research to sprint-ready."

Xhakala will:
1. Delegate to @market-research  -> benchmark competitor tracking features
2. Delegate to @user-research    -> synthesize customer pain points around shipment visibility
3. Write / delegate to @prd-writer -> full PRD
4. Delegate to @tech-feasibility -> flag integration risk with existing courier systems
5. Delegate to @roadmap-prioritization -> RICE score vs. other roadmap initiatives
6. Delegate to @pbi-writer        -> break the PRD into PBIs ready for Azure DevOps/Jira
7. Delegate to @gtm-launch        -> rollout plan & positioning
8. Delegate to @metrics-okr       -> success metrics & related OKRs
9. Delegate to @stakeholder-comms -> executive update for leadership
```

## Customization

- **Rename the persona**: edit the `description` field and heading in `agent/xhakala.md` — the filename determines the agent's name in OpenCode, so rename the file if you want to change the persona's name.
- **Adjust for your industry**: add domain-specific context (e.g. logistics/fintech) to the "Operating philosophy" or "Areas of expertise" section in `xhakala.md` so recommendations are more relevant to your business.
- **Integrate with an external tracker**: the `pbi-writer.md` output is already designed to be compatible with Azure DevOps/Jira via the user's skill; adjust template fields (e.g. add `Iteration Path`, `Area Path`) as needed.
- **Restrict tool access**: tighten the `permission` block in each `agent/*.md` file (e.g. `bash: deny`, `edit: deny`) to match the level of trust you want per subagent.

## License

Feel free to use, modify, and republish this as needed (add your license of choice, e.g. MIT, in a `LICENSE` file before publishing to GitHub).
