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

  forEachSystem = f: genAttrs systems (s: f (importPkgs s));
  forEachSystem' = f: listToAttrs (concatMap (s: f (importPkgs s)) systems);

  importPkgs =
    system:
    import nixpkgs {
      inherit system;
      config = { };
      overlays = [ ];
    };

  filterDirFn =
    dir: n: v:
    (!hasPrefix "_" n)
    && (
      (v == "regular" && hasSuffix ".nix" n) || (v == "directory" && pathExists "${dir}/${n}/default.nix")
    );

  mapDirs = mapFn: dir: mapAttrs' mapFn (filterAttrs (filterDirFn dir) (readDir dir));
  mapDirs' = mapFn: dir: map mapFn (attrsToList (filterAttrs (filterDirFn dir) (readDir dir)));

  mkName = filename: if hasSuffix ".nix" filename then removeSuffix ".nix" filename else filename;

  mkFormatter = pkgs: pkgs.nixfmt-rfc-style;

  mkChecks =
    pkgs:
    {
      pre-commit-check = self.inputs.pre-commit-hooks.lib.${pkgs.system}.run {
        src = ./.;
        hooks = {
          nixpkgs-fmt.enable = false;
          nixfmt-rfc-style.enable = true;
        };
      };
    }
    // (mapDirs (
      n: _:
      let
        name = mkName n;
      in
      nameValuePair name (
        pkgs.nixosTest (
          {
            inherit name;
            nodes.test = _: {
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
    pkgs:
    mapDirs' (
      v:
      let
        n = v.name;
        name = mkName n;
      in
      {
        name = "${name}-${pkgs.system}";
        value = nixosSystem {
          inherit (pkgs) system;
          modules = [
            self.nixosModules.lonsdaleite
            ../hosts/${n}
          ];
        };
      }
    ) ../hosts;

  mkPkgs =
    pkgs:
    mapDirs (
      n: _: nameValuePair (mkName n) (pkgs.callPackage ../packages/${n} { inherit (pkgs) system; })
    ) ../packages;

  mkApps =
    pkgs:
    let
      test-vm = {
        type = "app";
        program = "${pkgs.writeShellScript "run-test-vm" ''
          QEMU_KERNEL_PARAMS=console=ttyS0 ${
            self.nixosConfigurations."test-${pkgs.system}".config.system.build.vm
          }/bin/run-nixos-vm -nographic 
        ''}";
      };
    in
    {
      inherit test-vm;
      default = test-vm;
    };

  mkModules =
    let
      lonsdaleite =
        { config, lib, ... }:
        {
          imports = [
            ../modules
            self.inputs.impermanence.nixosModules.impermanence
          ];
          _module.args.lon-lib = import ./lon-lib.nix { inherit lib config; };
        };
    in
    {
      inherit lonsdaleite;
      default = lonsdaleite;
    };

  mkGithubActions = self.inputs.nix-github-actions.lib.mkGithubMatrix {
    checks = {
      # TODO: support for more architectures
      x86_64-linux = self.checks.x86_64-linux // self.packages.x86_64-linux;
    };
  };

  mkDevShell =
    pkgs:
    let
      lonsdaleite = pkgs.mkShell {
        inherit (self.checks.${pkgs.system}.pre-commit-check) shellHook;
        buildInputs = self.checks.${pkgs.system}.pre-commit-check.enabledPackages;
        packages = with pkgs; [
          nixd
          nixfmt-rfc-style
        ];
      };
    in
    {
      inherit lonsdaleite;
      default = lonsdaleite;
    };
}
