{
  config,
  lib,
  pkgs,
  ...
}:

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

  # Zed UI palette. It lives under modules/ so a system module can import it
  # too.
  zed = import ../../modules/themes/zed-ui.nix;

  # `borderVariant` -> `border_variant`, so templates read `#@zed_border_variant@`
  # the same way as `#@base05@`.
  toSnakeCase =
    name:
    lib.concatStrings (
      map (part: if builtins.isList part then "_" + lib.toLower (builtins.head part) else part) (
        builtins.split "([A-Z])" name
      )
    );

  zedVars = lib.mapAttrs' (
    name: value: lib.nameValuePair "zed_${toSnakeCase name}" (lib.removePrefix "#" value)
  ) zed;

  templateVars =
    palette
    // zedVars
    // {
      DEFAULT_AUDIO_SINK = null;
      DEFAULT_AUDIO_SOURCE = null;
    };

  themed =
    src:
    pkgs.replaceVars src (
      lib.filterAttrs (name: _: lib.hasInfix "@${name}@" (builtins.readFile src)) templateVars
    );

in
{
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./kitty.nix
    ./gtk.nix
    ./wlogout.nix
    ./fish.nix
    ./codex.nix
    ./claude-code.nix
    ./fzf.nix
    ./broot.nix
    ./browser.nix
    ./harness.nix
    ./teamspeak.nix
  ];

  _module.args = { inherit themed zed; };

  home = {
    username = "tea";
    homeDirectory = "/home/tea";
    stateVersion = "26.05";
  };

  # These apps take Stylix's palette by hand, through `themed` templates or
  # config.lib.stylix.colors in Nix, so their generated targets would collide.
  stylix.targets = {
    hyprland.enable = false;
    hyprlock.enable = false;
    kitty.enable = false;
    mako.enable = false;
    waybar.enable = false;
    wofi.enable = false;
    broot.enable = false;
  };

}
