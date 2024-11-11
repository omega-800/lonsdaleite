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
      PrivateMounts = true;
      PrivateTmp = true;
      ProtectControlGroups = true;
      ProtectHome = true;
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
    # https://github.com/i-learned-eu/systemd-hardened/blob/main/dnsmasq/dnsmasq.service
    dnsmasq.serviceConfig = {
      User = "dnsmasq";
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
      SecureBits = "keep-caps";
      NoNewPrivileges = true;
      UMask = "0077";
      ProtectHome = true;
      RestrictNamespaces = true;
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectKernelTunables = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      LockPersonality = true;
      RestrictSUIDSGID = true;
      RemoveIPC = true;
      RestrictRealtime = true;
      SystemCallFilter = [ "@system-service" ];
      SystemCallArchitectures = "native";
      MemoryDenyWriteExecute = true;
      ProtectSystem = "full";
      ProtectHostname = true;
      ProcSubset = "pid";
      ProtectProc = "ptraceable";
      ReadWriteDirectories = [ "/run/dnsmasq" ];
    };
    # https://github.com/rusty-snake/kyst/blob/main/systemd/avahi-daemon.service.d%2Boverride.conf
    avahi-daemon.serviceConfig = {
      PrivateDevices = true;
      ProtectClock = true;
      CapabilityBoundingSet = [
        "CAP_DAC_OVERRIDE"
        "CAP_SETUID"
        "CAP_SETGID"
        "CAP_SYS_CHROOT"
      ];
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      SystemCallArchitectures = "native";
      MemoryDenyWriteExecute = true;
      RestrictNamespaces = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
      ProtectKernelTunables = true;
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];
      RestrictRealtime = true;
      ProtectSystem = "full";
      ProtectProc = "invisible";
      ProcSubset = "pid";
      ProtectHome = true;
      PrivateTmp = true;
      SystemCallFilter = [
        "@system-service"
        "chroot"
        "~@resources"
      ];
      InaccessiblePaths = [
        "-/boot"
        "-/mnt"
        "-/media"
        "-/run/media"
      ];
      PrivateIPC = true;
    };
  };
}
