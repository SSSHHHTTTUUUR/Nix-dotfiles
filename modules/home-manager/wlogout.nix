{ config, zed, ... }:

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
        # Explicit user action may override agents' sleep inhibitors: systemd's
        # default "auto" still enforces them in logind without a terminal.
        # hypridle keeps --check-inhibitors=yes for automatic suspend.
        action = "systemctl suspend --check-inhibitors=no";
        text = "󰒲\nSuspend";
        keybind = "u";
      }
      {
        label = "logout";
        action = "hyprctl dispatch 'hl.dsp.exit()'";
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

        background-color: alpha(${zed.surface}, 0.96);

        border: 1px solid ${zed.border};
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

      /* Neutral by default; destructive actions get Zed's tinted semantic
         backgrounds instead of a saturated fill. */
      button:hover,
      button:focus {
        color: ${c.base05};
        background-color: ${zed.hover};
        border-color: ${zed.border};
      }

      button:active {
        background-color: ${zed.selected};
      }

      #suspend:hover,
      #suspend:focus {
        color: ${c.base0D};
        background-color: ${zed.infoBg};
        border-color: ${zed.infoBorder};
      }

      #reboot:hover,
      #reboot:focus {
        color: ${c.base0A};
        background-color: ${zed.warningBg};
        border-color: ${zed.warningBorder};
      }

      #shutdown:hover,
      #shutdown:focus {
        color: ${c.base08};
        background-color: ${zed.errorBg};
        border-color: ${zed.errorBorder};
      }
    '';
  };
}
