{ pkgs ? (import <nixpkgs> {}), haskellPackages ? pkgs.haskellPackages }:

let
  ukb = pkgs.callPackage (import ./ukb.nix) {};
  drv = haskellPackages.callCabal2nix "ukb" ./. {};
  inherit (pkgs.haskell.lib) appendConfigureFlag;

  pythonPackages = pkgs.python3Packages;
  posScript =
      pkgs.stdenv.mkDerivation {
        name = "pos-tag";
        nativeBuildInputs = [ pkgs.makeWrapper ];
        buildInputs = [ pythonPackages.nltk pythonPackages.six ];
        buildCommand = with pythonPackages; ''
          mkdir -p $out/bin
          makeWrapper ${./pos-tag.py} $out/bin/pos-tag.py \
              --prefix PYTHONPATH : "$(toPythonPath ${nltk}):$(toPythonPath ${six})" \
              --set POS_TAG_DATA_DIR ${posResources}
        '';
      };

  posResources = pkgs.stdenv.mkDerivation {
    name = "pos-tag-resources";
    buildInputs = [ pythonPackages.nltk pythonPackages.six ];
    buildCommand = ''
      mkdir -p $out
      python -m nltk.downloader -q -d $out punkt averaged_perceptron_tagger wordnet
    '';
  };
    
in 
  appendConfigureFlag
    (appendConfigureFlag drv "--ghc-option=-DPOS_TAG_PATH=\"${posScript}/bin/pos-tag.py\"")
    "--ghc-option=-DUKB_WSD_PATH=\"${ukb}/bin/ukb_wsd\""
    // { passthru.ukb = ukb; }