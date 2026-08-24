{ themed, ... }:

{
  xdg.configFile = {
    "waybar/config.jsonc".source = themed ./config/waybar/config.jsonc;
    "waybar/style.css".source = themed ./config/waybar/style.css;
  };
}
