{ lib, stdenv, fetchurl, pkg-config, glib, popt }:

stdenv.mkDerivation rec {
  pname = "babeltrace2";
  version = "2.0.4";

  src = fetchurl {
    url = "https://www.efficios.com/files/babeltrace/babeltrace-${version}.tar.bz2";
    sha256 = "1hkg3phnamxfrhwzmiiirbhdgckzfkqwhajl0lmr1wfps7j47wcz";
  };

  nativeBuildInputs = [ pkg-config popt ];
  buildInputs = [ glib ];

  meta = with lib; {
    description = "Command-line tool and library to read and convert LTTng tracefiles";
    homepage = "https://www.efficios.com/babeltrace";
    license = licenses.mit;
    maintainers = [ maintainers.quartz55 ];
  };
}
