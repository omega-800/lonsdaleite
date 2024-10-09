{
  # awesome resources this project is based on, many kudos
  # https://github.com/cynicsketch/nix-mineral
  # https://github.com/Kicksecure/security-misc
  # https://madaidans-insecurities.github.io/guides/linux-hardening.html
  # https://theprivacyguide1.github.io/linux_hardening_guide
  # 
  # honorable mentions
  # https://spectrum-os.org/doc/installation/getting-spectrum.html

  description = "NixOS module to harden your system";

  inputs = {
    # use stable channel by default
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    # TODO: does flake-parts enable lazy evaluation of flake inputs?
    # i don't like trashing projects full with deps
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { self, nixpkgs, impermanence, ... }: {
    nixosModules = rec {
      lonsdaleite = { config, lib, ... }: {
        imports = [ ./modules impermanence.nixosModules.impermanence ];
        _module.args.lonLib = import ./lib { inherit lib config; };
      };
      default = lonsdaleite; # convention
    };

    nixosConfigurations.test = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ self.nixosModules.lonsdaleite ./test ];
    };
  };
}
