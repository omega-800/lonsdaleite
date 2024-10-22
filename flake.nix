{
  # awesome resources this project is based on, many kudos
  # https://xeiaso.net/blog/paranoid-nixos-2021-07-18/
  # https://github.com/cynicsketch/nix-mineral
  # https://github.com/Kicksecure/security-misc
  # https://madaidans-insecurities.github.io/guides/linux-hardening.html
  # https://theprivacyguide1.github.io/linux_hardening_guide
  # https://www.debian.org/doc/manuals/securing-debian-manual/
  # https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/security_guide/index
  # https://documentation.suse.com/sles/12-SP5/html/SLES-all/preface-security.html
  # https://wiki.archlinux.org/title/Security
  # https://owasp.org/
  # https://wiki.gentoo.org/wiki/Project:Hardened
  # https://github.com/redcode-labs/RedNixOS
  # https://github.com/qbit/xin
  # https://github.com/Mic92/dotfiles
  # 
  # honorable mentions
  # https://spectrum-os.org/doc/installation/getting-spectrum.html
  # https://github.com/NixOS/nixpkgs/issues/7220
  # https://github.com/NixOS/nixpkgs/pull/7212
  # https://www.redhat.com/en/blog/automated-auditing-system-using-scap
  # https://presentations.nordisch.org/apparmor/#/

  description = "NixOS module to harden your system";

  inputs = {
    # use stable channel by default
    # TODO: switch back to stable after testing apparmor-d
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # TODO: does flake-parts enable lazy evaluation of flake inputs?
    # i don't like trashing projects full with deps
    impermanence.url = "github:nix-community/impermanence";
    apparmor-d = {
      url = "github:omega-800/apparmor.d";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }:
    let
      # TODO: system
      flake-lib = import ./lib/flake-lib.nix {
        inherit self;
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
      };
    in
    {
      nixosModules = flake-lib.mkModule;
      nixosConfigurations = flake-lib.mkHosts "x86_64-linux";
      checks = flake-lib.mkChecks "x86_64-linux";
      packages = flake-lib.mkPkgs "x86_64-linux";
    };
}
