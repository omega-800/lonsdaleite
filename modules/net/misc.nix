{ pkgs, config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.net.misc;
  inherit (lib) mkIf mkMerge concatMapStrings mkOption mkDefault;
  inherit (lib.types) listOf nonEmptyStr;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom mkPersistFiles mkPersistDirs;
  usr = config.lonsdaleite.trustedUser;
in
{
  #TODO: implement
  options.lonsdaleite.net.misc =
    (mkEnableFrom [ "net" ] "Hardens random network related things")
    // (mkParanoiaFrom [ "net" ] [ "" "" "" ]) // { };

  config = mkIf cfg.enable {
    networking = {
      wireless.enable = false;
      enableIPv6 = cfg.paranoia != 2;
      # Use networkd instead of the pile of shell scripts
      useNetworkd = true;
      dhcpcd.enable = false;
      useDHCP = false;
      nameservers = [
        # DNSWatch
        "84.200.69.80"
        # Quad9
        "208.67.222.222"
        # Google
        "8.8.8.8"
        # Cloudflare
        "1.1.1.1"
      ];
      networkmanager = {
        # TODO: add option to enable networkmanager
        enable = mkDefault false;
        ethernet.macAddress = "random";
        wifi = {
          macAddress = "random";
          scanRandMacAddress = true;
        };
        # Enable IPv6 privacy extensions in NetworkManager.
        connectionConfig."ipv6.ip6-privacy" = 2;
      };
    };

    services.resolved.dnssec = "true";

    users = mkIf
      (
        # usr != null
        false
      )
      { users.${usr}.extraGroups = [ "networkmanager" ]; };

    # The notion of "online" is a broken concept
    # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
    systemd = {
      services = {
        NetworkManager-wait-online.enable = false;
        # Do not take down the network for too long when upgrading,
        # This also prevents failures of services that are restarted instead of stopped.
        # It will use `systemctl restart` rather than stopping it with `systemctl stop`
        # followed by a delayed `systemctl start`.
        systemd-networkd.stopIfChanged = false;
        # Services that are only restarted might be not able to resolve when resolved is stopped before
        systemd-resolved.stopIfChanged = false;
      };
      network = {
        wait-online.enable = false;
        # Enable IPv6 privacy extensions for systemd-networkd.
        config.networkConfig.IPv6PrivacyExtensions = "kernel";
      };
    };

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
