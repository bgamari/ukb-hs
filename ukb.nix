{ stdenv, fetchFromGitHub, autoreconfHook, boost }:

stdenv.mkDerivation {
  name = "ukb";
  src = fetchFromGitHub {
    owner = "bgamari";
    repo = "ukb";
    rev = "f4243169a7500bfcded4ff472ac71e3428a2f7ab";
    sha256 = "0fky7gmy4k1gdgb60kr6a8rvlz0c60qmp0n1srasxz34h2lfrnjk";
  };
  sourceRoot = "source/src";
  patches = [ ./ukb-parsability.patch ];

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ boost ];
  configureFlags = [ "--with-boost-include=${boost.dev}/include" "--with-boost-lib=${boost}/lib" ];
  enableParallelBuilding = true;
}
