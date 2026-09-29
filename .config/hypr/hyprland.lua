----------
-- THEME (symlink at ~/.config/themes/current/theme rotates per active theme;
-- falls back to kanso-zen if missing, then to an empty table on fresh installs)
----------
local function load_theme()
	local home = os.getenv("HOME")
	local candidates = {
		home .. "/.config/themes/current/theme/hyprland.lua",
		home .. "/.config/themes/kanso-zen/hyprland.lua",
	}
	for _, path in ipairs(candidates) do
		local ok, result = pcall(dofile, path)
		if ok and type(result) == "table" then
			return result
		end
	end
	return {}
end
local theme = load_theme()

----------
-- MONITORS
----------
hl.monitor({ output = "", mode = "highrr", position = "auto", scale = 1.25 })

----------
-- PROGRAMS
----------
local terminal = "kitty"
local fileManager = "nautilus"

----------
-- SHELL (bar, notifications, OSD, launcher, screenshots): flip to switch
----------
local shell_name = "noctalia" -- "noctalia" | "wayle"

local shells = {
	noctalia = {
		start = "noctalia",
		restart = "killall -w noctalia; setsid -f noctalia",
		launcher = "noctalia msg panel-toggle launcher",
		power_menu = "noctalia msg panel-toggle session",
		dnd = "noctalia msg notification-dnd-toggle",
		screenshot_area = "noctalia msg screenshot-region",
		screenshot_screen = "noctalia msg screenshot-fullscreen",
		screenshot_edit = "noctalia msg screenshot-annotate",
		-- Capture source, audio, and output dir live in the screen_recorder plugin settings.
		record = "noctalia msg plugin noctalia/screen_recorder:service all toggle",
		-- Generic wpctl; the noctalia OSD reacts to the PipeWire change
		volume_up = "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+",
		volume_down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-",
		volume_mute = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
		mic_mute = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle",
	},
	wayle = {
		start = "systemctl --user start wayle.service", -- systemd unit gives Restart=on-failure
		restart = "systemctl --user restart wayle.service",
		launcher = "rofi -show drun",
		power_menu = "~/.config/scripts/wayle/power_menu.sh",
		dnd = "wayle notify dnd",
		screenshot_area = "grimblast --notify --freeze copy area",
		screenshot_screen = "grimblast --notify copy screen",
		screenshot_edit = 'GRIMBLAST_EDITOR="satty --filename" grimblast edit screen',
		-- Toggle region capture (video only, no audio) via wf-recorder.
		-- pkill -INT succeeds when it stops a recording, fails when none is running.
		record = 'pkill -INT wf-recorder && notify-send -a wf-recorder "Recording stopped" '
			.. '|| { g=$(slurp) && notify-send -a wf-recorder "Recording started" '
			.. '&& wf-recorder -g "$g" -c h264_vaapi -d /dev/dri/renderD128 '
			.. "-f ~/Videos/$(date +%Y-%m-%d_%H-%M-%S).mp4; }",
		-- wayle's own audio commands drive its OSD
		volume_up = "wayle audio output-volume +5",
		volume_down = "wayle audio output-volume -5",
		volume_mute = "wayle audio output-mute",
		mic_mute = "wayle audio input-mute",
	},
}
local shell = shells[shell_name]

----------
-- HELPERS
----------
local function is_running(name)
	local p = io.popen("pgrep -x " .. name .. " >/dev/null && echo y")
	local r = p:read("*a")
	p:close()
	return r:match("y") ~= nil
end

-- Toggle between target workspace and the previous one
local function workspace_toggle(target)
	local active = hl.get_active_workspace()
	local dest = (active and active.id == target) and "previous" or target
	hl.dispatch(hl.dsp.focus({ workspace = dest }))
end

----------
-- AUTOSTART
----------
hl.on("hyprland.start", function()
	-- push session env into systemd/dbus and bring up graphical-session.target,
	-- otherwise xdg-desktop-portal won't start (Requisite=graphical-session.target)
	-- and apps like Firefox/Zen lose the dark color-scheme preference
	hl.exec_cmd(
		"dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE"
	)
	hl.exec_cmd("systemctl --user start hyprland-session.target")
	hl.exec_cmd("xrdb -merge ~/.Xresources")
	hl.exec_cmd("~/.config/scripts/theme-switcher.sh")
	hl.exec_cmd(shell.start)
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("hyprsunset --identity")
	hl.exec_cmd("systemctl --user start hypridle.service") -- systemd unit gives Restart=on-failure (auto-recovers crashes)
	hl.exec_cmd("wl-clip-persist --clipboard regular")
	hl.exec_cmd("flatpak run app.zen_browser.zen")
	hl.exec_cmd("discord")
end)

