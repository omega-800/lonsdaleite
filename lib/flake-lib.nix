{ self, pkgs, ... }:
let
  inherit (pkgs) nixosTest callPackage;
  inherit (pkgs.lib)
    mapAttrs' removeSuffix nameValuePair filterAttrs hasPrefix hasSuffix;
  inherit (builtins) readDir;
in
rec {
  mapDirs = mapFn: dir:
    mapAttrs' (n: v: mapFn n v) (filterAttrs
      (n: v:
        (!hasPrefix "_" n) && ((v == "regular" && hasSuffix ".nix" n)
        || (v == "directory" && builtins.pathExists "${dir}/${n}/default.nix")))
      (readDir dir));

  mkName = filename:
    if hasSuffix ".nix" filename then
      removeSuffix ".nix" filename
    else
      filename;

  # https://nixos.org/manual/nixos/stable/index.html#sec-nixos-tests
  mkChecks = system: {
    "${system}" = mapDirs
      (n: v:
        let name = mkName n;
        in nameValuePair name (nixosTest ({
          inherit name;
          nodes.test = { ... }: {
            imports = [ self.nixosModules.lonsdaleite ../examples/test.nix ];
          };
        } // (import ../checks/${n})))) ../checks;
  };

  mkHosts = system:
    mapDirs
      (n: v:
        let name = mkName n;
        in nameValuePair name (self.inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ self.nixosModules.lonsdaleite ../examples/${n} ];
        })) ../examples;

  mkPkgs = system: {
    "${system}" = mapDirs
      (n: v:
        let name = mkName n;
        in nameValuePair name (callPackage ../packages/${n} { inherit system; }))
      ../packages;
  };

  mkModule = rec {
    lonsdaleite = { config, lib, ... }: {
      imports =
        [ ../modules self.inputs.impermanence.nixosModules.impermanence ];
      _module.args = {
        inherit self;
        lon-lib = import ./lon-lib.nix { inherit lib config; };
      };
    };
    default = lonsdaleite; # convention
  };
}
