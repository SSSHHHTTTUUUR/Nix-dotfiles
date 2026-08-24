{ config, ... }:

let
  c = config.lib.stylix.colors.withHashtag;
in
{
  programs.wlogout = {
    enable = true;

    layout = [
      {
        label = "lock";
        action = "hyprlock";
        text = "󰌾\nLock";
        keybind = "l";
      }
      {
        label = "suspend";
        action = "systemctl suspend";
        text = "󰒲\nSuspend";
        keybind = "u";
      }
      {
        label = "logout";
        action = "hyprctl dispatch exit";
        text = "󰍃\nLogout";
        keybind = "e";
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        text = "󰜉\nReboot";
        keybind = "r";
      }
      {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "󰐥\nShutdown";
        keybind = "s";
      }
    ];

    style = ''
      * {
        background-image: none;
        box-shadow: none;
        font-family: "JetBrainsMono Nerd Font";
      }

      window {
        background-color: alpha(${c.base00}, 0.92);
      }

      button {
        color: ${c.base05};

        background-color: alpha(${c.base01}, 0.96);

        border: 1px solid alpha(${c.base03}, 0.75);
        border-radius: 18px;

        margin: 10px;
        padding: 28px;

        font-size: 19px;
        font-weight: 500;

        outline-style: none;
        text-shadow: none;

        transition:
          background-color 150ms ease,
          border-color 150ms ease,
          color 150ms ease;
      }

      button:hover,
      button:focus {
        color: ${c.base00};
        background-color: ${c.base0D};
        border-color: ${c.base0D};
      }

      button:active {
        background-color: ${c.base0C};
        border-color: ${c.base0C};
      }

      #shutdown:hover,
      #shutdown:focus {
        background-color: ${c.base08};
        border-color: ${c.base08};
      }

      #reboot:hover,
      #reboot:focus {
        background-color: ${c.base09};
        border-color: ${c.base09};
      }

      #suspend:hover,
      #suspend:focus {
        background-color: ${c.base0A};
        border-color: ${c.base0A};
      }
    '';
  };
}
