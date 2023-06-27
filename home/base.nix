{ pkgs, ... }:
{
  imports = [
    ./fish.nix
    ./kakoune.nix
    ./starship.nix
    ./pijul.nix
  ];

  programs.home-manager.enable = true;
  systemd.user.startServices = true;

  home.packages = with pkgs; [
    git

    # nix
    cachix
    devenv

    # terminal/shell goodies
    ranger
    nnn
    tig
    gitui
    ### rust replacements
    ripgrep # grep  
    exa # ls
    fd # find
    du-dust # du
    procs # FIXME: temporarily broken ps
    tokei # wc (not quite)
    bottom # htop
    zoxide # z (cd jump)
    jq
    fzy
    skim
  ];

  # caches.cachix = [
  #   "devenv"
  # ];

  home.sessionVariables = {
    EDITOR = "kak";
  };

  programs.bash.enable = true;

  programs.nix-index.enable = true;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.bat.enable = true;

  programs.neovim = {
    enable = true;
    vimAlias = true;
    extraConfig = ''
      colorscheme gruvbox
    '';
    plugins = with pkgs.vimPlugins; [
      vim-nix
      gruvbox
    ];
  };
}
