{
  config,
  lib,
  pkgs,
  zed,
  ...
}:

let
  cfg = config.dotfiles.noctalia;
  toml = pkgs.formats.toml { };
  c = config.lib.stylix.colors.withHashtag;

  # Noctalia's fixed-palette JSON (src/theme/cli.cpp, parseFixedPaletteJson),
  # built from the same base16 + Zed UI roles as the rest of the desktop, so
  # Stylix stays the only palette. Blue marks active state only (primary:
  # active workspace, sliders, toggles); hover stays a neutral wash.
  palette = {
    mPrimary = c.base0D;
    mOnPrimary = zed.canvas;
    mSecondary = c.base0A;
    mOnSecondary = zed.canvas;
    mTertiary = c.base0C;
    mOnTertiary = zed.canvas;
    mError = c.base08;
    mOnError = zed.canvas;
    mSurface = zed.canvas;
    mOnSurface = c.base05;
    mSurfaceVariant = zed.surface;
    mOnSurfaceVariant = c.base04;
    mOutline = zed.border;
    mShadow = "#000000";
    mHover = zed.hover;
    mOnHover = c.base05;

    # The loader rejects a palette without this block (readModeTerminalJson),
    # although with templates off nothing is written from it. Standard base16
    # ANSI mapping.
    terminal =
      let
        ansi = {
          black = c.base00;
          red = c.base08;
          green = c.base0B;
          yellow = c.base0A;
          blue = c.base0D;
          magenta = c.base0E;
          cyan = c.base0C;
          white = c.base05;
        };
      in
      {
        normal = ansi;
        bright = ansi // {
          black = c.base03;
          white = c.base07;
        };
        foreground = c.base05;
        background = c.base00;
        cursor = c.base05;
        cursorText = c.base00;
        selectionFg = c.base05;
        selectionBg = zed.selection;
      };
  };

  # Default bar islands (dotfiles.noctalia.islands); each id is a separate
  # mkDefault, so a consumer can replace one island and keep the rest.
  defaultIslands = {
    workspaces = [ "workspaces" ];
    window = [ "active_window" ];
    time = [ "clock" ];
    media = [ "media" ];
    controls = [
      "keyboard_layout"
      "volume"
      "network"
      "brightness"
    ];
    system = [
      "cpu"
      "ram"
      "battery"
      "power_profile"
      "tray"
    ];
    session = [
      "notifications"
      "control-center"
      "session"
    ];
  };

  defaults = {
    theme = {
      mode = "dark";
      source = "custom";
      custom_palette = cfg.paletteName;
      # Stylix owns dconf's color-scheme and every app's colours; Noctalia
      # writing them as well would be a second, competing source.
      sync_color_scheme = false;
      templates = {
        enable_builtin_templates = false;
        enable_community_templates = false;
      };
    };

    shell = {
      font_family = config.stylix.fonts.sansSerif.name;
      setup_wizard_enabled = false;
      telemetry_enabled = false;
      # The unit restarts on failure; apps started from the launcher get
      # their own scopes and outlive a shell restart.
      launch_apps_as_systemd_services = true;
      # hyprpolkitagent stays the one polkit agent.
      polkit_agent = false;
      # cliphist (clipboard.nix) keeps the history; one is enough.
      clipboard_enabled = false;
      launcher.show_app_actions = true;
    };

    # Floating islands: the bar surface itself is fully transparent and every
    # group of widgets is its own rounded capsule, so the wallpaper shows
    # between them. Logical pixels; 10 px of air above the islands.
    bar = {
      order = [ "default" ];
      default = {
        position = "top";
        thickness = 48;
        margin_edge = 10;
        margin_ends = 12;
        padding = 0;
        background_opacity = 0.0;
        border_width = 0.0;
        shadow = false;
        compositor_blur = false;
        # Gap between islands.
        widget_spacing = 10;

        capsule = true;
        capsule_thickness = 0.92;
        capsule_radius = 14.0;
        capsule_padding = 14.0;
        capsule_border = "outline_variant";
        capsule_border_width = 1.0;
        capsule_group = lib.mapAttrsToList (id: members: { inherit id members; }) cfg.islands;

        start = [
          "group:workspaces"
          "group:window"
        ];
        center = [ "group:time" ];
        end = [
          "group:media"
          "group:controls"
          "group:system"
          "group:session"
        ];
      };
    };

    widget = {
      clock = {
        type = "clock";
        format = "{:%d.%m  %H:%M}";
      };
      # Keeps the right-hand islands clear of the centred clock on a
      # 2048 px wide (scaled) laptop panel.
      media.max_length = 160.0;
      keyboard_layout.hide_when_single_layout = true;
      # Each bar lists its own monitor's workspaces, as Waybar did.
      workspaces = {
        type = "workspaces";
        show_all_outputs = false;
      };
    };

    # Idle policy (dim, DPMS, suspend) stays with hypridle; Noctalia only
    # answers logind's Lock and PrepareForSleep.
    idle.behavior = lib.genAttrs [ "lock" "screen-off" "lock-and-suspend" ] (_: {
      enabled = false;
    });

    lockscreen = {
      enabled = true;
      lock_before_suspend = true;
    };

    # A shell that dies while locked leaves logind's LockedHint at yes (only an
    # unlock clears it); the restarted unit takes the lock back over instead
    # of leaving the session on Hyprland's lock-failure screen.
    hooks.started = [
      ''[ "$(loginctl show-session "''${XDG_SESSION_ID:-auto}" -p LockedHint --value)" = yes ] && ${lib.getExe cfg.package} msg session lock''
    ];

    # One popup on the output in use, as mako did, not one per monitor.
    notification = {
      enable_daemon = true;
      follow_focused_output = true;
    };
    osd.follow_focused_output = true;
  };
