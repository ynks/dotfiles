{ config, pkgs, lib, inputs, ... }:

let
  nvidia-offload = pkgs.writeShellApplication {
    name = "nvidia-offload";
    text = ''
      if (( $# == 0 )); then
        printf 'usage: nvidia-offload <command> [args...]\n' >&2
        exit 2
      fi

      export __NV_PRIME_RENDER_OFFLOAD=1
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only

      exec "$@"
    '';
  };

  # Upstream's nix/default.nix (github:dim-ghub/Caelestia-Greeter) has a bug:
  # its derivation attrset isn't `rec`, so the `${version}` interpolation
  # inside cmakeFlags refers to nothing and the package fails to *evaluate*
  # at all (verified with `nix eval .#packages.x86_64-linux.default.version`
  # against the upstream flake directly -- not something an `overrideAttrs`
  # on top of it can fix, since the base attrset itself never evaluates).
  # This is a from-scratch equivalent of that file with the bug fixed, plus
  # the sessiondiscovery.cpp path patch (see the greetd module below for why)
  # and an M3Shapes QML import fix (see below).
  caelestia-greeter-package = let
    system = pkgs.stdenv.hostPlatform.system;
    quickshell = inputs.caelestia-greeter.inputs.quickshell.packages.${system}.default;
    m3shapes = inputs.caelestia-greeter.inputs.m3shapes;

    # The greeter's shell.qml imports the M3Shapes QML plugin but never builds
    # or installs it itself -- upstream's own README says it's "Provided by
    # caelestia-shell". Confirmed live: running the unpatched package directly
    # (`caelestia-greeter` with quickshell's own stderr, which greetd's
    # compositor command normally discards via `>/dev/null 2>&1`) produces
    # `module "M3Shapes" is not installed`, and the greeter exits instantly --
    # this is what greetd logged as "greeter exited without creating a
    # session" in a restart loop until it hit systemd's start-limit-hit,
    # leaving VT1 blank. caelestia-shell exposes the plugin as a passthru
    # derivation (`caelestia-m3shapes`, built with
    # `INSTALL_QMLDIR = qt6.qtbase.qtQmlPrefix`, i.e. installed at
    # `$out/lib/qt-6/qml/M3Shapes`) -- reuse that build instead of compiling
    # our own copy. Same story for `Caelestia.Blobs` (used by
    # components/SettingsModal.qml) and the rest of the `Caelestia.*` QML
    # plugin family -- that's caelestia-shell's separate `plugin` passthru
    # derivation (`caelestia-qml-plugin`), also built with
    # INSTALL_QMLDIR = qt6.qtbase.qtQmlPrefix.
    m3shapesModule = inputs.caelestia-shell.packages.${system}.default.m3shapesModule;
    caelestiaPlugin = inputs.caelestia-shell.packages.${system}.default.plugin;
  in pkgs.stdenv.mkDerivation rec {
    pname = "caelestia-greeter";
    version = "1.0.2";
    src = inputs.caelestia-greeter;

    postPatch = ''
      substituteInPlace plugin/src/sessiondiscovery.cpp \
        --replace-fail '/usr/share/wayland-sessions' '/etc/greeter-sessions/wayland-sessions' \
        --replace-fail '/usr/share/xsessions'        '/etc/greeter-sessions/xsessions'
    '';

    nativeBuildInputs = with pkgs; [ cmake ninja pkg-config qt6.wrapQtAppsHook makeWrapper ];
    buildInputs = with pkgs.qt6; [ qtbase qtdeclarative qtquick3d ];

    cmakeFlags = [
      "-DFETCHCONTENT_SOURCE_DIR_M3SHAPES_EXTERNAL=${m3shapes}"
      "-DINSTALL_QSCONFDIR=etc/xdg/quickshell/caelestia-greeter"
      "-DCAELESTIA_GREETER_VERSION=${version}"
    ];

    postInstall = ''
      wrapProgram $out/bin/caelestia-greeter \
        --prefix PATH : ${pkgs.lib.makeBinPath [ quickshell pkgs.wlr-randr ]} \
        --prefix QML2_IMPORT_PATH : "$out/lib/qt6/qml:${m3shapesModule}/lib/qt-6/qml:${caelestiaPlugin}/lib/qt-6/qml:$QML2_IMPORT_PATH"
    '';

    meta = with pkgs.lib; {
      description = "A Quickshell frontend for greetd matching Caelestia M3 design";
      homepage = "https://github.com/dim-ghub/caelestia-greeter";
      license = licenses.mit;
      platforms = platforms.linux;
    };
  };

  kaveh-power-sync = pkgs.writeShellApplication {
    name = "kaveh-power-sync";
    runtimeInputs = with pkgs; [
      coreutils
      gawk
      gnused
      jq
      libnotify
      power-profiles-daemon
      procps
      supergfxctl
      systemd
      upower
      kdePackages.kdialog
      kdePackages.libkscreen
      hyprland
    ];
    text = ''
      notify() {
        notify-send --app-name="Kaveh Power" "$@"
      }

      on_battery() {
        [[ "$(upower --dump | awk '/on-battery:/ { print $2; exit }')" == "yes" ]]
      }

      # This unit runs under both Plasma and Hyprland (systemd.user.services
      # below is WantedBy graphical-session.target in either session), so
      # every display/session-control call site branches on which one is
      # currently active.
      session() {
        case "''${XDG_CURRENT_DESKTOP:-}" in
          *[Hh]yprland*) printf 'hyprland' ;;
          *) printf 'plasma' ;;
        esac
      }

      display_state() {
        if [[ "$(session)" == hyprland ]]; then
          hyprctl -j monitors 2>/dev/null
        else
          kscreen-doctor --json 2>/dev/null
        fi
      }

      external_display_active() {
        if [[ "$(session)" == hyprland ]]; then
          display_state | jq -e '
            .[]
            | select(.disabled | not)
            | select(.name | startswith("eDP") | not)
          ' >/dev/null
        else
          display_state | jq -e '
            .outputs[]
            | select(.connected and .enabled)
            | select(.name | startswith("eDP") | not)
          ' >/dev/null
        fi
      }

      set_panel_refresh() {
        local refresh="$1"
        local output mode
        local state

        state="$(display_state)" || return 0

        if [[ "$(session)" == hyprland ]]; then
          local x y scale
          output="$(jq -r '.[] | select(.name | startswith("eDP")) | .name' <<<"$state" | head -n1)"
          [[ -n "$output" ]] || return 0

          x="$(jq -r --arg o "$output" '.[] | select(.name == $o) | .x' <<<"$state")"
          y="$(jq -r --arg o "$output" '.[] | select(.name == $o) | .y' <<<"$state")"
          scale="$(jq -r --arg o "$output" '.[] | select(.name == $o) | .scale' <<<"$state")"

          # hyprctl keyword monitor replaces the whole rule for this output, so
          # position and scale must be re-emitted or the layout gets clobbered.
          if ! hyprctl keyword monitor "$output,2880x1800@''${refresh}.000,''${x}x''${y},''${scale}" >/dev/null 2>&1; then
            notify --urgency=normal "Display policy" \
              "The 2880x1800@''${refresh}Hz mode is unavailable; leaving the display unchanged."
          fi
          return 0
        fi

        output="$(jq -r '.outputs[] | select(.connected and (.name | startswith("eDP"))) | .name' <<<"$state" | head -n1)"
        [[ -n "$output" ]] || return 0

        mode="$(jq -r --argjson refresh "$refresh" --arg output "$output" '
          .outputs[]
          | select(.name == $output)
          | .modes[]
          | select(.size.width == 2880 and .size.height == 1800)
          | select(((.refreshRate - $refresh) | fabs) < 1)
          | .id
        ' <<<"$state" | head -n1)"
        [[ -n "$mode" ]] || {
          notify --urgency=normal "Display policy" \
            "The exact 2880x1800@''${refresh} mode is unavailable; leaving the display unchanged."
          return 0
        }

        kscreen-doctor "output.''${output}.mode.''${mode}" >/dev/null
      }

      request_gpu_mode() {
        local desired="$1"
        local current reboot_needed message

        current="$(supergfxctl --get 2>/dev/null || true)"
        [[ -n "$current" && "$current" != "$desired" ]] || return 0

        if [[ "$desired" == "Integrated" ]] && external_display_active; then
          notify --urgency=normal "GPU switch deferred" \
            "An external display is active; keeping ''${current} mode until the next power event."
          return 0
        fi

        reboot_needed=0
        if [[ "$current" == "AsusMuxDgpu" ]]; then
          reboot_needed=1
          message="Switch graphics from dedicated MUX mode to ''${desired}? A reboot is required."
        else
          message="Switch graphics from ''${current} to ''${desired}? The session must log out cleanly."
        fi

        if ! kdialog --title "Kaveh GPU policy" --warningyesno "$message"; then
          notify --urgency=normal "GPU switch deferred" \
            "''${desired} mode will be offered again at the next login or power event."
          return 0
        fi

        # The Plasma system monitor starts a long-lived `nvidia-smi dmon`
        # process for NVIDIA sensors. That process holds nvidia_uvm open and
        # makes supergfxd roll an Integrated transition back to Hybrid. Stop
        # the monitor cleanly before asking supergfxd to unload the driver; it
        # is part of graphical-session.target and returns at the next login.
        # (There is no Hyprland equivalent -- nothing under Hyprland holds a
        # long-lived nvidia-smi handle open.)
        if [[ "$desired" == "Integrated" && "$(session)" == plasma ]]; then
          systemctl --user stop plasma-ksystemstats.service || true

          for _attempt in {1..20}; do
            pgrep -u "$UID" -x nvidia-smi >/dev/null || break
            sleep 0.25
          done

          if pgrep -u "$UID" -x nvidia-smi >/dev/null; then
            systemctl --user start plasma-ksystemstats.service || true
            notify --urgency=critical "GPU switch blocked" \
              "A user NVIDIA monitor is still running. Close it and retry Integrated mode."
            return 1
          fi
        fi

        # supergfxd owns the transition and keeps the request while the session
        # exits. Stopping the display manager releases KWin's/Hyprland's
        # remaining handle.
        nohup supergfxctl --mode "$desired" >"''${XDG_RUNTIME_DIR}/kaveh-supergfxctl.log" 2>&1 &
        sleep 2

        if [[ "$(session)" == hyprland ]]; then
          # There is no Hyprland equivalent of org.kde.LogoutPrompt's direct
          # promptReboot/promptLogout calls; open Caelestia's session drawer
          # (confirmed via modules/Shortcuts.qml in the caelestia-shell
          # source -- IpcHandler { target: "drawers" } toggles the "session"
          # drawer by name) so the reboot or logout can be confirmed with one
          # more click.
          notify --urgency=normal "GPU switch ready" \
            "''${reboot_needed:+A reboot is required. }Opening the session menu to finish the ''${desired} switch."
          caelestia shell drawers toggle session || true
        elif [[ "$reboot_needed" == 1 ]]; then
          busctl --user call org.kde.LogoutPrompt /LogoutPrompt org.kde.LogoutPrompt promptReboot
        else
          busctl --user call org.kde.LogoutPrompt /LogoutPrompt org.kde.LogoutPrompt promptLogout
        fi
      }

      apply_policy() {
        if on_battery; then
          set_panel_refresh 60
          request_gpu_mode Integrated
        else
          set_panel_refresh 120
          request_gpu_mode Hybrid
        fi
      }

      show_status() {
        local source refresh gpu profile

        if on_battery; then
          source="battery"
        else
          source="AC"
        fi
        if [[ "$(session)" == hyprland ]]; then
          refresh="$(display_state | jq -r '
            .[]
            | select(.name | startswith("eDP"))
            | .refreshRate
          ' | head -n1)"
        else
          refresh="$(display_state | jq -r '
            .outputs[]
            | select(.connected and (.name | startswith("eDP")))
            | .currentModeId as $mode
            | .modes[]
            | select(.id == $mode)
            | .refreshRate
          ' | head -n1)"
        fi
        gpu="$(supergfxctl --get 2>/dev/null || printf 'unavailable')"
        profile="$(powerprofilesctl get 2>/dev/null || printf 'unavailable')"
        printf 'session=%s\npower-source=%s\ngpu-mode=%s\npower-profile=%s\npanel-refresh=%sHz\n' \
          "$(session)" "$source" "$gpu" "$profile" "''${refresh:-unknown}"
      }

      monitor() {
        local previous=""
        local current

        reconcile() {
          if on_battery; then
            current="battery"
          else
            current="AC"
          fi

          if [[ "$current" != "$previous" ]]; then
            sleep 3
            apply_policy || notify --urgency=critical "Power policy failed" \
              "Run kaveh-power-sync --status and check the user service log."
            previous="$current"
          fi
        }

        reconcile
        while IFS= read -r _event; do
          [[ "$_event" == "Monitoring activity from the power daemon."* ]] && continue
          reconcile
        done < <(upower --monitor)
      }

      case "''${1:---apply}" in
        --apply)
          apply_policy
          ;;
        --status)
          show_status
          ;;
        --monitor)
          monitor
          ;;
        *)
          printf 'usage: kaveh-power-sync [--apply|--status|--monitor]\n' >&2
          exit 2
          ;;
      esac
    '';
  };
