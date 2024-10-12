{ config, lib, lonLib, pkgs, ... }:
let
  cfg = config.lonsdaleite.os.pam;
  inherit (lib) mkIf mkDefault mkBefore mkMerge mkForce mapAttrs;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom mkLink;
in {
  options.lonsdaleite.os.pam = (mkEnableFrom [ "os" ] ''
    Hardens pam
      Sources: 
      ${
        mkLink "Redhat"
        "https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/6/html/managing_smart_cards/pluggable_authentication_modules"
      }
      ${
        mkLink "the-practical-linux-hardening-guide"
        "https://github.com/trimstray/the-practical-linux-hardening-guide/wiki/PAM-Module"
      }
      ${
        mkLink "linux-audit"
        "https://linux-audit.com/locking-users-after-failed-login-attempts-with-pam_tally2/"
      }'') // mkParanoiaFrom [ "os" ] [ "" "" "" ];

  config = mkIf cfg.enable {
    #TODO: research and harden
    security.pam = {
      # TODO: implement encrypting /home, configure pam_mount
      mount = {
        enable = true;
        # TODO: research security implications? i hope there aren't any. i mean, ssd optimization would be nice. but allow is a word i don't like to hear in this context
        cryptMountOptions = [ "allow_discard" ];
        logoutHup = true;
        #logoutKill = cfg.paranoia == 2;
        #logoutTerm = cfg.paranoia == 1;
      };
      enableFscrypt = cfg.paranoia == 0;
      # TODO: research, configure
      enableOTPW = true;
      # is enabled by default 
      # TODO: research
      sshAgentAuth.enable = true;
      oath = {
        enable = true;
        digits = 8;
        usersFile = "/etc/users.oath";
        window = 5 - cfg.paranoia;
      };
      # TODO: zfs integration?
      # TODO: research, configure
      krb5.enable = config.lonsdaleite.net.kerberos.enable;
      # TODO: research pam.p11
      makeHomeDir.umask = "0077";
      loginLimits = [
        {
          domain = "*";
          item = "core";
          type = "hard";
          value = 0;
        }
        {
          domain = "*";
          item = "nofile";
          type = "hard";
          value = 512;
        }
        {
          domain = "ftp";
          item = "nproc";
          type = "hard";
          value = 0;
        }
        {
          domain = "*";
          item = "maxlogins";
          type = "-";
          value = 4 - cfg.paranoia;
        }
        {
          domain = "*";
          item = "maxsyslogins";
          type = "-";
          value = 4 - cfg.paranoia;
        }
        {
          domain = "*";
          item = "nonewprivs";
          type = "-";
          value = 1;
        }
      ];
      services = mkMerge [
        (mapAttrs (s: {
          rules.password = {
            # https://github.com/NixOS/nixpkgs/issues/287420#issuecomment-2209405124
            unix = {
              control = mkForce "required";
              settings = {
                use_authtok = true;
                # Increase hashing rounds for /etc/shadow; this doesn't automatically
                # rehash your passwords, you'll need to set passwords for your accounts
                # again for this to work.
                sha512 = true;
                shadow = true;
                rounds = 65536;
              };
            };
            # Require secure passwords
            pwquality = {
              control = "required";
              modulePath =
                "${pkgs.libpwquality.lib}/lib/security/pam_pwquality.so";
              # order BEFORE pam_unix.so
              order =
                config.security.pam.services.${s}.rules.password.unix.order
                - 10;
              settings = {
                # https://github.com/libpwquality/libpwquality/blob/master/doc/man/pam_pwquality.8.pod
                retry = 3 - cfg.paranoia;
                minlen = 12 + (cfg.paranoia * 4);
                difok = 6 + (cfg.paranoia * 2); # difference from the old pw
                dcredit = -1 - cfg.paranoia; # digits
                ucredit = -1 - cfg.paranoia; # uppercase
                lcredit = -1 - cfg.paranoia; # lowercase
                ocredit = -1 - cfg.paranoia; # other chars
                minclass = 4; # must contain all char types
                maxrepeat = 3 - cfg.paranoia; # disallow N consecutive chars
                maxsequence = 4 - cfg.paranoia; # disallow N sequential chars
                maxclassrepeat = 5
                  - cfg.paranoia; # disallow N consecutive char types
                gecoscheck = 1; # see manpage
                dictcheck = 1; # enabled by default
                usercheck = 1; # enabled by default
                usersubstr = 1;
                enforcing = 1; # enabled by default
                enforce_for_root = true;
                use_authtok = false;
              };
            };
          };
        }) [ "passwd" "chpasswd" ])
        {
          # TODO: testing
          # Enable PAM support for securetty, to prevent root login.
          # https://unix.stackexchange.com/questions/670116/debian-bullseye-disable-console-tty-login-for-root
          login.text = mkDefault (mkBefore ''
            # Enable securetty support.
            auth       requisite  pam_nologin.so
            auth       requisite  pam_securetty.so
          '');

          su.requireWheel = true;
          su-l.requireWheel = true;
          system-login.failDelay.delay = "4000000";
        }
      ];
    };
  };
}
