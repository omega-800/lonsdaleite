{ config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.net.sshd;
  inherit (lib) mkIf mkMerge mkDefault mkForce mkOption concatMapStrings;
  inherit (lib.types) listOf nonEmptyStr;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom mkLink mkEtcPersist;
  inherit (lonLib.const) systemd;
  usr = config.lonsdaleite.trustedUser;
in
{
  # TODO: SetEnv and AcceptEnv fail to build if no args passed? but that's the point?
  options.lonsdaleite.net.sshd = (mkEnableFrom [ "net" ] ''
    Hardens ssh daemon. 
      Sources: ${
        mkLink "linux-audit"
        "https://linux-audit.com/audit-and-harden-your-ssh-configuration/"
      }'') // (mkParanoiaFrom [ "net" ] [ "" "" "enforces secure algorithms" ])
  // {
    allow-hosts = mkOption {
      type = listOf nonEmptyStr;
      description =
        "Hosts to allow connecting to. Only required if paranoia == 2";
      default = [ ];
    };
    revoked-keys = mkOption {
      description = "Revoked keys";
      type = listOf nonEmptyStr;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    environment = mkEtcPersist "ssh/sshd_revoked_keys"
      (builtins.concatStringsSep "\n" cfg.revoked-keys);
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
        # TODO: make persistent
        authorizedKeysFiles = mkIf
          (!config.services.gitea.enable
            && !config.services.gitlab.enable && !config.services.gitolite.enable
            && !config.services.gerrit.enable && !config.services.forgejo.enable)
          (mkForce [ "/etc/ssh/authorized_keys.d/%u" ]);

        settings = {
          StrictModes = true;
          PrintMotd = mkDefault true;
          LogLevel = "VERBOSE";
          GatewayPorts = "no";
          # By default, the SSH server can check if the client connecting maps back to the same combination of hostname and IP address. Use the option UseDNS to perform this basic check as an additional safeguard.
          # Note: this option may not work properly in all situations. It could result in an additional delay, as the daemon is waiting for a timeout during the initial connection. Only use this when you are sure your internal DNS is properly configured.
          UseDns = cfg.paranoia > 0;
          UsePAM = cfg.paranoia > 0;
          TCPKeepAlive = false;
          ClientAliveInterval = 300 - (cfg.paranoia * 100);
          ClientAliveCountMax = 3 - cfg.paranoia;
          MaxSessions = 3 - cfg.paranoia;
          # TODO: https://linux-audit.com/locking-users-after-failed-login-attempts-with-pam_tally2/
          MaxAuthTries = 4 - cfg.paranoia;
          # Should be the default
          PermitEmptyPasswords = false;
          PermitRootLogin = "no";
          KbdInteractiveAuthentication = mkDefault false;
          HostbasedAuthentication = false;
          AllowTcpForwarding = false;
          AllowAgentForwarding = false;
          AllowStreamLocalForwarding = false;
          # The X11 protocol was never built with security in mind. As it opens up channel back to the client, the server could send malicious commands back to the client.
          X11Forwarding = false;
          # unbind gnupg sockets if they exists
          StreamLocalBindUnlink = true;
          PermitUserEnvironment = false;
          # While not common anymore, rhosts was a weak method to authenticate systems. It defines a way to trust another system simply by its IP address. 
          IgnoreRhosts = true;
          # Deprecated
          # RhostsAuthentication = false;
          # RhostsRSAAuthentication = false;
        };
        extraConfig =
          let t = toString (9 - (cfg.paranoia * 3));
          in ''
            ChannelTimeout global=${t}m
            # equals
            # ChannelTimeout x11-connection=${t}m tun-connection=${t}m session=${t}m agent-connection=${t}m direct-tcpip=${t}m direct-streamlocal@openssh.com=${t}m 
            UnusedConnectionTimeout ${t}m
            # Should be the default
            Protocol 2
            # SetEnv 
            DisableForwarding yes
            PermitTunnel no
            ExposeAuthInfo no
            FingerprintHash sha256
            GSSAPIAuthentication no
            KerberosAuthentication ${
              if config.lonsdaleite.net.kerberos.enable then "yes" else "no"
            }
            # KerberosGetAFSToken no
            KerberosOrLocalPasswd no
            KerberosTicketCleanup yes
            LoginGraceTime ${toString (120 - (cfg.paranoia * 30))}
            MaxStartups ${toString (10 - (cfg.paranoia * 3))}:${
              toString (30 + (cfg.paranoia * 20))
            }:${toString (100 - (cfg.paranoia * 30))}
            PrintLastLog yes
            RevokedKeys /etc/ssh/sshd_revoked_keys
            Compression yes
          '';
      }
      (mkIf (cfg.paranoia >= 1) {
        extraConfig = ''
          # AcceptEnv 
          RequiredRSASize 3072
        '';
        settings = mkMerge [{
          PasswordAuthentication = false;
          AuthenticationMethods = mkDefault "publickey";
          # denies access to all other users by default
          AllowUsers = if usr == null then [ ] else [ usr ];
          AllowGroups =
            if usr == null then [ ] else [ (lonLib.userByName usr).group ];
        }];
        allowSFTP = false;
      })
      (mkIf (cfg.paranoia == 2) {
        extraConfig = ''
          AddressFamily inet
          PermitUserRC no
          PubkeyAuthOptions verify-required
          RekeyLimit 500M
          Match Address ${concatMapStrings (h: "!${h},") cfg.allow-hosts}*
            PubKeyAuthentication no
          #TODO: TrustedUserCAKeys CASignatureAlgorithms
        '';
        ports = [ 51423 ];
        settings = {
          PrintMotd = false;
          KbdInteractiveAuthentication = true;
          AuthenticationMethods = "publickey,keyboard-interactive:pam";
          # TODO: move these to global vars
          KexAlgorithms = config.programs.ssh.kexAlgorithms;
          Macs = config.programs.ssh.macs;
          Ciphers = config.programs.ssh.ciphers;
          HostKeyAlgorithms =
            builtins.concatStringsSep "," config.programs.ssh.hostKeyAlgorithms;
        };
      })
    ];
    # TODO
    systemd.services.sshd.serviceConfig =
      mkIf config.lonsdaleite.os.systemd.enable (systemd.def // systemd.usr);
  };
}
