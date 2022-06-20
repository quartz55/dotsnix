{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.programs.pijul;
  tomlFormat = pkgs.formats.toml { };
in
{
  meta.maintainers = [ maintainers.quartz55 ];

  options.programs.pijul = {
    enable = mkEnableOption "pijul";

    package = mkOption {
      type = types.package;
      default = pkgs.pijul;
      defaultText = literalExpression "pkgs.pijul";
      description = "The package to use for the pijul binary.";
    };

    settings = mkOption {
      type = with types;
        let
          prim = either bool (either int str);
          primOrPrimAttrs = either prim (attrsOf prim);
          entry = either prim (listOf primOrPrimAttrs);
          entryOrAttrsOf = t: either entry (attrsOf t);
          entries = entryOrAttrsOf (entryOrAttrsOf entry);
        in
        attrsOf entries // { description = "Pijul configuration"; };
      default = { };
      example = literalExpression ''
        {
          author = {
            name = "jdoe";
            full_name = "Jane Doe";
            email = "jane.doe@anonymous.org";
          };
        }
      '';
      description = ''
        Configuration written to
        <filename>$XDG_CONFIG_HOME/pijul/config.toml</filename>.
        </para><para>
        See <link xlink:href="https://pijul.org/manual/configuration.html" /> for the full list
        of options.
      '';
    };

  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."pijul/config.toml" = mkIf (cfg.settings != { }) {
      source = tomlFormat.generate "pijul-config" cfg.settings;
    };
  };
}
