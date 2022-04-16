{ pkgs, ... }:
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
      kak-prelude
      case-kak
      kak-auto-pairs
      kak-buffers
      kak-powerline
      kak-fzf
    ];
  };
}
