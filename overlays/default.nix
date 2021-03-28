self: super:

let
  inherit (super) callPackage;
  inherit (super.lib) optionalAttrs;
  inherit (super.stdenv) isDarwin;
in
optionalAttrs isDarwin {
  folderify = callPackage ./folderify.nix {};
  zig-master = callPackage ./zig-master.nix {};
  ssm = callPackage ./ssm.nix {};
}
