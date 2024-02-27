{ pkgs, ... }: {
  home.packages = with pkgs;
    [
      ((emacsPackagesFor emacs-unstable).emacsWithPackages
        (epkgs: [ epkgs.vterm ]))
    ];
}
