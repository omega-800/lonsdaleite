{ config
, lib
, ...
}:
let
  cfg = config.lonsdaleite.os.systemd;
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
      DevicePolicy = "closed";
      KeyringMode = "private";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      OOMPolicy = "continue";
      PrivateDevices = true;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = "read-only";
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectSystem = true;
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
    };
    "httpd@".serviceConfig = {
      DevicePolicy = "closed";
      KeyringMode = "private";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      OOMPolicy = "continue";
      PrivateDevices = true;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = "read-only";
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectSystem = true;
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
    };
    # https://src.fedoraproject.org/rpms/abrt/pull-request/32#request_diff
    abrt.serviceConfig = {
      DevicePolicy = "closed";
      KeyringMode = "private";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = "read-only";
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "full";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
    };
    # https://github.com/fwupd/fwupd/pull/6860/files
    fwupd.serviceConfig = {
      KeyringMode = "private";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = false;
      PrivateDevices = false;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "full";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = "~@mount";
    };
    # https://gitlab.freedesktop.org/realmd/realmd/-/merge_requests/42
    realmd.serviceConfig = {
      DevicePolicy = "closed";
      KeyringMode = "private";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "no";
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
    };
    # https://github.com/firewalld/firewalld/pull/1313
    firewalld.serviceConfig = {
      DevicePolicy = "closed";
      KeyringMode = "private";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = false;
      ProtectKernelTunables = false;
      ProtectSystem = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
    };
    # https://github.com/bus1/dbus-broker/pull/345
    dbus-broker.serviceConfig = {
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectSystem = "full";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
    };
    # https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/merge_requests/1879
    NetworkManager.serviceConfig = {
      RestrictNamespaces = true;
      # ProtectHome = true;
      UMask = "0077";

      DevicePolicy = "closed";
      KeyringMode = "private";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = false;
      PrivateDevices = false;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = "read-only";
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = false;
      ProtectProc = "invisible";
      ProtectSystem = true;
      ProcSubset = "pid";
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
    };
    # https://gitlab.freedesktop.org/polkit/polkit/-/blob/master/data/polkit.service.in?ref_type=heads
    polkit.serviceConfig = {
      LimitMEMLOCK = 0;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateNetwork = true;
      PrivateTmp = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectKernelTunables = true;
      ProtectSystem = "strict";
      ProtectClock = true;
      ProtectHostname = true;
      RemoveIPC = true;
      RestrictAddressFamilies = "AF_UNIX";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = "@system-service";
      UMask = "0077";
    };
    # https://github.com/PackageKit/PackageKit/pull/719
    packagekit.serviceConfig = {
      KeyringMode = "private";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = false;
      PrivateDevices = false;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = false;
      ProtectKernelModules = false;
      ProtectKernelTunables = false;
      ProtectSystem = false;
      RemoveIPC = false;
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
    };
    # https://github.com/hughsie/colord/blob/main/data/colord.service.in
    colord.serviceConfig = {
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      RestrictRealtime = true;
      ConfigurationDirectory = "colord";
      StateDirectory = "colord";
      CacheDirectory = "colord";
      CapabilityBoundingSet = [
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
      NoNewPrivileges = true;
      PrivateUsers = true;
      ProtectProc = "invisible";
      ProcSubset = "pid";
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      RestrictNamespaces = [
        "~cgroup"
        "user"
        "pid"
        "net"
        "uts"
        "mnt"
        "ipc"
      ];
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      RemoveIPC = true;
    };
    # https://gitlab.freedesktop.org/libfprint/fprintd/-/blob/master/data/fprintd.service.in?ref_type=heads
    fprintd.serviceConfig = {
      ProtectSystem = "strict";
      ProtectKernelTunables = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      StateDirectory = "fprint";
      StateDirectoryMode = 700;
      ProtectHome = true;
      PrivateTmp = true;
      SystemCallFilter = "@system-service";
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_LOCAL"
        "AF_NETLINK"
      ];
      MemoryDenyWriteExecute = true;
      ProtectKernelModules = true;
      RestrictRealtime = true;
      NoNewPrivileges = true;
      ProtectClock = true;
      DeviceAllow = [
        "char-usb_device rw"
        "char-spi rw"
        "char-hidraw rw"
        "/dev/cros_fp rw"
      ];
      ReadWritePaths = "/sys/devices";
    };
    # https://gitlab.gnome.org/GNOME/gdm/-/merge_requests/245
    gdm.serviceConfig = {
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = false;
      PrivateDevices = false;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = "read-only";
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectSystem = false;
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
    };
    # https://src.fedoraproject.org/rpms/open-vm-tools/pull-request/9
    vgauthd.serviceConfig = {
      DevicePolicy = "closed";
      KeyringMode = "private";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = true;
      ProcSubset = "pid";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
    };
    vmtools.serviceConfig = {
      DevicePolicy = "closed";
      KeyringMode = "private";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateDevices = false;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = false;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = true;
      ProcSubset = "pid";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
    };
    # https://src.fedoraproject.org/rpms/openssh/pull-request/69
    sshd.serviceConfig = {
      DevicePolicy = "closed";
      KeyringMode = "private";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = false;
      PrivateDevices = true;
      PrivateTmp = false;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = false;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = true;
      ProcSubset = "pid";
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
    };
    "sshd@".serviceConfig = {
      StandardInput = "socket";
      DevicePolicy = "closed";
      KeyringMode = "private";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = false;
      PrivateDevices = true;
      PrivateTmp = false;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = false;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = true;
      ProcSubset = "pid";
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
    };
    # https://github.com/cronie-crond/cronie/pull/179/files
    cronie.serviceConfig = {
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = false;
      PrivateDevices = false;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = false;
      ProtectHostname = true;
      ProtectKernelLogs = false;
      ProtectKernelModules = true;
      ProtectKernelTunables = false;
      ProtectProc = "invisible";
      ProtectSystem = false;
      RestrictNamespaces = false;
      RestrictRealtime = true;
      RestrictSUIDSGID = false;
    };
    # https://gitlab.freedesktop.org/upower/power-profiles-daemon/-/merge_requests/173
    power-profiles-daemon.serviceConfig = {
      DevicePolicy = "closed";
      KeyringMode = "private";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      RemoveIPC = true;
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_LOCAL"
        "AF_NETLINK"
      ];
      RestrictRealtime = true;
      RestrictNamespaces = true;
      RestrictSUIDSGID = true;
    };
  };
}
