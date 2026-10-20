{
  config,
  lib,
  themed,
  ...
}:

{
  imports = [ ./lib.nix ];

  # Configuration only: the stylesheet relies on the wofi patches in core
  # (style priority, expandable rows), so install wofi from there.
  options.dotfiles.wofi.enable = lib.mkEnableOption "the themed wofi launcher configuration";

  config = lib.mkIf config.dotfiles.wofi.enable {
    stylix.targets.wofi.enable = false;

    xdg.configFile = {
      "wofi/config".source = ../../config/wofi/config;
      "wofi/style.css".source = themed ../../config/wofi/style.css;
    };
  };
}
