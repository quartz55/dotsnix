{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;

  imports = [
    ./modules/programs/fish.nix
    ./modules/programs/kakoune.nix
  ];

  home.packages = with pkgs; [
    # nix
    cachix
    nixpkgs-fmt
    rnix-lsp

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
    procs # ps
    tokei # wc (not quite)
    bottom # htop
    zoxide # z (cd jump)
    jq
    fzy
    skim
    # helix

    # compilers/vms/runtimes
    python2Full
    python39
    nodejs_latest
    zig-master

    # others
    ffmpeg
    sqlite
    bitwarden-cli
    ssm

    # os goodies
    folderify
  ];

  home.sessionVariables = {
    EDITOR = "kak";
    # PAGER = "col -b -x | kak";
    # MANPAGER = "col -b -x | kak -e 'set buffer filetype man'";
  };


  programs.bash.enable = true;
  programs.zsh.enable = true;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    settings = {};
  };

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
