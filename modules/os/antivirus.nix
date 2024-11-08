{ pkgs
, config
, lib
, lon-lib
, ...
}:
let
  cfg = config.lonsdaleite.os.antivirus;
  inherit (lib)
    mkIf
    mkForce
    mkMerge
    filterAttrs
    mapAttrsToList
    mkEnableOption
    concatStringsSep
    ;
  inherit (lon-lib) mkEnableFrom mkParanoiaFrom mkPersistDirs;
  notifyScript = pkgs.writeShellScript "malware_detected" ./malware_detected.sh;
  sus-user-dirs = [
    "Downloads"
    ".mozilla"
    ".vscode"
  ];
  all-normal-users = filterAttrs (n: c: c.isNormalUser) config.users.users;
  all-sus-dirs = builtins.concatMap
    (
      dir: mapAttrsToList (u: c: c.home + "/" + dir) all-normal-users
    )
    sus-user-dirs;
  all-user-folders = mapAttrsToList (u: c: c.home) all-normal-users;
  #TODO: research
  all-system-folders = [
    "/boot"
    "/etc"
    "/nix"
    "/opt"
    "/root"
    "/usr" # "/srv" "/var"
  ];
  prefix = if cfg.log-systemd then "${pkgs.systemd}/bin/systemd-cat --identifier=av-scan " else "";
in
{
  #TODO: rewrite notify script
  #TODO: centralized logging
  options.lonsdaleite.os.antivirus =
    (mkEnableFrom [ "os" ] "Enables antivirus (clamav)")
    // (mkParanoiaFrom [ "os" ] [
      ""
      ""
      ""
    ])
    // {
      log-systemd = mkEnableOption "Forward logs to systemd";
    };

  config = mkIf cfg.enable {
    environment = mkPersistDirs [
      "/etc/clamav"
      "/var/lib/clamav"
      "/var/log/clamav"
    ];
    security = mkMerge (
      let
        priv = config.lonsdaleite.os.privilege;
      in
      [
        (mkIf (priv.enable && priv.use-sudo) {
          sudo.extraConfig = "clamav ALL = (ALL) NOPASSWD: SETENV: ${pkgs.libnotify}/bin/notify-send";
        })
        (mkIf (priv.enable && (!priv.use-sudo)) {
          doas.extraConfig = "permit keepenv nopass clamav as root cmd ${pkgs.libnotify}/bin/notify-send";
        })
      ]
    );
    users.users.clamav.shell = "/bin/false";
    services.clamav = {
      daemon = {
        enable = true;
        settings = {
          ExtendedDetectionInfo = "yes";
          FixStaleSocket = "yes";
          LogFileMaxSize = "${toString (6 + (cfg.paranoia * 6))}M";
          LogRotate = "yes";
          LogTime = "yes";
          MaxDirectoryRecursion = "${toString (15 + (cfg.paranoia * 5))}";
          MaxThreads = "20";
          OnAccessExcludeUname = "clamav";
          OnAccessIncludePath = all-sus-dirs;
          OnAccessPrevention = "yes";
          User = "clamav";
          VirusEvent = "${notifyScript}";
          #https://wiki.archlinux.org/title/ClamAV
          DetectPUA = "yes";
          HeuristicAlerts = "yes";
          ScanPE = "yes";
          ScanELF = "yes";
          ScanOLE2 = "yes";
          ScanPDF = "yes";
          ScanSWF = "yes";
          ScanXMLDOCS = "yes";
          ScanHWP3 = "yes";
          ScanOneNote = "yes";
          ScanMail = "yes";
          ScanHTML = "yes";
          ScanArchive = "yes";
          Bytecode = "yes";
          AlertBrokenExecutables = "yes";
          AlertBrokenMedia = "yes";
          AlertEncrypted = "yes";
          AlertEncryptedArchive = "yes";
          AlertEncryptedDoc = "yes";
          AlertOLE2Macros = "yes";
          AlertPartitionIntersection = "yes";
        };
      };
      updater = {
        enable = true;
        interval = "hourly";
        frequency = 4 + (cfg.paranoia * 3);
      };
      fangfrisch = {
        enable = true;
        interval = "hourly";
      };
    };
    systemd = {
      # FIXME: upstream pull request, add check != "yes"
      # https://github.com/NixOS/nixpkgs/blob/f069d542234727fa1821ed96a69360474a7a2abf/nixos/modules/security/systemd-confinement.nix#L189
      # needs to be boolean for systemd confinement
      services.clamav-daemon.serviceConfig.PrivateTmp = mkForce true;
      services.clamav-fangfrisch.serviceConfig.PrivateTmp = mkForce true;
      services.clamav-fangfrisch-init.serviceConfig.PrivateTmp = mkForce true;
      services.clamav-freshclam.serviceConfig.PrivateTmp = mkForce true;

      services.clamav-clamonacc = {
        description = "ClamAV daemon (clamonacc)";
        after = [ "clamav-freshclam.service" ];
        wantedBy = [ "multi-user.target" ];
        restartTriggers = [ "/etc/clamav/clamd.conf" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = prefix + "${pkgs.clamav}/bin/clamonacc -F --fdpass --allmatch";
          PrivateTmp = true;
          PrivateDevices = true;
          PrivateNetwork = true;
        };
      };

      timers.av-user-scan = {
        description = "scan normal user directories for suspect files";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = if cfg.paranoia == 2 then "daily" else "weekly";
          Unit = "av-user-scan.service";
        };
      };

      services.av-user-scan = {
        description = "scan normal user directories for suspect files";
        # after = [ "network-online.target" ];
        # wantedBy = [ "network-online.target" ];
        after = [ "clamav-freshclam.service" ];
        wants = [ "clamav-freshclam.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart =
            prefix
            + "${pkgs.clamav}/bin/clamdscan --quiet --recursive --fdpass --multiscan --allmatch --infected ${concatStringsSep " " all-user-folders}";
        };
      };

      timers.av-all-scan = {
        description = "scan all directories for suspect files";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar =
            if cfg.paranoia == 1 then
              "weekly"
            else if cfg.paranoia == 2 then
              "daily"
            else
              "monthly";
          Unit = "av-all-scan.service";
        };
      };

      services.av-all-scan = {
        description = "scan all directories for suspect files";
        # after = [ "network-online.target" ];
        # wantedBy = [ "network-online.target" ];
        after = [ "clamav-freshclam.service" ];
        wants = [ "clamav-freshclam.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart =
            prefix
            + "${pkgs.clamav}/bin/clamdscan --quiet --recursive --fdpass --multiscan --allmatch --infected ${concatStringsSep " " all-system-folders}";
        };
      };
    };
  };
}
