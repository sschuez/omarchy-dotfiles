-- My Hyprland overrides, loaded last from ~/.config/hypr/hyprland.lua
-- so everything here wins over Omarchy's defaults.
-- Apply after editing:  hyprctl reload && hyprctl configerrors
--
-- Reference:
--   Omarchy's defaults:    /usr/share/omarchy/default/hypr/
--   Current keybindings:   omarchy menu keybindings --print

-- Rounded corners
hl.config({ decoration = { rounding = 2 } })

-- Keyboard: US International with dead keys (" then a = ä), Caps Lock as an extra Ctrl.
-- kb_options replaces Omarchy's default (Shift+Caps = Compose), which dead keys make unnecessary.
hl.config({ input = { kb_layout = "us", kb_variant = "intl", kb_options = "ctrl:nocaps" } })
