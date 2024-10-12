{ lib, lonLib, config, ... }:
let
  inherit (lib) mkEnableOption mkOption mapAttrsToList filterAttrs;
  inherit (lib.types) enum nullOr;
in {
  imports = [ ./fs ./hw ./net ./os ./sw ];

  options.lonsdaleite = let
    allUsers = mapAttrsToList (n: v: v.name)
      (filterAttrs (n: v: v.isNormalUser) config.users.users);
  in {
    enable = mkEnableOption "Enables lonsdaleite";
    trustedUser = mkOption {
      type = nullOr (enum allUsers);
      description =
        "The one and only trusted user. Or none, if you can't trust yourself either";
      default = null;
    };
  } // (lonLib.mkParanoiaOptionDef [
    "You still want your machine to be usable"
    "You like pretending to be schizo"
    "The feds are after you"
  ] 2);
}
