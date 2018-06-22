{ pkgs ? (import <nixpkgs> {}), haskellPackages ? pkgs.haskellPackages }:

let
  ukb = pkgs.callPackage (import ./ukb.nix) {};
  drv = haskellPackages.callCabal2nix "ukb" ./. {};
  inherit (pkgs.haskell.lib) appendConfigureFlag;
in 
  appendConfigureFlag
    (appendConfigureFlag drv "--ghc-option=-DPOS_TAG_PATH=\"${./pos-tag.py}\"")
    "--ghc-option=-DUKB_WSD_PATH=\"${ukb}/bin/ukb_wsd\""