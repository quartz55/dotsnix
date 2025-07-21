{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    ((emacsPackagesFor emacs-30).emacsWithPackages (epkgs: [ epkgs.vterm ]))

    # global lsps
    vscode-langservers-extracted
    nodePackages.typescript-language-server
    nodePackages.prettier
  ];
}
