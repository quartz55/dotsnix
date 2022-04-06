{
  description = "quartz's system configs using Nix";

  inputs = {
    # nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable-darwin.url = "github:nixos/nixpkgs/nixpkgs-21.11-darwin";
    nixos-stable.url = "github:nixos/nixpkgs/nixos-21.11";
    nur.url = "github:nix-community/NUR";

    # env
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # others
    flake-registry = { url = "github:NixOS/flake-registry"; flake = false; };
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    comma = { url = "github:fzakaria/comma/check-local-index"; flake = false; };
    utils.url = "github:numtide/flake-utils";
    # malob.url = "github:malob/nixpkgs";
    ocaml-overlays = { url = "github:anmonteiro/nix-overlays"; flake = false; };
    # rnix-lsp.url = "github:nix-community/rnix-lsp";
    # rnix-lsp.inputs.nixpkgs.follows = "nixpkgs";
    # rnix-lsp.inputs.utils.follows = "utils";
  };

  outputs = { ... } @ args: import ./outputs.nix args;
}
