{ system, stdenv, fetchFromGitHub, bash, coreutils }:
let name = "apparmor-d";
in derivation {
  inherit name system;
  src = fetchFromGitHub {
    owner = "roddhjav";
    repo = "apparmor.d";
    rev = "f079792aeef4341487681acfd927d0d49814f637";
    hash = "sha256-Lgs+dsshg6txB7+vTvGKRc9FpVBxUc4Lq1l5ZJ2YwY4=";
  };
  builder = "${bash}/bin/bash";
  # now the question arises:
  # how the hell should i patch all of the binary paths (as well as other 
  # fsh-compliant paths) which are located in the nix store... 
  args = [
    "-c"
    ''
      ${coreutils}/bin/mkdir -p $out/bin
      ${coreutils}/bin/cp -r $src/* $out/
    ''
  ];
}
