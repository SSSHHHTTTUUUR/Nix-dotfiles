# dotfiles

Home Manager modules for a keyboard-driven Hyprland desktop, themed from one
palette: [Stylix](https://github.com/nix-community/stylix) supplies the base16
scheme (Zed's "Ayu Dark"), and a second, finer UI palette taken from the Zed
editor builds the interface — canvas, surfaces, chrome, borders and tinted
status colours.

Hand-written config files (Hyprland's Lua config, Waybar, wofi, kitty,
hyprlock) are kept as real files with `@base05@`-style placeholders and
rendered by Nix, so the palette is applied at build time rather than copied
into each file.

## Features

| Module | What it configures |
|---|---|
| `hyprland` | `hyprland.lua` (keybindings, animations, workspace swipe and wheel stepping, window rules, autostart), `hypridle.conf` (dim → lock → screen off → suspend, battery-aware), `hyprlock.conf`, satty, and supervised user services for hypridle and the cliphist watchers |
| `waybar` | Bar config and stylesheet: workspaces, window title, clock with calendar, MPRIS, keyboard layout, tray, CPU, memory, backlight, audio, network, battery, power profile |
| `wofi` | Launcher config and stylesheet |
| `clipboard` | `cliphist-wofi`, the SUPER+V clipboard history picker with image thumbnails and Shift+Delete removal |
| `mako` | Notifications |
| `kitty` | Terminal config and the Ayu Dark terminal palette; a fish `ssh` function that uses `kitten ssh` inside kitty only |
| `gtk` | GTK 2/3/4 and libadwaita colour overrides on top of Stylix's GTK target |
| `wlogout` | Five-button session menu |
| `broot` | broot with a base16 skin, opening with the preview panel |
| `fzf` | fzf with fish integration |
| `direnv` | direnv with nix-direnv, so a project flake loads into the shell |
| `claude-code` | Merges the official rust-analyzer LSP plugin into the mutable `~/.claude/settings.json`; host-specific proxy and hooks stay in the consumer's `settings` |
| `zed-editor` | Zed with workspace trust prompts, and its recent projects as desktop actions in the launcher |
| `helium` | The Helium browser, wrapped with a theme extension generated from the palette |

`nixosModules.theme` holds the system-wide Stylix setup: the scheme, JetBrains
Mono Nerd Font, Bibata cursor and Papirus icons.

## Requirements

- Home Manager and Stylix from the 26.05 release branches (the lock file pins
  the tested revisions). The modules read `config.lib.stylix.colors`, so the
  Stylix Home Manager module must be loaded — the Stylix NixOS module does that
  for every user automatically.
- Hyprland 0.55 or newer with Lua configuration (`hyprland.lua`).
- Programs the configuration calls but does not install, expected on `PATH`
  from the system: Hyprland, Waybar, wofi, hypridle, hyprlock, hyprpolkitagent,
  hyprshot, hyprpicker, satty, wlogout, awww, wl-clipboard, cliphist,
  brightnessctl, playerctl, pavucontrol, Thunar. The `core` repository's
  `core.desktop.hyprland` module installs exactly this set.
- Patched Waybar and wofi for full behaviour: workspace clicks under the Lua
  config, Right/Left in the launcher, the clipboard picker's `key_delete` and
  `uniform_rows` options. Unpatched builds run, but those features are missing.
  `core` ships both.
- Optional, from `core.power`: `on-ac` and `wake-displays` (used by
  `hypridle.conf`) and `display-power-mode` (run by `hyprland.lua`). Without
  them hypridle behaves as on battery all the time, and the refresh-rate call
  does nothing.
- `x86_64-linux` is the tested platform.

## Installation

Add the flake and import the default module for a user. With NixOS and the
Home Manager NixOS module:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles = {
      url = "github:OWNER/dotfiles"; # replace OWNER with the publishing account
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        stylix.follows = "stylix";
      };
    };
  };

  outputs =
    { nixpkgs, home-manager, stylix, dotfiles, ... }:
    {
      nixosConfigurations.example = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          dotfiles.nixosModules.theme
          {
            dotfiles.theme.enable = true;

            home-manager.useGlobalPkgs = true;
            home-manager.users.alice = {
              imports = [ dotfiles.homeManagerModules.default ];
              dotfiles.desktop.enable = true;
              home.stateVersion = "26.05";
            };
          }
          ./configuration.nix
        ];
      };
    };
}
```

`dotfiles.desktop.enable` turns on `hyprland`, `waybar`, `wofi`,
`clipboard`, `mako`, `kitty`, `gtk` and `wlogout`. The remaining modules
(`broot`, `fzf`, `zed-editor`, `helium`) have their own enable options.
`homeModules` is an alias of `homeManagerModules`.

## Individual modules

Every module is exported on its own and pulls in only the shared helper
(`lib.nix`):

```nix
{
  imports = [
    dotfiles.homeManagerModules.waybar
    dotfiles.homeManagerModules.kitty
  ];
  dotfiles.waybar.enable = true;
  dotfiles.kitty.enable = true;
}
```

Standalone Home Manager without NixOS works too; load Stylix yourself:

```nix
home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  modules = [
    stylix.homeModules.stylix
    dotfiles.homeManagerModules.waybar
    {
      stylix.enable = true;
      stylix.base16Scheme = "${dotfiles}/themes/zed-ayu-dark.yaml";
      dotfiles.waybar.enable = true;
      home = { username = "alice"; homeDirectory = "/home/alice"; stateVersion = "26.05"; };
    }
  ];
}
```

## Customization

Hyprland options (all optional):

| Option | Default | Meaning |
|---|---|---|
| `dotfiles.hyprland.monitors` | `[ ]` | List of `{ output, mode, position ? "auto", scale ? 1 }`, rendered as `hl.monitor` calls |
| `dotfiles.hyprland.internalDisplay` | `null` | Laptop panel to switch off on lid close and on when it opens |
| `dotfiles.hyprland.keyboard.layout` / `.options` | `"us"` / `""` | xkb layouts and options |
| `dotfiles.hyprland.terminal` | `"kitty"` | SUPER+Q |
| `dotfiles.hyprland.fileManager` | `"thunar"` | SUPER+E |
| `dotfiles.hyprland.launcher` | `"wofi --show drun"` (prefixed with `zed-recent-projects; ` when `zed-editor` is on) | SUPER+R |
| `dotfiles.hyprland.browser` | `"firefox"` | SUPER+B |
| `dotfiles.hyprland.messenger` | `"Telegram"` | SUPER+T |
| `dotfiles.hyprland.extraConfig` | `""` | Lua appended to `hyprland.lua` (device rules, extra binds, window rules) |

Other overrides:

- Any option of the underlying Home Manager modules can be set as usual, e.g.
  `services.mako.settings.default-timeout = 10000;` or
  `programs.fzf.defaultOptions = [ … ];`.
- A generated file can be replaced outright with `lib.mkForce`, e.g.
  `xdg.configFile."waybar/config.jsonc".source = lib.mkForce ./my-waybar.jsonc;`.
- `dotfiles.helium.package` selects the Helium build to wrap (default
  `pkgs.helium`, which the core overlay provides).

## Themes

Colours reach applications in three ways:

1. **Stylix targets** generate the config for apps without a module here.
2. **Nix attribute sets**: `mako`, `broot`, `wlogout`, `gtk` and `helium` read
   `config.lib.stylix.colors` and the UI palette directly.
3. **Templates**: `hyprland.lua`, `hyprlock.conf`, Waybar, wofi and kitty are
   files in `config/` rendered with `pkgs.replaceVars`. Placeholders are
   `@base00@`…`@base0F@` (hex without `#`) and `@zed_<name>@` for the UI
   palette (`borderVariant` → `@zed_border_variant@`). Only placeholders that
   occur in a file are substituted.

