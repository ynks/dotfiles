-- ROG Control Center is the only fan/GPU-mode tray UI on this laptop, and
-- Hyprland (like niri before it) does not read XDG autostart. It checks for
-- an existing StatusNotifierWatcher exactly once at startup and silently
-- gives up (no window, no tray icon, no retry) if it doesn't find one yet --
-- which loses the race against `caelestia shell -d` on every cold login, since
-- that's fired from the same hyprland.start event a few lines earlier in
-- execs.lua. Wait for the shell's watcher to actually be up first.
hl.on("hyprland.start", function()
    hl.exec_cmd(
        "sh -c '" ..
        "for i in $(seq 1 50); do " ..
            "busctl --user status org.kde.StatusNotifierWatcher >/dev/null 2>&1 && break; " ..
            "sleep 0.2; " ..
        "done; " ..
        "exec rog-control-center'"
    )
end)

-- Caps Lock <-> left Super swap (custom xkb layout defined in
-- hosts/kaveh/default.nix as services.xserver.xkb.extraLayouts.capssuper).
hl.config({
    input = {
        kb_layout = "capssuper",
    },
})

-- 125% scaling on the eDP-1 panel. Overrides hyprland.lua's own default
-- `hl.monitor({ output = "", ..., scale = 1 })` rule, which runs earlier --
-- Hyprland prefers the most specific matching `monitor` rule, and an exact
-- output name beats the "" wildcard.
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.25 })
