{ config, lib, ... }:

{
  options.dotfiles.fzf.enable = lib.mkEnableOption "fzf with fish integration and a compact reverse layout";

  config = lib.mkIf config.dotfiles.fzf.enable {
    programs.fzf = {
      enable = true;
      enableFishIntegration = true;
      defaultOptions = [
        "--height=40%"
        "--layout=reverse"
        "--border=rounded"
      ];
    };
  };
}
