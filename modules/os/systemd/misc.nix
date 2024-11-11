{ config
, lib
, ...
}:
let
  cfg = config.lonsdaleite.os.systemd;
  inherit (lib) mkIf;
in
{
  systemd.services = mkIf cfg.enable {
    # https://lists.debian.org/debian-devel/2023/10/msg00055.html
    rsyslog.serviceConfig = {
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectHome = true;
      ProtectSystem = "full";
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectClock = true;
      SystemCallFilter = "@system-service";
      CapabilityBoundingSet = [
        "CAP_BLOCK_SUSPEND"
        "CAP_CHOWN"
        "CAP_LEASE"
        "CAP_NET_ADMIN"
        "CAP_NET_BIND_SERVICE"
        "CAP_SYS_ADMIN"
        "CAP_SYS_RESOURCE"
        "CAP_SYSLOG"
      ];
    };

    # https://github.com/NixOS/nixpkgs/pull/104944/files
    chrony.serviceConfig = {
      KeyringMode = "private";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateMounts = "yes";
      PrivateTmp = "yes";
      ProtectControlGroups = true;
      ProtectHome = "yes";
      ProtectHostname = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectSystem = "strict";
      ReadWritePaths = [
        "/var/run/chrony"
        "/var/lib/chrony"
      ];
      RemoveIPC = true;
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallFilter = "@system-service @clock";
      SystemCallArchitectures = "native";

      # even though in the default configuration chrony does not access the rtc clock,
      # it may be configured to so so either with the 'rtcfile' configuration option
      # or using the '-s' flag. so we make sure rtc devices can still be used by it.
      # at the same time there is no need for chrony to access any other device types.
      DeviceAllow = "char-rtc";
      DevicePolicy = "closed";
    };
  };
}