in
{
  imports = [ ./lib.nix ];

  options.dotfiles.noctalia = {
    enable = lib.mkEnableOption ''
      the Noctalia v5 shell (bar, launcher, notifications, lock screen,
      wallpaper, OSD, session menu) as a supervised user unit, with a palette
      generated from Stylix (needs the Stylix Home Manager module: palette
      and font)
    '';

    package = lib.mkPackageOption pkgs "noctalia" { } // {
      description = ''
        The Noctalia package. The settings and Hyprland binds assume 5.4 or
        later (custom palettes, `window-switcher hold`, brightness targets);
        nixpkgs 26.05 ships 5.0.1, so take it from nixos-unstable there.
      '';
    };

    paletteName = lib.mkOption {
      type = lib.types.str;
      default = "stylix";
      description = "File name (without .json) of the generated palette in ~/.config/noctalia/palettes.";
    };

    islands = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      defaultText = lib.literalExpression "workspaces, window, time, media, controls, system and session (see noctalia.nix)";
      example = lib.literalExpression ''{ time = [ "clock" "clock-utc" ]; }'';
      description = ''
        Bar islands: capsule groups by id, each a list of widget instances.
        The default bar lanes reference them as `group:<id>` (start:
        workspaces, window; center: time; end: media, controls, system,
        session). Setting one id replaces only that island.
      '';
    };

    settings = lib.mkOption {
      inherit (toml) type;
      default = { };
      example = lib.literalExpression ''
        {
          wallpaper.default.path = "/home/alice/Pictures/wall.png";
          bar.default.center = [ "clock" ];
        }
      '';
      description = ''
        Written to ~/.config/noctalia/config.toml, merged over this module's
        defaults. Values changed in the settings window land in
        ~/.local/state/noctalia/settings.toml, which takes precedence over
        this file until removed there.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    dotfiles.noctalia = {
      settings = lib.mapAttrsRecursive (_: lib.mkDefault) defaults;
      islands = lib.mapAttrs (_: lib.mkDefault) defaultIslands;
    };

    warnings = lib.optional (lib.versionOlder cfg.package.version "5.4") ''
      dotfiles.noctalia: ${cfg.package.name} is older than 5.4; the generated
      settings and the Hyprland binds expect 5.4 (set dotfiles.noctalia.package).
    '';

    home.packages = [ cfg.package ];

    xdg.configFile = {
      "noctalia/config.toml".source = toml.generate "noctalia-config.toml" cfg.settings;
      "noctalia/palettes/${cfg.paletteName}.json".text = builtins.toJSON { dark = palette; };
    };

    # Started and stopped by hyprland.lua like the other session units: this
    # session never reaches graphical-session.target. Noctalia finds its logind
    # session through XDG_SESSION_ID, which hyprland.lua imports first; without
    # it lid and `loginctl lock-session` would not lock.
    systemd.user.services.noctalia = {
      Unit = {
        Description = "Noctalia desktop shell";
        Documentation = [ "https://docs.noctalia.dev/" ];
        PartOf = [ "graphical-session.target" ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      Service = {
        ExecStart = lib.getExe cfg.package;
        Restart = "on-failure";
        RestartSec = 2;
        Slice = "session.slice";
      };
    };
  };
}
