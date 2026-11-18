#!/usr/bin/env bash
# Claude Code PreToolUse hook (Bash). A bare `bin/ci` ends with a GitHub signoff
# that deploys on protected branches (submissio's AGENTS.md). Block it there;
# `dcr bin/ci` (Docker, no signoff) and any feature branch stay allowed.
# Contract: exit 2 + stderr blocks the call and tells Claude why.
set -euo pipefail

input="$(cat)"
cmd="$(jq -r '.tool_input.command // empty' <<<"$input")"
# cwd follows Claude into a worktree; CLAUDE_PROJECT_DIR stays at the start.
dir="$(jq -r '.cwd // empty' <<<"$input")"
dir="${dir:-${CLAUDE_PROJECT_DIR:-$PWD}}"

if echo "$cmd" | grep -qE '(^|[;&|] *)(bin/ci)\b'; then
  branch="$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')"
  if [[ "$branch" =~ ^(main|develop|testing)$ ]]; then
    echo "BLOCKED: bare 'bin/ci' on protected branch '$branch' signs off and deploys. Run it on a feature branch, or use 'dcr bin/ci'." >&2
    exit 2
  fi
fi
exit 0
