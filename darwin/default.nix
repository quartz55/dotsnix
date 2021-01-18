{ lib, config, pkgs, ... }:

{
  imports = [
    # ./bootstrap.nix
    ./macos.nix
    ./yabai.nix
  ] ++ lib.filter lib.pathExists [ ./private.nix ];

  nixpkgs.overlays = [
    (self: super: {
      lazygit = super.callPackage ./pkgs/lazygit.nix { };
      zig-master = super.callPackage ./pkgs/zig-master.nix { };
      ssm = super.callPackage ./pkgs/ssm.nix { };
      # yabai = super.yabai.overrideAttrs (o: {
      #   version = "3.3.6";

      #   src = super.fetchFromGitHub {
      #     owner = "koekeishiya";
      #     repo = "yabai";
      #     rev = "v3.3.6";
      #     sha256 = "0319k35c2rm0hsf0s5qdx4510g2n3nzg42cw1mhxcqrpi63604gg";
      #   };
      # });
    })
  ];

  environment.systemPackages = with pkgs; [
    exa
    curl
    wget
    htop
    git
    vim
    ssm
    yabai
    skhd
  ];

  users.users.jcosta = {
    home = "/Users/jcosta";
    description = "João Costa";
    shell = pkgs.fish;
    packages = with pkgs; [
      home-manager
    ];
  };

  environment.variables = {
    PAGER = "less -R";
    EDITOR = "kak";
  };

  environment.shellAliases = {
    ls = "exa";
  };

  programs.nix-index.enable = true;

  services.lorri = {
    enable = true;
  };

  programs.bash.enable = true;
  programs.zsh.enable = true;
  programs.fish = {
    enable = true;
    # shellInit = ''
    #   function __nix_darwin_fish_macos_fix_path -d "reorder path prioritizing darwin-nix paths"
    #     set -l path $PATH
    #     set -l SYS_PATHS /usr/local/bin /usr/bin /bin /usr/sbin /sbin
    #     set -l found
    #     set -l i 1
    #     while not test -z $path[$i]
    #       set -l p $path[$i]
    #       if contains $p $SYS_PATHS; and not contains $p $fish_user_paths
    #         set found $found $p
    #         set -e path[$i]
    #         continue
    #       end
    #       set i (math $i + 1)
    #     end
    #     set -g PATH $path $found
    #   end
    # '';
    # interactiveShellInit = "__nix_darwin_fish_macos_fix_path";

    # Needed to address bug where $PATH is not properly set for fish:
    # https://github.com/LnL7/nix-darwin/issues/122
    interactiveShellInit = ''
      set -pg fish_function_path ${pkgs.fishPlugins.foreign-env}/share/fish/vendor_functions.d
      fenv source ${config.system.build.setEnvironment}
    '';
  };
  # Needed to ensure Fish is set as the default shell:
  # https://github.com/LnL7/nix-darwin/issues/146
  environment.variables.SHELL = "/run/current-system/sw/bin/fish";
  environment.shells = with pkgs; [ fish zsh bash ];


  services.activate-system.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # Enable experimental version of nix with flakes support
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  nix.maxJobs = 12;
  nix.buildCores = 0;
  nix.nixPath = pkgs.lib.mkForce [{
    darwin-config = builtins.concatStringsSep ":" [
      "$HOME/.nixpkgs/darwin-configuration.nix"
      "$HOME/.nix-defexpr/channels"
    ];
  }];
}

