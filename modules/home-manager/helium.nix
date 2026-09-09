{ pkgs, ... }:

{
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.chromium = {
    enable = true;
    package = pkgs.chromium;
    commandLineArgs = [ "--no-default-browser-check" ];
    extensions = [
      "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin Lite
      "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # Privacy Badger
    ];
  };
}
