{ config, lib, themed, ... }:

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
      background-color = "#${colors.base01}";
      text-color = "#${colors.base05}";
      border-color = "#${colors.base03}";
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

      "urgency=low".border-color = "#${colors.base02}";
      "urgency=critical" = {
        border-color = "#${colors.base08}";
        default-timeout = 0;
      };
    };
  };

  # Hyprland 0.55 prefers hyprland.lua when it exists. Keep the established
  # Hyprlang configuration authoritative after Home Manager activation.
  home.activation.removeHyprlandLuaConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rm -f -- "${config.home.homeDirectory}/.config/hypr/hyprland.lua"
  '';

  xdg.configFile = {
    "hypr/hyprland.conf" = {
      source = themed ./config/hypr/hyprland.conf;
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
