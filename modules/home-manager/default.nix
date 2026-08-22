{ config, lib, pkgs, ... }:

let
  colors = config.lib.stylix.colors;
  palette = {
    inherit (colors)
      base00
      base01
      base02
      base03
      base04
      base05
      base06
      base07
      base08
      base09
      base0A
      base0B
      base0C
      base0D
      base0E
      base0F
      ;
  };

  templateVars = palette // {
    DEFAULT_AUDIO_SINK = null;
    DEFAULT_AUDIO_SOURCE = null;
  };

  themed = src:
    pkgs.replaceVars src (
      lib.filterAttrs (name: _: lib.hasInfix "@${name}@" (builtins.readFile src)) templateVars
    );
in
{
  home = {
    username = "tea";
    homeDirectory = "/home/tea";
    stateVersion = "26.05";
  };

  # These configs use Stylix's palette through the templates below.
  # Disable the built-in targets so they do not generate conflicting files.
  stylix.targets = {
    hyprland.enable = false;
    hyprlock.enable = false;
    kitty.enable = false;
    waybar.enable = false;
    wofi.enable = false;
  };

  xdg.configFile = {
    "hypr/hyprland.conf".source = themed ./config/hypr/hyprland.conf;
    "hypr/hypridle.conf".source = ./config/hypr/hypridle.conf;
    "hypr/hyprlock.conf".source = themed ./config/hypr/hyprlock.conf;

    "kitty/kitty.conf".source = themed ./config/kitty/kitty.conf;

    "waybar/config.jsonc".source = themed ./config/waybar/config.jsonc;
    "waybar/style.css".source = themed ./config/waybar/style.css;

    "wofi/config".source = ./config/wofi/config;
    "wofi/style.css".source = themed ./config/wofi/style.css;
  };
}
