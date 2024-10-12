{ config, pkgs, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.os.tty;
  inherit (lib) mkIf mkDefault mkBefore mkMerge;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom mkEtcPersist;
  usr = config.lonsdaleite.trustedUser;
in
{
  options.lonsdaleite.os.tty = (mkEnableFrom [ "os" ] "Hardens tty") // { };

  config = mkIf cfg.enable {
    # TODO: disable root login by /sbin/nologin?
    # https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/security_guide/sec-controlling_root_access#sec-Disallowing_Root_Access
    #TODO: sulogin
    users.users = mkMerge [{
      root.shell = "${lib.getExe' pkgs.util-linux "nologin"}";
    }
      # infinite recursion 
      # (mkIf (usr != null) { "${usr}".uid = 1000; })
    ];
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
      #   # Disallow everyone else
      #   auth       requisite  ${pkgs.linux-pam}/lib/pam_nologin.so
      #   auth       requisite  ${pkgs.linux-pam}/lib/pam_securetty.so
      # '');
    };
    environment = mkMerge [
      {
        # https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/security_guide/sec-controlling_root_access#sect-Security_Guide-Administrative_Controls-Enabling_Automatic_Logouts
        extraInit = # sh
          ''
            trap "" 1 2 3 15
            TMOUT="$(( 60*10 ))";
            if [ -z "$DISPLAY" ]; then 
              export TMOUT;
              readonly TMOUT
            fi

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

      # TODO: 
      # Borrow Kicksecure gitconfig, disabling git symlinks and enabling fsck
      # by default for better git security.
    ];
  };
}
