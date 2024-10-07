{ config, lib, ... }:
let
  cfg = config.lonsdaleite.fs.permissions;
  inherit (lib) mkOption types mkIf mkMerge;
in
{
  options.lonsdaleite.fs.permissions = (lib.lonsdaleite.mkParentDefEnableOption
    "sets hardened filesystem permissions" [ "fs" ]) // { };
  config = mkIf (cfg.enable && sys.paranoid) {
    fileSystems = {
      #FIXME: separate partitions
      # https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/6/html/installation_guide/s2-diskpartrecommend-x86#idm140491990747664
      # /                 8
      # /var              4
      # /var/log/audit    4
      # /home             4
      # /tmp              2
      # /swap             2
      "/home" = {
        device = lib.mkDefault "/home";
        options = [
          "bind"
          "nodev"
          "nosuid"
          "nouser"
          "auto"
          "async"
          "usrquota"
          "grpqouta"
          "rw"
        ] ++ (if sys.paranoid then [ "noexec" ] else [ "exec" ]);
      };
      "/root" = {
        device = lib.mkDefault "/root";
        options = [ "bind" "nodev" "nosuid" "nouser" "noexec" ];
      };
      "/tmp" = {
        device = "/tmp";
        options = [
          "bind"
          "nodev"
          "nosuid"
          "nouser"
          "noatime"
          "usrquota"
          "grpquota"
          "rw"
          "size=200M"
          "nr_inodes=5k"
          "mode=1700"
        ] ++ (if sys.paranoid then [ "noexec" ] else [ "exec" ]);
      };
      "/var" = {
        device = lib.mkDefault "/var";
        options = [
          "defaults"
          "bind"
          "nodev"
          "nosuid"
          "nouser"
          "noatime"
          "usrquota"
          "grpqouta"
        ] ++ (if sys.paranoid then [ "noexec" ] else [ "exec" ]);
      };
      "/var/lib" = {
        device = lib.mkDefault "/var/lib";
        options = [ "defaults" "bind" "nodev" "nosuid" "nouser" ]
          ++ (if sys.paranoid then [ "noexec" ] else [ "exec" ]);
      };
      "/boot" = {
        device = lib.mkDefault "/boot";
        options = [ "defaults" "nodev" "nosuid" "noexec" "umask=0077" ]
          ++ (if sys.paranoid then [ "ro" ] else [ ]);
      };
      "/srv" = {
        device = lib.mkDefault "/srv";
        options = [ "bind" "nodev" "noexec" "nosuid" "nouser" ];
      };
      "/etc" = {
        device = lib.mkDefault "/etc";
        options = [ "defaults" "bind" "nodev" "nosuid" "nouser" ];
      };
      "/etc/nixos" = {
        device = lib.mkDefault "/etc/nixos";
        options = [ "defaults" "bind" "nodev" "nosuid" "noexec" "nouser" ];
      };

      "/" = {
        device = lib.mkDefault "/";
        options = [ "defaults" "noexec" "mode=755" ];
      };
      "/usr" = {
        device = lib.mkDefault "/usr";
        options = [ "defaults" "nodev" "errors=remount-ro" ];
      };
      "/usr/share" = {
        device = lib.mkDefault "/usr/share";
        options = [ "defaults" "nodev" "ro" "nosuid" ];
      };
      "/swap" = {
        device = lib.mkDefault "/swap";
        options = [ "defaults" "nodev" "noexec" "nosuid" "nouser" "sw" ];
      };
      "/nix" = {
        device = lib.mkDefault "/nix";
        options = [ "defaults" "nodev" "nosuid" "nouser" "noatime" ];
      };
      "/nix/store" = {
        device = lib.mkDefault "/nix/store";
        options = [ "defaults" "nodev" "nosuid" "nouser" "noatime" ];
      };
      "/var/log" = {
        device = lib.mkDefault "/var/log";
        options = [ "defaults" "nodev" "noexec" "nosuid" "nouser" "rw" ];
      };
      "/var/log/audit" = {
        device = lib.mkDefault "/var/log/audit";
        options = [ "defaults" "nodev" "noexec" "nosuid" "nouser" "rw" ];
      };
      "/var/tmp" = {
        device = lib.mkDefault "/var/tmp";
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
        device = lib.mkDefault "/mnt/fd0";
        options = [ "defaults" "nodev" "noexec" "nosuid" "ro" ];
      };
      "/mnt/floppy" = {
        device = lib.mkDefault "/mnt/floppy";
        options = [ "defaults" "nodev" "noexec" "nosuid" "ro" ];
      };
      "/mnt/cdrom" = {
        device = lib.mkDefault "/mnt/cdrom";
        options = [ "defaults" "nodev" "noexec" "nosuid" "ro" ];
      };
      "/mnt/tmp" = {
        device = lib.mkDefault "/mnt/tmp";
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
          "hidepid=${if sys.paranoid then "4" else "2"}"
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
