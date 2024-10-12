{ lib, lonLib, config, ... }:
let
  inherit (lib) mkEnableOption mkOption mapAttrsToList filterAttrs;
  inherit (lib.types) enum nullOr;
in
{
  imports = [ ./fs ./hw ./net ./os ./sw ];

  options.lonsdaleite =
    let
      allUsers = mapAttrsToList (n: v: v.name)
        (filterAttrs (n: v: v.isNormalUser) config.users.users);
    in
    {
      enable = mkEnableOption "Enables lonsdaleite";
      trustedUser = mkOption {
        type = nullOr (enum allUsers);
        description =
          "The one and only trusted user. Or none, if you can't trust yourself either";
        default = null;
      };
      decapitated = mkEnableOption ''
        If the host will be running in "headless" mode, eg. a server. If you are expecting your gui to work, don't enable this option. If you are a tui-only gigachad then enjoy the extra security by enabling it.'';
    } // (lonLib.mkParanoiaOptionDef [
      "You still want your machine to be usable"
      "You like pretending to be schizo"
      "The feds are after you"
    ] 2);
}
