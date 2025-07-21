{
  description = "quartz's system configs using Nix";

  inputs = {
    # nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable-darwin.url = "github:nixos/nixpkgs/nixpkgs-25.05-darwin";
    nixos-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nur.url = "github:nix-community/NUR";

    # env
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # cachix
    cachix.url = "github:jonascarpay/declarative-cachix";
    attic.url = "github:zhaofengli/attic";

    # emacs
    darwin-emacs = {
      url = "github:c4710n/nix-darwin-emacs";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin-emacs-packages = {
      url = "github:nix-community/emacs-overlay";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    # others
    deploy-rs.url = "github:serokell/deploy-rs";
    nuenv.url = "https://flakehub.com/f/DeterminateSystems/nuenv/*.tar.gz";
    crowdsec = {
      url = "git+https://codeberg.org/kampka/nix-flake-crowdsec.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix = {
      url = "github:musnix/musnix";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-registry = {
      url = "github:NixOS/flake-registry";
      flake = false;
    };
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { ... }@args: import ./outputs.nix args;
}
