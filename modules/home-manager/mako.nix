{
  config,
  lib,
  zed,
  ...
}:

let
  colors = config.lib.stylix.colors;
in
{
  imports = [ ./lib.nix ];

  options.dotfiles.mako.enable = lib.mkEnableOption "mako notifications in the Zed UI palette";

  config = lib.mkIf config.dotfiles.mako.enable {
    stylix.targets.mako.enable = false;

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
  };
}
