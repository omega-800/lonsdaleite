{ config
, lib
, lon-lib
, ...
}:
let
  cfg = config.lonsdaleite.os.systemd;
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
    mkDefault
    mkForce
    ;
  inherit (lon-lib) mkEnableFrom mkParanoiaFrom;
  inherit (builtins) mapAttrs elem attrNames;
in
# TODO: difference between boot.initrd.systemd.services and systemd.services?
{
  # https://www.reddit.com/r/NixOS/comments/1aqck9l/systemd_hardening_some_preconfigured_options_d/
  # https://documentation.suse.com/smart/security/html/systemd-securing/index.html
  # https://github.com/alegrey91/systemd-service-hardening
  # https://gist.github.com/joachifm/022ca74fd447bd8bb2f80a133c0ab3a9
  # https://madaidans-insecurities.github.io/guides/linux-hardening.html#systemd-service-sandboxing
  # https://0pointer.de/blog/projects/security.html
  # https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html
  # sytemd-analyze security
  # https://docs.google.com/spreadsheets/d/1BLKqBSsF0B9gYz6b4TIPnJ93SpiUVDiD8z_80pTyXJc/edit?gid=0#gid=0

  # TODO: research
  # man systemd.exec
  # TODO: AppArmorProfile
  options = {
    lonsdaleite.os.systemd =
      (mkEnableFrom [ "os" ] "Hardens systemd")
      // (mkParanoiaFrom [ "os" ] [
        ""
        ""
        ""
      ])
      // {
        confineAll = {
          enable = mkOption {
            type = types.bool;
            default = cfg.paranoia > 0;
            description = ''
              Confines all systemd services. 
              WARNING: Will render your system unusable if the systemd services you need aren't whitelisted.
            '';
          };
          fullUnit = mkOption {
            type = types.bool;
            default = cfg.confineAll && cfg.paranoia == 2;
            description = ''
              Sets fullUnit = true to all systemd confinements. 
              WARNING: If you do not want your machine to just be a fancy brick, whitelist the services you need or override their serviceConfig.
            '';
          };
          # TODO: whitelist only required services by default
          # check if commented-out services still work
          whitelist = mkOption {
            type = types.listOf types.str;
            description = "Systemd services to be whitelisted.";
            default = [
              # "ModemManager"
              # "NetworkManager"
              # "NetworkManager-dispatcher"
              # "NetworkManager-wait-online"
              "apparmor"
              "audit"
              "auto-cpufreq"
              # "autovt@"
              # "av-all-scan"
              # "av-user-scan"
              # "clamav-clamonacc"
              # "clamav-daemon"
              # "clamav-fangfrisch"
              # "clamav-fangfrisch-init"
              # "clamav-freshclam"
              "console-getty"
              "container-getty@"
              "container@"
              "dbus"
              "disable-kernel-module-loading"
              # "display-manager"
              # "emergency"
              "firewall"
              "generate-shutdown-ramfs"
              # "getty@"
              # "getty@tty1"
              # "getty@tty7"
              "jitterentropy"
              "kmod-static-nodes"
              "logrotate"
              "logrotate-checkconf"
              "mount-pstore"
              "network-local-commands"
              # "nix-daemon"
              # "nix-gc"
              # "nix-optimise"
              # "nixos-rebuild-switch-to-configuration"
              # "nixos-upgrade"
              "nscd"
              "polkit"
              "post-resume"
              "pre-sleep"
              "prepare-kexec"
              # "qemu-guest-agent"
              "reload-systemd-vconsole-setup"
              # "rescue"
              "save-hwclock"
              "serial-getty@"
              # "sshd"
              "suid-sgid-wrappers"
              "syslog"
              "systemd-ask-password-console"
              "systemd-ask-password-wall"
              "systemd-backlight@"
              "systemd-fsck@"
              "systemd-importd"
              "systemd-journal-flush"
              "systemd-journald"
              "systemd-journald@"
              "systemd-logind"
              "systemd-makefs@"
              "systemd-mkswap@"
              "systemd-modules-load"
              "systemd-network-wait-online@"
              "systemd-networkd"
              "systemd-networkd-wait-online"
              "systemd-nspawn@"
              "systemd-oomd"
              "systemd-pstore"
              "systemd-random-seed"
              "systemd-remount-fs"
              "systemd-resolved"
              "systemd-rfkill"
              "systemd-sysctl"
              "systemd-timedated"
              "systemd-tmpfiles-resetup"
              "systemd-udev-settle"
              "systemd-udevd"
              "systemd-update-utmp"
              "systemd-user-sessions"
              "thermald"
              "user-runtime-dir@"
              "user@"
              "user@1000"
            ];
          };
        };
      };
    # override defaults for all systemd services
    systemd.services = mkOption {
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          let
            # https://developer.hashicorp.com/vault/tutorials/operations/production-hardening#extended-recommendations
            serviceConfig = {
              "ProtectSystem" = mkDefault "full";
              "PrivateTmp" = mkDefault true;
              "CapabilityBoundingSet" = mkDefault [
                "CAP_SYSLOG"
                "CAP_IPC_LOCK"
              ];
              "AmbientCapabilities" = mkDefault "CAP_IPC_LOCK";
              "ProtectHome" = mkDefault "read-only";
              "PrivateDevices" = mkDefault true;
              "NoNewPrivileges" = mkDefault true;
            };
          in
          {
            config = {
              confinement = mkIf (!(elem name cfg.confineAll.whitelist)) {
                inherit (cfg.confineAll) enable fullUnit;
                inherit serviceConfig;
              };
            };
          }
        )
      );
    };
  };

  config = mkIf cfg.enable {
    assertions = map
      (name: {
        assertion = elem name (attrNames config.systemd.services);
        message = "`lonsdaleite.os.systemd.confineAll.whitelist' must only contain values in (attrNames `systemd.services'). Offending value is \"${name}\"";
      })
      cfg.confineAll.whitelist;

    # Given that our systems are headless, emergency mode is useless.
    # We prefer the system to attempt to continue booting so
    # that we can hopefully still access it remotely.
    boot.initrd.systemd.suppressedUnits = mkIf config.lonsdaleite.decapitated [
      "emergency.service"
      "emergency.target"
    ];

    services.journald = {
      forwardToSyslog = true;
      extraConfig = ''
        SystemMaxUse=50M
        SystemMaxFiles=5'';
      rateLimitBurst = 500;
      rateLimitInterval = "30s";
    };
    # https://pastebin.com/fi6VBm2z
    systemd = mkMerge [
      {
        # TODO: gather coredump cfgs from sysctl, pam, systemd
        coredump = {
          enable = false;
          extraConfig = "Storage=none";
        };
      }
      (mkIf config.lonsdaleite.decapitated {
        # Given that our systems are headless, emergency mode is useless.
        # We prefer the system to attempt to continue booting so
        # that we can hopefully still access it remotely.
        enableEmergencyMode = false;

        # For more detail, see:
        #   https://0pointer.de/blog/projects/watchdog.html
        watchdog = {
          # systemd will send a signal to the hardware watchdog at half
          # the interval defined here, so every 10s.
          # If the hardware watchdog does not get a signal for 20s,
          # it will forcefully reboot the system.
          runtimeTime = "20s";
          # Forcefully reboot if the final stage of the reboot
          # hangs without progress for more than 30s.
          # For more info, see:
          #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
          rebootTime = "30s";
        };

        sleep.extraConfig = ''
          AllowSuspend=no
          AllowHibernation=no
        '';
      })
      (mkIf (cfg.paranoia == 2) {
        services =
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

        ### FEDORA ###

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
      })
    ];
  };
}
