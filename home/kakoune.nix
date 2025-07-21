{ pkgs, config, ... }:
{
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
      # Source a local project kak config if it exists
      # Make sure it is set as a kak filetype
      hook global BufCreate (.*/)?(\.kakrc\.local) %{
          set-option buffer filetype kak
      }
      try %{ source .kakrc.local }

      set global grepcmd '${pkgs.ripgrep}/bin/rg --column --with-filename'

      ## Some pickers
      define-command -hidden open_buffer_picker %{
        prompt buffer: -menu -buffer-completion %{
          buffer %val{text}
        }
      }

      define-command -hidden open_file_picker %{
        prompt file: -menu -shell-script-candidates '${pkgs.fd}/bin/fd --type=file' %{
          edit -existing %val{text}
        }
      }

      define-command -hidden open_rg_picker %{
        prompt search: %{
          prompt refine: -menu -shell-script-candidates "${pkgs.ripgrep}/bin/rg -in '%val{text}'" %{
            eval "edit -existing  %sh{(cut -d ' ' -f 1 | tr ':' ' ' ) <<< $kak_text}"
          }
        }
      }
      map global user -docstring 'open buffer' b :open_buffer_picker<ret>
      map global user -docstring 'open file' f :open_file_picker<ret>
      map global user -docstring 'grep' g :open_rg_picker<ret>

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
              set-option buffer curword '''
          } }
      }
      add-highlighter global/ dynregex '%opt{curword}' 0:CurWord

      # System clipboard handling
      # ─────────────────────────
      evaluate-commands %sh{
          case $(uname) in
              Linux)  name="X11"; copy="xclip -i"; paste="xclip -o" ;;
              Darwin)  name="macOS"; copy="pbcopy"; paste="pbpaste" ;;
          esac

          printf "map global user -docstring 'paste (after) from clipboard' p '<a-!>%s<ret>'\n" "$paste"
          printf "map global user -docstring 'paste (before) from clipboard' P '!%s<ret>'\n" "$paste"
          printf "map global user -docstring 'yank to primary' y '<a-|>%s<ret>:echo -markup %%{{Information}copied selection to $name primary}<ret>'\n" "$copy"
          printf "map global user -docstring 'yank to clipboard' Y '<a-|>%s<ret>:echo -markup %%{{Information}copied selection to $name clipboard}<ret>'\n" "$copy -selection clipboard"
          printf "map global user -docstring 'replace from clipboard' R '|%s<ret>'\n" "$paste"
      }

      # Enable <tab>/<s-tab> for insert completion selection
      # ──────────────────────────────────────────────────────
      hook global InsertCompletionShow .* %{ map window insert <tab> <c-n>; map window insert <s-tab> <c-p> }
      hook global InsertCompletionHide .* %{ unmap window insert <tab> <c-n>; unmap window insert <s-tab> <c-p> }

      ## kitty integration
      define-command -hidden kitty-split -params 1 -docstring 'split the current window according to the param (vsplit / hsplit)' %sh{
        kitty @ launch --no-response --location $1 kak -c $kak_session
      }

      ## zellij integration
      define-command -hidden zellij-split -params 1 -docstring 'split (down / right)' %sh{
        zellij action new-pane -cd $1 -- kak -c $kak_session
      }
      define-command -hidden zellij-move-pane -params 1 -docstring 'move to pane' %sh{
        zellij action move-focus $1
      }
    '';

    plugins = with pkgs.kakounePlugins; [
      kak-prelude
      case-kak
      kak-auto-pairs
      kak-buffers
      kakoune-registers
      kak-powerline
      kak-fzf
      kakoune-lsp
      kakoune-easymotion
    ];
  };

  home.packages =
    let
      kak = "${config.programs.kakoune.package}/bin/kak";
      kakide = pkgs.writeShellScriptBin "kakide" ''
        server_name=$(basename `pwd`)
        socket_file=$(${kak} -l | grep $server_name)

        if [[ $socket_file == "" ]]; then
            # Create new kakoune daemon for current dir
            ${pkgs.toybox}/bin/setsid ${kak} -d -s $server_name &
        fi

        # and run kakoune (with any arguments passed to the script)
        ${kak} -c $server_name $@
      '';
    in
    [ kakide ];
}
