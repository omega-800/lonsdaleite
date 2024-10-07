{ config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.net.sshd;
  inherit (lib) mkIf mkMerge mkDefault mkEnableOption;
  inherit (lonLib) mkEnableFrom mkParanoiaOption;
in {
  options.lonsdaleite.net.sshd = (mkEnableFrom [ "net" ] "hardens ssh daemon")
    // {
      algorithms = mkParanoiaOption [ "" "" "enforces secure algorithms" ];
    };

  config = mkIf cfg.enable {
    services.openssh = mkMerge [
      {
        enable = true;
        openFirewall = true;
        banner = ''
          Thank you for your login credentials
          :)
        '';
        # Only allow system-level authorized_keys to avoid injections.
        # We currently don't enable this when git-based software that relies on this is enabled.
        # It would be nicer to make it more granular using `Match`.
        # However those match blocks cannot be put after other `extraConfig` lines
        # with the current sshd config module, which is however something the sshd
        # config parser mandates.
        authorizedKeysFiles = mkIf (!config.services.gitea.enable
          && !config.services.gitlab.enable && !config.services.gitolite.enable
          && !config.services.gerrit.enable && !config.services.forgejo.enable)
          (lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ]);

        settings = {
          PrintMotd = true;
          X11Forwarding = false;
        };
      }
      #TODO: move these around
      (mkIf (cfg.paranoia >= 1) {
        settings = {
          # unbind gnupg sockets if they exists
          StreamLocalBindUnlink = true;
          LogLevel = "VERBOSE";
          TCPKeepAlive = false;
          MaxSessions = 2;
          GatewayPorts = "no";
          KbdInteractiveAuthentication = false;
          # AllowUsers = [ usr.username ];
          PasswordAuthentication = false;
          PermitRootLogin = lib.mkForce "no";
          PermitEmptyPasswords = false;
          PermitUserEnvironment = false;
          UseDns = false;
          UsePAM = true;
          StrictModes = true;
          IgnoreRhosts = true;
          RhostsAuthentication = false;
          RhostsRSAAuthentication = false;
          ClientAliveInterval = 300;
          ClientAliveCountMax = 0;
          MaxAuthTries = 3;
          AllowTcpForwarding = false;
          AllowAgentForwarding = false;
          AllowStreamLocalForwarding = false;
          AuthenticationMethods = "publickey";
        };
      })
      (mkIf (cfg.paranoia == 2) {
        ports = [ 51423 ];
        allowSFTP = false;
        MaxSessions = lib.mkForce 1;
        HostbasedAuthentication = false;
        KexAlgorithms = config.programs.ssh.kexAlgorithms;
        Macs = config.programs.ssh.macs;
        Ciphers = config.programs.ssh.ciphers;
        HostKeyAlgorithms =
          builtins.concatStringsSep "," config.programs.ssh.hostKeyAlgorithms;
      })
    ];
  };
}
