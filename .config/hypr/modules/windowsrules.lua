--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

hl.window_rule({
	-- Ignore maximize requests from all apps. You'll probably like this.
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})
if hl.plugin.hyprglass then
	local hg = hl.plugin.hyprglass
	hg.config({
		dark = {
			brightness = 1.05,
			adaptive_dim = 0.1,
			contrast = 0.90,
		},
		default_theme = "dark",
		default_preset = "glass",
		layers = { enabled = false },
		edge_thickness = 0.06,
		refraction_strength = 0.24,
		blur_strength = 0.18,
		chromatic_aberration = 0.03,
	})

end
hl.window_rule({
	match = { class = "zen" },
	opacity = "0.90 ", -- focused unfocused
})
hl.window_rule({
	match = { class = ".*" },
	opacity = "0.8 0.76",
})
hl.window_rule({
	match  = {class = "reaper"},
	opacity = "1.0 0.9"
})