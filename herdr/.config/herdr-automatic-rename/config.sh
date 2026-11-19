# Settings for the herdr-automatic-rename plugin (qu8n/herdr-automatic-rename),
# which names Herdr tabs like tmux's automatic-rename: "[1] nvim", or the task
# an agent is working on. Installed, pinned to a version, by omarchy-supplement's
# install-overrides.sh; its shell hook is loaded from ~/.config/bash/aliases.
# The plugin sources this file, so it is shell syntax. Every setting and its
# default: config.example.sh in the plugin's repo.

# Number the tabs, not the workspaces: "[2] nvim" in the tab bar, plain
# workspace names in the sidebar.
AUTO_INDEX_WORKSPACES=0