Each module that styles an app by hand disables that app's Stylix target, so
the two never collide.

The base16 scheme is `themes/zed-ayu-dark.yaml`, Zed's Ayu Dark
(ayu-colors v2) rather than the older base16 "ayu-dark". Stylix's YAML reader
is strict: keep that file to bare `key: "value"` lines without inline
comments.

The UI palette is the option `dotfiles.theme.ui`, defaulting to
`themes/zed-ui.nix`. Each key can be overridden alone:

```nix
{ dotfiles.theme.ui.surface = "#202228"; }
```

Conventions the stylesheets follow: blue (`base0D`) marks focus and active
state only; red, yellow and green report a condition as a tinted background
plus matching border, not a saturated fill.

Helium is themed by an unpacked theme extension built from the palette and
loaded with `--load-extension`. Stylix's chromium target stays disabled in
`nixosModules.theme`, because its `BrowserThemeColor` policy locks the
browser's appearance settings.

## Displays

Monitor layout is never hardcoded in this repository; supply it from your own
configuration:

```nix
{
  dotfiles.hyprland = {
    monitors = [
      { output = "DP-1"; mode = "2560x1440@144"; position = "0x0"; }
      { output = "eDP-1"; mode = "1920x1200@60"; position = "512x1440"; scale = 1.25; }
    ];
    internalDisplay = "eDP-1";
  };
}
```

With no monitors listed, Hyprland applies its own defaults. Connector names
come from `hyprctl monitors`. XWayland runs with `force_zero_scaling`, so
X11 apps on a scaled output need their own DPI or scale setting.

## Application configuration

| Path | Rendered to | Notes |
|---|---|---|
| `config/hypr/hyprland.lua` | `~/.config/hypr/hyprland.lua` | Template; monitors, lid binds, keyboard, commands and `extraConfig` are filled from options |
| `config/hypr/hypridle.conf` | `~/.config/hypr/hypridle.conf` | Copied as is |
| `config/hypr/hyprlock.conf` | `~/.config/hypr/hyprlock.conf` | Template |
| `config/waybar/` | `~/.config/waybar/` | Templates; `@DEFAULT_AUDIO_SINK@` is wpctl syntax and stays literal |
| `config/wofi/` | `~/.config/wofi/` | `style.css` is a template |
| `config/kitty/kitty.conf` | `~/.config/kitty/kitty.conf` | Template |
| `modules/home-manager/` | — | One module per application; `lib.nix` holds the template helper |
| `modules/nixos/theme.nix` | — | System-wide Stylix setup |
| `themes/` | — | base16 scheme and UI palette |

## Development

```console
nix develop          # nixfmt, statix, deadnix, nixd, lua
nix fmt              # format (nixfmt via nixfmt-tree)
nix flake check      # all checks below
```

The checks:

- `nixos-with-all-modules` — a NixOS system with Stylix, Home Manager, the
  theme module and every Home Manager module enabled evaluates.
- `standalone-home-manager` — a single module evaluates under standalone Home
  Manager, without NixOS or the theme module.
- `templates` — renders the templates (unfilled placeholders fail the build),
  parses the rendered `hyprland.lua` with `luac -p`, and checks that monitor,
  lid and `extraConfig` options land in it.
- `format`, `statix`, `deadnix`.

To try a change against a real system before committing, build the consuming
flake with `--override-input dotfiles path:/path/to/dotfiles`.

## Screenshots

None are included yet.

## License

Original code and configuration: [MIT](LICENSE). Palette origin and
third-party software: [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
