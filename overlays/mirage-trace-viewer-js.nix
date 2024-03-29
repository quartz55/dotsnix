{ lib
, fetchgit
, ocamlPackages
}:

with ocamlPackages;
let
  mirage-trace-viewer = buildDunePackage {
    pname = "mirage-trace-viewer";
    version = "master";

    useDune2 = true;

    minimumOCamlVersion = "4.08";

    src = fetchgit {
      url = "https://github.com/quartz55/mirage-trace-viewer";
      rev = "13b53d6";
      sha256 = "sha256-Yw84KPTruhs7REPFhRRhfy507xzg7Uoo3Wiyp+mSOq0=";
    };

    nativeBuildInputs = [ ];
    propagatedBuildInputs = [ ocplib-endian itv-tree cmdliner ];

    strictDeps = true;

    doCheck = true;
  };
in
buildDunePackage {
  pname = "mirage-trace-viewer-js";
  inherit (mirage-trace-viewer) version useDune2 src;

  buildInputs = [ mirage-trace-viewer ];

  propagatedBuildInputs = [
    js_of_ocaml-tyxml
    js_of_ocaml-ppx
    js_of_ocaml-lwt
    js_of_ocaml
  ];
}
