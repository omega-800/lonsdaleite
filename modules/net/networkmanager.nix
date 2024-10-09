{ pkgs, config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.net.networkmanager;
  inherit (lib) mkIf mkMerge concatMapStrings mkOption;
  inherit (lib.types) listOf nonEmptyStr;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom;
  usr = config.lonsdaleite.trustedUser;
in {
  #TODO: implement
  options.lonsdaleite.net.networkmanager =
    (mkEnableFrom [ "net" ] "Hardens NetworkManager")
    // (mkParanoiaFrom [ "net" ] [ "" "" "" ]) // { };

  config = mkIf cfg.enable {
    networking.networkmanager = {
      ethernet.macAddress = "random";
      wifi = {
        macAddress = "random";
        scanRandMacAddress = true;
      };
      # Enable IPv6 privacy extensions in NetworkManager.
      # TODO: read up on this
      connectionConfig."ipv6.ip6-privacy" = 2;
    };
    users =
      mkIf (usr != null) { users.${usr}.extraGroups = [ "networkmanager" ]; };
  };
}