hl.on("hyprland.shutdown", function()
	-- stop the session target on exit so graphical-session.target and its
	-- user services tear down cleanly instead of leaking into the next session
	os.execute("systemctl --user stop hyprland-session.target && sleep 0.1")
end)

----------
-- ENV VARS
----------
hl.env("QT_QPA_PLATFORM", "wayland")

----------
-- LOOK AND FEEL
----------
-- Geometry preset — uncomment one
local geo = { gaps_in = 6, gaps_out = 12, rounding = 8 } -- rounded (current)

hl.config({
	xwayland = { force_zero_scaling = true },

	general = {
		gaps_in = geo.gaps_in,
		gaps_out = geo.gaps_out,
		border_size = 2,
		resize_on_border = false,
		allow_tearing = false,
		layout = "scrolling",
		col = theme.active_border and { active_border = theme.active_border } or nil,
	},

	scrolling = {
		column_width = 0.5,
		fullscreen_on_one_column = true,
		focus_fit_method = 1,
		follow_focus = true,
		explicit_column_widths = "0.33333, 0.5, 0.66667",
		wrap_focus = true,
		wrap_swapcol = true,
		direction = "right",
	},

	decoration = {
		rounding = geo.rounding,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		shadow = {
			enabled = true,
			range = 2,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
		blur = {
			enabled = false,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},

	animations = { enabled = true },

	dwindle = {
		preserve_split = true,
		force_split = 2,
	},

	master = {
		new_status = "master",
	},

	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		focus_on_activate = false,
	},

	input = {
		kb_layout = "us,it",
		follow_mouse = 2,
		sensitivity = 0,
		touchpad = {
			natural_scroll = false,
		},
	},
})

----------
-- ANIMATIONS
----------
-- Explicit values pin behavior across upgrades; defaults drift
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
--hl.curve("easy", { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })
hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, spring = "easy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = false })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

----------
-- KEYBINDINGS
----------
local mainMod = "SUPER"

-- Window actions
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen())

-- Scrolling-layout actions (H/L = direction, mirrors nvim & focus binds)
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.layout("swapcol r"))
hl.bind(mainMod .. " + CTRL + h", hl.dsp.layout("consume_or_expel prev"))
hl.bind(mainMod .. " + CTRL + l", hl.dsp.layout("consume_or_expel next"))
hl.bind(mainMod .. " + W", hl.dsp.layout("colresize +conf"))
hl.bind(mainMod .. " + ALT + W", hl.dsp.layout("colresize -conf"))
hl.bind(mainMod .. " + P", hl.dsp.layout("promote"))

hl.bind(mainMod .. " + F", hl.dsp.layout("fit active"))

-- App launchers
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(shell.launcher))

-- System triggers
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(shell.dnd))
hl.bind(mainMod .. " + ALT + space", hl.dsp.exec_cmd("~/.config/scripts/theme_menu.sh"))
hl.bind(mainMod .. " + ALT + B", hl.dsp.exec_cmd("~/.config/scripts/wallpaper-cycle.sh"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd(shell.power_menu))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("~/.config/scripts/toggle-webcam.sh"))
hl.bind(
	mainMod .. " + SHIFT + R",
	hl.dsp.exec_cmd([[hyprctl reload && notify-send "Hyprland" "Configuration reloaded"]])
)
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(shell.restart))

-- Focus movement (scrolling-layout-aware: wraps within workspace, navigates stacked columns)
hl.bind(mainMod .. " + h", hl.dsp.layout("focus l"))
hl.bind(mainMod .. " + l", hl.dsp.layout("focus r"))
hl.bind(mainMod .. " + k", hl.dsp.layout("focus u"))
hl.bind(mainMod .. " + j", hl.dsp.layout("focus d"))
hl.bind("ALT + Tab", hl.dsp.window.cycle_next())

-- Workspaces 1..10 + move-to-workspace
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(i) }))
end

