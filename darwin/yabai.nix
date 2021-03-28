{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ yabai shkd ];
  services.yabai = {
    enable = true;
    package = pkgs.yabai;
    enableScriptingAddition = true;
    config = {
      focus_follows_mouse = "off";
      mouse_follows_focus = "off";
      window_placement = "second_child";
      window_opacity = "off";
      window_opacity_duration = "0.0";
      window_border = "on";
      window_border_placement = "inset";
      window_border_width = 2;
      window_border_radius = 3;
      active_window_border_topmost = "off";
      window_topmost = "on";
      window_shadow = "float";
      active_window_border_color = "0xff5c7e81";
      normal_window_border_color = "0xff505050";
      insert_window_border_color = "0xffd75f5f";
      active_window_opacity = "1.0";
      normal_window_opacity = "1.0";
      split_ratio = "0.50";
      auto_balance = "on";
      mouse_modifier = "fn";
      mouse_action1 = "move";
      mouse_action2 = "resize";
      layout = "bsp";
      top_padding = 5;
      bottom_padding = 5;
      left_padding = 5;
      right_padding = 5;
      window_gap = 5;
    };

    extraConfig = ''
      # rules
      yabai -m rule --add app='System Preferences' manage=off

      # labels
      yabai -m space 1 --label meet
      yabai -m space 2 --label web
      yabai -m space 3 --label dev
      yabai -m space 4 --label misc

      # signals
      yabai -m signal --add event=window_destroyed action="yabai -m query --windows --window &> /dev/null || yabai -m window --focus mouse"
      yabai -m signal --add event=application_terminated action="yabai -m query --windows --window &> /dev/null || yabai -m window --focus mouse"
    '';
  };

  services.skhd = {
    enable = true;
    package = pkgs.skhd;
    skhdConfig = ''
      fn + alt - h : yabai -m window --focus west
      fn + alt - l : yabai -m window --focus east
      fn + alt - k : yabai -m window --focus north
      fn + alt - j : yabai -m window --focus south
      fn + alt - z : yabai -m window --focus stack.prev
      fn + alt - x : yabai -m window --focus stack.next

      fn + alt - s : yabai -m space --layout stack
      fn + alt - a : yabai -m space --layout bsp

      fn + alt - d : yabai -m window --toggle zoom-parent
      fn + alt - f : yabai -m window --toggle zoom-fullscreen

      fn + alt - e : yabai -m window --toggle split

      fn + alt - space : yabai -m window --toggle float
      fn + alt - p : yabai -m window --toggle sticky;\
                     yabai -m window --toggle topmost;\
                     yabai -m window --toggle pip

      ctrl + shift + alt - tab : yabai -m space --focus recent
      cmd + alt - 1 : yabai -m space --focus 1
      cmd + alt - 2 : yabai -m space --focus 2
      cmd + alt - 3 : yabai -m space --focus 3
      cmd + alt - 4 : yabai -m space --focus 4
      cmd + alt - 5 : yabai -m space --focus 5
      cmd + alt - 6 : yabai -m space --focus 6
      cmd + alt - 7 : yabai -m space --focus 7
      cmd + alt - 8 : yabai -m space --focus 8
      cmd + alt - 9 : yabai -m space --focus 9
      cmd + alt - 0 : yabai -m space --focus 10

      cmd + shift + alt - 1 : yabai -m window --space 1
      cmd + shift + alt - 2 : yabai -m window --space 2
      cmd + shift + alt - 3 : yabai -m window --space 3
      cmd + shift + alt - 4 : yabai -m window --space 4
      cmd + shift + alt - 5 : yabai -m window --space 5
      cmd + shift + alt - 6 : yabai -m window --space 6
      cmd + shift + alt - 7 : yabai -m window --space 7
      cmd + shift + alt - 8 : yabai -m window --space 8
      cmd + shift + alt - 9 : yabai -m window --space 9
      cmd + shift + alt - 0 : yabai -m window --space 10
    '';
  };
}
