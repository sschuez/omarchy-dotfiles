-- My Hyprland overrides, loaded last from ~/.config/hypr/hyprland.lua
-- so everything here wins over Omarchy's defaults.
-- Apply after editing:  hyprctl reload && hyprctl configerrors
--
-- Reference:
--   Omarchy's defaults:    /usr/share/omarchy/default/hypr/
--   Current keybindings:   omarchy menu keybindings --print

-- Rounded corners
hl.config({ decoration = { rounding = 2 } })

-- Apple Studio Display (5120x2880) at 2.5x, i.e. 2048x1152 of space.
-- Matched by its name, not its port, so it follows the display to any machine
-- and leaves the laptop screen alone. Between 2x (tiny) and 3.2x (huge), the
-- scales that stay pixel-exact on this panel are 2.133333, 2.5 and 2.666667.
hl.monitor({ output = "desc:Apple Computer Inc StudioDisplay", mode = "preferred", position = "auto", scale = 2.5 })

-- Keyboard: Caps Lock as an extra Ctrl.
-- Replaces Omarchy's kb_options (Shift+Caps = Compose); US International's
-- dead keys (" then a = ä) cover accents instead. The layout itself lives in
-- ~/.config/omarchy/keyboard-layouts (omarchy package); install-keyboard.sh in
-- omarchy-supplement makes fcitx5 match.
hl.config({ input = { kb_options = "ctrl:nocaps" } })

-- Workspaces are per monitor in Omarchy (default/hypr/monitor-workspaces.lua):
-- each screen has its own slots 1-10, which Hyprland numbers 1-10 on the laptop
-- panel, 11-20 on the next monitor, and so on. Everything below talks in slots,
-- through o.workspaces, so it works the same on whichever screen has focus.
local function current_slot()
	local workspace = hl.get_active_workspace()
	if not (workspace and not workspace.special and workspace.id > 0) then
		return 1
	end
	return (workspace.id - 1) % o.workspaces.slots + 1
end

-- Super+[ / Super+] step through the focused screen's ten slots, empty ones
-- included, wrapping 10 -> 1 and 1 -> 10.
local function cycle_workspace(step)
	return function()
		local slots = o.workspaces.slots
		o.workspaces.focus((current_slot() - 1 + step) % slots + 1)()
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

-- Super+Tab switches windows the Mac way (Cmd+Tab), through the same plugin:
-- hold Super, tap Tab to step through the windows, most recently used first,
-- and let go of Super to jump to the selected one. Shift goes backwards.
-- Replaces Omarchy's Super+Tab workspace cycling (Super+[ / Super+] above
-- cover that); Alt+Tab is left as Omarchy's own.
-- A release bind on Super is skipped once another key (Tab) was pressed during
-- the hold, so Super is watched while a switch is under way instead.
local switching = false
local function watch_super()
	if hl.is_key_down("Super_L") or hl.is_key_down("Super_R") then
		hl.timer(watch_super, { timeout = 15, type = "oneshot" })
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
			watch_super()
		end
	end
end
o.rebind("SUPER + TAB", "Switch window", switch_window("next"), { repeating = true })
o.rebind("SUPER + SHIFT + TAB", "Switch window back", switch_window("previous"), { repeating = true })
-- While switching, a tap of Ctrl (Super still held) steps back as well. Only
-- while switching, and non-consuming, so Super+Ctrl+<key> chords still work.
local function ctrl_back()
	if switching then
		hl.dispatch(hl.dsp.global("window-overview:switch-previous"))
	end
end
o.bind("SUPER + Control_L", "Switch window back (while switching)", ctrl_back, { non_consuming = true })
o.bind("SUPER + Control_R", "Switch window back (while switching)", ctrl_back, { non_consuming = true })
-- Omarchy's Super+Ctrl+Tab (former workspace) stays, except mid-switch, where
-- the Ctrl press above already stepped back.
o.rebind("SUPER + CTRL + TAB", "Former workspace", function()
	if not switching then
		hl.dispatch(hl.dsp.focus({ workspace = "previous_per_monitor" }))
	end
end)

-- Omarchy binds Super+arrows to move focus, so the arrows never reach the
-- switcher. While a switch is under way they step through it instead;
-- otherwise they keep Omarchy's focus behaviour.
local function arrow(direction, step)
	return function()
		if switching then
			hl.dispatch(hl.dsp.global("window-overview:switch-" .. step))
		else
			hl.dispatch(hl.dsp.focus({ direction = direction }))
		end
	end
end
o.rebind("SUPER + LEFT", "Focus on left window", arrow("l", "previous"), { repeating = true })
o.rebind("SUPER + RIGHT", "Focus on right window", arrow("r", "next"), { repeating = true })
o.rebind("SUPER + UP", "Focus on above window", arrow("u", "up"), { repeating = true })
o.rebind("SUPER + DOWN", "Focus on below window", arrow("d", "down"), { repeating = true })

