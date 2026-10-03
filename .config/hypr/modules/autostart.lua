-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
hl.on("hyprland.start", function()
	hl.exec_cmd("qs")
	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("swaync")
	hl.exec_cmd("hyprpm reload -n")
	hl.exec_cmd("systemctl --user start hyprpolkitagent")
	hl.exec_cmd("/usr/libexec/hyprpolkitagent")
	hl.exec_cmd("swaync --style ~/.configto/swaync/style.css")
	hl.exec_cmd("swayosd-server -s ~/.config/swayosd/style.css")
	hl.exec_cmd("/usr/lib/hyprpolkitagent")
	hl.exec_cmd("hyprsunset")
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("swww-daemon")
end)
