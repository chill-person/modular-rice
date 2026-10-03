# swayosd theme

Matches the teal / peach / ink-navy / balloon-red palette from your wallpaper.

## Install

```sh
cp -r swayosd ~/.config/
```

Then (re)start the daemon, e.g. add to your Hyprland `hyprland.start`:

```sh
swayosd-server &
```

and bind volume/brightness keys to `swayosd-client` instead of raw `wpctl`, e.g.:

```
bindl = , XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise
bindl = , XF86AudioLowerVolume, exec, swayosd-client --output-volume lower
bindl = , XF86AudioMute, exec, swayosd-client --output-volume mute-toggle
bindl = , XF86MonBrightnessUp, exec, swayosd-client --brightness raise
bindl = , XF86MonBrightnessDown, exec, swayosd-client --brightness lower
```

## Files

- `style.css` — colors/shape (teal bg, navy border, peach text/icons, red accent bar)
- `config.toml` — top_margin / max_volume server settings, tweak top_margin to sit below waybar
