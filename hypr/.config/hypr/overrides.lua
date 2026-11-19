-- My Hyprland overrides, loaded last from ~/.config/hypr/hyprland.lua
-- so everything here wins over Omarchy's defaults.
-- Apply after editing:  hyprctl reload && hyprctl configerrors
--
-- Reference:
--   Omarchy's defaults:    /usr/share/omarchy/default/hypr/
--   Current keybindings:   omarchy menu keybindings --print

-- Rounded corners
hl.config({ decoration = { rounding = 2 } })

-- Keyboard: Caps Lock as an extra Ctrl.
-- Replaces Omarchy's kb_options (Shift+Caps = Compose); US International's
-- dead keys (" then a = ä) cover accents instead. The layout itself lives in
-- ~/.config/omarchy/keyboard-layouts (omarchy package); install-keyboard.sh in
-- omarchy-supplement makes fcitx5 match.
hl.config({ input = { kb_options = "ctrl:nocaps" } })

-- Super+[ / Super+] step through all ten workspaces, empty ones included,
-- wrapping 10 -> 1 and 1 -> 10. (Omarchy's Super+Tab skips empty ones.)
local function cycle_workspace(step)
	return function()
		local workspace = hl.get_active_workspace()
		local current = (workspace and not workspace.special and workspace.id > 0) and workspace.id or 1
		hl.dispatch(hl.dsp.focus({ workspace = tostring((current - 1 + step) % 10 + 1) }))
	end
end
o.bind("SUPER + BRACKETLEFT", "Previous workspace", cycle_workspace(-1))
o.bind("SUPER + BRACKETRIGHT", "Next workspace", cycle_workspace(1))

-- Alt+[ / Alt+] for previous/next browser tab: sends Ctrl+PgUp/PgDn, but only
-- when a browser is focused. Non-consuming, so terminals and Neovim still get
-- Alt+[ themselves. Down and up are sent separately, as in Omarchy's clipboard
-- bindings, so the synthetic key doesn't get stuck repeating.
local browsers = { chromium = true, ["google-chrome"] = true, ["brave-browser"] = true, firefox = true }
local function browser_shortcut(mods, key)
	return function()
		local window = hl.get_active_window()
		if not (window and browsers[window.class]) then
			return
		end
		hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))
		hl.timer(function()
			hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
		end, { timeout = 50, type = "oneshot" })
	end
end
o.bind("ALT + BRACKETLEFT", "Previous browser tab", browser_shortcut("CTRL", "Page_Up"), { non_consuming = true })
o.bind("ALT + BRACKETRIGHT", "Next browser tab", browser_shortcut("CTRL", "Page_Down"), { non_consuming = true })

-- Window Overview, my shell plugin (github.com/sschuez/omarchy-window-overview,
-- installed by omarchy-supplement): every window as a live thumbnail, type to
-- search, Enter to jump there. The plugin listens on Hyprland global
-- shortcuts, so a keypress starts no process.
o.bind("SUPER + E", "Window Overview", hl.dsp.global("window-overview:toggle"))
-- No compositor fade on the overview: it should just be there.
hl.layer_rule({ match = { namespace = "window-overview" }, no_anim = true, animation = "none" })

-- Alt+Tab switches windows the Mac way, through the same plugin: hold Alt, tap
-- Tab to step through the windows, most recently used first, and let go of Alt
-- to jump to the selected one. Shift goes backwards. Replaces Omarchy's
-- Alt+Tab, which only cycles the windows of the current workspace.
-- A release bind on Alt is skipped once another key (Tab) was pressed during
-- the hold, so Alt is watched while a switch is under way instead.
local switching = false
local function watch_alt()
	if hl.is_key_down("Alt_L") or hl.is_key_down("Alt_R") then
		hl.timer(watch_alt, { timeout = 15, type = "oneshot" })
	else
		switching = false
		hl.dispatch(hl.dsp.global("window-overview:switch-commit"))
	end
end
local function switch_window(direction)
	return function()
		hl.dispatch(hl.dsp.global("window-overview:switch-" .. direction))
		if not switching then
			switching = true
			watch_alt()
		end
	end
end
o.rebind("ALT + TAB", "Switch window", switch_window("next"), { repeating = true })
o.rebind("ALT + SHIFT + TAB", "Switch window back", switch_window("previous"), { repeating = true })

-- Fixed workspaces: each app always opens on its own workspace, and you're
-- taken there. Use "<n> silent" instead to open it there without switching.
-- Find an app's class with: hyprctl clients
o.window("chrome-app\\.hey\\.com__.*", { workspace = "1" }) -- HEY
o.window("chrome-chalet\\.do__.*", { workspace = "2" }) -- Chalet
o.window("(chromium|google-chrome|brave-browser|firefox)", { workspace = "3" }) -- Browser
-- Terminals, including tmux and Herdr (they run inside one). Omarchy's own
-- terminal windows (org.omarchy.*, TUI.*) don't match and stay where they open.
o.window("(Alacritty|kitty|com\\.mitchellh\\.ghostty|foot|org\\.codeberg\\.dnkl\\.foot)", { workspace = "4" })
o.window("(chrome-web\\.whatsapp\\.com__.*|signal|Signal)", { workspace = "5" }) -- WhatsApp, Signal
o.window("com\\.anthropic\\.Claude", { workspace = "6" }) -- Claude Desktop
o.window("org\\.gnome\\.Nautilus", { workspace = "7" }) -- Files
