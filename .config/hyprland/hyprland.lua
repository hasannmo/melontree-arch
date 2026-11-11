-- Hyprland Configuration (Lua)

monitor = ",preferred,auto,1"

input {
    kb_layout = "us"
    follow_mouse = 1
    sensitivity = 0
}

general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    ["col.active_border"] = "rgba(33ccffee)"
    ["col.inactive_border"] = "rgba(595959aa)"
    layout = "dwindle"
}

decoration {
    rounding = 10
    blur = {
        enabled = true
        size = 3
        passes = 1
    }
}

animations {
    enabled = true
}

dwindle {
    pseudotile = true
    preserve_split = true
}

exec_once = {
    "waybar",
    "mako",
}

$mainMod = "SUPER"

bind = {
    "$mainMod, T, exec, kitty",
    "$mainMod, R, exec, rofi -show drun -backend wayland",
    "$mainMod, E, exec, pcmanfm",
    "$mainMod, B, exec, firefox",
    "$mainMod, Q, killactive",
    "$mainMod, F, fullscreen, 0",
    "$mainMod, V, togglefloating",
    
    "$mainMod, 1, workspace, 1",
    "$mainMod, 2, workspace, 2",
    "$mainMod, 3, workspace, 3",
    "$mainMod, 4, workspace, 4",
    "$mainMod, 5, workspace, 5",
    "$mainMod, 6, workspace, 6",
    "$mainMod, 7, workspace, 7",
    "$mainMod, 8, workspace, 8",
    "$mainMod, 9, workspace, 9",
    "$mainMod, 0, workspace, 10",
    
    "$mainMod SHIFT, 1, movetoworkspace, 1",
    "$mainMod SHIFT, 2, movetoworkspace, 2",
    "$mainMod SHIFT, 3, movetoworkspace, 3",
    "$mainMod SHIFT, 4, movetoworkspace, 4",
    "$mainMod SHIFT, 5, movetoworkspace, 5",
    "$mainMod SHIFT, 6, movetoworkspace, 6",
    "$mainMod SHIFT, 7, movetoworkspace, 7",
    "$mainMod SHIFT, 8, movetoworkspace, 8",
    "$mainMod SHIFT, 9, movetoworkspace, 9",
    "$mainMod SHIFT, 0, movetoworkspace, 10",
    
    "$mainMod SHIFT, E, exit",
}

bindm = {
    "$mainMod, mouse:272, movewindow",
    "$mainMod, mouse:273, resizewindow",
}
