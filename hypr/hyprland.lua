local terminal = "alacritty"
local mainMod = "SUPER"

-- Wofi
local wofiConf = "~/.config/wofi/config"
local wofiStyle = "~/.config/wofi/style.css"
local wofiColors = "~/.config/wofi/colors"
local wofiSettings = "--conf " .. wofiConf .. " --style " .. wofiStyle .. " --color " .. wofiColors
local menu = "wofi --show drun --prompt 'Search...' " .. wofiSettings

-- Some default env vars.
hl.env("XCURSOR_SIZE", "18")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- Monitor settings
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.2 })
hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1 })

-- Floating windows
hl.window_rule({ match = { class = "^.*pavucontrol$" }, float = true, size = "1000 700", center = true })

hl.window_rule({ match = { class = "firefox.*$", title = "Library" }, float = true, size = "1000 700", center = true })

hl.config({
    input = {
        kb_layout = "no",
        kb_variant = "nodeadkeys",
        follow_mouse = 1,

        touchpad = {
            natural_scroll = true,
        },
        accel_profile = "flat",
        sensitivity = 0.25,
    },
})

hl.config({
    general = {
        gaps_in = 0,
        gaps_out = 0,
        border_size = 1,

        col = {
            inactive_border = "rgba(595959aa)",
        },

        layout = "dwindle",
    },
})

hl.config({
    decoration = {
        rounding = 3,

        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0x1a1a1aee,
        },

        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            new_optimizations = true,
        },
    },
})

hl.config({
    animations = {
        enabled = true,
    },
})

hl.curve("overshoot", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })

hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "default" })      -- styles: slide, popin, gnomed
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "default" })    -- window open zoom
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default" })   -- window close
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "default" })  -- window moving (moving, dragging, resizing)

-- hl.animation({ leaf = "layers" })                     -- styles: slide, popin, fade
-- hl.animation({ leaf = "layersIn" })                   -- layer open
-- hl.animation({ leaf = "layersOut" })                  -- layer close

hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 3, bezier = "default" })       -- fade in for window open
hl.animation({ leaf = "fadeOut", enabled = true, speed = 4, bezier = "default" })      -- fade out for window close
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 2, bezier = "default" })   -- fade on changing activewindow and its opacity
hl.animation({ leaf = "fadeShadow", enabled = true, speed = 2, bezier = "default" })   -- fade on changing activewindow for shadows
hl.animation({ leaf = "fadeDim", enabled = true, speed = 2, bezier = "default" })      -- the easing of the dimming of inactive windows
-- hl.animation({ leaf = "fadeLayers" })                 -- for controlling fade on layers
-- hl.animation({ leaf = "fadeLayersIn" })               -- fade in for layer open
-- hl.animation({ leaf = "fadeLayersOut" })              -- fade out for layer close

hl.animation({ leaf = "border", enabled = false, speed = 1, bezier = "default" })       -- for animating the border's color switch speed
hl.animation({ leaf = "borderangle", enabled = false, speed = 1, bezier = "default" })  -- for animating the border's gradient angle - styles: once (default), loop

hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "default" })          -- Workspace switching
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "default" })    -- styles: same as workspaces

hl.config({
    dwindle = {
        preserve_split = true, -- you probably want this
    },
})

hl.config({
    misc = {
        force_default_wallpaper = -1, -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo = true,
    },
})

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close({}))
hl.bind(mainMod .. " + SHIFT + CTRL + E", hl.dsp.exit())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({}))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo({})) -- dwindle

-- Move focus with mainMod + arrow keys/vim
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Move window with mainMod + SHIFT + arrow keys/vim
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = "1" }))
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = "2" }))
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = "3" }))
hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = "4" }))
hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = "5" }))
hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = "6" }))
hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = "7" }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = "8" }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = "9" }))
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = "10" }))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = "1" }))
hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = "2" }))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = "3" }))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = "4" }))
hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = "5" }))
hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = "6" }))
hl.bind(mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = "7" }))
hl.bind(mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = "8" }))
hl.bind(mainMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = "9" }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = "10" }))

hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd("hyprlock"))

-- Screenshot with notification
local ssAppName = "Grim"
local ssFolder = "$HOME/Pictures/Screenshots/"

-- Save screenshot to folder
local ssFile = ssFolder .. "/$(date +'%Y-%m-%d_%H-%M-%S_grim.png')"
local ssNoti = "notify-send -i " .. ssFile .. " '" .. ssAppName .. "' 'Screenshot saved to ~/Pictures/Screenshots/' --app-name='" .. ssAppName .. "'"
local ssCmd = "bash -c \"grim " .. ssFile .. " && " .. ssNoti .. "\""
local ssSelCmd = "bash -c \"grim -g '$(slurp)' " .. ssFile .. " && " .. ssNoti .. "\""

