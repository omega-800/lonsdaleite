{ config
, lib
, ...
}:
let
  cfg = config.lonsdaleite.os.systemd;
  inherit (lib) mkIf;
in
{
  # https://wiki.debian.org/ReleaseGoals/SystemdAnalyzeSecurity
  systemd.services = mkIf cfg.enable {
    ### NOT YET MERGED (i think) ###

    # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1032233
    wpa_supplicant.serviceConfig = {
      CapabilityBoundingSet = [
        "CAP_NET_ADMIN"
        "CAP_BLOCK_SUSPEND"
        "CAP_NET_RAW"
      ];
      RestrictNamespaces = true;
      SystemCallFilter = [
        "~@mount"
        "@cpu-emulation"
        "@debug"
        "@raw-io"
        "@reboot"
        "@resources"
        "@swap"
        "@module"
        "@obsolete"
      ];
      ProtectProc = "invisible";
      SystemCallArchitectures = "native";
      DeviceAllow = "/dev/rfkill";
      DevicePolicy = "closed";
      UMask = "0077";
      NoNewPrivileges = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      ProtectSystem = true;
      ProtectHome = true;
      PrivateTmp = true;
      MemoryDenyWriteExecute = true;
      ProtectHostname = true;
      LockPersonality = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
    };
    # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1032327
    auditd.serviceConfig = {
      CapabilityBoundingSet = [
        "CAP_AUDIT_CONTROL"
        "CAP_AUDIT_WRITE"
        "CAP_CHOWN"
        "CAP_FSETID"
        "CAP_NET_BIND_SERVICE"
        "CAP_SYS_NICE"
        "CAP_SYS_RESOURCE"
      ];
      ProtectProc = "invisible";
      SystemCallArchitectures = "native";
      DevicePolicy = "closed";
      UMask = "0077";
      NoNewPrivileges = true;
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      ProtectSystem = true;
      ProtectHome = true;
      PrivateTmp = true;
      ProtectHostname = true;
      LockPersonality = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallFilter = [
        "~@mount"
        "@cpu-emulation"
        "@debug"
        "@raw-io"
        "@reboot"
        "@swap"
        "@module"
        "@obsolete"
        "@clock"
      ];
      ProtectClock = true;
      RestrictNamespaces = true;
      ProtectKernelTunables = true;
      PrivateDevices = true;
      PrivateNetwork = true;
      RestrictAddressFamilies = "~AF_(INET|INET6)";
    };
    # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1040203
    udisks2.serviceConfig = {
      CapabilityBoundingSet = "CAP_SYS_ADMIN";
      SystemCallFilter = [
        "~@cpu-emulation"
        "@debug"
        "@raw-io"
        "@reboot"
        "@swap"
        "@obsolete"
        "@privileged"
      ];
      SystemCallArchitectures = "native";
      UMask = "0077";
      NoNewPrivileges = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      RestrictNamespaces = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
      ProtectHostname = true;
      ProtectKernelTunables = true;
      RestrictAddressFamilies = "AF_UNIX";
    };
    # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1032331
    dictd.serviceConfig = {
      CapabilityBoundingSet = [
        "CAP_SETUID"
        "CAP_SETGID"
        "CAP_KILL"
        "CAP_SYS_PTRACE"
      ];
      SystemCallFilter = [
        "~@mount"
        "@cpu-emulation"
        "@debug"
        "@raw-io"
        "@reboot"
        "@resources"
        "@swap"
        "@module"
        "@obsolete"
        "@clock"
      ];
      ProtectSystem = "strict";
      ProtectProc = "invisible";
      SystemCallArchitectures = "native";
      DevicePolicy = "closed";
      UMask = "0077";
      NoNewPrivileges = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      ProtectHome = true;
      PrivateTmp = true;
      MemoryDenyWriteExecute = true;
      ProtectHostname = true;
      LockPersonality = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      ProtectClock = true;
      RestrictNamespaces = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
    };
    # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1009964
    php-fpm.serviceConfig = {
      CapabilityBoundingSet = [
        "CAP_DAC_OVERRIDE"
        "CAP_CHOWN"
        "CAP_SETGID"
        "CAP_SETUID"
      ];
      LockPersonality = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateTmp = true;
      ProcSubset = "pid";
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "full";
      RemoveIPC = true;
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = "@system-service";
    };
    # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1020328
    /*
      logcheck.serviceConfig = {
        CapabilityBoundingSet = "";
        RestrictNamespaces = true;
        DevicePolicy = "strict";
        IPAddressDeny = "any";
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = "read-only";
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "noaccess";
        ProtectSystem = "strict";
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "@resources"
        ];
        RestrictRealtime = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RemoveIPC = true;
        UMask = "0077";
        ProtectHostname = true;
        ProcSubset = "pid";
        StateDirectory = "%p";
        PrivateNetwork = false;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        IPAddressAllow = "localhost";
      };
    */
    logcheck.serviceConfig = {
      ProtectHome = "read-only";
      PrivateTmp = true;
      PrivateMounts = true;
      DevicePolicy = "strict";
      DeviceAllow = [
        "/dev/stdout w"
        "/dev/stdin r"
        "/dev/stderr w"
        "/dev/null rw"
      ];
      ProtectProc = "invisible";
      ProcSubset = "pid";
      RemoveIPC = true;
      ProtectControlGroups = true;
      AmbientCapabilities = "";
      CapabilityBoundingSet = [
        "CAP_SETGID"
        "CAP_SETUID"
        "CAP_FSETID"
        "CAP_CHOWN"
        "CAP_DAC_OVERRIDE"
        "CAP_FOWNER"
      ];
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
      ];
    };
    # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1077004
    xinetd.serviceConfig = {
      RestrictSUIDSGID = true;
      PrivateTmp = true;
      UMask = "0077";
      ProtectControlGroups = true;
      ProtectClock = true;
      ProtectHostname = true;
      ProtectKernelTunables = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      SystemCallArchitectures = "native";
      MemoryDenyWriteExecute = true;
      RestrictNamespaces = true;
      LockPersonality = true;
      RestrictRealtime = true;
      # The following settings are quite useful but have a higher probability of breaking things.
      CapabilityBoundingSet = [
        "CAP_DAC_OVERRIDE"
        "CAP_DAC_READ_SEARCH"
        "CAP_SETGID"
        "CAP_SETUID"
        "CAP_NET_BIND_SERVICE"
        "CAP_SYS_RESOURCE"
      ];
      SystemCallFilter = [
        "~@mount"
        "@cpu-emulation"
        "@debug"
        "@raw-io"
        "@reboot"
        "@swap"
        "@module"
        "@obsolete"
        "@clock"
      ];
    };

    ### UPSTREAM ###

    # https://salsa.debian.org/etbe/etbemon/-/blob/master/systemd/mon.service?ref_type=heads
    mon.serviceConfig = {
      CapabilityBoundingSet = [
        "CAP_DAC_OVERRIDE"
        "CAP_DAC_READ_SEARCH"
        "CAP_SETGID"
        "CAP_SETUID"
        "CAP_SYS_ADMIN"
        "CAP_SYS_CHROOT"
        "CAP_SYS_PTRACE"
        "CAP_SYS_RAWIO"
        "CAP_NET_BIND_SERVICE"
        "CAP_NET_BROADCAST"
        "CAP_NET_RAW"
        "CAP_SYS_ADMIN"
        "CAP_SYS_RESOURCE"
      ];
      SystemCallFilter = [
        "~@mount"
        "@cpu-emulation"
        "@debug"
        "@raw-io"
        "@reboot"
        "@swap"
        "@module"
        "@obsolete"
        "@clock"
      ];
      ProtectClock = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      SystemCallArchitectures = "native";
      MemoryDenyWriteExecute = true;
      RestrictNamespaces = true;
      RestrictSUIDSGID = true;
      ProtectHostname = true;
      LockPersonality = true;
      ProtectKernelTunables = true;
      RestrictRealtime = true;
      ProtectHome = true;
      PrivateTmp = true;
      UMask = "0077";
      ProtectControlGroups = true;
    };

    # https://sources.debian.org/src/memlockd/1.3.1-2/debian/memlockd.service/
    memlockd.serviceConfig = {
      CapabilityBoundingSet = [
        "CAP_DAC_OVERRIDE"
        "CAP_SETUID"
        "CAP_SETGID"
        "CAP_SYS_PTRACE"
        "CAP_IPC_LOCK"
      ];
      RestrictNamespaces = true;
      SystemCallFilter = [
        "~@mount"
        "@cpu-emulation"
        "@debug"
        "@raw-io"
        "@reboot"
        "@resources"
        "@swap"
        "@module"
        "@obsolete"
        "@clock"
      ];
      ProtectSystem = "strict";
      ProtectProc = "invisible";
      SystemCallArchitectures = "native";
      UMask = "0077";
      NoNewPrivileges = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      ProtectHome = true;
      PrivateTmp = true;
      MemoryDenyWriteExecute = true;
      ProtectHostname = true;
      LockPersonality = true;
      RestrictRealtime = true;
      DevicePolicy = "closed";
      ProtectClock = true;
      RestrictSUIDSGID = true;
      ProtectKernelTunables = true;
      PrivateDevices = true;
      RestrictAddressFamilies = [
        "~AF_INET"
        "AF_INET6"
        "AF_PACKET"
        "AF_NETLINK"
      ];
      PrivateNetwork = true;
    };
  };
}
