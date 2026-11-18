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
the file. `~/.config/bash` and `~/.config/xcompose` are such folder links.

## Packages

| Package | Files in `~` | What | Loaded by |
|---|---|---|---|
| `bash` | `.config/bash/aliases` | Aliases and functions: Bundler, tools, Docker Compose (`dcr` starts Selenium for system tests) | Include line in `~/.bashrc` |
| `hypr` | `.config/hypr/overrides.lua` | Caps Lock as Ctrl, window rounding | Include line in `~/.config/hypr/hyprland.lua` |
| `omarchy` | `.config/omarchy/keyboard-layouts` | US International keyboard (`"` then `a` = ä) | Omarchy's Hyprland config. fcitx5 is matched by `install-keyboard.sh` in omarchy-supplement. |
| `xcompose` | `.config/xcompose/dead-keys` | Windows-style dead keys: they combine with vowels only (plus ç, ñ), so `I'm`, `"hello"` and `''` type as-is | Include line in `~/.XCompose` |
| `tmux` | `.config/tmux/overrides.conf` | Vim-style navigation: `Ctrl+h/j/k/l` across panes and Neovim splits, `Alt+Shift+H/L` windows, `prefix h/j/k/l` panes, `prefix X` kill window, `prefix \|` / `prefix -` splits | Include line in `~/.config/tmux/tmux.conf` |
| `nvim` | `.config/nvim/lazyvim.json` | LazyVim extras (owned outright, see below) | LazyVim |
| | `.config/nvim/lua/plugins/lsp.lua` | Language servers (Ruby LSP, Herb, HTML, CSS, Emmet, XML), formatting through the language servers, extra syntax parsers | LazyVim, which loads every file in `lua/plugins/` |
| | `.config/nvim/lua/plugins/tmux-navigator.lua` | Neovim side of the `Ctrl+h/j/k/l` tmux navigation | LazyVim |
| | `.config/nvim/plugin/personal.lua` | Relative line numbers, format on save | Neovim, which runs every file in `plugin/` |
| `mise` | `.default-gems` | `ruby-lsp`, installed with every Ruby mise installs | mise |

## Editing and applying changes

The files in `~` are symlinks into this repo, so edit either path, then commit
here.

| Change | Apply with |
|---|---|
| Bash | Open a new terminal |
| Hyprland | `hyprctl reload && hyprctl configerrors` |
| Keyboard layout | `hyprctl reload`, then `~/Code/omarchy-supplement/install-keyboard.sh` |
| XCompose | `omarchy restart xcompose` |
| tmux | `prefix q` |
| Neovim | Restart Neovim. Toggle extras with `:LazyExtras`; the change lands in `lazyvim.json` here. |

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
  `lazyvim.json` is the exception: LazyVim warns about extras loaded from
  anywhere else, and Omarchy's updates don't touch that file.
- **No monitor settings.** They're machine-specific; Omarchy writes
  `~/.config/hypr/monitors.lua` per machine.
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
