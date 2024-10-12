{ config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.os.tty;
  inherit (lib) mkIf;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom;
in {
  options.lonsdaleite.os.tty = (mkEnableFrom [ "os" ] "Hardens tty") // { };

  config = mkIf cfg.enable {
    environment = {
      extraInit = # sh
        ''
          TMOUT="$(( 60*10 ))";
          [ -z "$DISPLAY" ] && export TMOUT;

          case $( /usr/bin/env tty ) in
          	/dev/tty[0-9]*) export TMOUT;;
          esac
        '';
      # Empty /etc/securetty to prevent root login on tty.
      etc = {
        securetty.text = ''
          # /etc/securetty: list of terminals on which root is allowed to login.
          # See securetty(5) and login(1).
        '';
        # Set machine-id to the Kicksecure machine-id, for privacy reasons.
        # /var/lib/dbus/machine-id doesn't exist on dbus enabled NixOS systems,
        # so we don't have to worry about that.
        machine-id.text = ''
          b08dfa6083e7567a1921a715000001fb
        '';
        # Borrow Kicksecure banner
        # https://github.com/Kicksecure/security-misc/blob/master/usr/lib/issue.d/20_security-misc.issue
        issue.text = ''
          By continuing, you acknowledge and give consent that the owner of this system has a right to keep a log of all activity.
          Unauthorized access is strictly prohibited and may result in legal action. Do not proceed!
        '';

        # TODO: 
        # Borrow Kicksecure gitconfig, disabling git symlinks and enabling fsck
        # by default for better git security.
      };

      persistence = lib.mkIf config.lonsdaleite.fs.impermanence.enable {
        "/nix/persist".files = [ "/etc/securetty" "/etc/issue" ];
      };
    };
  };
}
