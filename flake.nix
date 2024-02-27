{
  description = "quartz's system configs using Nix";

  inputs = {
    # nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable-darwin.url = "github:nixos/nixpkgs/nixpkgs-23.11-darwin";
    nixos-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nur.url = "github:nix-community/NUR";

    # env
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    devenv.url = "github:cachix/devenv/latest";

    # cachix
    cachix.url = "github:jonascarpay/declarative-cachix";

    # emacs
    darwin-emacs = {
      url = "github:c4710n/nix-darwin-emacs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin-emacs-packages = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # others
    flake-registry = {
      url = "github:NixOS/flake-registry";
      flake = false;
    };
    comma.url = "github:nix-community/comma";
    utils.url = "github:numtide/flake-utils";
    # malob.url = "github:malob/nixpkgs";
    ocaml-overlays.url = "github:anmonteiro/nix-overlays";
    ocaml-overlays.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { ... }@args: import ./outputs.nix args;
}
