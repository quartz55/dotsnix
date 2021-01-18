{
  description = "quartz's system configs using Nix";

  inputs = {
    # nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs-stable-darwin.url = "github:nixos/nixpkgs/nixpkgs-20.09-darwin";
    nixos-stable.url = "github:nixos/nixpkgs/nixos-20.09";
    nur.url = "github:nix-community/NUR";


    # env
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # others
    comma = { url = "github:Shopify/comma"; flake = false; };
    flake-utils.url = "github:numtide/flake-utils";
  };


  outputs = { self, nixpkgs, nur, darwin, home-manager, flake-utils, ... }@inputs:
  let
    nixpkgsConfig = with inputs; {
      config.allowUnfree = true;
      overlays = self.overlays;
    };

    homeManagerConfig = with self.homeManagerModules; {
      imports = [
        ./home
      ];
    };

    mkNixDarwinModules = { user }: [
      self.darwinModules.programs.fish
      ./darwin
      home-manager.darwinModules.home-manager
      {
        nixpkgs = nixpkgsConfig;
        users.users.${user}.home = "/Users/${user}";
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${user} = homeManagerConfig;
      }
    ];
  in {
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

    darwinModules = {
      programs.fish = import ./darwin/modules/programs/fish.nix;
    };

    homeManagerModules = { };

    overlays = with inputs; [
      (final: prev: {
        comma = import comma { inherit (prev) pkgs; };
      })
      (import ./overlays)
    ];

    defaultPackage."x86_64-darwin" = self.darwinConfigurations.personalMacPro.system;

  } // flake-utils.lib.eachDefaultSystem (system: {
      legacyPackages = import nixpkgs { inherit system; inherit (nixpkgsConfig) config overlays; };
  });
}
