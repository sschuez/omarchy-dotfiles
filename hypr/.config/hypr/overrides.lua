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
