-- ~/.config/hypr/hyprland.lua
-- Basic functional Hyprland config
-- Wiki: https://wiki.hypr.land/Configuring/Start/

------------------
---- MONITORS ----
------------------
-- https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

hl.window_rule({
    match = { class = "^(com.gabm.satty)$" },
               float = true,
               size = "600 600",
               center = true,
               opaque = true,
})

windowrule = {
    { "float", "class:^(cava-strip)$" },
    { "pin", "class:^(cava-strip)$" },
    { "noborder", "class:^(cava-strip)$" },
    { "size 1920 60", "class:^(cava-strip)$" },
    { "move 0 0", "class:^(cava-strip)$" },
    { "noblur", "class:^(cava-strip)$" },
}

windowrule = {
    "opacity 0.90 0.90,class:^(neovide)$",
    "bind = SUPER, RETURN, exec, neovide",
}

-- Blur what's behind waybar so its transparent/glass pills in style.css
-- actually show frosted content instead of flat alpha.
hl.layer_rule({
    match = { namespace = "waybar" },
    blur = true,
    ignore_alpha = 0.2,
})

hl.layer_rule({
    match = { namespace = "notifications" },
    blur = true,
    ignore_alpha = 0.2,
})

---------------------
---- MY PROGRAMS ----
---------------------
local terminal    = "kitty"
local fileManager = "pcmanfm"
local menu        = "wofi --show drun"

-------------------
---- AUTOSTART ----
-------------------
-- https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
hl.exec_cmd("waybar")
hl.exec_cmd("awww-daemon")
hl.exec_cmd("nm-applet")
hl.dispatch(hl.dsp.exec_cmd("wl-paste --watch cliphist store"))
hl.exec_cmd("qs -c ~/.config/quickshell")
-- Faster waybar/layer disappear animation
hl.exec_cmd("hyprctl keyword animation 'layersOut,1,2,default,popin 90%'")
end)

--exec_once = { "hyprpaper" }
--exec_once = {
--    "kitty --class cava-strip -e cava"
--}

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-----------------------
---- LOOK AND FEEL ----
-----------------------
-- https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 8,
        border_size = 1,
        col = {
            -- Ashen Reverie: vermilion signature accent for active, charcoal for inactive.
            active_border   = "rgba(9e433bee)",
            inactive_border = "rgba(3b3731aa)",
        },
        resize_on_border = true,
        layout = "dwindle",
    },
    decoration = {
        rounding = 0,
        active_opacity = 0.85,
        inactive_opacity = 0.65,
        shadow = { enabled = false },
        blur = { enabled = true, size = 6, passes = 3, xray = true, new_optimizations = true },
    },
    animations = {
        enabled = true,
    },
    dwindle = {
        preserve_split = true,
    },
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = { natural_scroll = false },
    },
})

---------------------
---- KEYBINDINGS ----
---------------------

-- App launchers / basic actions
hl.bind("SUPER + Q", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + X", hl.dsp.window.close())
hl.bind("SUPER + F", hl.dsp.exec_cmd(fileManager))
hl.bind("SUPER + SHIFT + F", hl.dsp.exec_cmd("kitty -e yazi")) -- yazi is a TUI app, needs a terminal
hl.bind("SUPER + B", hl.dsp.exec_cmd("firefox"))
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + R", hl.dsp.exec_cmd(menu))
hl.bind("SUPER + A", hl.dsp.exec_cmd("code"))
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"))
hl.bind("CTRL + SUPER + up", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind("SUPER + N", hl.dsp.exec_cmd("neovide"))
hl.bind("SUPER + K", hl.dsp.exec_cmd("kate"))
hl.bind("SUPER + P", hl.dsp.exec_cmd("wallpaper-cycle.sh"))
-- Force-close all windows on the current workspace (no confirmation)
hl.bind("SUPER + SHIFT + X", hl.dsp.exec_cmd(
    "hyprctl clients -j | jq -r '.[] | select(.workspace.id == (\"'$(hyprctl activeworkspace -j | jq -r .id)'\"|tonumber)) | .pid' | xargs -r kill -9"
))

-- Focus movement
hl.bind("SUPER + left",  hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up",    hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down",  hl.dsp.focus({ direction = "down" }))

-- gesture
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Workspaces 1-10
for i = 1, 10 do
    local key = i % 10
    hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
    end

    -- Move/resize with mouse
    hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
    hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

    -- Scroll through workspaces
    hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
    hl.bind("SUPER + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

    -- Volume/Screenshot/Brightness keys
    hl.bind("SUPER + F1", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
    hl.bind("SUPER + F2", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
    hl.bind("SUPER + F3", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1"))

    hl.bind("Print", hl.dsp.exec_cmd("~/.local/bin/screenshot-full.sh"))
    hl.bind("SHIFT + Print", hl.dsp.exec_cmd("~/.local/bin/screenshot-region.sh"))

    hl.bind("F10", hl.dsp.exec_cmd("brightnessctl set +5%"))
    hl.bind("SHIFT + F10", hl.dsp.exec_cmd("brightnessctl set 100%"))
    hl.bind("F9", hl.dsp.exec_cmd("brightnessctl set 5%-"))
    hl.bind("SHIFT + F9", hl.dsp.exec_cmd("brightnessctl set 20%"))






    -----------------------------------
    ---- ALT+TAB WINDOW SWITCHING ----
    -----------------------------------
    -- Native Hyprland has no built-in visual preview overlay for alt-tab (that requires
    -- a plugin/tool like "hyprswitch" or "hy3" workspace switcher — let me know if you
    -- want that wired up). What we CAN do natively is real alt-tab-style cycling:
    -- tap ALT+Tab once -> jumps to the most recently used window (great for your
    -- kitty <-> browser case). Keep holding ALT and tap Tab repeatedly -> cycles
    -- through all open windows one by one; releasing ALT leaves you on whichever
    -- window you last landed on.
    hl.bind("ALT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.bring_to_top())
    end, { repeating = true })

    -- Reverse direction: ALT + SHIFT + Tab cycles backwards
    hl.bind("ALT + SHIFT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next({ previous = true }))
    hl.dispatch(hl.dsp.window.bring_to_top())
    end, { repeating = true })

    -----------------------
    ---- WAYBAR TOGGLE ----
    -----------------------
    -- Kills waybar if it's running, otherwise starts it. One key, one shell check.
    hl.bind("SUPER + W", hl.dsp.exec_cmd("pgrep -x waybar > /dev/null && killall waybar || waybar & disown"))

    
