{ lib, config, pkgs, ... }:

{
  imports = [
    ./macos.nix
    ./remote-builder
  ]
  ++ lib.filter lib.pathExists [ ./private.nix ];

  environment.systemPackages = with pkgs; [
    exa
    curl
    wget
    htop
    git
    vim
    comma
    lima
    colima
  ];

  nix.configureBuildUsers = true;

  environment.variables = {
    PAGER = "less -R";
  };

  environment.shellAliases = {
    ls = "exa";
  };

  programs.bash.enable = true;
  # programs.zsh.enable = true;
  programs.fish = {
    enable = true;
    useBabelfish = true;
    babelfishPackage = pkgs.babelfish;
    # Needed to address bug where $PATH is not properly set for fish:
    # https://github.com/LnL7/nix-darwin/issues/122
    loginShellInit = ''
      ### Add nix binary paths to the PATH
      # Perhaps someday will be fixed in nix or nix-darwin itself
      if test (uname) = Darwin
          for p in (string split : $NIX_PROFILES)
            fish_add_path --prepend "$p/bin"
          end
      end
    '';
  };
  # Needed to ensure Fish is set as the default shell:
  # https://github.com/LnL7/nix-darwin/issues/146
  environment.variables.SHELL = "${pkgs.fish}/bin/fish";
  environment.shells = with pkgs; [ fish zsh bash ];


  services.activate-system.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  nix.settings.max-jobs = 10;
  nix.settings.cores = 0;
}
