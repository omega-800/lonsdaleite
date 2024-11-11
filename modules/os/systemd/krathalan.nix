{ config
, lib
, ...
}:
let
  cfg = config.lonsdaleite.os.systemd;
  inherit (lib) mkIf;
in
{
  # https://github.com/krathalan/systemd-sandboxing/tree/master
  systemd.services = mkIf cfg.enable {
    # https://github.com/krathalan/systemd-sandboxing/blob/master/bluetooth.service.d/hardening.conf
    bluetooth.serviceConfig = {
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_BLUETOOTH"
      ];
      IPAddressDeny = "any";
      ProtectSystem = "strict";
      ReadWritePaths = [
        "-/var/lib/bluetooth"
        "-/run/systemd/unit-root"
      ];
      PrivateTmp = true;
      ProtectProc = "ptraceable";
      ProcSubset = "pid";
      DevicePolicy = "closed";
      DeviceAllow = [
        "/dev/rfkill rw"
        "/dev/uinput rw"
      ];
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      NoNewPrivileges = true;
      ProtectHostname = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      RestrictNamespaces = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallFilter = [
        "@system-service"
        "~@resources"
        "@privileged"
      ];
      SystemCallArchitectures = "native";
    };

    # https://github.com/krathalan/systemd-sandboxing/blob/master/dovecot.service.d/hardening.conf
    dovecot.serviceConfig = {
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
      ];
      IPAccounting = true;
      ProtectSystem = "strict";
      ReadWritePaths = [
        "-/run/dovecot"
        "-/var/lib/dovecot"
        "-/var/spool/postfix"
      ];
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      CapabilityBoundingSet = [
        "CAP_DAC_READ_SEARCH"
        "CAP_DAC_OVERRIDE"
        "CAP_SYS_CHROOT"
        "CAP_AUDIT_WRITE"
        "CAP_KILL"
        "CAP_SETGID"
        "CAP_SETUID"
        "CAP_CHOWN"
        "CAP_NET_BIND_SERVICE"
        "CAP_SYS_RESOURCE"
      ];
      ProtectHostname = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      RestrictNamespaces = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallFilter = [
        "@mount"
        "@privileged"
        "@system-service"
        "~@resources"
      ];
      SystemCallArchitectures = "native";
    };

    # https://github.com/krathalan/systemd-sandboxing/blob/master/nginx.service.d/hardening.conf
    nginx.serviceConfig = {
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
      ];
      IPAccounting = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ReadWritePaths = [
        "-/run/nginx"
        "-/var/log/nginx"
        "-/var/lib/nginx-pacman-cache"
      ];
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectHostname = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      RestrictNamespaces = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      RemoveIPC = true;
      SystemCallFilter = [
        "@system-service"
        "~@resources"
        "@privileged"
      ];
      SystemCallArchitectures = "native";
    };

    # https://github.com/krathalan/systemd-sandboxing/blob/master/postfix.service.d/hardening.conf
    postfix.serviceConfig = {
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];
      IPAccounting = true;
      ProtectSystem = "strict";
      ReadWritePaths = [
        "-/var/spool/postfix"
        "-/var/lib/postfix"
        "-/run/opendkim"
        "-/run/postgrey"
      ];
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      CapabilityBoundingSet = [
        "CAP_DAC_READ_SEARCH"
        "CAP_DAC_OVERRIDE"
        "CAP_KILL"
        "CAP_SETUID"
        "CAP_SETGID"
        "CAP_NET_BIND_SERVICE"
      ];
      ProtectHostname = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      RestrictNamespaces = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      RemoveIPC = true;
      SystemCallFilter = [
        "@privileged"
        "@system-service"
        "~@resources"
      ];
      SystemCallArchitectures = "native";
    };

    # https://github.com/krathalan/systemd-sandboxing/blob/master/org.cups.cupsd.service.d/hardening.conf
    cups.serviceConfig = {
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
        "AF_UNIX"
      ];
      # TODO: 
      # IPAddressDeny="any";
      # IPAddressAllow=[ "localhost" "192.168.1.0/8" "172.16.1.0/8" "10.0.1.0/8" ];
      ProtectHome = true;
      ProtectSystem = "strict";
      ReadWritePaths = [
        "/etc/cups"
        "/etc/printcap"
        "/var/cache/cups"
        "/var/spool/cups"
      ];
      LogsDirectory = "cups";
      RuntimeDirectory = "cups";
      PrivateTmp = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      CapabilityBoundingSet = [
        "CAP_CHOWN"
        "CAP_AUDIT_WRITE"
        "CAP_DAC_OVERRIDE"
        "CAP_FSETID"
        "CAP_KILL"
        "CAP_NET_BIND_SERVICE"
        "CAP_SETGID"
        "CAP_SETUID"
      ];
      ProtectHostname = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      RestrictNamespaces = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallFilter = "@system-service";
      SystemCallArchitectures = "native";
    };

    # https://github.com/krathalan/systemd-sandboxing/blob/master/redis.service.d/hardening.conf
    redis.serviceConfig = {
      PrivateNetwork = false;
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
      ];
      IPAccounting = true;
      IPAddressAllow = "localhost";
      IPAddressDeny = "any";
      ProtectHome = true;
      ProtectProc = "ptraceable";
      ProtectSystem = "strict";
      ReadWritePaths = [ "/var/lib/redis" ];
      PrivateTmp = true;
      PrivateUsers = true;
      PrivateDevices = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      AmbientCapabilities = "";
      NoNewPrivileges = true;
      ProtectHostname = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      RestrictNamespaces = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      RemoveIPC = true;
      SystemCallFilter = [
        "@system-service"
        "~@resources"
        "@privileged"
      ];
      SystemCallArchitectures = "native";
    };
  };
}
