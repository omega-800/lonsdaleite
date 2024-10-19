{
  # awesome resources this project is based on, many kudos
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
  # 
  # honorable mentions
  # https://spectrum-os.org/doc/installation/getting-spectrum.html
  # https://github.com/NixOS/nixpkgs/issues/7220
  # https://github.com/NixOS/nixpkgs/pull/7212
  # https://www.redhat.com/en/blog/automated-auditing-system-using-scap

  description = "NixOS module to harden your system";

  inputs = {
    # use stable channel by default
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    # TODO: does flake-parts enable lazy evaluation of flake inputs?
    # i don't like trashing projects full with deps
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { self, nixpkgs, impermanence, ... }:
    let
      # TODO: system
      flake-lib = import ./lib/flake-lib.nix {
        inherit self;
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
      };
    in
    {
      nixosModules = rec {
        lonsdaleite = { config, lib, ... }: {
          imports = [ ./modules impermanence.nixosModules.impermanence ];
          _module.args.lonLib = import ./lib { inherit lib config; };
        };
        default = lonsdaleite; # convention
      };

      nixosConfigurations = flake-lib.mkHosts "x86_64-linux";

      # https://nixos.org/manual/nixos/stable/index.html#sec-nixos-tests
      checks = flake-lib.mkChecks "x86_64-linux";
    };
}
