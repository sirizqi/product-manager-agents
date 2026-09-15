#!/usr/bin/env bash
#
# Product Manager Agent Installer
# Cross-platform installer for OpenCode, Claude Code, OpenAI Codex, Hermes, and custom projects.
#

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACTION="symlink" # default: symlink for easy updates, or 'copy'
TARGET_OPENCODE=false
TARGET_CLAUDE=false
TARGET_CODEX=false
TARGET_HERMES=false
TARGET_PROJECT=""
AUTO_DETECT=true

# Text colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_banner() {
    echo -e "${BOLD}${BLUE}====================================================${NC}"
    echo -e "${BOLD}${BLUE}      AI Senior Product Manager Agent Installer     ${NC}"
    echo -e "${BOLD}${BLUE}====================================================${NC}"
    echo ""
}

show_help() {
    print_banner
    echo -e "Usage: ./install.sh [options]"
    echo ""
    echo "Options:"
    echo "  --all             Install globally to all detected runtimes (OpenCode, Claude Code, Codex, Hermes)"
    echo "  --opencode        Install globally to OpenCode (~/.config/opencode/agents/)"
    echo "  --claudecode      Install globally to Claude Code (~/.claude/agents/)"
    echo "  --codex           Install globally to OpenAI Codex (~/.codex/skills/ & ~/.codex/AGENTS.md)"
    echo "  --hermes          Install globally to Hermes (~/.hermes/agents/product-manager/)"
    echo "  --project <dir>   Install into a specific project workspace"
    echo "  --copy            Copy files instead of creating symlinks (default is symlink)"
    echo "  --help, -h        Show this help message"
    echo ""
    echo "If no runtime flags are specified, install.sh will auto-detect which runtimes exist on your system."
    exit 0
}

# Parse flags
while [[ $# -gt 0 ]]; do
    case "$1" in
        --all)
            TARGET_OPENCODE=true
            TARGET_CLAUDE=true
            TARGET_CODEX=true
            TARGET_HERMES=true
            AUTO_DETECT=false
            shift
            ;;
        --opencode)
            TARGET_OPENCODE=true
            AUTO_DETECT=false
            shift
            ;;
        --claudecode|--claude)
            TARGET_CLAUDE=true
            AUTO_DETECT=false
            shift
            ;;
        --codex)
            TARGET_CODEX=true
            AUTO_DETECT=false
            shift
            ;;
        --hermes)
            TARGET_HERMES=true
            AUTO_DETECT=false
            shift
            ;;
        --project)
            TARGET_PROJECT="${2:-}"
            if [[ -z "$TARGET_PROJECT" ]]; then
                echo -e "${RED}Error: --project requires a directory path${NC}"
                exit 1
            fi
            AUTO_DETECT=false
            shift 2
            ;;
        --copy)
            ACTION="copy"
            shift
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            ;;
    esac
done

link_or_copy() {
    local src="$1"
    local dest="$2"

    mkdir -p "$(dirname "$dest")"
    if [[ -e "$dest" || -L "$dest" ]]; then
        rm -rf "$dest"
    fi

    if [[ "$ACTION" == "copy" ]]; then
        cp -R "$src" "$dest"
    else
        ln -sf "$src" "$dest"
    fi
}

print_banner

# Auto-detect if no specific runtime flag was provided
if [[ "$AUTO_DETECT" == true && -z "$TARGET_PROJECT" ]]; then
    echo -e "${YELLOW}Auto-detecting installed AI runtimes on this system...${NC}"
    if [[ -d "$HOME/.config/opencode" || -f "$HOME/.config/opencode/opencode.jsonc" || -f "$HOME/.config/opencode/opencode.json" ]]; then
        TARGET_OPENCODE=true
        echo -e "  [+] OpenCode detected (~/.config/opencode)"
    fi
    if [[ -d "$HOME/.claude" ]]; then
        TARGET_CLAUDE=true
        echo -e "  [+] Claude Code detected (~/.claude)"
    fi
    if [[ -d "$HOME/.codex" ]]; then
        TARGET_CODEX=true
        echo -e "  [+] OpenAI Codex detected (~/.codex)"
    fi
    if [[ -d "$HOME/.hermes" ]]; then
        TARGET_HERMES=true
        echo -e "  [+] Hermes detected (~/.hermes)"
    fi

    if [[ "$TARGET_OPENCODE" == false && "$TARGET_CLAUDE" == false && "$TARGET_CODEX" == false && "$TARGET_HERMES" == false ]]; then
        echo -e "${YELLOW}No existing runtime folders found. Installing to OpenCode, Claude Code, and Codex by default.${NC}"
        TARGET_OPENCODE=true
        TARGET_CLAUDE=true
        TARGET_CODEX=true
    fi
    echo ""
fi

