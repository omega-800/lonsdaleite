{ config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.fs.usbguard;
  inherit (lib) mkIf mkMerge mkDefault mkEnableOption;
  inherit (lonLib) mkEnableFrom mkParanoiaOption;
in {
  options.lonsdaleite.fs.usbguard = (mkEnableFrom [ "fs" ] "enables usbguard")
    // {
      gnome-integration = mkEnableOption
        "Enable USBGuard dbus daemon and polkit rules for integration with GNOME Shell.";
    };

  config = mkIf cfg.enable {
    services.usbguard = {
      enable = true;
      IPCAllowedGroups = [ "wheel" ];
      IPCAllowedUsers = [ "root" ];
    };
    security.polkit = mkIf (cfg.gnome-integration) {
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
