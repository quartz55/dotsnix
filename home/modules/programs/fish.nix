{ pkgs, ... }:
{
  programs.fish = {
    enable = true;

    shellAliases = {
      ls = "exa";
      ll = "exa -l";
      lt = "exa -T";
      llt = "exa -lT";
      llx = "exa -lahgmU@ --git";
    };

    shellAbbrs = {
      l = "less";
      gs = "git status";
      gst = "git stash";
      gco = "git checkout";
      gct = "git checkout -t origin/";
      gfa = "git fetch --all";
    };

    interactiveShellInit = ''
      bind \cr re_search
      set -gx fish_greeting
      # TODO do this programatically?
      zoxide init fish | source
    '';

    functions = {
      re_search = ''
        history merge
        set -l input (commandline -b)
        set -l exec (history | sk --tiebreak index,score,begin,end -q $input)
        if [ $status = 0 ]
          commandline -r $exec
        end
      '';
    };

    plugins = [
      {
        name = "bax";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "bax.fish";
          rev = "f009f1dc9e013c64b572e0ffba8cd4be3024eaa4";
          sha256 = "0f70ymn9zmawf99z1c952fv6dj66bkpakx2xwv3b6706sxb9jf7a";
        };
      }
      {
        name = "done";
        src = pkgs.fetchFromGitHub {
          owner = "franciscolourenco";
          repo = "done";
          rev = "3409c4a7b5363c786981761f12184112eccead70";
          sha256 = "1fn4q2clm0n9agb9f2vx1zj3g785kfjyyfdr2w3zzmsjaa8kcxqr";
        };
      }
      {
        name = "pisces";
        src = pkgs.fetchFromGitHub {
          owner = "laughedelic";
          repo = "pisces";
          rev = "34971b9671e217cfba0c71964f5028d44b58be8c";
          sha256 = "05wjq7v0v5hciqa27wx2xypyywa4291pxmmvfv5yvwmxm1pc02hm";
        };
      }
    ];
  };
}