in

{
  imports = [
    ./hardware.nix
    inputs.caelestia-greeter.nixosModules.default
  ];

  networking.hostName = "kaveh";
  networking.wireless.enable = true;

  ##################################################
  # NVIDIA Optimus (AMD iGPU + NVIDIA dGPU)
  ##################################################

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];

  # The GA403 exposes only s2idle. The 40 GiB swap partition leaves 8 GiB of
  # headroom around a full-RAM 32 GiB hibernation image.
  boot.resumeDevice = "/dev/disk/by-uuid/47ddae35-dcd3-4070-9331-7527e0689e2f";
  systemd.sleep.settings.Sleep = {
    AllowSuspend = true;
    AllowHibernation = true;
    AllowSuspendThenHibernate = true;
    HibernateDelaySec = "1h";
  };
  systemd.tmpfiles.rules = [
    "w /sys/power/image_size - - - - 34359738368"
  ];

  boot.initrd.kernelModules = [ "amdgpu" ];

  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  ##################################################
  # ASUS ROG
  ##################################################

  # supergfxd uses lsof to terminate stale monitoring clients before unloading
  # nvidia_uvm during a Hybrid -> Integrated transition.
  systemd.services.supergfxd = {
    path = [
      pkgs.jq
      pkgs.lsof
      pkgs.pciutils
    ];

    # supergfxctl persists the selected mode in this file. Preserve that mode,
    # but normalize the full schema and enforce ASUS dgpu_disable hotplugging so
    # newer daemons do not reject the partial NixOS-generated JSON.
    preStart = ''
      mode=Hybrid
      if test -r /etc/supergfxd.conf; then
        saved_mode=$(jq --raw-output --exit-status '.mode // empty' /etc/supergfxd.conf 2>/dev/null || true)
        if test -n "$saved_mode"; then
          mode="$saved_mode"
        fi
      fi

      jq --null-input --arg mode "$mode" '{
        mode: $mode,
        vfio_enable: false,
        vfio_save: false,
        always_reboot: false,
        no_logind: false,
        logout_timeout_s: 180,
        hotplug_type: "Asus"
      }' > /run/supergfxd.conf
      install -m 0644 /run/supergfxd.conf /etc/supergfxd.conf
    '';
  };

  services.supergfxd = {
    enable = true;
  };

  services.asusd.enable = true;
  services.upower.enable = true;
  networking.modemmanager.enable = false;

  # Brother scanners supported by the brscan4 SANE backend.
  hardware.sane = {
    enable = true;
    brscan4.enable = true;
  };
  users.users.xein.extraGroups = [ "scanner" "lp" ];

  # NOTE: this host used to force xdg.portal.extraPortals down to just
  # xdg-desktop-portal-kde, to avoid starting a redundant GTK portal in every
  # Plasma session. That's gone now that programs.hyprland (below) pulls in
  # xdg-desktop-portal-hyprland with its own portal *config*
  # (configPackages = mkDefault [ cfg.package ]) -- each desktop picks its
  # own backend via $XDG_CURRENT_DESKTOP, no manual override needed.

  ##################################################
  # Hyprland + Caelestia session (Wayland, alongside Plasma)
  ##################################################

  # Custom xkb layout swapping Caps Lock and left Super: physical Caps Lock
  # becomes a real Super modifier (works with every SUPER+ keybind, including
  # Hyprland's own tap-to-launch on Super_L), and physical left Super becomes
  # a real Caps Lock (toggles lock state/LED natively -- no external tool
  # needed). Sets environment.sessionVariables.XKB_CONFIG_ROOT, which
  # libxkbcommon (used natively by Hyprland, no Xorg involved) honours same
  # as Xorg/Plasma. Referenced from config/caelestia/hypr-user.lua via
  # `input.kb_layout = "capssuper"`.
  services.xserver.xkb.extraLayouts.capssuper = {
    description = "US, Caps Lock as Super, left Super as Caps Lock";
    languages = [ "eng" ];
    symbolsFile = ../../config/caelestia/caps-super-swap.xkb;
  };

  # NixOS's extraLayouts module only exports XKB_CONFIG_ROOT via
  # environment.sessionVariables/environment.variables, both of which land
  # solely in /etc/set-environment -- a shell script sourced by login shells
  # (/etc/profile, /etc/zshenv). greetd's cage and Hyprland-via-UWSM both
  # exec their target binary directly with no shell in between, so that
  # file is never sourced and Hyprland's xkbcommon never sees the var:
  # "[Runtime Error] Invalid keyboard layout passed ... layout:capssuper" at
  # startup. /etc/environment.d/*.conf is the modern systemd mechanism read
  # directly during PAM/systemd session setup regardless of shell -- NixOS
  # already relies on it for PATH itself (see the generated
  # 50-systemd-path.conf), so it's proven to reach every session on this
  # host; write our own entry into the same directory.
  environment.etc."environment.d/90-xkb-config-root.conf".text =
    "XKB_CONFIG_ROOT=${config.services.xserver.xkb.dir}\n";

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    # Hyprland does not activate graphical-session.target on its own. UWSM
    # does, which is what the caelestia home-manager units and
    # kaveh-power-sync (below) bind to.
    withUWSM = true;
  };

  # hypr/hyprland/execs.lua (from the caelestia dots) execs these by hardcoded
  # Arch paths that don't resolve on NixOS; enabling the NixOS-native
  # equivalents as system services means those failed exec_cmd calls are
  # harmless no-ops, and the daemons still run.
  services.gnome.gnome-keyring.enable = true;
  services.geoclue2.enableDemoAgent = true;

  # Caelestia Greeter (greetd-based) replaces SDDM as kaveh's login manager.
  # Plasma stays fully installed and shows up as its own session in the
  # picker: services.desktopManager.plasma6 registers
  # `share/wayland-sessions/plasma.desktop` (Name=Plasma (Wayland)) via
  # services.displayManager.sessionPackages, exactly the same mechanism
  # programs.hyprland uses for its own session entry, and NixOS aggregates
  # every sessionPackages entry into services.displayManager.sessionData.
  services.greetd.caelestiaGreeter = {
    enable = true;
    # The upstream module's "hyprland" compositor branch runs bare
    # `Hyprland` with no config and never actually starts the greeter --
    # cage (the module default) is the only option that works.
    compositor = "cage";

    # plugin/src/sessiondiscovery.cpp's reload() hardcodes
    # /usr/share/{wayland-sessions,xsessions}, which don't exist on NixOS;
    # unpatched, the picker collapses to a single hardcoded "Hyprland"
    # fallback entry. Point it at the aggregated session data instead
    # (wired up via environment.etc."greeter-sessions" below). The patch
    # itself lives in caelestia-greeter-package above, alongside the fix for
    # upstream's broken nix/default.nix.
    package = caelestia-greeter-package;
  };

  # 125% scaling for the greeter too, matching the Hyprland session (see
  # config/caelestia/hypr-user.lua). cage itself has no scale concept -- the
  # caelestia-greeter binary applies monitor flags like this to the running
  # compositor via wlr-randr on startup, before handing off to quickshell.
  # The upstream NixOS module hardcodes this whole command line with no way
  # to pass extra arguments, so override it wholesale (mkForce, since the
  # module sets it directly rather than via mkDefault).
  services.greetd.settings.default_session.command = lib.mkForce
    "${pkgs.cage}/bin/cage -s -- ${caelestia-greeter-package}/bin/caelestia-greeter --output eDP-1 --scale 1.25 >/dev/null 2>&1";

  # The greetd/cage process doesn't inherit XDG_DATA_DIRS, so give the
  # patched greeter (above) a stable filesystem path to read session
  # .desktop files from instead. Also prefix every session's Exec= with
  # `env XKB_CONFIG_ROOT=...`: the plain (non-uwsm) "Hyprland" entry execs
  # start-hyprland directly with whatever bare environment greetd's PAM
  # session handed it, which does not reliably include vars from
  # environment.d (that mechanism needs a full systemd --user/logind
  # session, which this direct-exec path may not have set up yet) -- this
  # is what caused "[Runtime Error] Invalid keyboard layout passed ...
  # layout:capssuper" even after the environment.d fix below. `env VAR=val
  # cmd...` guarantees the var reaches the whole process tree regardless.
  environment.etc."greeter-sessions".source =
    let
      xkbConfigRoot = config.services.xserver.xkb.dir;
    in
    pkgs.runCommand "greeter-sessions" { } ''
      mkdir -p "$out/wayland-sessions" "$out/xsessions"
      for dir in wayland-sessions xsessions; do
        for f in "${config.services.displayManager.sessionData.desktops}/share/$dir/"*.desktop; do
          [ -e "$f" ] || continue
          sed "s|^Exec=|Exec=env XKB_CONFIG_ROOT=${xkbConfigRoot} |" \
            "$f" > "$out/$dir/$(basename "$f")"
        done
      done
    '';

  # nixos/modules/services/display-managers/greetd.nix creates the `greeter`
  # user with no extra groups; the greeter needs DRM and libinput access.
  users.users.greeter.extraGroups = [ "video" "input" ];

  services.displayManager.sddm.enable = lib.mkForce false;

  ##################################################
  # Home-manager overrides
  ##################################################

  home-manager.users.xein = { lib, ... }: {
    imports = [ ../../modules/desktop/hyprland.nix ];

    # uwsm (the "Hyprland (uwsm-managed)" session entry) sources its own
    # per-compositor env file before starting the compositor's systemd
    # units, independently of whatever environment greetd/PAM handed it.
    # Belt-and-suspenders alongside the greeter Exec= patch above, which
    # covers this same variable for the plain (non-uwsm) entry.
    xdg.configFile."uwsm/env-hyprland".text = ''
      export XKB_CONFIG_ROOT="${config.services.xserver.xkb.dir}"
    '';

    home.packages = [
      kaveh-power-sync
      nvidia-offload
    ];

    programs.plasma = {
      enable = true;

      # Never subscribe the desktop temperature widget to the NVIDIA sensor.
      # KSystemStats implements it with persistent nvidia-smi polling, which
      # prevents Hybrid-mode runtime suspend and blocks Integrated transitions.
      configFile."plasma-org.kde.plasma.desktop-appletsrc" = {
        "Containments][1][Applets][31][Configuration][Sensors" = {
          highPrioritySensorIds = ''["cpu/all/averageTemperature"]'';
        };
      };

      powerdevil = {
        AC = {
          powerProfile = "performance";
          autoSuspend.action = "nothing";
          whenLaptopLidClosed = "sleep";
          whenSleepingEnter = "standbyThenHibernate";
          inhibitLidActionWhenExternalMonitorConnected = true;
          turnOffDisplay = {
            idleTimeout = 900;
            idleTimeoutWhenLocked = 20;
          };
        };

        battery = {
          powerProfile = "powerSaving";
          autoSuspend = {
            action = "sleep";
            idleTimeout = 900;
          };
          whenLaptopLidClosed = "sleep";
          whenSleepingEnter = "standbyThenHibernate";
          inhibitLidActionWhenExternalMonitorConnected = true;
          dimDisplay.idleTimeout = 60;
          turnOffDisplay = {
            idleTimeout = 300;
            idleTimeoutWhenLocked = 20;
          };
          keyboardBrightness = 0;
        };

        lowBattery = {
          powerProfile = "powerSaving";
          whenLaptopLidClosed = "sleep";
          whenSleepingEnter = "standbyThenHibernate";
          inhibitLidActionWhenExternalMonitorConnected = true;
          dimDisplay.idleTimeout = 30;
          turnOffDisplay = {
            idleTimeout = 120;
            idleTimeoutWhenLocked = 20;
          };
          keyboardBrightness = 0;
        };

        batteryLevels = {
          lowLevel = 15;
          criticalLevel = 5;
          criticalAction = "hibernate";
        };
        general.pausePlayersOnSuspend = true;
      };
    };

    systemd.user.services.kaveh-power-sync = {
      Unit = {
        Description = "Apply Kaveh AC and battery GPU/display policy";
        After = [
          "graphical-session.target"
          "plasma-kwin_wayland.service"
          "plasma-powerdevil.service"
        ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${kaveh-power-sync}/bin/kaveh-power-sync --monitor";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # Remove obsolete copies made by Home Manager's backup extension. XDG's
    # autostart generator treats every .desktop.backup* file as an application.
    home.activation.removeRogAutostartBackups = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.findutils}/bin/find /home/xein/.config/autostart \
        -maxdepth 1 -name 'rog-control-center.desktop.backup*' -delete
    '';

    # ROG Control Center is the only fan/GPU-mode tray UI available under
    # Hyprland (which doesn't have Plasma's system settings module for it),
    # so it now autostarts in both sessions: this XDG entry for Plasma, and
    # `hl.exec_cmd("rog-control-center")` in config/caelestia/hypr-user.lua
    # for Hyprland (which does not read XDG autostart at all).
    #
    # kmix and Discover's update notifier still duplicate Plasma/asusd
    # functionality or can't update the declarative NixOS system, so those
    # stay suppressed.
    xdg.configFile = {
      "autostart/rog-control-center.desktop".text = ''
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=ROG Control Center
        Comment=Make your ASUS ROG Laptop go Brrrrr!
        Icon=rog-control-center
        Exec=rog-control-center
        Terminal=false
        X-GNOME-Autostart-enabled=true
      '';
      "autostart/kmix_autostart.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=KMix
        Hidden=true
      '';
      "autostart/org.kde.discover.notifier.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Discover Notifier
        Hidden=true
      '';
    };
  };

  ##################################################
  # Audio
  ##################################################

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;

    alsa = {
      enable = true;
      support32Bit = true;
    };

    pulse.enable = true;
    jack.enable = true;
  };

  programs.nix-ld.enable = true;
}
