{ config
, lon-lib
, lib
, ...
}:
let
  cfg = config.lonsdaleite.os.systemd;
  inherit (lon-lib) mkLowDefault;
  inherit (lib) mkIf;
in
{
  ### HARDENED PROFILES IN FEDORA UPSTREAM (most of em) ###
  # sources: 
  # https://discussion.fedoraproject.org/t/f40-change-proposal-systemd-security-hardening-system-wide/96423/20
  # https://discussion.fedoraproject.org/t/f40-change-proposal-systemd-security-hardening-system-wide/96423/20
  # TODO: check with nixos profiles for similarities / differences
  # upstream as soon as tested?
  systemd.services = mkIf cfg.enable {
    # https://src.fedoraproject.org/rpms/httpd/c/dee54cd734ac9fb909a122b141005210c218dbfd?branch=rawhide
    httpd.serviceConfig = {
      DevicePolicy = mkLowDefault "closed";
      KeyringMode = mkLowDefault "private";
      LockPersonality = mkLowDefault true;
      MemoryDenyWriteExecute = mkLowDefault true;
      OOMPolicy = mkLowDefault "continue";
      PrivateDevices = mkLowDefault true;
      PrivateTmp = mkLowDefault true;
      ProtectClock = mkLowDefault true;
      ProtectControlGroups = mkLowDefault true;
      ProtectHome = mkLowDefault "read-only";
      ProtectHostname = mkLowDefault true;
      ProtectKernelLogs = mkLowDefault true;
      ProtectKernelModules = mkLowDefault true;
      ProtectKernelTunables = mkLowDefault true;
      ProtectSystem = mkLowDefault true;
      RestrictNamespaces = mkLowDefault true;
      RestrictRealtime = mkLowDefault true;
      RestrictSUIDSGID = mkLowDefault true;
      SystemCallArchitectures = mkLowDefault "native";
    };
    "httpd@".serviceConfig = {
      DevicePolicy = mkLowDefault "closed";
      KeyringMode = mkLowDefault "private";
      LockPersonality = mkLowDefault true;
      MemoryDenyWriteExecute = mkLowDefault true;
      OOMPolicy = mkLowDefault "continue";
      PrivateDevices = mkLowDefault true;
      PrivateTmp = mkLowDefault true;
      ProtectClock = mkLowDefault true;
      ProtectControlGroups = mkLowDefault true;
      ProtectHome = mkLowDefault "read-only";
      ProtectHostname = mkLowDefault true;
      ProtectKernelLogs = mkLowDefault true;
      ProtectKernelModules = mkLowDefault true;
      ProtectKernelTunables = mkLowDefault true;
      ProtectSystem = mkLowDefault true;
      RestrictNamespaces = mkLowDefault true;
      RestrictRealtime = mkLowDefault true;
      RestrictSUIDSGID = mkLowDefault true;
      SystemCallArchitectures = mkLowDefault "native";
    };
    # https://src.fedoraproject.org/rpms/abrt/pull-request/32#request_diff
    abrt.serviceConfig = {
      DevicePolicy = mkLowDefault "closed";
      KeyringMode = mkLowDefault "private";
      LockPersonality = mkLowDefault true;
      MemoryDenyWriteExecute = mkLowDefault true;
      NoNewPrivileges = mkLowDefault true;
      PrivateDevices = mkLowDefault true;
      PrivateTmp = mkLowDefault true;
      ProtectClock = mkLowDefault true;
      ProtectControlGroups = mkLowDefault true;
      ProtectHome = mkLowDefault "read-only";
      ProtectHostname = mkLowDefault true;
      ProtectKernelLogs = mkLowDefault true;
      ProtectKernelModules = mkLowDefault true;
      ProtectKernelTunables = mkLowDefault true;
      ProtectProc = mkLowDefault "invisible";
      ProtectSystem = mkLowDefault "full";
      RestrictNamespaces = mkLowDefault true;
      RestrictRealtime = mkLowDefault true;
      RestrictSUIDSGID = mkLowDefault true;
      SystemCallArchitectures = mkLowDefault "native";
    };
    # https://github.com/fwupd/fwupd/pull/6860/files
    fwupd.serviceConfig = {
      KeyringMode = mkLowDefault "private";
      LockPersonality = mkLowDefault true;
      MemoryDenyWriteExecute = mkLowDefault true;
      NoNewPrivileges = mkLowDefault false;
      PrivateDevices = mkLowDefault false;
      PrivateTmp = mkLowDefault true;
      ProtectClock = mkLowDefault true;
      ProtectControlGroups = mkLowDefault true;
      ProtectHome = mkLowDefault true;
      ProtectHostname = mkLowDefault true;
      ProtectKernelLogs = mkLowDefault true;
      ProtectKernelModules = mkLowDefault true;
      ProtectKernelTunables = mkLowDefault true;
      ProtectProc = mkLowDefault "invisible";
      ProtectSystem = mkLowDefault "full";
      RestrictNamespaces = mkLowDefault true;
      RestrictRealtime = mkLowDefault true;
      RestrictSUIDSGID = mkLowDefault true;
      SystemCallArchitectures = mkLowDefault "native";
      SystemCallFilter = mkLowDefault "~@mount";
    };
    # https://gitlab.freedesktop.org/realmd/realmd/-/merge_requests/42
    realmd.serviceConfig = {
      DevicePolicy = mkLowDefault "closed";
      KeyringMode = mkLowDefault "private";
      LockPersonality = mkLowDefault true;
      MemoryDenyWriteExecute = mkLowDefault true;
      NoNewPrivileges = mkLowDefault true;
      PrivateDevices = mkLowDefault true;
      ProtectClock = mkLowDefault true;
      ProtectControlGroups = mkLowDefault true;
      ProtectHome = mkLowDefault true;
      ProtectHostname = mkLowDefault true;
      ProtectKernelLogs = mkLowDefault true;
      ProtectKernelModules = mkLowDefault true;
      ProtectKernelTunables = mkLowDefault true;
      ProtectProc = mkLowDefault "invisible";
      ProtectSystem = mkLowDefault "no";
      RestrictRealtime = mkLowDefault true;
      RestrictSUIDSGID = mkLowDefault true;
      SystemCallArchitectures = mkLowDefault "native";
    };
    # https://github.com/firewalld/firewalld/pull/1313
    firewalld.serviceConfig = {
      DevicePolicy = mkLowDefault "closed";
      KeyringMode = mkLowDefault "private";
      LockPersonality = mkLowDefault true;
      MemoryDenyWriteExecute = mkLowDefault true;
      NoNewPrivileges = mkLowDefault true;
      PrivateDevices = mkLowDefault true;
      ProtectClock = mkLowDefault true;
      ProtectControlGroups = mkLowDefault true;
      ProtectHome = mkLowDefault true;
      ProtectHostname = mkLowDefault true;
      ProtectKernelLogs = mkLowDefault true;
      ProtectKernelModules = mkLowDefault false;
      ProtectKernelTunables = mkLowDefault false;
      ProtectSystem = mkLowDefault true;
      RestrictRealtime = mkLowDefault true;
      RestrictSUIDSGID = mkLowDefault true;
      SystemCallArchitectures = mkLowDefault "native";
    };
    # https://github.com/bus1/dbus-broker/pull/345
    dbus-broker.serviceConfig = {
      LockPersonality = mkLowDefault true;
      MemoryDenyWriteExecute = mkLowDefault true;
      NoNewPrivileges = mkLowDefault true;
      PrivateDevices = mkLowDefault true;
      PrivateTmp = mkLowDefault true;
      ProtectClock = mkLowDefault true;
      ProtectControlGroups = mkLowDefault true;
      ProtectHome = mkLowDefault true;
      ProtectHostname = mkLowDefault true;
      ProtectKernelLogs = mkLowDefault true;
      ProtectKernelModules = mkLowDefault true;
      ProtectKernelTunables = mkLowDefault true;
      ProtectSystem = mkLowDefault "full";
      RestrictNamespaces = mkLowDefault true;
      RestrictRealtime = mkLowDefault true;
      RestrictSUIDSGID = mkLowDefault true;
      SystemCallArchitectures = mkLowDefault "native";
    };
    # https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/merge_requests/1879
    NetworkManager.serviceConfig = {
      RestrictNamespaces = mkLowDefault true;
      # ProtectHome = mkLowDefault true;
      UMask = mkLowDefault "0077";
      DevicePolicy = mkLowDefault "closed";
      KeyringMode = mkLowDefault "private";
      LockPersonality = mkLowDefault true;
      MemoryDenyWriteExecute = mkLowDefault true;
      NoNewPrivileges = mkLowDefault false;
      PrivateDevices = mkLowDefault false;
      PrivateTmp = mkLowDefault true;
      ProtectClock = mkLowDefault true;
      ProtectControlGroups = mkLowDefault true;
      ProtectHome = mkLowDefault "read-only";
      ProtectHostname = mkLowDefault true;
      ProtectKernelLogs = mkLowDefault true;
      ProtectKernelModules = mkLowDefault true;
      ProtectKernelTunables = mkLowDefault false;
      ProtectProc = mkLowDefault "invisible";
      ProtectSystem = mkLowDefault true;
      ProcSubset = mkLowDefault "pid";
      RestrictRealtime = mkLowDefault true;
      RestrictSUIDSGID = mkLowDefault true;
      SystemCallArchitectures = mkLowDefault "native";
    };
    # https://gitlab.freedesktop.org/polkit/polkit/-/blob/master/data/polkit.service.in?ref_type=heads
    polkit.serviceConfig = {
      LimitMEMLOCK = mkLowDefault 0;
      LockPersonality = mkLowDefault true;
      MemoryDenyWriteExecute = mkLowDefault true;
      NoNewPrivileges = mkLowDefault true;
      PrivateDevices = mkLowDefault true;
      PrivateNetwork = mkLowDefault true;
      PrivateTmp = mkLowDefault true;
      ProtectControlGroups = mkLowDefault true;
      ProtectHome = mkLowDefault true;
      ProtectKernelModules = mkLowDefault true;
      ProtectKernelLogs = mkLowDefault true;
      ProtectKernelTunables = mkLowDefault true;
      ProtectSystem = mkLowDefault "strict";
      ProtectClock = mkLowDefault true;
      ProtectHostname = mkLowDefault true;
      RemoveIPC = mkLowDefault true;
      RestrictAddressFamilies = mkLowDefault "AF_UNIX";
      RestrictNamespaces = mkLowDefault true;
      RestrictRealtime = mkLowDefault true;
      RestrictSUIDSGID = mkLowDefault true;
      SystemCallArchitectures = mkLowDefault "native";
      SystemCallFilter = mkLowDefault "@system-service";
      UMask = mkLowDefault "0077";
    };
    # https://github.com/PackageKit/PackageKit/pull/719
    packagekit.serviceConfig = {
      KeyringMode = mkLowDefault "private";
      LockPersonality = mkLowDefault true;
      MemoryDenyWriteExecute = mkLowDefault true;
      NoNewPrivileges = mkLowDefault false;
      PrivateDevices = mkLowDefault false;
      PrivateTmp = mkLowDefault true;
      ProtectClock = mkLowDefault true;
      ProtectControlGroups = mkLowDefault true;
      ProtectHome = mkLowDefault true;
      ProtectHostname = mkLowDefault true;
      ProtectKernelLogs = mkLowDefault false;
      ProtectKernelModules = mkLowDefault false;
      ProtectKernelTunables = mkLowDefault false;
      ProtectSystem = mkLowDefault false;
      RemoveIPC = mkLowDefault false;
      RestrictNamespaces = mkLowDefault true;
      RestrictRealtime = mkLowDefault true;
      RestrictSUIDSGID = mkLowDefault true;
      SystemCallArchitectures = mkLowDefault "native";
    };
    # https://github.com/hughsie/colord/blob/main/data/colord.service.in
    colord.serviceConfig = {
      PrivateTmp = mkLowDefault true;
      ProtectSystem = mkLowDefault "strict";
      ProtectHome = mkLowDefault true;
      ProtectHostname = mkLowDefault true;
      ProtectKernelTunables = mkLowDefault true;
      ProtectKernelModules = mkLowDefault true;
      ProtectKernelLogs = mkLowDefault true;
      ProtectControlGroups = mkLowDefault true;
      RestrictRealtime = mkLowDefault true;
      ConfigurationDirectory = mkLowDefault "colord";
      StateDirectory = mkLowDefault "colord";
      CacheDirectory = mkLowDefault "colord";
      CapabilityBoundingSet = mkLowDefault [
        "~CAP_SETUID"
        "CAP_SETGID"
        "CAP_SETPCAP"
        "CAP_SYS_ADMIN"
        "CAP_SYS_PTRACE"
        "CAP_CHOWN"
        "CAP_FSETID"
        "CAP_SETFCAP"
        "CAP_DAC_OVERRIDE"
        "CAP_DAC_READ_SEARCH"
        "CAP_FOWNER"
        "CAP_IPC_OWNER"
        "CAP_NET_ADMIN"
        "CAP_SYS_RAWIO"
        "CAP_SYS_TIME"
        "CAP_AUDIT_CONTROL"
        "CAP_AUDIT_READ"
        "CAP_AUDIT_WRITE"
        "CAP_KILL"
        "CAP_MKNOD"
        "CAP_NET_BIND_SERVICE"
        "CAP_NET_BROADCAST"
        "CAP_NET_RAW"
        "CAP_SYS_NICE"
        "CAP_SYS_RESOURCE"
        "CAP_MAC_ADMIN"
        "CAP_MAC_OVERRIDE"
        "CAP_SYS_BOOT"
        "CAP_LINUX_IMMUTABLE"
        "CAP_IPC_LOCK"
        "CAP_SYS_CHROOT"
        "CAP_BLOCK_SUSPEND"
        "CAP_LEASE"
        "CAP_SYS_PACCT"
        "CAP_SYS_TTY_CONFIG"
        "CAP_WAKE_ALARM"
      ];
      NoNewPrivileges = mkLowDefault true;
      PrivateUsers = mkLowDefault true;
      ProtectProc = mkLowDefault "invisible";
      ProcSubset = mkLowDefault "pid";
      RestrictSUIDSGID = mkLowDefault true;
      SystemCallArchitectures = mkLowDefault "native";
      RestrictNamespaces = mkLowDefault [
        "~cgroup"
        "user"
        "pid"
        "net"
        "uts"
        "mnt"
        "ipc"
      ];
      LockPersonality = mkLowDefault true;
      MemoryDenyWriteExecute = mkLowDefault true;
      RemoveIPC = mkLowDefault true;
    };
    # https://gitlab.freedesktop.org/libfprint/fprintd/-/blob/master/data/fprintd.service.in?ref_type=heads
    fprintd.serviceConfig = {
      ProtectSystem = mkLowDefault "strict";
      ProtectKernelTunables = mkLowDefault true;
      ProtectKernelLogs = mkLowDefault true;
      ProtectControlGroups = mkLowDefault true;
      StateDirectory = mkLowDefault "fprint";
      StateDirectoryMode = mkLowDefault 700;
      ProtectHome = mkLowDefault true;
      PrivateTmp = mkLowDefault true;
      SystemCallFilter = mkLowDefault "@system-service";
      RestrictAddressFamilies = mkLowDefault [
        "AF_UNIX"
        "AF_LOCAL"
        "AF_NETLINK"
      ];
      MemoryDenyWriteExecute = mkLowDefault true;
      ProtectKernelModules = mkLowDefault true;
      RestrictRealtime = mkLowDefault true;
      NoNewPrivileges = mkLowDefault true;
      ProtectClock = mkLowDefault true;
      DeviceAllow = mkLowDefault [
        "char-usb_device rw"
        "char-spi rw"
        "char-hidraw rw"
        "/dev/cros_fp rw"
      ];
      ReadWritePaths = mkLowDefault "/sys/devices";
    };
    # https://gitlab.gnome.org/GNOME/gdm/-/merge_requests/245
    gdm.serviceConfig = {
      LockPersonality = mkLowDefault true;
      MemoryDenyWriteExecute = mkLowDefault true;
      NoNewPrivileges = mkLowDefault false;
      PrivateDevices = mkLowDefault false;
      PrivateTmp = mkLowDefault true;
      ProtectClock = mkLowDefault true;
      ProtectControlGroups = mkLowDefault true;
      ProtectHome = mkLowDefault "read-only";
      ProtectHostname = mkLowDefault true;
      ProtectKernelLogs = mkLowDefault true;
      ProtectKernelModules = mkLowDefault true;
      ProtectKernelTunables = mkLowDefault true;
      ProtectSystem = mkLowDefault false;
      RestrictNamespaces = mkLowDefault true;
      RestrictRealtime = mkLowDefault true;
      RestrictSUIDSGID = mkLowDefault true;
      SystemCallArchitectures = mkLowDefault "native";
    };
    # https://src.fedoraproject.org/rpms/open-vm-tools/pull-request/9
    vgauthd.serviceConfig = {
      DevicePolicy = mkLowDefault "closed";
      KeyringMode = mkLowDefault "private";
      LockPersonality = mkLowDefault true;
      MemoryDenyWriteExecute = mkLowDefault true;
      NoNewPrivileges = mkLowDefault true;
      PrivateDevices = mkLowDefault true;
      PrivateTmp = mkLowDefault true;
      ProtectClock = mkLowDefault true;
      ProtectControlGroups = mkLowDefault true;
      ProtectHome = mkLowDefault true;
      ProtectHostname = mkLowDefault true;
      ProtectKernelLogs = mkLowDefault true;
      ProtectKernelModules = mkLowDefault true;
      ProtectKernelTunables = mkLowDefault true;
      ProtectProc = mkLowDefault "invisible";
      ProtectSystem = mkLowDefault true;
      ProcSubset = mkLowDefault "pid";
      RestrictNamespaces = mkLowDefault true;
      RestrictRealtime = mkLowDefault true;
      RestrictSUIDSGID = mkLowDefault true;
      SystemCallArchitectures = mkLowDefault "native";
    };
    vmtools.serviceConfig = {
      DevicePolicy = mkLowDefault "closed";
      KeyringMode = mkLowDefault "private";
      LockPersonality = mkLowDefault true;
      MemoryDenyWriteExecute = mkLowDefault true;
      NoNewPrivileges = mkLowDefault true;
      PrivateDevices = mkLowDefault false;
      PrivateTmp = mkLowDefault true;
      ProtectClock = mkLowDefault true;
      ProtectControlGroups = mkLowDefault true;
      ProtectHome = mkLowDefault true;
      ProtectHostname = mkLowDefault true;
      ProtectKernelLogs = mkLowDefault true;
      ProtectKernelModules = mkLowDefault false;
      ProtectKernelTunables = mkLowDefault true;
      ProtectProc = mkLowDefault "invisible";
      ProtectSystem = mkLowDefault true;
      ProcSubset = mkLowDefault "pid";
      RestrictNamespaces = mkLowDefault true;
      RestrictRealtime = mkLowDefault true;
      RestrictSUIDSGID = mkLowDefault true;
      SystemCallArchitectures = mkLowDefault "native";
    };
    # https://src.fedoraproject.org/rpms/openssh/pull-request/69
    sshd.serviceConfig = {
      DevicePolicy = mkLowDefault "closed";
      KeyringMode = mkLowDefault "private";
      LockPersonality = mkLowDefault true;
      MemoryDenyWriteExecute = mkLowDefault true;
      NoNewPrivileges = mkLowDefault false;
      PrivateDevices = mkLowDefault true;
      PrivateTmp = mkLowDefault false;
      ProtectClock = mkLowDefault true;
      ProtectControlGroups = mkLowDefault true;
      ProtectHome = mkLowDefault false;
      ProtectHostname = mkLowDefault true;
      ProtectKernelLogs = mkLowDefault true;
      ProtectKernelModules = mkLowDefault true;
      ProtectKernelTunables = mkLowDefault true;
      ProtectProc = mkLowDefault "invisible";
      ProtectSystem = mkLowDefault true;
      ProcSubset = mkLowDefault "pid";
      RestrictRealtime = mkLowDefault true;
      RestrictSUIDSGID = mkLowDefault true;
      SystemCallArchitectures = mkLowDefault "native";
    };
    "sshd@".serviceConfig = {
      StandardInput = mkLowDefault "socket";
      DevicePolicy = mkLowDefault "closed";
      KeyringMode = mkLowDefault "private";
      LockPersonality = mkLowDefault true;
      MemoryDenyWriteExecute = mkLowDefault true;
      NoNewPrivileges = mkLowDefault false;
      PrivateDevices = mkLowDefault true;
      PrivateTmp = mkLowDefault false;
      ProtectClock = mkLowDefault true;
      ProtectControlGroups = mkLowDefault true;
      ProtectHome = mkLowDefault false;
      ProtectHostname = mkLowDefault true;
      ProtectKernelLogs = mkLowDefault true;
      ProtectKernelModules = mkLowDefault true;
      ProtectKernelTunables = mkLowDefault true;
      ProtectProc = mkLowDefault "invisible";
      ProtectSystem = mkLowDefault true;
      ProcSubset = mkLowDefault "pid";
      RestrictRealtime = mkLowDefault true;
      RestrictSUIDSGID = mkLowDefault true;
      SystemCallArchitectures = mkLowDefault "native";
    };
    # https://github.com/cronie-crond/cronie/pull/179/files
    cronie.serviceConfig = {
      LockPersonality = mkLowDefault true;
      MemoryDenyWriteExecute = mkLowDefault true;
      NoNewPrivileges = mkLowDefault false;
      PrivateDevices = mkLowDefault false;
      PrivateTmp = mkLowDefault true;
      ProtectClock = mkLowDefault true;
      ProtectControlGroups = mkLowDefault true;
      ProtectHome = mkLowDefault false;
      ProtectHostname = mkLowDefault true;
      ProtectKernelLogs = mkLowDefault false;
      ProtectKernelModules = mkLowDefault true;
      ProtectKernelTunables = mkLowDefault false;
      ProtectProc = mkLowDefault "invisible";
      ProtectSystem = mkLowDefault false;
      RestrictNamespaces = mkLowDefault false;
      RestrictRealtime = mkLowDefault true;
      RestrictSUIDSGID = mkLowDefault false;
    };
    # https://gitlab.freedesktop.org/upower/power-profiles-daemon/-/merge_requests/173
    power-profiles-daemon.serviceConfig = {
      DevicePolicy = mkLowDefault "closed";
      KeyringMode = mkLowDefault "private";
      LockPersonality = mkLowDefault true;
      MemoryDenyWriteExecute = mkLowDefault true;
      NoNewPrivileges = mkLowDefault true;
      PrivateDevices = mkLowDefault true;
      PrivateTmp = mkLowDefault true;
      ProtectClock = mkLowDefault true;
      ProtectControlGroups = mkLowDefault true;
      ProtectHome = mkLowDefault true;
      ProtectHostname = mkLowDefault true;
      ProtectKernelLogs = mkLowDefault true;
      ProtectKernelModules = mkLowDefault true;
      ProtectProc = mkLowDefault "invisible";
      ProtectSystem = mkLowDefault "strict";
      RemoveIPC = mkLowDefault true;
      RestrictAddressFamilies = mkLowDefault [
        "AF_UNIX"
        "AF_LOCAL"
        "AF_NETLINK"
      ];
      RestrictRealtime = mkLowDefault true;
      RestrictNamespaces = mkLowDefault true;
      RestrictSUIDSGID = mkLowDefault true;
    };
  };
}
