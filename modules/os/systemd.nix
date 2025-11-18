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
  inherit (lon-lib) mkEnableFrom mkParanoiaFrom mkHighDefault;
  inherit (builtins) mapAttrs elem attrNames;
in
# TODO: difference between boot.initrd.systemd.services and systemd.services?
{
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

  # FIXME: test first
  # imports = [ ./systemd ];

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
            default = cfg.confineAll.enable && cfg.paranoia == 2;
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
              # "logrotate"
              # "logrotate-checkconf"
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
              "ProtectSystem" = mkHighDefault "full";
              "PrivateTmp" = mkHighDefault true;
              "CapabilityBoundingSet" = mkHighDefault [
                "CAP_SYSLOG"
                "CAP_IPC_LOCK"
              ];
              "AmbientCapabilities" = mkHighDefault "CAP_IPC_LOCK";
              "ProtectHome" = mkHighDefault "read-only";
              "PrivateDevices" = mkHighDefault true;
              "NoNewPrivileges" = mkHighDefault true;
            };
          in
          {
            config = {
              inherit serviceConfig;
              confinement = mkIf (!(elem name cfg.confineAll.whitelist)) {
                inherit (cfg.confineAll) enable fullUnit;
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
    ];
  };
}
