{ stdenv, fetchFromGitHub, autoreconfHook, boost }:

stdenv.mkDerivation {
  name = "ukb";
  src = fetchFromGitHub {
    owner = "bgamari";
    repo = "ukb";
    rev = "f4243169a7500bfcded4ff472ac71e3428a2f7ab";
    sha256 = null;
  };
  sourceRoot = "source/src";
  patches = [ ./ukb-parsability.patch ];

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ boost ];
  configureFlags = [ "--with-boost-include=${boost.dev}/include" "--with-boost-lib=${boost}/lib" ];
  enableParallelBuilding = true;
}
