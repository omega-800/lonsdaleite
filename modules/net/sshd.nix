{ config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.net.sshd;
  inherit (lib) mkIf mkMerge mkDefault mkForce mkOption concatMapStrings;
  inherit (lib.types) listOf nonEmptyStr;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom;
  usr = config.lonsdaleite.trustedUser;
in
{
  options.lonsdaleite.net.sshd = (mkEnableFrom [ "net" ] "Hardens ssh daemon")
    // (mkParanoiaFrom [ "net" ] [ "" "" "enforces secure algorithms" ]) // {
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
    environment = mkMerge [
      {
        etc."ssh/sshd_revoked_keys".text =
          builtins.concatStringsSep "\n" cfg.revoked-keys;
      }
      (mkIf config.lonsdaleite.fs.impermanence.enable {
        persistence."/nix/persist".directories =
          [ "/etc/ssh/sshd_revoked_keys" ];
      })
    ];
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
          UseDns = false;
          UsePAM = mkDefault false;
          TCPKeepAlive = false;
          ClientAliveInterval = 300 - (cfg.paranoia * 100);
          ClientAliveCountMax = 3 - cfg.paranoia;
          MaxSessions = 3 - cfg.paranoia;
          MaxAuthTries = 4 - cfg.paranoia;
          PermitEmptyPasswords = false;
          PermitRootLogin = "no";
          RhostsAuthentication = false;
          RhostsRSAAuthentication = false;
          KbdInteractiveAuthentication = mkDefault false;
          HostbasedAuthentication = false;
          AllowTcpForwarding = false;
          AllowAgentForwarding = false;
          AllowStreamLocalForwarding = false;
          X11Forwarding = false;
          # unbind gnupg sockets if they exists
          StreamLocalBindUnlink = true;
          PermitUserEnvironment = false;
        };
        extraConfig =
          let t = toString (9 - (cfg.paranoia * 3));
          in ''
            ChannelTimeout global=${t}m
            # equals
            # ChannelTimeout x11-connection=${t}m tun-connection=${t}m session=${t}m agent-connection=${t}m direct-tcpip=${t}m direct-streamlocal@openssh.com=${t}m 
            UnusedConnectionTimeout ${t}m
            Protocol 2
            SetEnv
            DisableForwarding yes
            PermitTunnel no
            ExposeAuthInfo no
            FingerprintHash sha256
            GSSAPIAuthentication no
            KerberosAuthentication ${
              if config.lonsdaleite.net.kerberos.enable then "yes" else "no"
            }
            KerberosGetAFSToken no
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
          AcceptEnv
          RequiredRSASize 2048
        '';
        settings = mkMerge [
          {
            PasswordAuthentication = false;
            IgnoreRhosts = true;
            AuthenticationMethods = mkDefault "publickey";
          }
          (mkIf (usr != null) {
            AllowUsers = [ usr ];
            AllowGroups = [ (lonLib.userByName usr).group ];
          })
        ];
      })
      (mkIf (cfg.paranoia == 2) {
        extraConfig = ''
          AddressFamily inet
          PerminUserRC no
          PubkeyAuthOptions verify-required
          RekeyLimit 500M
          Match Address ${concatMapStrings (h: "!${h},") cfg.allow-hosts}*
            PubKeyAuthentication no
          #TODO: TrustedUserCAKeys CASignatureAlgorithms
        '';
        ports = [ 51423 ];
        allowSFTP = false;
        settings = {
          PrintMotd = false;
          UsePAM = true;
          KbdInteractiveAuthentication = true;
          AuthenticationMethods = "publickey,keyboard-interactive:pam";
          KexAlgorithms = config.programs.ssh.kexAlgorithms;
          Macs = config.programs.ssh.macs;
          Ciphers = config.programs.ssh.ciphers;
          HostKeyAlgorithms =
            builtins.concatStringsSep "," config.programs.ssh.hostKeyAlgorithms;
        };
      })
    ];
  };
}
