final: prev:

let
  inherit (prev) callPackage;
  inherit (prev.lib) optionalAttrs;
  inherit (prev.stdenv) isDarwin;
in
{
  awscli2 = (
    prev.buildEnv {
      name = "wrapped-awscli2-${prev.awscli2.version}";
      paths = [ prev.awscli2 ];
      pathsToLink = [ "/bin" ];
      buildInputs = [ prev.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/aws --unset PYTHONPATH
      '';
    }
  );
  proxmox-lxc-idmapper = callPackage ./proxmox-lxc-idmapper.nix { };
}
// optionalAttrs isDarwin {
  folderify = callPackage ./folderify.nix { };
  ssm = callPackage ./ssm.nix { };
}
