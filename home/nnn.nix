{ ... }:
{
programs.nnn = {
  enable = true;
  bookmarks = {
    w = "~/Documents/Workspace";
    q = "~/Documents/Workspace/dotsnix";
    d = "~/Documents";
    D = "~/Downloads";
    p = "~/Pictures";
    v = "~/Videos";
  };
  plugins = {
    src = ./plugins;
    mappings = {
      c = "fzcd";
      f = "finder";
      v = "imgview";
    };
  };
};
}
