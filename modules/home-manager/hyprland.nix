{
  config,
  lib,
  pkgs,
  themed,
  themedWith,
  ...
}:

let
  cfg = config.dotfiles.hyprland;
  inherit (lib) mkOption types;

  # Lua string literals; JSON's quoting is valid Lua for these values.
  lua = builtins.toJSON;

  renderMonitor =
    m:
    "hl.monitor({ output = ${lua m.output}, mode = ${lua m.mode}, position = ${lua m.position}, scale = ${lua m.scale} })";

  # The panel is switched off on lid close and back on when it opens; outputs
  # not named here keep running, so a closed lid with an external monitor is
  # clamshell mode. `locked`, because by the time the lid opens hyprlock is up.
  lidSwitchBinds = lib.optionalString (cfg.internalDisplay != null) ''
    hl.bind("switch:on:Lid Switch",  hl.dsp.dpms({ action = "off", monitor = ${lua cfg.internalDisplay} }), { locked = true })
    hl.bind("switch:off:Lid Switch", hl.dsp.dpms({ action = "on",  monitor = ${lua cfg.internalDisplay} }), { locked = true })'';

  hyprlandVars = {
    monitors =
      if cfg.monitors == [ ] then
        "-- None configured: Hyprland applies its defaults to every output."
      else
        lib.concatMapStringsSep "\n" renderMonitor cfg.monitors;
    terminal = lua cfg.terminal;
    file_manager = lua cfg.fileManager;
    launcher = lua cfg.launcher;
    browser = lua cfg.browser;
    messenger = lua cfg.messenger;
    kb_layout = lua cfg.keyboard.layout;
    kb_options = lua cfg.keyboard.options;
    lid_switch_binds = lidSwitchBinds;
    extra_config = cfg.extraConfig;
  };

  monitorType = types.submodule {
    options = {
      output = mkOption {
        type = types.str;
        example = "eDP-1";
        description = "Connector name as `hyprctl monitors` reports it.";
      };
      mode = mkOption {
        type = types.str;
        example = "2560x1600@120";
        description = "Resolution and refresh rate, or `preferred` / `highres` / `highrr`.";
      };
      position = mkOption {
        type = types.str;
        default = "auto";
        example = "0x0";
        description = "Top-left corner in the layout, in logical pixels, or `auto`.";
      };
      scale = mkOption {
        type = types.either types.int types.float;
        default = 1;
        example = 1.25;
        description = "Output scale.";
      };
    };
  };
in
{
  imports = [ ./lib.nix ];

  options.dotfiles.hyprland = {
    enable = lib.mkEnableOption ''
      the Hyprland Lua configuration, hypridle, hyprlock, satty and the
      supervised session services (hypridle, cliphist watchers)
    '';

    monitors = mkOption {
      type = types.listOf monitorType;
      default = [ ];
      example = lib.literalExpression ''
        [
          { output = "HDMI-A-1"; mode = "3440x1440@100"; position = "0x0"; }
          { output = "eDP-1"; mode = "2560x1600@120"; position = "696x1440"; scale = 1.25; }
        ]
      '';
      description = "Monitor rules, rendered as `hl.monitor` calls at the top of hyprland.lua.";
    };

    internalDisplay = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "eDP-1";
      description = ''
        The laptop panel. When set, closing the lid turns this output off and
        opening it turns it back on (the lock itself is logind's job). `null`
        adds no lid binds.
      '';
    };

    keyboard = {
      layout = mkOption {
        type = types.str;
        default = "us";
        example = "us,ru";
        description = "xkb layouts (`input.kb_layout`).";
      };
      options = mkOption {
        type = types.str;
        default = "";
        example = "grp:alt_shift_toggle";
        description = "xkb options (`input.kb_options`).";
      };
    };

    terminal = mkOption {
      type = types.str;
      default = "kitty";
      description = "Command run by SUPER+Q.";
    };

    fileManager = mkOption {
      type = types.str;
      default = "thunar";
      description = "Command run by SUPER+E.";
    };

    launcher = mkOption {
      type = types.str;
      default =
        lib.optionalString (config.dotfiles.zed-editor.enable or false) "zed-recent-projects; "
        + "wofi --show drun";
      defaultText = lib.literalExpression ''"zed-recent-projects; wofi --show drun" (the first command only with dotfiles.zed-editor.enable)'';
      description = "Command run by SUPER+R.";
    };

    browser = mkOption {
      type = types.str;
      default = "firefox";
      description = "Command run by SUPER+B.";
    };

    messenger = mkOption {
      type = types.str;
      default = "Telegram";
      description = "Command run by SUPER+T.";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      example = ''
        hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })
      '';
      description = "Lua appended to the end of hyprland.lua: device rules, extra binds and window rules.";
    };
  };

  config = lib.mkIf cfg.enable {
    # The colours come from the templates below, not from Stylix's targets.
    stylix.targets = {
      hyprland.enable = false;
      hyprlock.enable = false;
    };

    # Session daemons that must not die quietly: hypridle carries every automatic
    # lock (lid, before sleep, idle), the watchers feed the clipboard history.
    # Bare hl.exec_cmd children had no one to restart them. This session never
    # reaches graphical-session.target, so WantedBy would start nothing:
    # hyprland.lua starts them on hyprland.start and stops them on shutdown.
    # The history is capped and wiped per session — cliphist keeps it as plain
    # text, readable by any of the user's processes.
    systemd.user.services =
      let
        sessionService = description: exec: {
          Unit = {
            Description = description;
            PartOf = [ "graphical-session.target" ];
            ConditionEnvironment = "WAYLAND_DISPLAY";
          };
          Service = {
            ExecStart = exec;
            Restart = "always";
            RestartSec = 2;
            Slice = "session.slice";
          };
        };
        watch =
          type:
          "${pkgs.wl-clipboard}/bin/wl-paste --type ${type} --watch ${pkgs.cliphist}/bin/cliphist -max-items 100 store";
      in
      {
        hypridle =
          let
            service = sessionService "Hyprland idle daemon" "${pkgs.hypridle}/bin/hypridle";
          in
          service
          // {
            Service = service.Service // {
              # Keep hyprlock started by hypridle alive when hypridle restarts.
              KillMode = "process";
            };
          };
        cliphist-text = sessionService "Clipboard history (text)" (watch "text");
        cliphist-image = sessionService "Clipboard history (images)" (watch "image");
      };

    xdg.configFile = {
      "hypr/hyprland.lua" = {
        source = themedWith hyprlandVars ../../config/hypr/hyprland.lua;
        force = true;
      };
      "hypr/hypridle.conf".source = ../../config/hypr/hypridle.conf;
      "hypr/hyprlock.conf".source = themed ../../config/hypr/hyprlock.conf;

      "satty/config.toml".text = ''
        [general]
        copy-command = "wl-copy"
        early-exit = true
        initial-tool = "arrow"
        output-filename = "~/Pictures/Screenshots/satty-%Y%m%d-%H%M%S.png"
        corner-roundness = 8
      '';
    };

    home.file."Pictures/Screenshots/.keep".text = "";
  };
}
