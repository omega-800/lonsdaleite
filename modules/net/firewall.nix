{ config
, lib
, lon-lib
, ...
}:
let
  cfg = config.lonsdaleite.net.firewall;
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
  # TODO: https://frrouting.org/
  options.lonsdaleite.net.firewall =
    (mkEnableFrom [ "net" ] "Enables firewall")
    // (mkParanoiaFrom [ "net" ] [
      ""
      ""
      ""
    ])
    // { };
  config = mkIf cfg.enable {
    networking.firewall = {
      enable = true;
      allowPing = cfg.paranoia != 2;
      pingLimit = "--limit 1/minute --limit-burst ${toString 5 - cfg.paranoia}";
      checkReversePath = if cfg.paranoia > 1 then "strict" else "loose";
      rejectPackets = false;
      filterForward = false;

      # Keep dmesg/journalctl -k output readable by NOT logging
      # each refused connection on the open internet.
      logRefusedConnections = cfg.paranoia > 1;
      # logRefusedPackets = cfg.paranoia == 2;
      logRefusedUnicastsOnly = true; # is default
      logReversePathDrops = cfg.paranoia > 1;
      autoLoadConntrackHelpers = false;
      connectionTrackingModules = [ ];

      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };
}
