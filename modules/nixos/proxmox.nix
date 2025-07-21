{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  cfg = config.proxmox;
  idMapping =
    with types;
    submodule {
      options = {
        id = mkOption { type = int; };
        name = mkOption { type = str; };
      };
    };
in
{
  meta.maintainers = [ maintainers.quartz55 ];

  options.proxmox = {
    enable = mkEnableOption ''
      Enable Proxmox support
    '';

    nix.gc = mkEnableOption ''
      Enable automatic garbage collection of nix store
    '';

    initialPassword = mkOption {
      type = types.str;
      default = "admin";
    };

    enableSops = mkEnableOption ''
      Enable automatic garbage collection of nix store
    '';

    mappedUsers = mkOption {
      type = types.listOf idMapping;
      default = [ ];
      example = [
        {
          id = 58;
          name = "video";
        }
      ];
    };

    mappedGroups = mkOption {
      type = types.listOf idMapping;
      default = [
        {
          id = 503;
          name = "media";
        }
      ];
    };
  };

  config = mkIf cfg.enable {
    nix = {
      package = pkgs.nixVersions.latest;
      extraOptions = ''
        experimental-features = nix-command flakes auto-allocate-uids
        keep-outputs = ${if cfg.nix.gc then "false" else "true"}
        keep-derivations = ${if cfg.nix.gc then "false" else "true"}
        min-free = ${toString (100 * 1024 * 1024)}
        max-free = ${toString (1024 * 1024 * 1024)}
      '';
      settings.trusted-users = [
        "root"
        "@wheel"
      ];
      nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
      registry = {
        self.flake = inputs.self;

        nixpkgs = {
          from = {
            id = "nixpkgs";
            type = "indirect";
          };
          flake = inputs.nixpkgs;
        };
      };

      # Optimise storage (https://nixos.wiki/wiki/Storage_optimization)
      optimise.automatic = true;
      optimise.dates = [ "03:00" ];
      gc = mkIf cfg.nix.gc {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };

    # Set root password + UID and GID mappings
    users.users =
      {
        root.initialPassword = cfg.initialPassword;
      }
      // listToAttrs (
        map (m: {
          name = m.name;
          value = {
            uid = m.id;
          };
        }) cfg.mappedUsers
      );

    users.groups = listToAttrs (
      map (m: {
        name = m.name;
        value = {
          gid = m.id;
        };
      }) cfg.mappedGroups
    );

    sops = mkIf cfg.enableSops {
      # This will automatically import SSH keys as age keys
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      age.keyFile = "/var/lib/sops-nix/key.txt";
      age.generateKey = true;
    };

    environment.systemPackages = with pkgs; [
      vim
      bat
      kakoune
    ];

    formatConfigs.proxmox =
      { config, modulesPath, ... }:
      {
        imports = [ (modulesPath + "/virtualisation/proxmox-image.nix") ];
      };

    formatConfigs.proxmox-lxc =
      { config, modulesPath, ... }:
      {
        imports = [ (modulesPath + "/virtualisation/proxmox-lxc.nix") ];
      };
  };
}
