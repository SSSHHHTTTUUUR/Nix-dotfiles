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
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./kitty.nix
    ./wlogout.nix
    ./fish.nix
    ./codex.nix
    ./fzf.nix
    ./yazi.nix
    ./browser.nix
  ];

  _module.args.themed = themed;

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
    mako.enable = false;
    waybar.enable = false;
    wofi.enable = false;
    yazi.enable = false;
  };

}
