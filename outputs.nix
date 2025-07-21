{
  self,
  nixpkgs,
  nur,
  darwin,
  home-manager,
  utils,
  ...
}@inputs:
let
  nixpkgsConfig = with inputs; {
    config.allowUnsupportedSystem = true;
    overlays = [
      self.overlays.default
      nur.overlays.default
      nuenv.overlays.nuenv
      (
        final: prev:
        let
          system = prev.stdenv.system;
          nixpkgs-stable = if prev.stdenv.isDarwin then nixpkgs-stable-darwin else nixos-stable;
        in
        {
          stable = nixpkgs-stable.legacyPackages.${system};
        }
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
        home-manager.darwinModules.home-manager
        ./darwin
        ./modules/home-manager.nix
        ./modules/nix.nix
        {
          nixpkgs.overlays = with inputs; [
            darwin-emacs.overlays.emacs
            darwin-emacs-packages.overlays.package
          ];
        }
        (
          { pkgs, ... }:
          {
            nixpkgs = nixpkgsConfig // {
              config.allowBroken = true;
            };
            system.primaryUser = "jcosta";
            users.users.jcosta = {
              home = "/Users/jcosta";
              description = "João Costa";
              shell = pkgs.fish;
            };
            nix.linux-builder = {
              enable = true;
              maxJobs = 4;
            };
            nix.settings.trusted-users = [ "jcosta" ];
            home-manager.users.jcosta = {
              imports = [
                inputs.cachix.homeManagerModules.declarative-cachix
                ./modules/home/darwin/trampoline-apps
                ./home/workstation.nix
              ];

              home.username = "jcosta";
              home.homeDirectory = "/Users/jcosta";
              home.stateVersion = "22.05";
              programs.home-manager.enable = true;
            };

            networking.computerName = "JC-m1max";
            networking.hostName = "JC-m1max";
            networking.knownNetworkServices = [
              "Wi-Fi"
              "USB 10/100/1000 LAN"
            ];
          }
        )
      ];
    };
  };

  nixosModules = lib.modulesIn ./modules/nixos;
  darwinModules = lib.modulesIn ./modules/darwin;
  homeManagerModules = lib.modulesIn ./modules/home;

  overlays = {
    default = (import ./overlays);
  };

  nixosConfigurations =
    with lib;
    let
      configs = modulesIn ./machines;
    in
    (mapAttrs (
      _: config:
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs nixosModules homeManagerModules; };
        modules = [
          inputs.nixos-generators.nixosModules.all-formats
          inputs.sops-nix.nixosModules.sops
          { nixpkgs = nixpkgsConfig; }
          home-manager.nixosModules.home-manager
          config
        ];
      }
    ) configs);

  deploy =
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      deployPkgs = import nixpkgs {
        inherit system;
        overlays = [
          inputs.deploy-rs.overlays.default
          (self: super: {
            deploy-rs = {
              inherit (pkgs) deploy-rs;
              lib = super.deploy-rs.lib;
            };
          })
        ];
      };
    in
    {
      sshUser = "root";
      user = "root";
      fastConnection = true;
      nodes = {
        builder = {
          hostname = "pve-nix-builder";
          profiles.system = {
            user = "root";
            path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.pvebuilder;
          };
        };
        dns = {
          hostname = "dns.qrtz.lab";
          profiles.system = {
            user = "root";
            path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.pvedns;
          };
        };
        nfs = {
          hostname = "pve-nfs";
          profiles.system = {
            user = "root";
            path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.pvenfs;
          };
        };
        seedbox = {
          hostname = "seedbox.qrtz.lab";
          profiles.system = {
            user = "root";
            path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.pveseedbox;
          };
        };
        media = {
          hostname = "media.qrtz.lab";
          profiles.system = {
            user = "root";
            path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.pvemedia;
          };
        };
        proxy = {
          hostname = "proxy.qrtz.lab";
          profiles.system = {
            user = "root";
            path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.pveproxy;
          };
        };
        git = {
          hostname = "git.qrtz.lab";
          profiles.system = {
            user = "root";
            path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.pvegit;
          };
        };
      };
    };

  checks = builtins.mapAttrs (
    system: deployLib: deployLib.deployChecks self.deploy
  ) inputs.deploy-rs.lib;
}
// utils.lib.eachDefaultSystem (
  system:
  let
    pkgs = import nixpkgs {
      inherit system;
      inherit (nixpkgsConfig) config overlays;
    };
    get-age-key = pkgs.writeShellScriptBin "get-age-key" ''
      ${pkgs.openssh}/bin/ssh-keyscan $1 | ${pkgs.ssh-to-age}/bin/ssh-to-age
    '';
    deploy-manual = pkgs.writeShellScriptBin "deploy-manual" ''
      ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake .#$1 --target-host $2 --fast
    '';
  in
  {
    legacyPackages = pkgs;
    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        get-age-key
        deploy-manual
        nixfmt-rfc-style
        nixd
        nil
        nixos-rebuild
        wireguard-tools
        sops
        gnupg
        proxmox-lxc-idmapper
        deploy-rs
      ];
    };
  }
)
