#!/usr/bin/env bash
#
# Product Manager Agent Uninstaller
# Cleans up installed agents across OpenCode, Claude Code, Codex, and Hermes.
#

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Text colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${BLUE}Uninstalling Product Manager Agent...${NC}"

# OpenCode
if [[ -d "$HOME/.config/opencode/agents" ]]; then
    for f in "$REPO_DIR"/agent/*.md; do
        fname=$(basename "$f")
        rm -f "$HOME/.config/opencode/agents/$fname"
    done
    rm -rf "$HOME/.config/opencode/templates"
    echo -e "${GREEN}  ✓ Cleaned up OpenCode agents and templates${NC}"
fi

# Claude Code
if [[ -d "$HOME/.claude/agents" ]]; then
    for f in "$REPO_DIR"/.claude/agents/*.md; do
        fname=$(basename "$f")
        rm -f "$HOME/.claude/agents/$fname"
    done
    echo -e "${GREEN}  ✓ Cleaned up Claude Code agents${NC}"
fi

# Codex
if [[ -d "$HOME/.codex/skills/product-manager" ]]; then
    rm -rf "$HOME/.codex/skills/product-manager"
    echo -e "${GREEN}  ✓ Removed Codex product-manager skill${NC}"
fi

# Hermes
if [[ -d "$HOME/.hermes/agents/product-manager" ]]; then
    rm -rf "$HOME/.hermes/agents/product-manager"
    echo -e "${GREEN}  ✓ Removed Hermes product-manager agent${NC}"
fi

echo -e "${BOLD}${GREEN}Uninstall complete.${NC}"