-- Workspace toggles (target ↔ previous, with optional auto-launch)
hl.bind(mainMod .. " + G", function()
	workspace_toggle(10)
end)
hl.bind(mainMod .. " + S", function()
	if not is_running("spotify") then
		hl.exec_cmd("spotify-launcher")
		hl.dispatch(hl.dsp.focus({ workspace = 9 }))
		return
	end
	workspace_toggle(9)
end)

-- Screenshots + recording
hl.bind("PRINT", hl.dsp.exec_cmd(shell.screenshot_area))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd(shell.screenshot_screen))
hl.bind("SUPER + PRINT", hl.dsp.exec_cmd(shell.screenshot_edit))
hl.bind("ALT + PRINT", hl.dsp.exec_cmd(shell.record))

-- Mouse drag (middle button)
hl.bind(mainMod .. " + mouse:274", hl.dsp.window.drag(), { mouse = true })

-- Volume + mic
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(shell.volume_up), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(shell.volume_down), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(shell.volume_mute), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(shell.mic_mute), { locked = true, repeating = true })
hl.bind(mainMod .. " + grave", hl.dsp.exec_cmd(shell.mic_mute))

-- Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

-- Media keys
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Hyprsunset
hl.bind(mainMod .. " + F1", hl.dsp.exec_cmd("hyprctl hyprsunset temperature 3000"))
hl.bind(mainMod .. " + F2", hl.dsp.exec_cmd("hyprctl hyprsunset identity && hyprctl hyprsunset gamma 100"))
hl.bind(mainMod .. " + F3", hl.dsp.exec_cmd("hyprctl hyprsunset gamma 70"))

----------
-- WINDOW RULES
----------

-- Keep workspaces 1-5 alive when empty so the bar always shows them
for i = 1, 5 do
	hl.workspace_rule({ workspace = tostring(i), persistent = true })
end

-- Suppress self-maximizing apps
-- hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- Single-window apps: open at full column width regardless of workspace
local fullwidth_apps = {
	"^(app\\.zen_browser\\.zen)$",
	"^(discord)$",
	"^(?i)spotify$",
	"^(org\\.gnome\\.Music)$",
}
for _, cls in ipairs(fullwidth_apps) do
	hl.window_rule({ match = { class = cls }, scrolling_width = 1.0 })
end

hl.window_rule({ match = { class = "^(discord)$" }, render_unfocused = true })

-- Centered floating dialogs
hl.window_rule({ match = { class = "^(xdg-desktop-portal-gtk)$" }, float = true, center = true, size = { 875, 600 } })
hl.window_rule({ match = { class = "^(hyprland-share-picker)$" }, float = true, center = true, size = { 875, 600 } })

-- Steam
hl.window_rule({ match = { class = "^(steam)$", title = "^(Friends List)$" }, float = true, size = { 360, 700 } })
hl.window_rule({ match = { class = "^(steam)$", title = "^(Steam Settings)$" }, float = true })

-- VSCode floating popups
hl.window_rule({ match = { class = "^(Code|code)$", float = true }, center = true })

-- Calculator
hl.window_rule({ match = { class = "org.gnome.Calculator" }, float = true })
hl.window_rule({ match = { class = "gnome-calculator" }, float = true })

-- Workspace assignments
local workspace_apps = {
	{ ws = "1 silent", classes = { "^(app\\.zen_browser\\.zen)$" } },
	{ ws = "2 silent", classes = { "^(discord)$" } },
	{ ws = "9 silent", classes = { "^(?i)spotify$", "^(org\\.gnome\\.Music)$" } },
	{
		ws = "10 silent",
		classes = {
			"^(steam)$",
			"^(lutris)$",
			"^(heroic)$",
			"^(bottles)$",
			"^(steam_app_).*",
			"^(bg3)$",
			"^(gamescope)$",
			"^(Waydroid)$",
			"^(Minecraft).*",
		},
	},
}
for _, group in ipairs(workspace_apps) do
	for _, cls in ipairs(group.classes) do
		hl.window_rule({ match = { class = cls }, workspace = group.ws })
	end
end

hl.window_rule({ match = { class = "^(Waydroid)$" }, fullscreen = true })

-- Workspace 10 (games): single-column layout, keep rendering when unfocused
hl.window_rule({ match = { workspace = "10" }, scrolling_width = 1.0, render_unfocused = true })

-- WoW / Wine resize-loop fixes
hl.window_rule({ match = { title = "^(World of Warcraft)$" }, suppress_event = "fullscreen", fullscreen = true })
