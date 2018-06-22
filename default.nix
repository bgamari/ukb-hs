with (import <nixpkgs> {});
let
  ukb = stdenv.mkDerivation {
    name = "ukb";
    src = fetchFromGitHub {
      owner = "bgamari";
      repo = "ukb";
      rev = "a57bd367dd2a30717b6032b3c3a1aad2dd2027ff";
      sha256 = null;
    };
    sourceRoot = "source/src";
    patches = [ ./ukb-parsability.patch ];

    nativeBuildInputs = [ autoreconfHook ];
    buildInputs = [ boost ];
    configureFlags = [ "--with-boost-include=${boost.dev}/include" "--with-boost-lib=${boost}/lib" ];
    enableParallelBuilding = true;
  };
in ukb
