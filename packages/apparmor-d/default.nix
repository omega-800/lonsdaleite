{ system, stdenv, fetchFromGitHub, go, lib }:
stdenv.mkDerivation {
  pname = "apparmor-d";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "omega-800";
    repo = "apparmor.d";
    rev = "4cc42239f094169b08c9f17332ed2852b2ff621d";
    hash = "sha256-ciJLYKqbMZqcTnf8rg/V9N1KfzdBOrIH+tzVc+h44BQ=";
  };

  nativeBuildInputs = [ go ];
  buildPhase = ''
    HOME=$(pwd) make
  '';

  installPhase = ''
    DESTDIR=$out PKGNAME=apparmor-d make install
  '';

  # installFlags = [ "DESTDIR=$out" "PKGNAME=apparmor-d" ];

  meta = {
    homepage = "https://apparmor.pujol.io";
    description = "Collection of apparmor profiles";
    licenses = with lib.licenses; [ gpl2 ];
    maintainers = [{
      github = "omega-800";
      githubId = 50942480;
      name = "omega";
    }];
    platforms = [ system ];
  };
}
