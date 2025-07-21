{
  lib,
  osConfig,
  config,
  pkgs,
  ...
}:

{
  imports = [ ./macos.nix ] ++ lib.filter lib.pathExists [ ./private.nix ];

  environment.systemPackages = with pkgs; [
    eza
    curl
    wget
    htop
    git
    vim
    comma
    lima
    colima
  ];

  environment.variables = {
    PAGER = "less -R";
  };

  environment.shellAliases = {
    ls = "eza";
    lg = "lazygit";
  };

  programs.bash.enable = true;
  # programs.zsh.enable = true;
  programs.fish = {
    enable = true;
    useBabelfish = true;
    babelfishPackage = pkgs.babelfish;
    # Needed to address bug where $PATH is not properly set for fish:
    # https://github.com/LnL7/nix-darwin/issues/122
    # FIX: https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
    loginShellInit =
      let
        dquote = str: ''"'' + str + ''"'';
        makeBinPathList = map (path: path + "/bin");
      in
      ''
        fish_add_path --move --prepend --path ${
          lib.concatMapStringsSep " " dquote (makeBinPathList config.environment.profiles)
        }
        fish_add_path --move --append --path /nix/var/nix/profiles/default/bin
        set fish_user_paths $fish_user_paths
      '';
  };

  # Needed to ensure Fish is set as the default shell:
  # https://github.com/LnL7/nix-darwin/issues/146
  environment.variables.SHELL = "${pkgs.fish}/bin/fish";
  environment.shells = with pkgs; [
    fish
    zsh
    bash
  ];

  nix.enable = true;
  ids.gids.nixbld = 30000;
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  nix.settings.max-jobs = 10;
  nix.settings.cores = 0;
}
