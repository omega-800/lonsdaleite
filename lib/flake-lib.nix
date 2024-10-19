{ self, pkgs, ... }:
let
  inherit (pkgs) nixosTest;
  inherit (pkgs.lib) mapAttrs' removeSuffix nameValuePair filterAttrs hasPrefix;
in
{
  mkChecks = system: {
    "${system}" = mapAttrs'
      (n: v:
        let name = removeSuffix ".nix" n;
        in nameValuePair name (nixosTest ({
          inherit name;
          nodes.test = { ... }: {
            imports = [ self.nixosModules.lonsdaleite ../examples/test.nix ];
          };
        } // (import ../checks/${n}))))
      (builtins.readDir ../checks);
  };
  mkHosts = system:
    mapAttrs'
      (n: v:
        let name = removeSuffix ".nix" n;
        in nameValuePair name (self.inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ self.nixosModules.lonsdaleite ../examples/${n} ];
        }))
      (filterAttrs (n: v: !(hasPrefix "_" n)) (builtins.readDir ../examples));
}
