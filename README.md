# modular-rice

My Hyprland (Lua config) setup. Heavy inspiration taken by Bintang M's hyprland rice

## ⚠️ Check usernames before using

Some files contain hardcoded paths with my username (e.g. `/home/<name>/...`).
Search the repo for `/home/` and replace them with your own username or `~`.
The main one is the rofi-wifi-menu path in `binds.lua`.

## Rofi wifi menu

The wifi menu is a separate script and is not included in this repo.

1. Clone it: https://github.com/ericmurphyxyz/rofi-wifi-menu
2. Put it somewhere (I use `~/rofi-wifi-menu/`).
3. Make it executable: `chmod +x rofi-wifi-menu.sh`
4. Update the path in the `SUPER + I` bind in `binds.lua` to match where you put it.

Needs `rofi` and NetworkManager (`nmcli`).

## Keybinds

`SUPER` is the main modifier.

| Keys | Action |
|---|---|
| SUPER + T | Terminal (kitty) |
| SUPER + E | File manager (thunar) |
| SUPER + D | App launcher (rofi) |
| SUPER + I | Wifi menu |
| SUPER + W | Wallpaper picker |
| SUPER + N | Toggle notification center |
| SUPER + Q | Close window |
| SUPER + M | Exit Hyprland |
| SUPER + ` | Power menu (wlogout) |
| SUPER + TAB | Lock screen (hyprlock) |
| PRINT | Screenshot region (hyprshot) |
| SUPER + Space | Toggle float (centered, 70% size) |
| SUPER + J | Toggle split |
| SUPER + P | Pseudo-tile |
| SUPER + R | Restart quickshell bar |
| SUPER + Arrow keys | Move focus |
| SUPER + 1-0 | Switch workspace |
| SUPER + SHIFT + 1-0 | Move window to workspace |
| SUPER + S | Toggle scratchpad |
| SUPER + SHIFT + S | Move window to scratchpad |
| SUPER + Scroll | Cycle workspaces |
| SUPER + Left click drag | Move window |
| SUPER + Right click drag | Resize window |
| Volume / mute / media keys | Handled through swayosd |
| Brightness keys | brightnessctl with swayosd |
