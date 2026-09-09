{ pkgs, ... }:

{
  stylix = {
    enable = true;
    polarity = "dark";

    # Ayu Dark exactly as Zed renders it (ayu-colors v2), not the older
    # base16-schemes "ayu-dark" which still carries the v1 foregrounds.
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

    # Можно не писать: по умолчанию включается через autoEnable.
    # Но для очевидности мне нравится оставить.
    targets.gtk.enable = true;
    # Chromium's interface theme is installed through Home Manager as a normal
    # Ayu Dark extension. The Stylix target would create managed browser policy.
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
