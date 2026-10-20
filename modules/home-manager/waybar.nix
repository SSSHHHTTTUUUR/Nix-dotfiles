{
  config,
  lib,
  themed,
  ...
}:

{
  imports = [ ./lib.nix ];

  # Configuration only: Waybar itself is started by hyprland.lua and comes from
  # the system (core installs a build patched for Hyprland's Lua dispatchers).
  options.dotfiles.waybar.enable = lib.mkEnableOption "the themed Waybar configuration and stylesheet";

  config = lib.mkIf config.dotfiles.waybar.enable {
    stylix.targets.waybar.enable = false;

    xdg.configFile = {
      "waybar/config.jsonc".source = themed ../../config/waybar/config.jsonc;
      "waybar/style.css".source = themed ../../config/waybar/style.css;
    };
  };
}
