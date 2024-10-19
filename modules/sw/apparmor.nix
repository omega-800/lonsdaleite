{ config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.sw.apparmor;
  inherit (lib) mkIf;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom mkPersistDirs;
in
{
  # https://gitlab.com/apparmor/apparmor
  # https://github.com/roddhjav/apparmor.d
  # TODO: research
  options.lonsdaleite.sw.apparmor = (mkEnableFrom [ "sw" ] "Enables apparmor")
    // (mkParanoiaFrom [ "sw" ] [ "" "" "" ]) // { };

  config = mkIf cfg.enable {
    environment = mkPersistDirs [ "/etc/apparmor" ];
    security.apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
      #TODO: implement? write my own? 
      includes = { };
      policies = {
        test = {
          enable = true;
          enforce = false;
          profile = ''
            # apparmor.d - Full set of apparmor profiles
            # Copyright (C) 2019-2021 Mikhail Morfikov
            # Copyright (C) 2021-2024 Alexandre Pujol <alexandre@pujol.io>
            # SPDX-License-Identifier: GPL-2.0-only

            abi <abi/4.0>,

            include <tunables/global>

            @{exec_path} = @{bin}/chsh
            profile chsh @{exec_path} {
              include <abstractions/base>
              include <abstractions/wutmp>
              include <abstractions/authentication>
              include <abstractions/nameservice-strict>

              # To write records to the kernel auditing log.
              capability audit_write,

              # To set the right permission to the files in the /etc/ dir.
              capability chown,
              capability fsetid,

              # gpasswd is a SETUID binary
              capability setuid,

              network netlink raw,

              @{exec_path} mr,

              owner @{PROC}/@{pid}/loginuid r,

              /etc/shells r,

              /etc/passwd rw,
              /etc/passwd- w,
              /etc/passwd+ rw,
              /etc/passwd.@{pid} w,
              /etc/passwd.lock wl -> /etc/passwd.@{pid},

              /etc/shadow r,

              # A process first uses lckpwdf() to lock the lock file, thereby gaining exclusive rights to
              # modify the /etc/passwd or /etc/shadow password database.
              /etc/.pwd.lock rwk,

              include if exists <local/chsh>
            }

            # vim:syntax=apparmor
          '';
        };
      };
    };
  };
}
