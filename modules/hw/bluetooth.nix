{ lib
, lon-lib
, config
, ...
}:
let
  cfg = config.lonsdaleite.hw.bluetooth;
  inherit (lib) mkMerge mkIf;
  inherit (lon-lib) mkPersistDirs mkEnableDef;
in
{
  options.lonsdaleite.hw.bluetooth = {
    enable = mkEnableDef config.hardware.bluetooth.enable "Hardens bluetooth";
    disable = mkEnableDef (!config.hardware.bluetooth.enable) "Removes bluetooth completely";
  };
  config = mkMerge [
    {
      assertions = [
        {
          assertion = !(cfg.enable && cfg.disable);
          message = ''
            One can only enable or disable bluetooth, not both.
            Set one of config.lonsdaleite.hw.bluetooth.{enable,disable} to false.
          '';
        }
      ];
      environment = mkPersistDirs [
        "/var/lib/bluetooth"
        "/etc/bluetooth"
      ];
    }
    (mkIf cfg.enable {
      # https://github.com/Kicksecure/security-misc/blob/master/etc/bluetooth/30_security-misc.conf
      hardware.bluetooth = {
        powerOnBoot = false;
        settings = {
          General = {
            PairableTimeout = 30;
            DiscoverableTimeout = 30;
            MaxControllers = 1;
            TemporaryTimeout = 0;
          };
          Policy = {
            AutoEnable = false;
            Privacy = "network/on";
          };
        };
      };
    })

    (mkIf cfg.disable {
      # SOURCE: https://raw.githubusercontent.com/Kicksecure/security-misc/refs/heads/master/etc/modprobe.d/30_security-misc_disable.conf
      ## Copyright (C) 2012 - 2024 ENCRYPTED SUPPORT LP <adrelanos@whonix.org>
      ## Bluetooth:
      ## Disable Bluetooth to reduce attack surface due to extended history of security vulnerabilities.
      ##
      ## https://en.wikipedia.org/wiki/Bluetooth#History_of_security_concerns
      boot.blacklistedKernelModules = [
        "bluetooth"
        "bluetooth_6lowpan"
        "bt3c_cs"
        "btbcm"
        "btintel"
        "btmrvl"
        "btmrvl_sdio"
        "btmtk"
        "btmtksdio"
        "btmtkuart"
        "btnxpuart"
        "btqca"
        "btrsi"
        "btrtl"
        "btsdio"
        "btusb"
        "virtio_bt"
      ];
    })
  ];
}
