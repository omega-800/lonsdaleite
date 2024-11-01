{ lib, lon-lib, config, pkgs, ... }:
let
  cfg = config.lonsdaleite.fs.hideHardwareInfo;
  inherit (lib) mkEnableOption mkIf;
  inherit (lon-lib) mkEnableFrom mkDisableOption boolToInt;
  usr = config.lonsdaleite.trustedUser;
in
{
  # TODO: borrow more stuff from kickstart https://github.com/Kicksecure/security-misc/tree/3af2684134279ba6f5b18b40986f02a50baa5604/usr/lib/systemd/system
  options.lonsdaleite.fs.hideHardwareInfo = (mkEnableFrom [ "fs" ]
    "Enables hide-hardware-info service implemented by [Kickstart](https://github.com/Kicksecure/security-misc/blob/3af2684134279ba6f5b18b40986f02a50baa5604/usr/lib/systemd/system/hide-hardware-info.service)")
  // {
    # TODO: implement whitelisting https://www.kicksecure.com/wiki/Security-misc#Whitelisting_Applications
    sysfsWhitelist = mkDisableOption "Enable /sys whitelist";
    cpuinfoWhitelist = mkDisableOption "Enable /proc/cpuinfo whitelist";
    hardenSysfs = mkDisableOption "Enable /sys hardening";
    selinuxMode = mkEnableOption
      "Enable selinux mode. NOTE: Not supported on NixOS (yet?)";
  };
  config = mkIf cfg.enable {
    users = {
      groups = {
        sysfs = { };
        cpuinfo = { };
      };
      users = mkIf usr != null { ${usr}.extraGroups = [ "sysfs" "cpuinfo" ]; };
    };
    # https://raw.githubusercontent.com/Kicksecure/security-misc/1bb843ec3863696170242c57668d0b3f44f41d7b/etc/hide-hardware-info.d/30_default.conf
    environment.etc."hide-hardware-info.d/30_default.conf".text = ''
      ## Copyright (C) 2012 - 2024 ENCRYPTED SUPPORT LP <adrelanos@whonix.org>
      ## See the file COPYING for copying conditions.

      ## Disable the /sys whitelist.
      sysfs_whitelist=${boolToInt cfg.sysfsWhitelist}

      ## Disable the /proc/cpuinfo whitelist.
      cpuinfo_whitelist=${boolToInt cfg.cpuinfoWhitelist}

      ## Disable /sys hardening.
      sysfs=${boolToInt cfg.hardenSysfs}

      ## Disable selinux mode.
      ## https://www.whonix.org/wiki/Security-misc#selinux
      selinux=${boolToInt cfg.selinuxMode}
    '';
    systemd.services = {
      # https://madaidans-insecurities.github.io/guides/linux-hardening.html#restricting-sysfs
      # For basic functionality to work on systems using systemd, you must whitelist a few system services.
      "user@".serviceConfig.SupplementaryGroups = [ "sysfs" ];

      hide-hardware-info = {
        enable = true;

        ## Copyright (C) 2012 - 2024 ENCRYPTED SUPPORT LP <adrelanos@whonix.org>
        ## See the file COPYING for copying conditions.

        unitConfig = {
          Description = "Hide hardware information to unprivileged users";
          Documentation = "https://github.com/Kicksecure/security-misc";
          DefaultDependencies = "no";
          Before = "sysinit.target";
          Requires = "local-fs.target";
          After = "local-fs.target";
        };

        serviceConfig = {
          Type = "oneshot";
          ExecStart = import ./hide-hardware-info-script.nix { inherit pkgs; };
          RemainAfterExit = "yes";
        };

        wantedBy = [ "sysinit.target" ];
      };
    };
  };
}
