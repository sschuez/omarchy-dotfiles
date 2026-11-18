#!/usr/bin/env bash
# Claude Code PreToolUse hook (Bash). Blocks destructive database commands, so
# a development database is never dropped or emptied without asking first.
# Contract: exit 2 + stderr blocks the call and tells Claude why.
set -euo pipefail

cmd="$(jq -r '.tool_input.command // empty')"
destructive='db:(drop|reset|migrate:reset|schema:load|truncate)|truncate_all|\bdropdb\b|TRUNCATE +(TABLE +)?|DELETE +FROM '

if echo "$cmd" | grep -qiE "$destructive"; then
  echo "BLOCKED: destructive database command. Ask the user first, and target only the database they name." >&2
  exit 2
fi
exit 0