# 1. Install for OpenCode
if [[ "$TARGET_OPENCODE" == true ]]; then
    OPENCODE_DIR="$HOME/.config/opencode"
    OPENCODE_AGENTS_DIR="$OPENCODE_DIR/agents"
    mkdir -p "$OPENCODE_AGENTS_DIR"

    echo -e "${BLUE}Installing to OpenCode (${OPENCODE_AGENTS_DIR})...${NC}"
    for f in "$REPO_DIR"/agent/*.md; do
        fname=$(basename "$f")
        link_or_copy "$f" "$OPENCODE_AGENTS_DIR/$fname"
    done
    link_or_copy "$REPO_DIR/templates" "$OPENCODE_DIR/templates"
    echo -e "${GREEN}  ✓ Installed 12 subagents + templates to OpenCode${NC}"
fi

# 2. Install for Claude Code
if [[ "$TARGET_CLAUDE" == true ]]; then
    CLAUDE_AGENTS_DIR="$HOME/.claude/agents"
    mkdir -p "$CLAUDE_AGENTS_DIR"

    echo -e "${BLUE}Installing to Claude Code (${CLAUDE_AGENTS_DIR})...${NC}"
    for f in "$REPO_DIR"/.claude/agents/*.md; do
        fname=$(basename "$f")
        link_or_copy "$f" "$CLAUDE_AGENTS_DIR/$fname"
    done
    echo -e "${GREEN}  ✓ Installed 12 subagents to Claude Code${NC}"
fi

# 3. Install for OpenAI Codex
if [[ "$TARGET_CODEX" == true ]]; then
    CODEX_DIR="$HOME/.codex"
    CODEX_PM_DIR="$CODEX_DIR/skills/product-manager"
    mkdir -p "$CODEX_PM_DIR"

    echo -e "${BLUE}Installing to OpenAI Codex (${CODEX_DIR})...${NC}"
    link_or_copy "$REPO_DIR/AGENTS.md" "$CODEX_PM_DIR/AGENTS.md"
    link_or_copy "$REPO_DIR/templates" "$CODEX_PM_DIR/templates"
    link_or_copy "$REPO_DIR/agent" "$CODEX_PM_DIR/agent"

    # Also make sure ~/.codex/AGENTS.md has reference to PM agent if empty or not present
    if [[ ! -f "$CODEX_DIR/AGENTS.md" || ! -s "$CODEX_DIR/AGENTS.md" ]]; then
        link_or_copy "$REPO_DIR/AGENTS.md" "$CODEX_DIR/AGENTS.md"
        echo -e "${GREEN}  ✓ Linked global AGENTS.md to $CODEX_DIR/AGENTS.md${NC}"
    else
        echo -e "${YELLOW}  ℹ Existing $CODEX_DIR/AGENTS.md preserved (skill installed at $CODEX_PM_DIR)${NC}"
    fi
    echo -e "${GREEN}  ✓ Installed Product Manager skill to OpenAI Codex${NC}"
fi

# 4. Install for Hermes
if [[ "$TARGET_HERMES" == true ]]; then
    HERMES_DIR="$HOME/.hermes/agents/product-manager"
    mkdir -p "$HERMES_DIR"

    echo -e "${BLUE}Installing to Hermes (${HERMES_DIR})...${NC}"
    link_or_copy "$REPO_DIR/agent" "$HERMES_DIR/agent"
    link_or_copy "$REPO_DIR/templates" "$HERMES_DIR/templates"
    echo -e "${GREEN}  ✓ Installed to Hermes agent directory${NC}"
fi

# 5. Install to a specific project directory
if [[ -n "$TARGET_PROJECT" ]]; then
    echo -e "${BLUE}Installing into project: ${TARGET_PROJECT}...${NC}"
    if [[ ! -d "$TARGET_PROJECT" ]]; then
        echo -e "${RED}Error: Project directory $TARGET_PROJECT does not exist.${NC}"
        exit 1
    fi

    # Project-level Claude Code agents
    mkdir -p "$TARGET_PROJECT/.claude/agents"
    for f in "$REPO_DIR"/.claude/agents/*.md; do
        fname=$(basename "$f")
        link_or_copy "$f" "$TARGET_PROJECT/.claude/agents/$fname"
    done

    # Project-level OpenCode agents & templates
    mkdir -p "$TARGET_PROJECT/.opencode/agents"
    for f in "$REPO_DIR"/agent/*.md; do
        fname=$(basename "$f")
        link_or_copy "$f" "$TARGET_PROJECT/.opencode/agents/$fname"
    done
    link_or_copy "$REPO_DIR/templates" "$TARGET_PROJECT/templates"
    link_or_copy "$REPO_DIR/AGENTS.md" "$TARGET_PROJECT/AGENTS.md"

    echo -e "${GREEN}  ✓ Configured .claude/agents, .opencode/agents, templates, and AGENTS.md in $TARGET_PROJECT${NC}"
fi

echo ""
echo -e "${BOLD}${GREEN}Installation completed successfully!${NC}"
echo -e "${BOLD}Quick Usage Guide:${NC}"
echo -e "  - ${BOLD}OpenCode:${NC}   Use @prd-writer or @pbi-writer in your chat."
echo -e "  - ${BOLD}Claude Code:${NC} Use @prd-writer or @pbi-writer in your CLI session."
echo -e "  - ${BOLD}Codex:${NC}       Reference AGENTS.md or invoke the Product Manager skill."
echo -e "  - ${BOLD}Templates:${NC}   Canonical Outline PRD & Azure DevOps PBI templates are available in templates/"
