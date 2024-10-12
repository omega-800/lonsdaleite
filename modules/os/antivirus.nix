{ pkgs, config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.os.antivirus;
  inherit (lib) mkIf mkMerge filterAttrs mapAttrsToList;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom;
  notifyScript = pkgs.writeShellScript "malware_detected" ./malware_detected.sh;
  sus-user-dirs = [ "Downloads" ".mozilla" ".vscode" ];
  all-normal-users = filterAttrs (n: c: c.isNormalUser) config.users.users;
  all-sus-dirs = builtins.concatMap
    (dir: mapAttrsToList (u: c: c.home + "/" + dir) all-normal-users)
    sus-user-dirs;
  all-user-folders = mapAttrsToList (u: c: c.home) all-normal-users;
  all-system-folders = [ "/boot" "/etc" "/nix" "/opt" "/root" "/usr" ];
in {
  #TODO: notify script depending on gui / tui
  options.lonsdaleite.os.antivirus =
    (mkEnableFrom [ "os" ] "Enables antivirus (clamav)") // { };

  config = mkIf cfg.enable {
    security = mkMerge [
      (mkIf config.lonsdaleite.os.privilege.enable
        && config.lonsdaleite.os.privilege.use-sudo {
          sudo.extraConfig =
            "clamav ALL = (ALL) NOPASSWD: SETENV: ${pkgs.libnotify}/bin/notify-send";
        })
      (mkIf config.lonsdaleite.os.privilege.enable
        && (!config.lonsdaleite.os.privilege.use-sudo) {
          doas.extraConfig =
            "permit keepenv nopass clamav as root cmd ${pkgs.libnotify}/bin/notify-send";
        })
    ];
    services.clamav = {
      daemon = {
        enable = true;
        settings = {
          ExtendedDetectionInfo = "yes";
          FixStaleSocket = "yes";
          LogFileMaxSize = "5M";
          LogRotate = "yes";
          LogTime = "yes";
          MaxDirectoryRecursion = "15";
          MaxThreads = "20";
          OnAccessExcludeUname = "clamav";
          OnAccessIncludePath = all-sus-dirs;
          OnAccessPrevention = "yes";
          User = "clamav";
          VirusEvent = "${notifyScript}";
        };
      };
      updater = {
        enable = true;
        interval = "hourly";
        frequency = 6;
      };
    };
    systemd = {
      services.clamav-clamonacc = {
        description = "ClamAV daemon (clamonacc)";
        after = [ "clamav-freshclam.service" ];
        wantedBy = [ "multi-user.target" ];
        restartTriggers = [ "/etc/clamav/clamd.conf" ];

        serviceConfig = {
          Type = "simple";
          ExecStart =
            "${pkgs.systemd}/bin/systemd-cat --identifier=av-scan ${pkgs.clamav}/bin/clamonacc -F --fdpass";
          PrivateTmp = "yes";
          PrivateDevices = "yes";
          PrivateNetwork = "yes";
        };
      };

      timers.av-user-scan = {
        description = "scan normal user directories for suspect files";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "weekly";
          Unit = "av-user-scan.service";
        };
      };

      services.av-user-scan = {
        description = "scan normal user directories for suspect files";
        after = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart =
            "${pkgs.systemd}/bin/systemd-cat --identifier=av-scan ${pkgs.clamav}/bin/clamdscan --quiet --recursive --fdpass ${
              toString all-user-folders
            }";
        };
      };

      timers.av-all-scan = {
        description = "scan all directories for suspect files";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "monthly";
          Unit = "av-all-scan.service";
        };
      };

      services.av-all-scan = {
        description = "scan all directories for suspect files";
        after = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = ''
            ${pkgs.systemd}/bin/systemd-cat --identifier=av-scan ${pkgs.clamav}/bin/clamdscan --quiet --recursive --fdpass ${
              toString all-system-folders
            }
          '';
        };
      };
    };
  };
}
