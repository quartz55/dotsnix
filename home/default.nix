{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    direnv
    ranger
    tig
    lazygit
    thefuck
    bitwarden-cli

    ripgrep # grep replacement (in rust)
    exa # ls replacement (in rust)
    fd # find replacement (in rust)
    jq
    fzy
    skim     
    ffmpeg

    sqlite
    nodejs_latest
    zig-master

    python2Full
    python39
  ];

  home.sessionVariables = {
    EDITOR = "kak";
    # PAGER = "col -b -x | kak";
    # MANPAGER = "col -b -x | kak -e 'set buffer filetype man'";
  };


  programs.bash.enable = true;
  programs.zsh.enable = true;
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
      gcb = "git checkout -b";
      gfa = "git fetch --all";
    };

    promptInit = ''
    '';

    interactiveShellInit = ''
      bind \cr re_search
      set -gx fish_greeting
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
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "78861a85fc4da704cd7d669c1133355c89a4c667";
          sha256 = "1ffjihdjbj3359hjhg2qw2gfx5h7rljlz811ma0a318nkdcg1asx";
        };
      }
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

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    settings = {
    };
  };

  programs.kakoune = {
    enable = true;
    config = {
      colorScheme = "palenight";
      tabStop = 4;
      indentWidth = 2;
      alignWithTabs = false;
      numberLines = {
        enable = true;
        relative = false;
        highlightCursor = true;
      };
      showWhitespace.enable = true;
      ui = {
        statusLine = "bottom";
        assistant = "clippy";
        enableMouse = true;
      };
      keyMappings = [
        {
          mode = "normal";
          docstring = "Toggle comment on selected lines";
          key = "'#'";
          effect = ":comment-line<ret>";
        }
      ];
    };

    extraConfig = ''
      set global grepcmd 'rg --column --with-filename'

      # Enable editor config
      # ────────────────────
      hook global BufOpenFile .* %{ editorconfig-load }
      hook global BufNewFile .* %{ editorconfig-load }

      # Highlight the word under the cursor
      # ───────────────────────────────────
      declare-option -hidden regex curword
      set-face global CurWord default,rgb:808080
      # set-face global CurWord default,rgba:80808040

      hook global NormalIdle .* %{
          eval -draft %{ try %{
              exec <space><a-i>w <a-k>\A\w+\z<ret>
              set-option buffer curword "\b\Q%val{selection}\E\b"
          } catch %{
              set-option buffer curword ''\'''\'
          } }
      }
      add-highlighter global/ dynregex '%opt{curword}' 0:CurWord

      # System clipboard handling
      # ─────────────────────────
      evaluate-commands %sh{
          case $(uname) in
              Linux) copy="xclip -i"; paste="xclip -o" ;;
              Darwin)  copy="pbcopy"; paste="pbpaste" ;;
          esac

          printf "map global user -docstring 'paste (after) from clipboard' p '!%s<ret>'\n" "$paste"
          printf "map global user -docstring 'paste (before) from clipboard' P '<a-!>%s<ret>'\n" "$paste"
          printf "map global user -docstring 'yank to primary' y '<a-|>%s<ret>:echo -markup %%{{Information}copied selection to X11 primary}<ret>'\n" "$copy"
          printf "map global user -docstring 'yank to clipboard' Y '<a-|>%s<ret>:echo -markup %%{{Information}copied selection to X11 clipboard}<ret>'\n" "$copy -selection clipboard"
          printf "map global user -docstring 'replace from clipboard' R '|%s<ret>'\n" "$paste"
      }

      # Enable <tab>/<s-tab> for insert completion selection
      # ──────────────────────────────────────────────────────
      hook global InsertCompletionShow .* %{ map window insert <tab> <c-n>; map window insert <s-tab> <c-p> }
      hook global InsertCompletionHide .* %{ unmap window insert <tab> <c-n>; unmap window insert <s-tab> <c-p> }
    '';

    plugins = with pkgs.kakounePlugins; [
      # TODO
      # kak-prelude
      # case-kak
      # kak-auto-pairs
      # kak-buffers
      # kak-powerline
      # kak-fzf
    ];
  };

  programs.bat.enable = true;

  programs.neovim = {
    enable = false;
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
