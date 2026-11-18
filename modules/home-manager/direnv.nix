{ config, lib, ... }:

{
  options.dotfiles.direnv.enable = lib.mkEnableOption ''
    direnv with nix-direnv, so a project flake loads into the shell that starts a program
  '';

  config = lib.mkIf config.dotfiles.direnv.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
