{
  description = "quartz's system configs using Nix";

  inputs = {
    # nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable-darwin.url = "github:nixos/nixpkgs/nixpkgs-20.09-darwin";
    nixos-stable.url = "github:nixos/nixpkgs/nixos-20.09";
    nur.url = "github:nix-community/NUR";

    # env
    # darwin.url = "github:lnl7/nix-darwin";
    # TODO temp fix (https://github.com/LnL7/nix-darwin/pull/308)
    darwin.url = "github:hardselius/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # others
    comma = { url = "github:Shopify/comma"; flake = false; };
    utils.url = "github:numtide/flake-utils";
    malob.url = "github:malob/nixpkgs";
    # rnix-lsp.url = "github:nix-community/rnix-lsp";
    # rnix-lsp.inputs.nixpkgs.follows = "nixpkgs";
    # rnix-lsp.inputs.utils.follows = "utils";
  };


  outputs = { self, nixpkgs, nur, darwin, home-manager, utils, ... }@inputs:
    let
      nixpkgsConfig = with inputs; {
        config.allowUnfree = true;
        config.allowUnsupportedSystem = true;
        overlays = self.overlays ++ [
          (
            final: prev:
              let
                system = prev.stdenv.system;
                nixpkgs-stable = if prev.stdenv.isDarwin then nixpkgs-stable-darwin else nixos-stable;
              in
                { stable = nixpkgs-stable.legacyPackages.${system}; }
          )
        ];
      };

      homeManagerConfig = with self.homeManagerModules; {
        imports = [
          ./home
        ];
      };

      mkNixDarwinModules = { user }: [
        inputs.malob.darwinModules.security.pam
        ./darwin
        home-manager.darwinModules.home-manager
        rec {
          nixpkgs = nixpkgsConfig;
          users.users.${user}.home = "/Users/${user}";
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${user} = homeManagerConfig;
          security.pam.enableSudoTouchIdAuth = true;
        }
      ];
    in
      {
        darwinConfigurations = {
          personalMacPro = darwin.lib.darwinSystem {
            inputs = { inherit darwin nixpkgs; };
            modules = mkNixDarwinModules { user = "jcosta"; } ++ [
              {
                networking.computerName = "quartz 💻";
                networking.hostName = "m13pro";
                networking.dns = [
                  "8.8.8.8"
                  "1.1.1.1"
                ];
                networking.knownNetworkServices = [
                  "Wi-Fi"
                  "USB 10/100/1000 LAN"
                ];
              }
            ];
          };

          workMacPro = darwin.lib.darwinSystem {
            inputs = { inherit darwin nixpkgs; };
            modules = mkNixDarwinModules { user = "jcosta"; } ++ [
              {
                networking.computerName = "quartz 💻";
                networking.hostName = "bp-m16pro";
                networking.dns = [
                  "8.8.8.8"
                  "1.1.1.1"
                ];
                networking.knownNetworkServices = [
                  "Wi-Fi"
                  "USB 10/100/1000 LAN"
                ];
              }
            ];
          };


          githubCI = darwin.lib.darwinSystem {
            modules = mkNixDarwinModules { user = "github-runner"; };
          };
        };

        darwinModules = {};

        homeManagerModules = {};

        overlays = with inputs; [
          (
            final: prev: {
              comma = import comma { inherit (prev) pkgs; };
              # rnix-lsp = import rnix-lsp { inherit (prev) pkgs; };
            }
          )
          (import ./overlays)
        ];

        defaultPackage."x86_64-darwin" = self.darwinConfigurations.personalMacPro.system;

      } // utils.lib.eachDefaultSystem (
        system: {
          legacyPackages = import nixpkgs { inherit system; inherit (nixpkgsConfig) config overlays; };
        }
      );
}
