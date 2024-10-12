{
  # awesome resources this project is based on, many kudos
  # https://github.com/cynicsketch/nix-mineral
  # https://github.com/Kicksecure/security-misc
  # https://madaidans-insecurities.github.io/guides/linux-hardening.html
  # https://theprivacyguide1.github.io/linux_hardening_guide
  # https://www.debian.org/doc/manuals/securing-debian-manual/
  # https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/security_guide/index
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

    test-vm = self.nixosConfigurations.test.config.system.build.vm;

    # to be run with nix run 
    # TODO: remove this when done with project
    apps.x86_64-linux = rec {
      default = test-vm;
      test-vm = {
        type = "app";
        program =
          "${self.nixosConfigurations.test.config.system.build.vm}/bin/run-nixos-vm";
        # "${(import nixpkgs { system = "x86_64-linux"; }).writeShellScript
        # "test" "echo '${
        #   builtins.concatStringsSep "xxx"
        #   (builtins.match "(.*)exec .* -cpu max(.*)" (builtins.readFile
        #     "${self.nixosConfigurations.test.config.system.build.vm}/bin/run-nixos-vm"))
        # }'"}";
      };
    };
  };
}
