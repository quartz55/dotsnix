{ lib, pkgs, ... }:
{
  programs.pijul = {
    enable = true;
    settings = {
      author = {
        name = "quartz55";
        full_name = "João Costa";
        email = "john.razor97@gmail.com";
      };
    };
  };
}