-- Save screenshot to clipboard
local ssNotiClip = "notify-send \"" .. ssAppName .. "\" -i /tmp/clipboard.png \"Screenshot copied to clipboard\" --app-name=\"" .. ssAppName .. "\""
local ssNotiImageClip = "wl-paste > /tmp/clipboard.png && (" .. ssNotiClip .. "; rm /tmp/clipboard.png)"
local ssCmdClip = "bash -c 'grim - | wl-copy && " .. ssNotiImageClip .. "'"
local ssSelCmdClip = "bash -c 'r=$(slurp); [ -n \"$r\" ] && grim -g \"$r\" - | wl-copy && " .. ssNotiImageClip .. "'"

-- Media keys
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })                          -- Audio Mute
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })   -- Audio Down
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })   -- Audo Up
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })                      -- Mic Mute
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%- > /dev/null"), { locked = true, repeating = true })         -- Brightness Down
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +10% > /dev/null"), { locked = true, repeating = true })           -- Brightness Up
-- hl.bind("XF86Display", hl.dsp.exec_cmd(""))                                                                                       -- Switch Video Mode
-- F8
hl.bind("Print", hl.dsp.exec_cmd(ssCmdClip))                                            -- Print Screen
hl.bind("XF86SelectiveScreenshot", hl.dsp.exec_cmd(ssSelCmdClip))                        -- Shift Selective Screenshot
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(ssCmd), { locked = true })                      -- Shift Print Screen
hl.bind("SHIFT + XF86SelectiveScreenshot", hl.dsp.exec_cmd(ssSelCmd))                    -- Shift Selective Screenshot
-- F11
-- hl.bind("XF86Favorites", hl.dsp.exec_cmd(""))                                         -- Bookmarks/Favorites

hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(ssSelCmdClip))

-- Color picker
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))

-- Switch to window control mode
-- ----------------------------------
hl.bind(mainMod .. " + M", hl.dsp.submap("wincont"))

hl.define_submap("wincont", function()
    hl.bind("F", hl.dsp.window.float({ action = "toggle" }))
    hl.bind("C", hl.dsp.window.center({}))

    -- Move
    hl.bind("SHIFT + Right", hl.dsp.window.move({ x = 20, y = 0, relative = true }))
    hl.bind("SHIFT + Left", hl.dsp.window.move({ x = -20, y = 0, relative = true }))
    hl.bind("SHIFT + Up", hl.dsp.window.move({ x = 0, y = -20, relative = true }))
    hl.bind("SHIFT + Down", hl.dsp.window.move({ x = 0, y = 20, relative = true }))

    hl.bind("SHIFT + l", hl.dsp.window.move({ x = 20, y = 0, relative = true }))
    hl.bind("SHIFT + h", hl.dsp.window.move({ x = -20, y = 0, relative = true }))
    hl.bind("SHIFT + k", hl.dsp.window.move({ x = 0, y = -20, relative = true }))
    hl.bind("SHIFT + j", hl.dsp.window.move({ x = 0, y = 20, relative = true }))

    -- Resize
    hl.bind("Right", hl.dsp.window.resize({ x = 10, y = 0, relative = true }))
    hl.bind("Left", hl.dsp.window.resize({ x = -10, y = 0, relative = true }))
    hl.bind("Up", hl.dsp.window.resize({ x = 0, y = -10, relative = true }))
    hl.bind("Down", hl.dsp.window.resize({ x = 0, y = 10, relative = true }))

    hl.bind("l", hl.dsp.window.resize({ x = 10, y = 0, relative = true }))
    hl.bind("h", hl.dsp.window.resize({ x = -10, y = 0, relative = true }))
    hl.bind("k", hl.dsp.window.resize({ x = 0, y = -10, relative = true }))
    hl.bind("j", hl.dsp.window.resize({ x = 0, y = 10, relative = true }))

    hl.bind("1", hl.dsp.exec_cmd("hyprctl dispatch setfloating; hyprctl dispatch resizeactive exact 800 600; hyprctl dispatch centerwindow"))
    hl.bind("2", hl.dsp.exec_cmd("hyprctl dispatch setfloating; hyprctl dispatch resizeactive exact 1280 720; hyprctl dispatch centerwindow"))
    hl.bind("3", hl.dsp.exec_cmd("hyprctl dispatch setfloating; hyprctl dispatch resizeactive exact 1440 900; hyprctl dispatch centerwindow"))

    hl.bind("escape", hl.dsp.submap("reset"))
end)
-- ----------------------------------

-- Lid switch
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("hyprctl dispatch dpms off"), { locked = true })
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("hyprctl dispatch dpms on"), { locked = true })

-- Clipboard history
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | wofi --dmenu " .. wofiSettings .. " | cliphist decode | wl-copy"))

hl.on("hyprland.start", function()
    hl.exec_cmd("wl-paste --type text --watch cliphist store -max-items 200 -max-dedupe-search 10")
    hl.exec_cmd("wl-paste --type image --watch cliphist store -max-items 20")

    -- Background
    hl.exec_cmd("hyprpaper")

    -- Statur bar
    hl.exec_cmd("waybar")

    -- Notifications
    hl.exec_cmd("swaync")

    -- Lock screen timer
    hl.exec_cmd("hypridle")
end)
