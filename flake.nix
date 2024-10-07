{
  description = "NixOS module to harden your system";

  # awesome resources this project is based on, many kudos
  # https://github.com/cynicsketch/nix-mineral
  # https://github.com/Kicksecure/security-misc
  # 
  # honorable mentions
  # https://spectrum-os.org/doc/installation/getting-spectrum.html

  # use stable channel by default
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

  outputs = { self, ... }: {
    nixosModules = rec {
      lonsdaleite.imports = [ ./src ];
      default = lonsdaleite; # convention
    };

    overlays = rec {
      lonsdaleite = final: prev: {
        lib = prev.lib.extend (finalLib: prevLib: {
          lonsdaleite = import ./lib {
            lib = finalLib;
            pkgs = final;
          };
        });
      };
      default = lonsdaleite;
    };
  };
}
