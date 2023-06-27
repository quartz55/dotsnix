{ self, nixpkgs, nur, darwin, home-manager, deploy-rs, utils, ... } @ inputs:
let
  nixpkgsConfig = with inputs; {
    config.allowUnsupportedSystem = true;
    overlays = self.overlays ++ [
      nur.overlay
      (final: prev: {
        devenv = devenv.packages.${prev.stdenv.system}.devenv;
      })
    ] ++ [
      (
        final: prev:
          let
            system = prev.stdenv.system;
            nixpkgs-stable = if prev.stdenv.isDarwin then nixpkgs-stable-darwin else nixos-stable;
          in
          # ocaml-overlays.overlays.${system}.default final prev //
          { stable = nixpkgs-stable.legacyPackages.${system}; }
      )
    ];
  };
in
rec {
  lib = nixpkgs.lib.extend (import ./lib);

  darwinConfigurations = {
    workMacPro = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit inputs darwinModules homeManagerModules; };
      modules = [
        # inputs.malob.darwinModules.security.pam
        home-manager.darwinModules.home-manager
        ./darwin
        ./modules/home-manager.nix
        ./modules/nix.nix
        ({ pkgs, ... }: {
          nixpkgs = nixpkgsConfig // { config.allowBroken = true; };
          users.users.jcosta = {
            home = "/Users/jcosta";
            description = "João Costa";
            shell = pkgs.fish;
          };
          home-manager.users.jcosta = {
            imports = [
              inputs.cachix-modules.homeManagerModules.declarative-cachix
              ./home/workstation.nix
            ];

            home.username = "jcosta";
            home.homeDirectory = "/Users/jcosta";
            home.stateVersion = "22.05";
            programs.home-manager.enable = true;
          };
          # security.pam.enableSudoTouchIdAuth = true;

          networking.computerName = "JC-m1max";
          networking.hostName = "JC-m1max";
          networking.dns = [
            "8.8.8.8"
            "1.1.1.1"
          ];
          networking.knownNetworkServices = [
            "Wi-Fi"
            "USB 10/100/1000 LAN"
          ];
        })
      ];
    };
  };

  nixosModules = lib.modulesIn ./modules/nixos;
  darwinModules = lib.modulesIn ./modules/darwin;
  homeManagerModules = lib.modulesIn ./modules/home;

  overlays = with inputs; [
    comma.overlays.default
    (import ./overlays)
  ];

  nixosConfigurations = with lib;
    let
      configs = modulesIn ./machines;
    in
    (mapAttrs
      (_: config: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs nixosModules homeManagerModules; };
        modules = [
          inputs.sops-nix.nixosModules.sops
          { nixpkgs = nixpkgsConfig; }
          home-manager.nixosModules.home-manager
          config
        ];
      })
      configs);
} // utils.lib.eachDefaultSystem (
  system:
  let pkgs = import nixpkgs {
    inherit system; inherit (nixpkgsConfig) config overlays;
  }; in
  {
    legacyPackages = pkgs;
    devShells.default = pkgs.mkShell
      {
        buildInputs = with pkgs; [
          nixpkgs-fmt
          nil
          nixos-rebuild
          wireguard-tools
          sops
          gnupg
        ];
      };
  }
)
