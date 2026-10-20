{
  config,
  lib,
  pkgs,
  themed,
  ...
}:

{
  imports = [ ./lib.nix ];

  options.dotfiles.kitty.enable = lib.mkEnableOption "kitty with the Zed Ayu Dark terminal palette";

  config = lib.mkIf config.dotfiles.kitty.enable {
    stylix.targets.kitty.enable = false;

    home.packages = [ pkgs.kitty ];

    xdg.configFile."kitty/kitty.conf".source = themed ../../config/kitty/kitty.conf;

    # kitten ssh only works inside kitty; an alias broke ssh in Zed's terminal
    # and on a TTY during recovery.
    programs.fish.functions.ssh = ''
      if set -q KITTY_WINDOW_ID; and isatty stdin
        kitten ssh $argv
      else
        command ssh $argv
      end
    '';
  };
}
