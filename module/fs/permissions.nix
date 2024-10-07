{ config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.fs.permissions;
  inherit (lib) mkIf mkMerge mkDefault;
  inherit (lonLib) mkEnableFrom mkParanoiaOption;
in
{
  options.lonsdaleite.fs.permissions =
    (mkEnableFrom [ "fs" ] "sets hardened filesystem permissions") // {
      home = mkParanoiaOption [ "defaults" "nosuid" "noexec" ];
      root = mkParanoiaOption [ "" "" "" ];
      tmp = mkParanoiaOption [ "" "" "" ];
      var = mkParanoiaOption [ "" "" "" ];
      boot = mkParanoiaOption [ "" "" "" ];
      srv = mkParanoiaOption [ "" "" "" ];
      etc = mkParanoiaOption [ "" "" "" ];
      "/" = mkParanoiaOption [ "" "" "" ];
      usr = mkParanoiaOption [ "" "" "" ];
      mnt = mkParanoiaOption [ "" "" "" ];
      proc = mkParanoiaOption [ "" "" "" ];
    };

  config = mkIf (cfg.enable) {
    fileSystems = {
      "/home" = {
        device = mkDefault "/home";
        options = [ "nodev" "nouser" "auto" "async" "usrquota" "grpqouta" "rw" ]
          ++ (if cfg.home.paranoia == 2 then [ "noexec" ] else [ "exec" ])
          ++ (if cfg.home.paranoia >= 1 then [ "bind" "nosuid" ] else [ ]);
      };
      "/root" = {
        device = mkDefault "/root";
        options = [ "nodev" "nouser" ]
          ++ (if cfg.root.paranoia == 2 then [ "noexec" ] else [ "exec" ])
          ++ (if cfg.root.paranoia >= 1 then [ "bind" "nosuid" ] else [ ]);
      };
      "/tmp" = {
        device = "/tmp";
        options = [
          "nouser"
          "nodev"
          "noatime"
          "usrquota"
          "grpquota"
          "rw"
          "size=200M"
          "nr_inodes=5k"
          "mode=1700"
        ] ++ (if cfg.tmp.paranoia >= 1 then [ "bind" "nosuid" ] else [ ]);
      };
      "/var" = {
        device = mkDefault "/var";
        options =
          [ "defaults" "nouser" "nodev" "noatime" "usrquota" "grpqouta" ]
          ++ (if cfg.var.paranoia == 2 then [ "noexec" ] else [ "exec" ])
          ++ (if cfg.var.paranoia >= 1 then [ "bind" "nosuid" ] else [ ]);
      };
      "/var/lib" = {
        device = mkDefault "/var/lib";
        options = [ "defaults" "nodev" "nouser" ]
          ++ (if cfg.var.paranoia == 2 then [ "noexec" ] else [ "exec" ])
          ++ (if cfg.var.paranoia >= 1 then [ "bind" "nosuid" ] else [ ]);
      };
      "/boot" = {
        device = mkDefault "/boot";
        options = [ "defaults" "nodev" "nosuid" "umask=0077" ]
          ++ (if cfg.boot.paranoia == 3 then [ "ro" ] else [ ])
          ++ (if cfg.boot.paranoia >= 1 then [ "noexec" ] else [ ]);
      };
      "/srv" = {
        device = mkDefault "/srv";
        options = [ "bind" "nodev" "nouser" ]
          ++ (if cfg.srv.paranoia == 3 then [ "noexec" ] else [ ])
          ++ (if cfg.srv.paranoia >= 1 then [ "nosuid" ] else [ ]);
      };
      "/etc" = {
        device = mkDefault "/etc";
        options = [ "defaults" "nodev" "nouser" ]
          ++ (if cfg.etc.paranoia >= 1 then [ "bind" "nosuid" ] else [ ]);
      };
      "/etc/nixos" = {
        device = mkDefault "/etc/nixos";
        options = [ "defaults" "nodev" "nouser" ]
          ++ (if cfg.etc.paranoia >= 1 then [
          "bind"
          "nosuid"
          "noexec"
        ] else
          [ ]);
      };
      "/" = {
        device = mkDefault "/";
        options = [ "defaults" ]
          ++ (if cfg."/".paranoia == 3 then [ "mode=755" ] else [ ])
          ++ (if cfg."/".paranoia >= 1 then [ "noexec" ] else [ ]);
      };
      "/usr" = {
        device = mkDefault "/usr";
        options = [ "defaults" "nodev" "errors=remount-ro" ];
      };
      "/usr/share" = {
        device = mkDefault "/usr/share";
        options = [ "defaults" "nodev" ]
          ++ (if cfg.usr.paranoia == 3 then [ "ro" ] else [ ])
          ++ (if cfg.usr.paranoia >= 1 then [ "nosuid" ] else [ ]);
      };
      "/swap" = {
        device = mkDefault "/swap";
        options = [ "defaults" "nodev" "noexec" "nosuid" "nouser" "sw" ];
      };
      "/nix" = {
        device = mkDefault "/nix";
        options = [ "defaults" "nodev" "nosuid" "nouser" "noatime" ];
      };
      "/nix/store" = {
        device = mkDefault "/nix/store";
        options = [ "defaults" "nodev" "nosuid" "nouser" "noatime" ];
      };
      "/var/log" = {
        device = mkDefault "/var/log";
        options = [ "defaults" "nodev" "noexec" "nosuid" "nouser" "rw" ];
      };
      "/var/log/audit" = {
        device = mkDefault "/var/log/audit";
        options = [ "defaults" "nodev" "noexec" "nosuid" "nouser" "rw" ];
      };
      "/var/tmp" = {
        device = mkDefault "/var/tmp";
        options = [
          "defaults"
          "nodev"
          "noexec"
          "nosuid"
          "nouser"
          "usrquota"
          "grpqouta"
          "rw"
        ];
      };
      "/mnt/fd0" = {
        device = mkDefault "/mnt/fd0";
        options = [ "defaults" "nodev" "noexec" "nosuid" "ro" ];
      };
      "/mnt/floppy" = {
        device = mkDefault "/mnt/floppy";
        options = [ "defaults" "nodev" "noexec" "nosuid" "ro" ];
      };
      "/mnt/cdrom" = {
        device = mkDefault "/mnt/cdrom";
        options = [ "defaults" "nodev" "noexec" "nosuid" "ro" ];
      };
      "/mnt/tmp" = {
        device = mkDefault "/mnt/tmp";
        options = [ "defaults" "nodev" "noexec" "nosuid" "ro" ];
      };
    };
    boot.specialFileSystems = {
      "/dev/shm" = {
        fsType = "tmpfs";
        options = [
          "nodev"
          "noexec"
          "nosuid"
          "nouser"
          "strictatime"
          "mode=1777"
          "size=${config.boot.devShmSize}"
        ];
      };
      "/run" = {
        fsType = "tmpfs";
        options = [
          "nosuid"
          "nodev"
          "noexec"
          "strictatime"
          "mode=755"
          "size=${config.boot.runSize}"
        ];
      };
      "/dev" = {
        fsType = "devtmpfs";
        options = [
          "nosuid"
          "noexec"
          "strictatime"
          "mode=755"
          "size=${config.boot.devSize}"
        ];
      };
      "/proc" = {
        fsType = "proc";
        device = "proc";
        options = [
          "nodev"
          "noexec"
          "nosuid"
          "nouser"
          "noatime"
          "hidepid=${if cfg.proc.paranoia == 2 then "4" else "2"}"
          "gid=proc"
        ];
      };
    };
    users.groups.proc = { };
    systemd.services = {
      systemd-logind.serviceConfig.SupplementaryGroups = [ "proc" ];
      "user@".serviceConfig.SupplementaryGroups = [ "proc" ];
    };
  };
}
