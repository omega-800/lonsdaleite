{ config
, lib
, lon-lib
, ...
}:
let
  cfg = config.lonsdaleite.fs.permissions;
  inherit (lib) mkIf mkMerge mkDefault;
  inherit (lon-lib) mkEnableFrom mkParanoiaOption mkParanoiaFrom;
in
{
  # TODO: https://www.kicksecure.com/wiki/SUID_Disabler_and_Permission_Hardener
  # https://madaidans-insecurities.github.io/guides/linux-hardening.html#file-permissions
  options.lonsdaleite.fs.permissions =
    (mkEnableFrom [ "fs" ] ''
      Sets hardened filesystem permissions. 
      [Partitioning guide](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/6/html/installation_guide/s2-diskpartrecommend-x86#idm140491990747664)
    '')
    // (mkParanoiaFrom [ "fs" ] [ ])
    // {
      home = mkParanoiaOption [
        "defaults"
        "nosuid"
        "noexec"
      ];
      root = mkParanoiaOption [
        ""
        ""
        ""
      ];
      tmp = mkParanoiaOption [
        ""
        ""
        ""
      ];
      var = mkParanoiaOption [
        ""
        ""
        ""
      ];
      boot = mkParanoiaOption [
        ""
        ""
        ""
      ];
      srv = mkParanoiaOption [
        ""
        ""
        ""
      ];
      etc = mkParanoiaOption [
        ""
        ""
        ""
      ];
      "/" = mkParanoiaOption [
        ""
        ""
        ""
      ];
      usr = mkParanoiaOption [
        ""
        ""
        ""
      ];
      mnt = mkParanoiaOption [
        ""
        ""
        ""
      ];
      proc = mkParanoiaOption [
        ""
        ""
        ""
      ];
    };

  config = mkIf cfg.enable {
    systemd.tmpfiles.settings = {
      # Restrict permissions of /home/$USER so that only the owner of the
      # directory can access it (the user). systemd-tmpfiles also has the benefit
      # of recursively setting permissions too, with the "Z" option as seen below.
      "restricthome"."/home/*".Z.mode = "0700";

      # Make all files in /etc/nixos owned by root, and only readable by root.
      # /etc/nixos is not owned by root by default, and configuration files can
      # on occasion end up also not owned by root. This can be hazardous as files
      # that are included in the rebuild may be editable by unprivileged users,
      # so this mitigates that.
      "restrictetcnixos"."/etc/nixos/*".Z = {
        mode = "0000";
        user = "root";
        group = "root";
      };

      # A few more examples are /boot, /usr/src and /{,usr/}lib/modules — these contain the kernel image, System.map and various other files, all of which can leak sensitive information about the kernel.
      "restrictusrsrc"."/usr/src/*".Z.mode = "0700";
      "restrictusrlibmodules"."/usr/lib/modules/*".Z.mode = "0700";
      "restrictlibmodules"."/lib/modules/*".Z.mode = "0700";

    };

    fileSystems = {
      "/home" = {
        device = mkDefault "/home";
        options =
          [
            "nodev"
            "nouser"
            "auto"
            "async"
            "usrquota"
            "grpqouta"
            "rw"
          ]
          ++ (if cfg.home.paranoia == 2 then [ "noexec" ] else [ "exec" ])
          ++ (
            if cfg.home.paranoia >= 1 then
              [
                "bind"
                "nosuid"
              ]
            else
              [ ]
          );
      };
      "/root" = {
        device = mkDefault "/root";
        options =
          [
            "nodev"
            "nouser"
          ]
          ++ (if cfg.root.paranoia == 2 then [ ] else [ ])
          ++ (
            if cfg.root.paranoia >= 1 then
              [
                "noexec"
                "bind"
                "nosuid"
              ]
            else
              [ ]
          );
      };
      "/tmp" = {
        device = "/tmp";
        options =
          [
            "nouser"
            "nodev"
            "noexec"
            "noatime"
            "usrquota"
            "grpquota"
            "rw"
            "size=200M"
            "nr_inodes=5k"
            "mode=1700"
          ]
          ++ (
            if cfg.tmp.paranoia >= 1 then
              [
                "bind"
                "nosuid"
              ]
            else
              [ ]
          );
      };
      "/var" = {
        device = mkDefault "/var";
        options =
          [
            "defaults"
            "nouser"
            "nodev"
            "noatime"
            "usrquota"
            "grpqouta"
          ]
          ++ (if cfg.var.paranoia == 2 then [ "noexec" ] else [ "exec" ])
          ++ (
            if cfg.var.paranoia >= 1 then
              [
                "bind"
                "nosuid"
              ]
            else
              [ ]
          );
      };
      "/var/lib" = {
        device = mkDefault "/var/lib";
        options =
          [
            "defaults"
            "nodev"
            "nouser"
          ]
          ++ (if cfg.var.paranoia == 2 then [ "noexec" ] else [ "exec" ])
          ++ (
            if cfg.var.paranoia >= 1 then
              [
                "bind"
                "nosuid"
              ]
            else
              [ ]
          );
      };
      "/boot" = {
        device = mkDefault "/boot";
        options =
          [
            "defaults"
            "nodev"
            "nosuid"
            "umask=0077"
          ]
          ++ (if cfg.boot.paranoia == 2 then [ "ro" ] else [ ])
          ++ (if cfg.boot.paranoia >= 1 then [ "noexec" ] else [ ]);
      };
      "/srv" = {
        device = mkDefault "/srv";
        options =
          [
            "bind"
            "nodev"
            "nouser"
          ]
          ++ (if cfg.srv.paranoia == 2 then [ "noexec" ] else [ ])
          ++ (if cfg.srv.paranoia >= 1 then [ "nosuid" ] else [ ]);
      };
      "/etc" = {
        device = mkDefault "/etc";
        options =
          [
            "defaults"
            "nodev"
            "nouser"
          ]
          ++ (
            if cfg.etc.paranoia >= 1 then
              [
                "bind"
                "nosuid"
              ]
            else
              [ ]
          );
      };
      "/etc/nixos" = {
        device = mkDefault "/etc/nixos";
        options =
          [
            "defaults"
            "nodev"
            "nouser"
          ]
          ++ (
            if cfg.etc.paranoia >= 1 then
              [
                "bind"
                "nosuid"
                "noexec"
              ]
            else
              [ ]
          );
      };
      "/" = {
        device = mkDefault "/";
        options =
          [ "defaults" ]
          ++ (if cfg."/".paranoia == 2 then [ "mode=755" ] else [ ])
          ++ (if cfg."/".paranoia >= 1 then [ "noexec" ] else [ ]);
      };
      "/usr" = {
        device = mkDefault "/usr";
        options = [
          "defaults"
          "nodev"
          "errors=remount-ro"
        ];
      };
      "/usr/share" = {
        device = mkDefault "/usr/share";
        options =
          [
            "defaults"
            "nodev"
          ]
          ++ (if cfg.usr.paranoia == 2 then [ "ro" ] else [ ])
          ++ (if cfg.usr.paranoia >= 1 then [ "nosuid" ] else [ ]);
      };
      "/swap" = {
        device = mkDefault "/swap";
        options = [
          "defaults"
          "nodev"
          "noexec"
          "nosuid"
          "nouser"
          "sw"
        ];
      };
      "/nix" = {
        device = mkDefault "/nix";
        options = [
          "defaults"
          "nodev"
          "nosuid"
          "nouser"
          "noatime"
        ];
      };
      "/nix/store" = {
        device = mkDefault "/nix/store";
        options = [
          "defaults"
          "nodev"
          "nosuid"
          "nouser"
          "noatime"
        ];
      };
      "/var/log" = {
        device = mkDefault "/var/log";
        options = [
          "defaults"
          "nodev"
          "noexec"
          "nosuid"
          "nouser"
          "rw"
        ];
      };
      "/var/log/audit" = {
        device = mkDefault "/var/log/audit";
        options = [
          "defaults"
          "nodev"
          "noexec"
          "nosuid"
          "nouser"
          "rw"
        ];
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
        options = [
          "defaults"
          "nodev"
          "noexec"
          "nosuid"
          "ro"
        ];
      };
      "/mnt/floppy" = {
        device = mkDefault "/mnt/floppy";
        options = [
          "defaults"
          "nodev"
          "noexec"
          "nosuid"
          "ro"
        ];
      };
      "/mnt/cdrom" = {
        device = mkDefault "/mnt/cdrom";
        options = [
          "defaults"
          "nodev"
          "noexec"
          "nosuid"
          "ro"
        ];
      };
      "/mnt/tmp" = {
        device = mkDefault "/mnt/tmp";
        options = [
          "defaults"
          "nodev"
          "noexec"
          "nosuid"
          "ro"
        ];
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
      # /proc is a pseudo-filesystem that contains information about all processes currently running on the system. By default, this is accessible to all users, which can allow an attacker to spy on other processes. 
      "/proc" = {
        fsType = "proc";
        device = "proc";
        options = [
          "nodev"
          "noexec"
          "nosuid"
          "nouser"
          "noatime"
          # To permit users to only see their own processes and not those of other users
          "hidepid=${if cfg.proc.paranoia == 2 then "4" else "2"}"
          "gid=proc"
        ];
      };
    };
    # systemd-logind still needs to see other users' processes, so this is needed for user sessions to work correctly on a systemd system
    systemd.services = {
      systemd-logind.serviceConfig.SupplementaryGroups = [ "proc" ];
      "user@".serviceConfig.SupplementaryGroups = [ "proc" ];
    };
    users.groups.proc = { };
  };
}
