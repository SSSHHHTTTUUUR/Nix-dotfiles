{
  config,
  pkgs,
  themed,
  zed,
  ...
}:

let
  colors = config.lib.stylix.colors;
in
{
  services.mako = {
    enable = true;
    settings = {
      anchor = "top-right";
      layer = "overlay";
      font = "JetBrains Mono 11";
      background-color = zed.surface;
      text-color = "#${colors.base05}";
      border-color = zed.border;
      border-size = 1;
      border-radius = 8;
      width = 360;
      height = 120;
      margin = "12";
      padding = "12";
      default-timeout = 5000;
      max-visible = 5;
      icons = true;
      markup = true;

      "urgency=low".border-color = zed.borderVariant;
      # A condition is a tinted wash plus a matching border.
      "urgency=critical" = {
        background-color = zed.errorBg;
        border-color = zed.errorBorder;
        text-color = "#${colors.base08}";
        default-timeout = 0;
      };
    };
  };

  # Session daemons that must not die quietly: hypridle carries every automatic
  # lock (lid, before sleep, idle), the watchers feed the clipboard history.
  # Bare hl.exec_cmd children had no one to restart them. This session never
  # reaches graphical-session.target, so WantedBy would start nothing:
  # hyprland.lua starts them on hyprland.start and stops them on shutdown.
  # The history is capped and wiped per session — cliphist keeps it as plain
  # text, readable by any of tea's processes, agents included.
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
      source = themed ./config/hypr/hyprland.lua;
      force = true;
    };
    "hypr/hypridle.conf".source = ./config/hypr/hypridle.conf;
    "hypr/hyprlock.conf".source = themed ./config/hypr/hyprlock.conf;
    "wofi/config".source = ./config/wofi/config;
    "wofi/style.css".source = themed ./config/wofi/style.css;

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
}
