{ pkgs, ... }:
{
  imports = [
    ./fish.nix
    # ./nushell.nix
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
    lazygit
    ### rust replacements
    ripgrep # grep
    eza # ls
    fd # find
    du-dust # du
    procs # ps
    tokei # wc (not quite)
    bottom # htop
    zoxide # z (cd jump)
    jq
    fzy
    skim
  ];

  # caches.cachix = [ "devenv" "nix-community" ];

  home.sessionVariables = {
    EDITOR = "kak";
  };

  programs.bash.enable = true;

  programs.nix-index.enable = true;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.bat.enable = true;
  programs.carapace.enable = true;

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
