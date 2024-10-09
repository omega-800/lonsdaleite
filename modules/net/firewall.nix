{ config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.net.firewall;
  inherit (lib) mkIf mkMerge concatMapStrings mkOption;
  inherit (lib.types) listOf nonEmptyStr;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom;
in {
  options.lonsdaleite.net.firewall = (mkEnableFrom [ "net" ] "Enables firewall")
    // (mkParanoiaFrom [ "net" ] [ "" "" "" ]) // { };
  config = mkIf cfg.enable {
    networking.firewall = {
      enable = true;
      allowPing = cfg.paranoia != 2;
      pingLimit = "--limit 1/minute --limit-burst 5";
      checkReversePath = "strict";
      rejectPackets = false;
      connectionTrackingModules = [ ];
      filterForward = false;

      # Keep dmesg/journalctl -k output readable by NOT logging
      # each refused connection on the open internet.
      logRefusedConnections = cfg.paranoia != 2;

      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };
}
