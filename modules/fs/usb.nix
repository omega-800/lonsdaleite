{ config
, lib
, lon-lib
, options
, ...
}:
let
  cfg = config.lonsdaleite.fs.usb;
  inherit (lib)
    mkIf
    mkMerge
    mkDefault
    mkEnableOption
    ;
  inherit (lon-lib)
    mkEnableFrom
    mkEnableDef
    mkMineralLink
    mkParanoiaFrom
    ;
  usr = config.lonsdaleite.trustedUser;
in
{
  options.lonsdaleite.fs.usb =
    (mkParanoiaFrom [ "fs" ] [
      ""
      ""
      ""
    ])
    // {
      enable = mkEnableDef config.lonsdaleite.decapitated "Enables usb support";
      disable = mkEnableDef (!config.lonsdaleite.fs.usb) "Disables usb support";
      usbguard =
        (mkEnableFrom [
          "fs"
          "usb"
        ]
          options.services.usbguard.enable.description)
        // (mkParanoiaFrom
          [
            "fs"
            "usb"
          ]
          [
            ""
            "block"
            "reject"
          ]
        )
        // {
          gnome-integration = mkEnableOption "Enable USBGuard dbus daemon and polkit rules for integration with GNOME Shell. ${mkMineralLink 537}";
          allow-at-boot = mkEnableOption "Automatically whitelist all USB devices at boot in USBGuard. ${mkMineralLink 532}";
        };
    };

  config = mkMerge [
    (mkIf (cfg.disable) {
      # You can also disable USB from system BIOS configuration option. Make sure BIOS is password protected. This is recommended option so that nobody can boot it from USB.
      boot = {
        blacklistedKernelModules = [
          "usb-storage"

          # TODO: are these needed when usb support should be available or can i yeet them anyway?
          "gnss-usb"
          "usbatm"
          "xusbatm"

          # TODO: bluetooth
          "btusb"
        ];
        kernelParams = [ "nousb" ];
        kernel.sysctl."kernel.deny_new_usb" = "1";
      };
    })
    (mkIf cfg.enable {
      boot.kernel.sysctl."kernel.deny_new_usb" = if cfg.paranoia >= 1 then "1" else "0";
      boot.blacklistedKernelModules = [
        # https://git.launchpad.net/ubuntu/+source/kmod/tree/debian/modprobe.d/blacklist.conf?h=ubuntu/disco
        # these drivers are very simple, the HID drivers are usually preferred
        "usbkbd"
        "usbmouse"
      ];
    })
    (mkIf cfg.usbguard.enable {
      services.usbguard = {
        enable = true;
        IPCAllowedGroups = [ "wheel" ];
        IPCAllowedUsers = [ "root" ] ++ (if (usr != null) then [ usr ] else [ ]);
        dbus.enable = cfg.usbguard.gnome-integration;
        presentDevicePolicy = if cfg.usbguard.allow-at-boot then "allow" else "apply-policy";
        implicitPolicyTarget = if cfg.usbguard.paranoia == 2 then "reject" else "block";
        presentControllerPolicy =
          if cfg.usbguard.paranoia == 2 then
            "reject"
          else if cfg.usbguard.paranoia == 1 then
            "block"
          else
            "apply-policy";
      };
      security.polkit = mkIf cfg.usbguard.gnome-integration {
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
    })
  ];
}
