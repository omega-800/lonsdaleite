{ config
, lib
, lon-lib
, ...
}:
let
  cfg = config.lonsdaleite.net.networkmanager;
  inherit (lib) mkIf mkMerge mkDefault;
  inherit (lib.types) listOf nonEmptyStr;
  inherit (lon-lib)
    mkEnableFrom
    mkParanoiaFrom
    mkPersistFiles
    mkPersistDirs
    ;
  usr = config.lonsdaleite.trustedUser;
in
{
  options.lonsdaleite.net.networkmanager =
    (mkEnableFrom [ "net" ] "Hardens NetworkManager")
    // (mkParanoiaFrom [ "net" ] [
      ""
      ""
      ""
    ])
    // { };

  config = mkIf cfg.enable {
    users = mkIf (usr != null && config.networking.networkmanager.enable) {
      users.${usr}.extraGroups = [ "networkmanager" ];
    };

    networking.networkmanager = {
      # TODO: add option to enable/disable networkmanager
      enable = mkDefault (!config.lonsdaleite.decapitated);
      ethernet.macAddress = "random";
      wifi = {
        macAddress = "random";
        scanRandMacAddress = true;
      };
      # Enable IPv6 privacy extensions in NetworkManager.
      connectionConfig."ipv6.ip6-privacy" = 2;
    };

    systemd.services.NetworkManager-wait-online.enable = false;

    environment = mkMerge [
      (mkPersistDirs [ "/etc/NetworkManager/system-connections" ])
      (mkPersistFiles [
        "/var/lib/NetworkManager/seen-bssids"
        "/var/lib/NetworkManager/timestamps"
        "/var/lib/NetworkManager/secret_key"
      ])
    ];
  };
}
