{ config
, lib
, ...
}:
let
  cfg = config.lonsdaleite.os.systemd;
  inherit (lib) mkIf;
in
{
  # https://www.reddit.com/r/NixOS/comments/1aqck9l/systemd_hardening_some_preconfigured_options_d/
  config = mkIf cfg.enable {
    systemd.services =
      let
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
        dirs = {
          InaccessibleDirectories = "/home";
          ReadOnlyDirectories = "/var";
          LimitNPROC = 1;
          LimitFSIZE = 0;
          DeviceALlow = "/dev/null rw";
        };
        basic = {
          ProtectClock = true;
          ProtectProc = "invisible";
          MemoryDenyWriteExecute = true;
          LockPersonality = true;
          RestrictRealtime = true;
          ProtectHome = true;
          UMask = "0077";
        };
        virtDef = {
          ProcSubset = "pid";
          ProtectControlGroups = true;
          ProtectSystem = "strict";
        } // basic;
        kernel = {
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
        };
        def = kernel // virtDef;
        virt = {
          ProtectKernelLogs = true;
          PrivateIPC = true;
          RestrictSUIDSGID = true;
          RestrictNamespaces = true;
          SystemCallArchitectures = "native";
        };
      in
      {
        #TODO: services.<name>.confinement.enable = true;
        systemd-rfkill.serviceConfig = {
          SystemCallArchitectures = "native";
          IPAddressDeny = "any";
          inherit SystemCallFilter;
        } // def;
        syslog.serviceConfig = {
          PrivateNetwork = true;
          CapabilityBoundingSet = [
            "CAP_DAC_READ_SEARCH"
            "CAP_SYSLOG"
            "CAP_NET_BIND_SERVICE"
          ];
          PrivateDevices = true;
          ProtectKernelLogs = true;
          PrivateMounts = true;
          SystemCallArchitectures = "native";
          PrivateUsers = true;
          RestrictNamespace = true;
          DeviceAllow = false;
          ProtectSystem = "full";
        } // kernel // basic;
        systemd-journald.serviceConfig = {
          UMask = 77;
          PrivateNetwork = true;
          ProtectHostname = true;
          ProtectKernelModules = true;
        };
        auto-cpufreq.serviceConfig = {
          ProtectClock = true;
          ProtectProc = true;
          PrivateTmp = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          ProtectHome = true;
          CapabilityBoundingSet = "";
          ProtectSystem = "full";
          PrivateNetwork = true;
          IPAddressDeny = "any";
          ProtectControlGroups = true;
          ProtectHostname = false;
          RestrictNamespaces = true;
          PrivateUsers = true;
          ReadOnlyPaths = [ "/" ];
          SystemCallArchitectures = "native";
          UMask = "0077";
        } // kernel;
        emergency.serviceConfig = {
          PrivateUsers = true;
          #PrivateDevices = true;  # Might need adjustment for emergency access
          RestrictAddressFamilies = "AF_INET";
          inherit SystemCallFilter;
        } // def // virt;
        rescue.serviceConfig = {
          PrivateUsers = true;
          #PrivateDevices = true;  # Might need adjustment for rescue operations
          RestrictAddressFamilies = "AF_INET AF_INET6"; # Networking might be necessary in rescue mode
          inherit SystemCallFilter;
          #FIXME
          #IPAddressDeny = "any";  # May need to be relaxed for network troubleshooting in rescue mode
        } // def // virt;
        "systemd-ask-password-console".serviceConfig = {
          PrivateUsers = true;
          #PrivateDevices = true;  # May need adjustment for console access
          RestrictAddressFamilies = "AF_INET AF_INET6";
          SystemCallFilter = [ "@system-service" ]; # A more permissive filter
          IPAddressDeny = "any";
        } // def // virt;
        "systemd-ask-password-wall".serviceConfig = {
          PrivateUsers = true;
          PrivateDevices = true;
          RestrictAddressFamilies = "AF_INET AF_INET6";
          SystemCallFilter = [ "@system-service" ]; # A more permissive filter
          IPAddressDeny = "any";
        } // def // virt;
        thermald.serviceConfig = {
          ProtectSystem = "strict";
          PrivateNetwork = true;
          #ProtectKernelTunables = true;  # Necessary for adjusting cooling policies
          #ProtectKernelModules = true;  # May need adjustment for module control
          ProtectControlGroups = true;
          ProcSubset = "pid";
          PrivateUsers = true;
          #PrivateDevices = true;  # May require access to specific hardware devices
          CapabilityBoundingSet = "";
          SystemCallFilter = [ "@system-service" ];
          IPAddressDeny = "any";
          DeviceAllow = [ ];
          RestrictAddressFamilies = [ ];
        } // virt // basic;
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
        "getty@tty1".serviceConfig = {
          PrivateUsers = true;
          PrivateDevices = true;
          RestrictAddressFamilies = "AF_INET";
          IPAddressDeny = "any";
          inherit SystemCallFilter;
        } // def // virt;
        "getty@tty7".serviceConfig = {
          PrivateUsers = true;
          PrivateDevices = true;
          RestrictAddressFamilies = "AF_INET";
          IPAddressDeny = "any";
          inherit SystemCallFilter;
        } // def // virt;
        display-manager.serviceConfig = {
          ProtectKernelLogs = true; # so we won't need all of this
        } // kernel;
        "dbus".serviceConfig = {
          PrivateTmp = true;
          #   PrivateNetwork = true;
          # ProtectSystem = "full";
          ProtectHome = true;
          #SystemCallFilter = "~@clock @cpu-emulation @module @mount @obsolete @raw-io @reboot @swap";
          # NoNewPrivileges = true;
          #   CapabilityBoundingSet = [
          #     "~CAP_SYS_TIME"
          #     "~CAP_SYS_PACCT"
          #     "~CAP_KILL"
          #     "~CAP_WAKE_ALARM"
          #     "~CAP_SYS_BOOT"
          #     "~CAP_SYS_CHROOT"
          #     "~CAP_LEASE"
          #     "~CAP_MKNOD"
          #     "~CAP_NET_ADMIN"
          #     "~CAP_SYS_ADMIN"
          #     "~CAP_SYSLOG"
          #     "~CAP_NET_BIND_SERVICE"
          #     "~CAP_NET_BROADCAST"
          #     "~CAP_AUDIT_WRITE"
          #     "~CAP_AUDIT_CONTROL"
          #     "~CAP_SYS_RAWIO"
          #     "~CAP_SYS_NICE"
          #     "~CAP_SYS_RESOURCE"
          #     "~CAP_SYS_TTY_CONFIG"
          #     "~CAP_SYS_MODULE"
          #     "~CAP_IPC_LOCK"
          #     "~CAP_LINUX_IMMUTABLE"
          #     "~CAP_BLOCK_SUSPEND"
          #     "~CAP_MAC_*"
          #     "~CAP_DAC_*"
          #     "~CAP_FOWNER"
          #     "~CAP_IPC_OWNER"
          #     "~CAP_SYS_PTRACE"
          #     "~CAP_SETUID"
          #     "~CAP_SETGID"
          #     "~CAP_SETPCAP"
          #     "~CAP_FSETID"
          #     "~CAP_SETFCAP"
          #     "~CAP_CHOWN"
          #   ];
          ProtectKernelLogs = true;
          #ProtectClock= true;
          ProtectControlGroups = true;
          RestrictNamespaces = true;
          #MemoryDenyWriteExecute= true;
          #RestrictAddressFamilies= ["~AF_PACKET" "~AF_NETLINK"];
          ProtectHostname = true;
          # LockPersonality = true;
          # RestrictRealtime = true;
          # PrivateUsers = true;
        } // kernel;
        reload-systemd-vconsole-setup.serviceConfig = {
          ##ProtectSystem = "strict";
          ProtectHome = true;
          ProtectControlGroups = true;
          ProtectKernelLogs = true;
          ProtectClock = true;
          PrivateUsers = true;
          PrivateDevices = true;
          #MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          LockPersonality = true;
          RestrictRealtime = true;
          RestrictNamespaces = true;
          UMask = "0077";
          IPAddressDeny = "any";
        } // kernel;
        "user@1000".serviceConfig = {
          #PrivateUsers = true;  # Be cautious, as this may restrict user operations
          PrivateDevices = true;
          RestrictAddressFamilies = "AF_INET AF_INET6";
          SystemCallFilter = [ "@system-service" ]; # Adjust based on user needs
        } // def // virt;
        "nixos-rebuild-switch-to-configuration".serviceConfig = {
          ProtectHome = true;
          NoNewPrivileges = true; # Prevent gaining new privileges
        };
        nix-daemon.serviceConfig = {
          ProtectHome = true;
          PrivateUsers = false;
        };
        virtlockd.serviceConfig = {
          PrivateUsers = true;
          #PrivateDevices = true;  # May need adjustment for accessing VM resources
          RestrictAddressFamilies = "AF_INET AF_INET6";
          SystemCallFilter = [ "@system-service" ]; # Adjust as necessary
          #FIXME
          #IPAddressDeny = "any";  # May need adjustment for network operations
        } // def // virt;
        virtlogd.serviceConfig = {
          PrivateUsers = true;
          #PrivateDevices = true;  # May need adjustment for accessing VM logs
          RestrictAddressFamilies = "AF_INET AF_INET6";
          SystemCallFilter = [ "@system-service" ]; # Adjust based on log management needs
          #FIXME
          #IPAddressDeny = "any";  # May need to be relaxed for network-based log collection
        } // def // virt;
        virtlxcd.serviceConfig = {
          #ProtectKernelTunables = true;  # Necessary for container management
          #PrivateUsers = true;  # Be cautious, might need adjustment for container user management
          #PrivateDevices = true;  # Containers might require broader device access
          #RestrictAddressFamilies = "AF_INET AF_INET6";  # Necessary for networked containers
          #SystemCallFilter = [ "@system-service" ];  # Adjust based on container operations
          #IPAddressDeny = "any";  # May need to be relaxed for network functionality
        } // virtDef // virt;
        virtqemud.serviceConfig = {
          #ProtectKernelTunables = true;  # Necessary for VM management
          #ProtectKernelModules = true;  # May need adjustment for VM hardware emulation
          #PrivateUsers = true;  # Be cautious, might need adjustment for VM user management
          #PrivateDevices = true;  # VMs might require broader device access
          #RestrictAddressFamilies = "AF_INET AF_INET6";  # Necessary for networked VMs
          #SystemCallFilter = [ "@system-service" ];  # Adjust based on VM operations
          #IPAddressDeny = "any";  # May need to be relaxed for network functionality
        } // virtDef // virt;
        virtvboxd.serviceConfig = {
          #ProtectKernelTunables = true;  # Required for some VM management tasks
          #ProtectKernelModules = true;  # May need adjustment for module handling
          #PrivateUsers = true;  # Be cautious, might need adjustment for VM user management
          #PrivateDevices = true;  # VMs may require access to certain devices
          #RestrictAddressFamilies = "AF_INET AF_INET6";  # Necessary for networked VMs
          #SystemCallFilter = [ "@system-service" ];  # Adjust based on VM operations
          #IPAddressDeny = "any";  # May need to be relaxed for network functionality
        } // virtDef // virt;
      };
  };
}
