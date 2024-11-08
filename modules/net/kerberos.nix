{ config
, lib
, lon-lib
, ...
}:
let
  cfg = config.lonsdaleite.net.kerberos;
  inherit (lib)
    mkIf
    mkMerge
    concatMapStrings
    mkOption
    ;
  inherit (lib.types) listOf nonEmptyStr;
  inherit (lon-lib) mkEnableFrom mkParanoiaFrom;
in
{
  options.lonsdaleite.net.kerberos =
    (mkEnableFrom [ "net" ] "hardens ssh client")
    // (mkParanoiaFrom [ "net" ] [
      ""
      ""
      "enforces secure algorithms"
    ])
    // { };

  config = mkIf cfg.enable {
    #TODO: research
    security.krb5 = { };
  };
}
