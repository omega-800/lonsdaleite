{ config, pkgs, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.os.tty;
  inherit (lib) mkIf mkDefault mkBefore mkMerge;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom mkEtcPersist;
  usr = config.lonsdaleite.trustedUser;
in
{
  options.lonsdaleite.os.tty = (mkEnableFrom [ "os" ] "Hardens tty")
    // (mkParanoiaFrom [ "os" ] [ "" "" "" ]);

  config = mkIf cfg.enable {
    # https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/security_guide/sec-controlling_root_access#sec-Disallowing_Root_Access
    boot.initrd.systemd.users.root.shell = "${pkgs.shadow}/bin/nologin";
    users.users = mkMerge [
      { root.shell = "${pkgs.shadow}/bin/nologin"; }
      (mkIf (usr != null) { "${usr}".uid = 1000; })
    ];
    # man 5 login.defs
    security.loginDefs.settings = {
      # login isn't allowed if one can't cd to home dir
      DEFAULT_HOME = "no";
      # TODO: research
      # ENCRYPT_METHOD = "";
      UMASK = "077"; # already default

      # https://www.debian.org/doc/manuals/securing-debian-manual/ch04s11.en.html#idm1318
      FAILLOG_ENAB = "yes";
      LOG_UNKFAIL_ENAB = "no";
      # These ones enable logging of su/sg attempts to syslog. Quite important on serious machines but note that this can create privacy issues as well.
      SYSLOG_SU_ENAB = if cfg.paranoia == 2 then "yes" else "no";
      SYSLOG_SG_ENAB = if cfg.paranoia == 2 then "yes" else "no";

      # https://www.redhat.com/sysadmin/password-expiration-date-linux
      PASS_MAX_DAYS = 90 - (cfg.paranoia * 20);
      PASS_MIN_DAYS = 7;
      PASS_WARN_AGE = 5;
      # TODO: nice to have
      # USERDEL_CMD
    };
    #TODO: sulogin
    security.pam.services.login = mkIf config.lonsdaleite.os.pam.enable {
      # TODO: testing
      # Enable PAM support for securetty, to prevent root login.
      # https://unix.stackexchange.com/questions/670116/debian-bullseye-disable-console-tty-login-for-root
      # http://www.tldp.org/HOWTO/html_single/Text-Terminal-HOWTO/
      # https://unix.stackexchange.com/questions/17906/can-i-allow-a-non-root-user-to-log-in-when-etc-nologin-exists

      # FIXME: pam_securetty prevents normal user login?
      # text = mkDefault (mkBefore ''
      #   # Allow UID 1000 to log in
      #   auth       [default=ignore success=1]  ${pkgs.linux-pam}/lib/pam_succeed_if.so quiet user uid eq 1000
      #   auth       required  ${pkgs.linux-pam}/lib/pam_listfile.so item=user sense=allow file=/etc/lonsdaleite/trusted-user
      #   # Disallow everyone else
      #   auth       requisite  ${pkgs.linux-pam}/lib/pam_nologin.so
      #   auth       requisite  ${pkgs.linux-pam}/lib/pam_securetty.so
      # '');
    };
    environment = mkMerge [
      {
        # https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/security_guide/sec-controlling_root_access#sect-Security_Guide-Administrative_Controls-Enabling_Automatic_Logouts
        # https://wiki.archlinux.org/title/Security#Automatic_logout
        extraInit = # sh
          ''
            trap "" 1 2 3 15
            TMOUT="$(( 60*10 ))";

            [ -z "$DISPLAY" ] && export TMOUT && readonly TMOUT

            case $( /usr/bin/env tty ) in
            	/dev/tty[0-9]*) export TMOUT && readonly TMOUT;;
            esac
          '';
      }
      # Create /etc/nologin so that no users can log in 
      (mkEtcPersist "nologin" ''
        This account is currently not available.
      '')
      # Empty /etc/securetty to prevent root login on tty.
      (mkEtcPersist "securetty" ''
        # /etc/securetty: list of terminals on which root is allowed to login.
        # See securetty(5) and login(1).
      '')
      # Set machine-id to the Kicksecure machine-id, for privacy reasons.
      # /var/lib/dbus/machine-id doesn't exist on dbus enabled NixOS systems,
      # so we don't have to worry about that.
      (mkEtcPersist "machine-id" ''
        b08dfa6083e7567a1921a715000001fb
      '')
      # Borrow Kicksecure banner
      # https://github.com/Kicksecure/security-misc/blob/master/usr/lib/issue.d/20_security-misc.issue
      (mkEtcPersist "issue" ''
        By continuing, you acknowledge and give consent that the owner of this system has a right to keep a log of all activity.
        Unauthorized access is strictly prohibited and may result in legal action. Do not proceed!
      '')

      # To prevent users from starting up the system interactively as root
      (mkEtcPersist "sysconfig/init" ''
        PROMPT=no
      '')

      # TODO: 
      # Borrow Kicksecure gitconfig, disabling git symlinks and enabling fsck
      # by default for better git security.
    ];
  };
}
