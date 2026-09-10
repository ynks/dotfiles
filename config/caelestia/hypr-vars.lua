-- Overrides for caelestia's hypr/variables.lua. Loaded by hyprland.lua before
-- any of the hyprland/*.lua modules, so these win.
return {
    terminal      = "konsole",
    browser       = "firefox",
    editor        = "konsole -e nvim",
    fileExplorer  = "dolphin",
    audioSettings = "pavucontrol",

    -- Upstream defaults to sweet-cursors, which we don't install.
    cursorTheme   = "breeze_cursors",
    cursorSize    = 24,

    -- Matches the existing powerdevil policy (standbyThenHibernate).
    sleepGestureCmd = "systemctl suspend-then-hibernate",

    -- Quit/close the focused window.
    kbCloseWindow = "SUPER + Backspace",
    kbTerminal    = "SUPER + Return",

    -- Three-finger horizontal swipe changes workspace (the vertical
    -- three-finger swipe already toggles the special workspace via
    -- gestureFingers, a separate axis so there's no conflict).
    workspaceSwipeFingers = 3,

    -- Thicker focus border (but still thin) and tighter gaps. The
    -- single-window case (one app alone on a workspace) is a separate
    -- variable applied via its own workspace rule in rules.lua -- default
    -- 20 is 2x the plain windowGapsOut default (10), so keep that ratio.
    windowBorderSize    = 2,
    windowGapsIn        = 3,
    windowGapsOut       = 6,
    singleWindowGapsOut = 12,
}
