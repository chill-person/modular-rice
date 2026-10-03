---------------------
---- KEYBINDINGS ----
---------------------

local terminal = "kitty"
local fileManager = "thunar"
local menu = "rofi -show drun"

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Format: hl.bind("keys/switch", dispatcher_or_function, { flags })
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("hyprlock & systemctl suspend"), { locked = true })
hl.bind(mainMod .. "+ I", hl.dsp.exec_cmd("/home/seesank/rofi-wifi-menu/rofi-wifi-menu.sh"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("~/.config/rofi/rofi-wallpaper.sh"))


-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))

local closeWindowBind = hl.bind(mainMod .. " + Q", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)
hl.bind(
	mainMod .. " + M",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)

-- wifi was remove, part of modi


-- Binds Super + Shift + S to screenshot a region
hl.bind(mainMod .. " + grave", hl.dsp.exec_cmd("wlogout"))
hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(mainMod .. " + TAB", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + Space", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))

    local w = hl.get_active_window()
    if w ~= nil and w.floating then
        local mon = hl.get_active_monitor()
        if mon ~= nil then
            local target_w = math.floor(mon.width * 0.7) 
            local target_h = math.floor(mon.height * 0.7)

            -- absolute resize (relative = false), not a delta
            hl.dispatch(hl.dsp.window.resize({ x = target_w, y = target_h, relative = false }))

            local mon_x = mon.x or 0
            local mon_y = mon.y or 0
            local target_x = mon_x + math.floor((mon.width - target_w) / 2)
            local target_y = mon_y + math.floor((mon.height - target_h) / 2)

            
            hl.dispatch(hl.dsp.window.move({ x = target_x, y = target_y, relative = false }))
        end
    end
end)
hl.bind(
	mainMod .. "+ N",
	hl.dsp.exec_cmd("swaync-client -t")
)
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) 
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("pkill qs || qs"))
-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+2" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("swayosd-client --output-volume +2 --max-volume 100"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("swayosd-client --output-volume -2"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"),
	{ locked = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"),
	{ locked = true }
)
-- Brightness Up: Raise physical brightness by 5%, then update the soft gamma curve
-- Brightness Up: Increase brightness with SwayOSD and pipe brightnessctl value to gamma
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(
    "brightnessctl set 5%+ && swayosd-client --custom-progress \"$(brightnessctl -m | cut -d, -f4 | tr -d '%' | awk '{print $1/100}')\" --custom-icon display-brightness-symbolic"
), { repeating = true })

hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(
    "brightnessctl --min-value=1 set 5%- && swayosd-client --custom-progress \"$(brightnessctl -m | cut -d, -f4 | tr -d '%' | awk '{print $1/100}')\" --custom-icon display-brightness-symbolic"
), { repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("swayosd-client --playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("swayosd-client --playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("swayosd-client --playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("swayosd-client --playerctl prev"), { locked = true })