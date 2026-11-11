{
  description = "Home Manager modules for a Hyprland desktop themed with Stylix and Zed's Ayu Dark palette";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Only the checks use these two; the exported modules expect the consumer
    # to provide Home Manager and Stylix.
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      stylix,
    }:
    let
      inherit (nixpkgs) lib;

      systems = [ "x86_64-linux" ];
      forAllSystems = f: lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      homeModuleNames = [
        "broot"
        "clipboard"
        "fzf"
        "gtk"
        "helium"
        "hyprland"
        "kitty"
        "mako"
        "noctalia"
        "waybar"
        "wlogout"
        "wofi"
        "zed-editor"
      ];

      homeManagerModules = lib.genAttrs homeModuleNames (name: ./modules/home-manager/${name}.nix) // {
        default = ./modules/home-manager;
      };
    in
    {
      inherit homeManagerModules;
      # The name current Home Manager documentation uses.
      homeModules = homeManagerModules;

      nixosModules = {
        theme = ./modules/nixos/theme.nix;
        default = self.nixosModules.theme;
      };

      checks = forAllSystems (
        pkgs:
        let
          inherit (pkgs.stdenv.hostPlatform) system;

          # Every module on, with stand-ins for what a real host provides.
          everything = {
            dotfiles = {
              desktop.enable = true;
              broot.enable = true;
              fzf.enable = true;
              zed-editor.enable = true;
              helium = {
                enable = true;
                package = pkgs.writeShellScriptBin "helium" "";
              };
              hyprland = {
                monitors = [
                  {
                    output = "eDP-1";
                    mode = "1920x1080@60";
                    scale = 1.25;
                  }
                ];
                internalDisplay = "eDP-1";
                keyboard.layout = "us,de";
                extraConfig = ''
                  hl.device({ name = "example-mouse", sensitivity = -0.5 })
                '';
              };
            };
            home.stateVersion = "26.05";
          };

          # 1. Inside NixOS, the way most consumers use it: Stylix's NixOS
          #    module themes the system and hands the palette to Home Manager.
          nixos = lib.nixosSystem {
            inherit system;
            modules = [
              stylix.nixosModules.stylix
              home-manager.nixosModules.home-manager
              self.nixosModules.theme
              {
                boot.loader.grub.enable = false;
                fileSystems."/" = {
                  device = "/dev/disk/by-label/nixos";
                  fsType = "ext4";
                };
                system.stateVersion = "26.05";

                dotfiles.theme.enable = true;
                users.users.alice.isNormalUser = true;
                home-manager.useGlobalPkgs = true;
                home-manager.users.alice = {
                  imports = [ self.homeManagerModules.default ];
                  config = everything;
                };
              }
            ];
          };
          hm = nixos.config.home-manager.users.alice;

          # The same desktop with Noctalia as the shell instead of Waybar & co.
          hmNoctalia =
            (nixos.extendModules {
              modules = [ { home-manager.users.alice.dotfiles.noctalia.enable = true; } ];
            }).config.home-manager.users.alice;

          # 2. Standalone Home Manager without NixOS and without the theme
          #    module: one individual module, Stylix configured by hand.
          standalone = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              stylix.homeModules.stylix
              self.homeManagerModules.waybar
              {
                home = {
                  username = "alice";
                  homeDirectory = "/home/alice";
                  stateVersion = "26.05";
                };
                stylix = {
                  enable = true;
                  base16Scheme = ./themes/zed-ayu-dark.yaml;
                };
                dotfiles.waybar.enable = true;
              }
            ];
          };

          # Writes a .drv path without building it: evaluation is what is tested.
          evaluates =
            name: drv: pkgs.writeText "eval-${name}" (builtins.unsafeDiscardStringContext drv.drvPath);

          lint =
            name: tools: command:
            pkgs.runCommand "check-${name}" { nativeBuildInputs = tools; } ''
              cd ${self}
              ${command}
              touch $out
            '';

          hyprlandLua = hm.xdg.configFile."hypr/hyprland.lua".source;
        in
        {
          nixos-with-all-modules = evaluates "nixos" nixos.config.system.build.toplevel;
          standalone-home-manager = evaluates "standalone" standalone.activationPackage;

          # Builds the rendered templates: replaceVars fails on any placeholder
          # it could not fill, and the Lua must parse.
          templates =
            pkgs.runCommand "check-templates"
              {
                nativeBuildInputs = [ pkgs.lua5_4 ];
                files = map (name: hm.xdg.configFile.${name}.source) [
                  "hypr/hyprlock.conf"
                  "kitty/kitty.conf"
                  "waybar/config.jsonc"
                  "waybar/style.css"
                  "wofi/style.css"
                ];
              }
              ''
                luac -p ${hyprlandLua}
                grep -q 'hl.monitor({ output = "eDP-1", mode = "1920x1080@60", position = "auto", scale = 1.25 })' ${hyprlandLua}
                grep -q 'switch:on:Lid Switch' ${hyprlandLua}
                grep -q 'example-mouse' ${hyprlandLua}
                for f in $files; do test -s "$f"; done
                touch $out
              '';

          # Noctalia replaces the bar, notifications, power menu and locker: the
          # Lua must select it, hypridle must not start hyprlock, and the
          # replaced configs must be gone.
          noctalia =
            pkgs.runCommand "check-noctalia"
              {
                nativeBuildInputs = [ pkgs.lua5_4 ];
                lua = hmNoctalia.xdg.configFile."hypr/hyprland.lua".source;
                idle = hmNoctalia.xdg.configFile."hypr/hypridle.conf".source;
                toml = hmNoctalia.xdg.configFile."noctalia/config.toml".source;
              }
              ''
                luac -p $lua
                grep -q 'local shell       = "noctalia"' $lua
                grep -q 'bin/noctalia msg panel-toggle launcher' $lua
                grep -q 'is-active noctalia || pidof hyprlock || hyprlock' $idle
                grep -q 'custom_palette = "stylix"' $toml
                touch $out
              '';

          assertions-noctalia =
            assert !(hmNoctalia.xdg.configFile ? "waybar/config.jsonc");
            assert !hmNoctalia.services.mako.enable;
            assert !hmNoctalia.programs.wlogout.enable;
            pkgs.emptyFile;

          format = lint "format" [ pkgs.nixfmt ] "nixfmt --check $(find . -name '*.nix')";
          statix = lint "statix" [ pkgs.statix ] "statix check .";
          deadnix = lint "deadnix" [ pkgs.deadnix ] "deadnix --fail .";
        }
      );

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            deadnix
            git
            lua5_4
            nixd
            nixfmt
            statix
          ];

          shellHook = ''
            echo "dotfiles development shell"
            echo "Format: nix fmt | Lint: statix check . | Unused code: deadnix . | Checks: nix flake check"
          '';
        };
      });

      # nixfmt-tree runs nixfmt over the whole tree; bare nixfmt gets no file
      # arguments from `nix fmt` and reads stdin.
      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
