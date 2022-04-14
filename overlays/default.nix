self: super:

let
  inherit (super) callPackage;
  inherit (super.lib) optionalAttrs;
  inherit (super.stdenv) isDarwin;
in
{
  helix = callPackage ./helix.nix { };
  babeltrace2 = callPackage ./babeltrace2.nix { };
  mirage-trace-viewer-js = callPackage ./mirage-trace-viewer-js.nix { };
  awscli2 = (super.buildEnv {
    name = "wrapped-awscli2-${super.awscli2.version}";
    paths = [ super.awscli2 ];
    pathsToLink = [ "/bin" ];
    buildInputs = [ super.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/aws --unset PYTHONPATH
    '';
  });
} // optionalAttrs isDarwin {
  folderify = callPackage ./folderify.nix { };
  zig-master = callPackage ./zig-master.nix { };
  ssm = callPackage ./ssm.nix { };
}