-- Brain.fm in the bar, my player for it (installed by omarchy-supplement's
-- install-brainfm.sh): Super+B opens its panel, and its terminal player
-- (`brainfm`) opens as a floating window like Omarchy's own.
o.bind("SUPER + B", "Brain.fm", { panel = "stephen.brainfm" })
o.window("org.omarchy.brainfm", { tag = "+floating-window" })

-- Fixed workspaces: each app always opens in its own slot on the focused
-- screen, and you're taken there. Not window rules: a rule names a global
-- workspace number, which belongs to one particular screen.
-- Lua patterns, matched against the whole class (escape - and . with %).
-- Find an app's class with: hyprctl clients
local app_slots = {
	{ 1, { "chrome%-app%.hey%.com__.*" } }, -- HEY
	{ 2, { "chrome%-chalet%.do__.*" } }, -- Chalet
	{ 3, { "chromium", "google%-chrome", "brave%-browser", "firefox" } }, -- Browser
	-- Terminals, including tmux and Herdr (they run inside one). Omarchy's own
	-- terminal windows (org.omarchy.*, TUI.*) don't match and stay where they open.
	{ 4, { "Alacritty", "kitty", "com%.mitchellh%.ghostty", "foot", "org%.codeberg%.dnkl%.foot" } },
	{
		5,
		{
			"chrome%-web%.whatsapp%.com__.*",
			"chrome%-appsignal%.com__.*",
			"chrome%-app%.appsignal%.com__.*",
			"[sS]ignal",
		},
	}, -- WhatsApp, AppSignal, Signal
	{ 6, { "com%.anthropic%.Claude" } }, -- Claude Desktop
	{ 7, { "org%.gnome%.Nautilus" } }, -- Files
}

local function slot_for(class)
	for _, entry in ipairs(app_slots) do
		for _, pattern in ipairs(entry[2]) do
			if class:match("^" .. pattern .. "$") then
				return entry[1]
			end
		end
	end
end

hl.on("window.open", function(window)
	local slot = window.class and slot_for(window.class)
	local monitor = hl.get_active_monitor()
	if not (slot and monitor) then
		return
	end
	local id = o.workspaces.workspace_id(monitor, slot)
	if window.workspace and window.workspace.id == id then
		return
	end
	hl.dispatch(hl.dsp.window.move({ workspace = tostring(id), follow = true, window = "address:" .. window.address }))
end)

-- Slots survive a screen going away: the monitor's 3 becomes the laptop's 3
-- when the cable is pulled, and the laptop's 3 the monitor's when the lid
-- closes. Omarchy alone queues such workspaces after the remaining screen's
-- own (monitor-workspaces.lua, as Niri does), and a screen that has just woken
-- up shows an empty 1, so everything landed one slot too far.
-- This runs right before Omarchy reconciles (on every monitor change), which
-- then finds nothing left to queue. A workspace is renumbered, layout intact;
-- where the slot exists already, its windows join the ones there.
local reconcile = o.workspaces.reconcile
o.workspaces.reconcile = function(added, gone)
	local slots = o.workspaces.slots
	local block_of = {} -- screen name -> its block of ten
	local plugged = {} -- the blocks whose screen is here
	for _, monitor in ipairs(hl.get_monitors()) do
		if not monitor.is_mirror and monitor.name ~= gone then
			local block = (o.workspaces.workspace_id(monitor, 1) - 1) // slots
			block_of[monitor.name] = block
			plugged[block] = true
		end
	end

	local focused = hl.get_active_window()
	local moved = false
	for _, workspace in ipairs(hl.get_workspaces()) do
		local block = workspace.monitor and block_of[workspace.monitor.name]
		local numbered = not workspace.special and workspace.id > 0
		if block and numbered and (workspace.windows or 0) > 0 and not plugged[(workspace.id - 1) // slots] then
			local id = block * slots + (workspace.id - 1) % slots + 1
			if hl.get_workspace(id) then
				for _, window in ipairs(hl.get_workspace_windows(workspace.id)) do
					hl.dispatch(hl.dsp.window.move({ workspace = tostring(id), follow = false, window = "address:" .. window.address }))
				end
			else
				hl.dispatch(hl.dsp.workspace.change_id({ workspace = tostring(workspace.id), id = id }))
			end
			moved = true
		end
	end
	-- Stay with the window that had focus, as Omarchy does after reconciling.
	if moved and focused and hl.get_window("address:" .. focused.address) then
		hl.dispatch(hl.dsp.focus({ window = "address:" .. focused.address }))
	end

	return reconcile(added, gone)
end

-- Letter keys for the two busiest slots: Super+U the browser (3), Super+I the
-- terminals (4), with Shift to move the focused window there. Super+I and
-- Super+Shift+I were Omarchy's input language switch, which does nothing with
-- one input method (US International, see keyboard-layouts).
o.bind("SUPER + U", "Switch to workspace 3 (browser)", o.workspaces.focus(3))
o.bind("SUPER + SHIFT + U", "Move window to workspace 3 (browser)", o.workspaces.move_window(3))
o.rebind("SUPER + I", "Switch to workspace 4 (terminals)", o.workspaces.focus(4))
o.rebind("SUPER + SHIFT + I", "Move window to workspace 4 (terminals)", o.workspaces.move_window(4))
