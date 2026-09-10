{ pkgs, ... }:

{
  stylix = {
    enable = true;
    polarity = "dark";

    # Ayu Dark exactly as Zed renders it (ayu-colors v2), not the older
    # base16-schemes "ayu-dark" with its v1 foregrounds.
    base16Scheme = ./themes/zed-ayu-dark.yaml;

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };

      sansSerif = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };

      serif = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };

    # Enabled by default via autoEnable; kept explicit for clarity.
    targets.gtk.enable = true;
    # Chromium's UI theme is a normal Ayu Dark extension installed by Home
    # Manager; the Stylix target would create managed browser policy.
    targets.chromium.enable = false;

    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus";
    };
  };

  # Stylix pulls this in for its own targets, but the starship prompt and the
  # hand-written kitty config need the Nerd Font glyphs system-wide.
  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
}
