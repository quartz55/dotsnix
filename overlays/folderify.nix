{ lib
, python3
, buildPythonPackage ? python3.pkgs.buildPythonPackage
, fetchPypi ? python3.pkgs.fetchPypi
}:

buildPythonPackage rec {
  pname = "folderify";
  version = "1.2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0brafpgwq5s700kzsqyg5nva9ksa21930xnyg8s1ks2l6dasc3ys";
  };

  meta = with lib; {
    description = "Generate pretty, beveled macOS folder icons.";
    longDescription = "";
    homepage = https://github.com/lgarron/folderify;
    license = licenses.mit;
    platforms = platforms.darwin;
    maintainers = with maintainers; [ quartz55 ];
  };
}
