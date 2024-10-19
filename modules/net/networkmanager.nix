{ config, lib, lon-lib, ... }:
let
  cfg = config.lonsdaleite.net.networkmanager;
  inherit (lib) mkIf mkMerge mkDefault;
  inherit (lib.types) listOf nonEmptyStr;
  inherit (lon-lib) mkEnableFrom mkParanoiaFrom mkPersistFiles mkPersistDirs;
  usr = config.lonsdaleite.trustedUser;
in
{
  options.lonsdaleite.net.networkmanager =
    (mkEnableFrom [ "net" ] "Hardens NetworkManager")
    // (mkParanoiaFrom [ "net" ] [ "" "" "" ]) // { };

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

    systemd.services = mkMerge [
      { NetworkManager-wait-online.enable = false; }
      (mkIf config.lonsdaleite.os.systemd.enable {
        NetworkManager-dispatcher.serviceConfig = {
          ProtectHome = true;
          ProtectControlGroups = true;
          ProtectKernelLogs = true;
          ProtectHostname = true;
          #ProtectClock = true;
          ProtectProc = "invisible";
          ProcSubset = "pid";
          PrivateUsers = true;
          PrivateDevices = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          LockPersonality = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RestrictAddressFamilies = "AF_INET";
          RestrictNamespaces = true;
          SystemCallFilter = [
            "write"
            "read"
            "openat"
            "close"
            "brk"
            "fstat"
            "lseek"
            "mmap"
            "mprotect"
            "munmap"
            "rt_sigaction"
            "rt_sigprocmask"
            "ioctl"
            "nanosleep"
            "select"
            "access"
            "execve"
            "getuid"
            "arch_prctl"
            "set_tid_address"
            "set_robust_list"
            "prlimit64"
            "pread64"
            "getrandom"
          ];
          SystemCallArchitectures = "native";
          UMask = "0077";
          IPAddressDeny = "any";
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
        };
        NetworkManager.serviceConfig = {
          NoNewPrivileges = true;
          #ProtectClock = true;
          ProtectKernelLogs = true;
          ProtectControlGroups = true;
          SystemCallArchitectures = "native";
          MemoryDenyWriteExecute = true;
          ProtectProc = "invisible";
          ProcSubset = "pid";
          RestrictNamespaces = true;
          ProtectHome = true;
          PrivateTmp = true;
          UMask = "0077";
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
        };
      })
    ];

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
