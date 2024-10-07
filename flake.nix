{
  # awesome resources this project is based on, many kudos
  # https://github.com/cynicsketch/nix-mineral
  # https://github.com/Kicksecure/security-misc
  # 
  # honorable mentions
  # https://spectrum-os.org/doc/installation/getting-spectrum.html

  description = "NixOS module to harden your system";

  # use stable channel by default
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

  outputs = { self, nixpkgs, ... }: {
    nixosModules = rec {
      lonsdaleite = { config, lib, ... }: {
        imports = [ ./module ];
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
