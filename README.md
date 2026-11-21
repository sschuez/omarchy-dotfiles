# omarchy-dotfiles

Only **my changes** on top of [Omarchy](https://omarchy.org), organised as
[GNU Stow](https://www.gnu.org/software/stow/) packages. Omarchy's own config
files stay untouched apart from one include line each.

Installed and hooked in by
[omarchy-supplement](https://github.com/sschuez/omarchy-supplement): on a new
machine, run its `install-all.sh`, not anything in here.

## How Stow works here

Each top-level folder is a package. Inside it, paths mirror the home folder:

```
tmux/.config/tmux/overrides.conf   →   ~/.config/tmux/overrides.conf (symlink)
```

`stow -t ~ tmux` creates the symlink and `stow -t ~ -D tmux` removes it. The
`-t ~` matters, because this repo lives in `~/Code`, not in `~`.

If the target folder doesn't exist yet, Stow links the whole folder instead of
the file. `~/.config/bash`, `~/.config/xcompose` and `~/.config/clouds` are
such folder links.

## Packages

| Package | Files in `~` | What | Loaded by |
|---|---|---|---|
| `bash` | `.config/bash/aliases` | Aliases and functions: Bundler, tools, Docker Compose (`dcr` starts Selenium for system tests). Last, the shell hook of my Herdr tabs plugin: it renames the tab when a command starts or ends (does nothing outside Herdr) | Include line in `~/.bashrc` |
| `hypr` | `.config/hypr/overrides.lua` | Apple Studio Display at 2.5x, Caps Lock as Ctrl, window rounding, `Super+[` / `Super+]` previous/next workspace, `Super+U` / `Super+I` browser/terminal workspace (Shift moves the window there), `Alt+[` / `Alt+]` previous/next browser tab, the keys for Window Overview (`Super+E`, `Super+Tab`), `Super+B` for the Brain.fm panel, apps on fixed workspaces (1 HEY, 2 Chalet, 3 browser, 4 terminals, 5 WhatsApp/AppSignal/Signal, 6 Claude, 7 Files) on whichever screen has focus, workspaces that keep their number when a screen is unplugged or the lid closes | Include line in `~/.config/hypr/hyprland.lua` |
| `omarchy` | `.config/omarchy/keyboard-layouts` | US International keyboard (`"` then `a` = ä) | Omarchy's Hyprland config. fcitx5 is matched by `install-keyboard.sh` in omarchy-supplement. |
| | `.config/omarchy/plugins/stephen.workspaces/` | Clone of Omarchy's workspaces bar widget that shows all ten workspaces, not the first five | Omarchy shell (enabled by `install-overrides.sh`) |
| `xcompose` | `.config/xcompose/dead-keys` | Windows-style dead keys: they combine with vowels only (plus ç, ñ), so `I'm`, `"hello"` and `''` type as-is | Include line in `~/.XCompose` |
| `tmux` | `.config/tmux/overrides.conf` | Vim-style navigation: `Ctrl+h/j/k/l` across panes and Neovim splits, `Alt+Shift+H/L` windows, `prefix h/j/k/l` panes, `prefix X` kill window, `prefix \|` / `prefix -` splits | Include line in `~/.config/tmux/tmux.conf` |
| `nvim` | `.config/nvim/lazyvim.json` | LazyVim extras (owned outright, see below) | LazyVim |
| | `.config/nvim/lua/plugins/lsp.lua` | Language servers (Ruby LSP, Herb, HTML, CSS, Emmet, XML), formatting through the language servers, extra syntax parsers | LazyVim, which loads every file in `lua/plugins/` |
| | `.config/nvim/lua/plugins/tmux-navigator.lua` | Neovim side of the `Ctrl+h/j/k/l` navigation, in tmux and in Herdr | LazyVim |
| | `.config/nvim/plugin/personal.lua` | Relative line numbers, format on save | Neovim, which runs every file in `plugin/` |
| `mise` | `.default-gems` | `ruby-lsp`, installed with every Ruby mise installs | mise |
| `herdr` | `.config/herdr/config.toml` | Herdr keys like tmux: `Ctrl+h/j/k/l` across panes and Neovim splits, `Ctrl+Alt+h/j/k/l` and `prefix h/j/k/l` focus panes, `prefix \|` / `prefix -` split, `prefix Shift+H/J/K/L` swap panes, `prefix X` close tab, `prefix D` close workspace, `Alt+Shift+H/L` tabs, `Alt+Shift+Left/Right` move a tab; sidebar in the style of Omarchy's tmux (active in bold accent blue, no filled rows) (owned outright, see below) | Herdr |
| | `.config/herdr/navigate-plugin/` | Herdr's half of vim-tmux-navigator: hands `Ctrl+h/j/k/l` on to Neovim (or fzf) when it's in the focused pane, focuses the next pane otherwise and leaves zoom on the way, as tmux does. A plugin because Herdr runs those without a login shell (~8 ms a press instead of ~19) | `herdr plugin link ~/.config/herdr/navigate-plugin`, bound in `config.toml` |
| | `.config/herdr/tabs-plugin/` | Tab names like tmux's automatic-rename: `2 nvim`, the folder for a shell at its prompt, the task for an agent. About 110 lines, 15–25 ms a run. A tab renamed by hand keeps its name; rename it to a bare number to hand it back | `herdr plugin link ~/.config/herdr/tabs-plugin` (Herdr's events), and the shell hook in `bash/.config/bash/aliases` (commands starting and ending) |
| `bin` | `.local/bin/wt` | Git worktrees with their own ports, Docker project and databases, fully cleaned up on removal (run `wt` for help) | Claude Code's `WorktreeCreate` / `WorktreeRemove` hooks, or by hand |
| `claude` | `.claude/hooks/block-*.sh` | Claude Code safety hooks: no bare `bin/ci` on `main`/`develop`/`testing` (it signs off and deploys), no destructive database commands | `PreToolUse` hooks merged into `~/.claude/settings.json` by `install-overrides.sh` |
| `wifi` | `.local/bin/wifi-sync` | The same Wi-Fi networks and passwords on this machine (NetworkManager) and in 1Password (vault `Wi-Fi`, personal account): saves this machine's networks there, adds the ones it doesn't know from there (run `wifi-sync help`) | The service below, or by hand; on a new machine, `install-wifi.sh` in omarchy-supplement |
| | `.config/systemd/user/wifi-sync.service` | Runs `wifi-sync watch`: a sync when this machine joins a network it hasn't synced before, with a notification saying what was saved or added | systemd (user service), enabled by `install-wifi.sh` in omarchy-supplement |
| `rclone` | `.config/systemd/user/rclone-gdrive.service` | Google Drive as the folder `~/GoogleDrive`, with `My Drive` and one folder per shared drive inside: mounted by rclone at login, files fetched when they're opened, the last 10 GB opened kept on disk for 30 days, Google Docs as links that open in the browser | systemd (user service), enabled by `install-google-drive.sh` in omarchy-supplement, which also does the Google sign-in |
| | `.config/systemd/user/rclone-icloud.service` | iCloud Drive as the folder `~/iCloudDrive`, mounted the same way; folder listings refreshed every 5 minutes, since iCloud doesn't report changes. Not mounted with a sign-in Apple refuses | systemd (user service), enabled by `install-icloud-drive.sh` in omarchy-supplement, which also does the Apple sign-in |
| | `.local/bin/icloud-signin-check` | Asks whether Apple still takes iCloud Drive's sign-in (it lasts 30 days). If not: a notification that opens the sign-in in a terminal when clicked | The mount's unit before it mounts, the two below every hour, and `install-icloud-drive.sh` |
| | `.config/systemd/user/rclone-icloud-check.timer`, `.service` | Every hour while iCloud Drive is mounted: unmounts it once Apple refuses the sign-in, so the folder is empty, not full of errors | systemd (user timer), enabled by `install-icloud-drive.sh` |
| `clouds` | `.local/bin/infomaniak`, `.local/bin/exoscale` | One command against a cloud, with its keys from 1Password for that command alone: `infomaniak openstack …` and `infomaniak aws …` for Infomaniak's Public Cloud (chalet), `exoscale exo …` for Exoscale (submissio). Which items they read, and how the keys are made: omarchy-supplement's README, "Clouds" | By hand; the command lines come from `install-cloud-clis.sh` in omarchy-supplement |
| | `.config/clouds/infomaniak-aws.conf` | aws's settings under `infomaniak`: Infomaniak's endpoint and region, and the bucket in the path, as chalet's own client sends it | `infomaniak` (`AWS_CONFIG_FILE`) |

## Editing and applying changes

The files in `~` are symlinks into this repo, so edit either path, then commit
here.

| Change | Apply with |
|---|---|
| Bash | Open a new terminal |
| Hyprland | `hyprctl reload && hyprctl configerrors` |
| Shell plugins | `omarchy restart shell` (the shell doesn't notice edits made through the symlinks) |
| Window Overview | Lives in its own repo, see below |
| Keyboard layout | `hyprctl reload`, then `~/Code/omarchy-supplement/install-keyboard.sh` |
| XCompose | Edit the rules in `xcompose/.config/xcompose/generate-dead-keys`, run it, then `omarchy restart xcompose` |
| tmux | `prefix q` |
| Google Drive mount | `systemctl --user daemon-reload && systemctl --user restart rclone-gdrive` |
| iCloud Drive mount | `systemctl --user daemon-reload && systemctl --user restart rclone-icloud` |
| `wifi-sync` | `systemctl --user daemon-reload && systemctl --user restart wifi-sync` (the service keeps running the script it started with) |
| Neovim | Restart Neovim. Toggle extras with `:LazyExtras`; the change lands in `lazyvim.json` here. |

## Window Overview

`Super+E` shows every window on every workspace as a live thumbnail (type to
search, a number jumps to that workspace's window, `Ctrl+W` closes one), and
`Super+Tab` switches windows the Mac way, like Cmd+Tab (`Alt+Tab` stays Omarchy's). It is my shell plugin
[omarchy-window-overview](https://github.com/sschuez/omarchy-window-overview),
kept in its own repo so it can be listed in Omarchy's plugin marketplace. Only
its keys are here, in `hypr/.config/hypr/overrides.lua`.

omarchy-supplement's `install-overrides.sh` installs it with
`omarchy plugin add`; update it with
`omarchy plugin update io.github.sschuez.window-overview`. To work on it, clone
it to `~/Code/omarchy-window-overview`, link
`~/.config/omarchy/plugins/io.github.sschuez.window-overview` to that folder,
and run `omarchy restart shell` after each change.

## Brain.fm

`Super+B` opens Brain.fm in the bar: my player for it, kept in a repo of its
own (private). Only its key and the window rule for its terminal player are
here, in `hypr/.config/hypr/overrides.lua`. omarchy-supplement's
`install-brainfm.sh` clones it to `~/Code/brainfm-tui` and runs its installer
with `--no-keybind`, so nothing is added to Omarchy's `bindings.lua`. To
update it, pull there and run `./install.sh --no-keybind`.

## Adding a package

```sh
mkdir -p <package>/<path relative to ~>
# create the file there, then:
stow -t ~ <package>
```

Then add the package to `PACKAGES` in omarchy-supplement's
`install-dotfiles.sh`, plus an include line in its `install-overrides.sh` if
the app needs one.

## Decisions worth knowing

- **Overlay, not replace.** Each file holds only my differences and is loaded
  after Omarchy's version, so Omarchy can keep improving its defaults.
  Owned outright instead: `lazyvim.json` (LazyVim warns about extras loaded
  from anywhere else) and Herdr's `config.toml` (no include mechanism; Omarchy's
  update migrations skip a symlinked one, so check its release notes for Herdr
  changes). The workspaces widget is a clone, Omarchy's sanctioned way to change
  a built-in widget, so it no longer gets Omarchy's updates either.
- **No machine monitor settings.** They're machine-specific; Omarchy writes
  `~/.config/hypr/monitors.lua` per machine. The one exception is the Apple
  Studio Display's 2.5x scale in `overrides.lua`: it's matched by the display's
  name, so it belongs to the display, not to a machine. Because overrides load
  last, it wins over Omarchy's Display panel after a `hyprctl reload`.
- **Workspaces by slot, not by number.** Omarchy gives each monitor its own
  workspaces 1-10, which Hyprland numbers 1-10 on the laptop panel and 11-20,
  21-30 on other monitors. So the fixed app workspaces are a `window.open`
  handler that moves the window to a slot on the focused screen (through
  `o.workspaces`), not window rules: a rule's `workspace = "3"` always means the
  laptop panel's 3. `Super+[` / `]` and `Super+U` / `I` use slots too.
  `Super+I` replaces Omarchy's input language switch, unused with one input method.
- **Slots survive a screen change.** When a screen goes away, Omarchy queues its
  workspaces after the remaining screen's own and sends them back when it
  returns. A screen that has just woken up shows an empty 1, so everything
  landed one slot too far. `overrides.lua` wraps `o.workspaces.reconcile` to
  renumber them into the same slots first (the monitor's 3 becomes the laptop's
  3), merging a slot both screens use. The price: they belong to the new screen
  now, so with both screens on they don't go back by themselves. If an Omarchy
  update changes `reconcile`, this is the place to look.
- **Keyboard layout in Omarchy's file, not in Hyprland overrides.** Omarchy
  routes typing through fcitx5, which re-sends keys with its own layout. Both
  have to say US International, and Omarchy's `omarchy setup keyboard` picker
  doesn't list it.
- **Ruby LSP from mise, not Mason**, so each project uses its own Ruby. Neovim
  starts `ruby-lsp` from the project folder, and mise picks the version.
- **Formatting goes through the language servers:** Ruby via Ruby LSP (the
  project's RuboCop), ERB via Herb (the project's `.herb.yml`). This replaces
  the Ruby extra's `rubocop` and `erb_format` command-line formatters.
- **Rails navigation via Ruby LSP** (`gd` on associations, callbacks, routes).
  vim-rails isn't installed; add it only if `:A` / `:R` turn out to be missed.
- **Worktrees without per-repo setup.** `wt` derives everything from
  conventions: ports from `${X_PORT:-default}` in the compose file (default +
  slot), `COMPOSE_PROJECT_NAME=<repo>_<name>`, Postgres names when
  `config/database.yml` reads `POSTGRES_DB` / `POSTGRES_TEST_DB`. Teardown only
  touches names it generated for that worktree. Worktrees live inside the
  repo, in `<repo>/.claude/worktrees/<name>`, where Claude Code puts its own.
  A repo that does not gitignore that folder gets it in `.git/info/exclude`.
- **Wi-Fi passwords in 1Password, not here.** Both repos are public. `wifi-sync`
  keeps each network as a Wireless Router item, 1Password's own type for it, in
  a vault of its own, and copies between that and NetworkManager, which is where
  Omarchy's network panel saves them. 1Password never talks to the system's
  Wi-Fi itself. The service syncs when a new network is joined, not on a timer:
  1Password may ask for approval, and that should come when I have just typed a
  Wi-Fi password, not out of nowhere. So a network added on another machine
  arrives with the next new network here, or with `wifi-sync` by hand. It never
  overwrites or deletes: a password changed on one side is reported as a
  difference to settle by hand.
- **Google Drive is mounted, not synced.** rclone fetches a file when it's
  opened, so the whole Drive is there without taking up disk space, and only
  what was opened lately works offline. Google Docs, Sheets and Slides are
  links that open in the browser: exported to .docx they have a size of 0 in a
  mount and often can't be opened. Only the unit is here. The Google sign-in
  lives in `~/.config/rclone/rclone.conf` and my Google API client in
  1Password (see omarchy-supplement). `systemctl --user disable` removes the
  unit's Stow link along with its own; restow the package to get it back.
- **iCloud Drive is unmounted once Apple refuses its sign-in.** The sign-in
  lasts 30 days, and rclone doesn't renew it: it keeps running on a folder that
  only shows errors, or fails and is started again every 30 seconds. So
  `icloud-signin-check` asks Apple before every mount (the unit's
  `ExecCondition`) and every hour after that (`rclone-icloud-check.timer`). On
  a refusal the folder is unmounted, and a notification runs
  `install-icloud-drive.sh` from omarchy-supplement when clicked: the password
  from 1Password (it is not kept on this machine), a new code from the iPhone,
  and it's mounted again. The check goes by the words of
  rclone's errors, listed in the script: if an rclone update changes them,
  that is the place to look.
- **Cloud keys in 1Password, not in the command lines' config.** openstack,
  aws and exo would each keep a key in a file of their own (`clouds.yaml`,
  `~/.aws/credentials`, `exoscale.toml`). `infomaniak` and `exoscale` hand it
  to one command with `op run` instead, so nothing on disk opens a cloud and a
  new machine needs only 1Password. The price is 1Password's approval, as for
  any `op` command.
