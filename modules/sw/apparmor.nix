{
  config,
  lib,
  lon-lib,
  pkgs,
  ...
}:
let
  cfg = config.lonsdaleite.sw.apparmor;
  inherit (lib) mkIf concatMapAttrs;
  inherit (lon-lib)
    mkEnableFrom
    mkParanoiaFrom
    mkPersistDirs
    mkEtcPersist
    ;
in
{
  # TODO: implement apparmor in nixos https://github.com/omega-800/apparmor-d
  options.lonsdaleite.sw.apparmor =
    (mkEnableFrom [ "sw" ] "Enables apparmor")
    // (mkParanoiaFrom
      [ "sw" ]
      [
        ""
        ""
        ""
      ]
    )
    // { };

  config = mkIf cfg.enable {
    environment = mkPersistDirs [
      "/etc/apparmor"
    ]
    #   // (mkEtcPersist "apparmor/parser.conf" ''
    #   Optimize=compress-fast
    # '')
    ;
    security = {
      apparmor = {
        enable = true;
        killUnconfinedConfinables = true;
      };
      # apparmor-d = {
      #   enable = true;
      #   statusAll = "complain";
      # };
    };
  };
}
