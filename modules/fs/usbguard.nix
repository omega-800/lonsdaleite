{ config, lib, lonLib, options, ... }:
let
  cfg = config.lonsdaleite.fs.usbguard;
  inherit (lib) mkIf mkMerge mkDefault mkEnableOption;
  inherit (lonLib) mkEnableFrom mkParanoiaOption mkMineralLink mkParanoiaFrom;
in {
  options.lonsdaleite.fs.usbguard =
    (mkEnableFrom [ "fs" ] options.services.usbguard.enable.description)
    // (mkParanoiaFrom [ "fs" ] [ ]) // {
      paranoia = mkParanoiaOption [ "" "block" "reject" ];
      gnome-integration = mkEnableOption
        "Enable USBGuard dbus daemon and polkit rules for integration with GNOME Shell. ${
          mkMineralLink 537
        }";
      allow-at-boot = mkEnableOption
        "Automatically whitelist all USB devices at boot in USBGuard. ${
          mkMineralLink 532
        }";
    };

  config = mkIf cfg.enable {
    services.usbguard = {
      enable = true;
      IPCAllowedGroups = [ "wheel" ];
      IPCAllowedUsers = [ "root" ];
      dbus.enable = cfg.gnome-integration;
      presentDevicePolicy =
        if cfg.allow-at-boot then "allow" else "apply-policy";
      implicitPolicyTarget = if cfg.paranoia == 2 then "reject" else "block";
      presentControllerPolicy = if cfg.paranoia == 2 then
        "reject"
      else if cfg.paranoia == 1 then
        "block"
      else
        "apply-policy";
    };
    security.polkit = mkIf cfg.gnome-integration {
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if ((action.id == "org.usbguard.Policy1.listRules" ||
               action.id == "org.usbguard.Policy1.appendRule" ||
               action.id == "org.usbguard.Policy1.removeRule" ||
               action.id == "org.usbguard.Devices1.applyDevicePolicy" ||
               action.id == "org.usbguard.Devices1.listDevices" ||
               action.id == "org.usbguard1.getParameter" ||
               action.id == "org.usbguard1.setParameter") &&
               subject.active == true && subject.local == true &&
               subject.isInGroup("wheel")) { return polkit.Result.YES; }
        });
      '';
    };
  };
}
