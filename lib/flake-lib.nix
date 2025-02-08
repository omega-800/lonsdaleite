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
    genAttrs
    attrsToList
    ;
  inherit (builtins)
    readDir
    pathExists
    listToAttrs
    concatMap
    ;
in
rec {
  systems = [
    "x86_64-linux"
    # TODO: 
    # "aarch64-linux"
    # "i686-linux"
  ];

  forEachSystem = f: genAttrs systems f;
  forEachSystem' = f: listToAttrs (concatMap f systems);

  pkgs = system: nixpkgs.legacyPackages.${system};

  filterDirFn =
    dir: n: v:
    (!hasPrefix "_" n)
    && (
      (v == "regular" && hasSuffix ".nix" n) || (v == "directory" && pathExists "${dir}/${n}/default.nix")
    );

  mapDirs = mapFn: dir: mapAttrs' mapFn (filterAttrs (filterDirFn dir) (readDir dir));
  mapDirs' = mapFn: dir: map mapFn (attrsToList (filterAttrs (filterDirFn dir) (readDir dir)));

  mkName = filename: if hasSuffix ".nix" filename then removeSuffix ".nix" filename else filename;

  mkFormatter = system: (pkgs system).nixfmt-rfc-style;

  mkChecks =
    system:
    {
      pre-commit-check = self.inputs.pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          nixpkgs-fmt.enable = false;
          nixfmt-rfc-style.enable = true;
        };
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
                _:
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
    mapDirs'
      (
        v:
        let
          n = v.name;
          name = mkName n;
        in
        {
          name = "${name}-${system}";
          value = nixosSystem {
            inherit system;
            modules = [
              self.nixosModules.lonsdaleite
              ../hosts/${n}
            ];
          };
        }
      ) ../hosts;

  mkPkgs =
    system:
    mapDirs
      (
        n: _: nameValuePair (mkName n) ((pkgs system).callPackage ../packages/${n} { inherit system; })
      ) ../packages;

  mkApps = system: rec {
    test-vm = {
      type = "app";
      program = "${self.nixosConfigurations."test-${system}".config.system.build.vm}/bin/run-nixos-vm";
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
