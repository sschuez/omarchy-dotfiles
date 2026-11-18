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
