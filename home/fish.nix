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
      repeat = ''
        while read -P "Press enter to restart..." -n1 -s
          command $argv
        end
      '';
    };

    plugins = [
      {
        name = "replay";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "replay.fish";
          rev = "bd8e5b89ec78313538e747f0292fcaf631e87bd2";
          sha256 = "0f70ymn9zmawf99z1c952fv6dj66bkpakx2xwv3b6706sxb9jf7a";
        };
      }
      {
        name = "done";
        src = pkgs.fetchFromGitHub {
          owner = "franciscolourenco";
          repo = "done";
          rev = "d6abb267bb3fb7e987a9352bc43dcdb67bac9f06";
          sha256 = "1fn4q2clm0n9agb9f2vx1zj3g785kfjyyfdr2w3zzmsjaa8kcxqr";
        };
      }
      {
        name = "pisces";
        src = pkgs.fetchFromGitHub {
          owner = "laughedelic";
          repo = "pisces";
          rev = "e45e0869855d089ba1e628b6248434b2dfa709c4";
          sha256 = "05wjq7v0v5hciqa27wx2xypyywa4291pxmmvfv5yvwmxm1pc02hm";
        };
      }
    ];
  };
}
