{ self }:
let
  inherit (self.inputs) nixpkgs;
  inherit (nixpkgs.lib)
    mapAttrs'
    removeSuffix
    nameValuePair
    filterAttrs
    hasPrefix
    hasSuffix
    nixosSystem
    ;
  inherit (builtins) readDir;
in
rec {
  pkgs = system: nixpkgs.legacyPackages.${system};

  mapDirs =
    mapFn: dir:
    mapAttrs' (n: v: mapFn n v) (
      filterAttrs
        (
          n: v:
          (!hasPrefix "_" n)
          && (
            (v == "regular" && hasSuffix ".nix" n)
            || (v == "directory" && builtins.pathExists "${dir}/${n}/default.nix")
          )
        )
        (readDir dir)
    );

  mkName = filename: if hasSuffix ".nix" filename then removeSuffix ".nix" filename else filename;

  mkFormatter = system: (pkgs system).nixfmt-rfc-style;

  mkChecks =
    system:
    {
      pre-commit-check = self.inputs.pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks.nixpkgs-fmt.enable = true;
      };
    }
    // (mapDirs
      (
        n: v:
        let
          name = mkName n;
        in
        nameValuePair name (
          (pkgs system).nixosTest (
            {
              inherit name;
              nodes.test =
                { ... }:
                {
                  imports = [
                    self.nixosModules.lonsdaleite
                    ../hosts/test.nix
                  ];
                };
            }
            // (import ../checks/${n})
          )
        )
      ) ../checks);

  mkHosts =
    system:
    mapDirs
      (
        n: v:
        let
          name = mkName n;
        in
        nameValuePair name (nixosSystem {
          inherit system;
          modules = [
            self.nixosModules.lonsdaleite
            ../hosts/${n}
          ];
        })
      ) ../hosts;

  mkPkgs =
    system:
    mapDirs
      (
        n: v: nameValuePair (mkName n) ((pkgs system).callPackage ../packages/${n} { inherit system; })
      ) ../packages;

  mkApps = system: rec {
    test-vm = {
      type = "app";
      program = "${self.nixosConfigurations.test.config.system.build.vm}/bin/run-nixos-vm";
    };
    default = test-vm;
  };

  mkModules = rec {
    lonsdaleite =
      { config, lib, ... }:
      {
        imports = [
          ../modules
          self.inputs.impermanence.nixosModules.impermanence
        ];
        _module.args = {
          inherit self;
          lon-lib = import ./lon-lib.nix { inherit lib config; };
        };
      };
    default = lonsdaleite; # convention
  };

  mkGithubActions = self.inputs.nix-github-actions.lib.mkGithubMatrix {
    checks = {
      # TODO: support for more architectures
      x86_64-linux = self.checks.x86_64-linux // self.packages.x86_64-linux;
    };
  };

  mkDevShell = system: rec {
    lonsdaleite = (pkgs system).mkShell {
      inherit (self.checks.${system}.pre-commit-check) shellHook;
      buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
      packages = with (pkgs system); [
        nixd
        nixfmt-rfc-style
      ];
    };
    default = lonsdaleite;
  };
}
