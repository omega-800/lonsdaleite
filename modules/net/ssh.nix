{ config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.net.ssh;
  inherit (lib) mkIf mkMerge concatMapStrings mkOption;
  inherit (lib.types) listOf nonEmptyStr;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom;
in
{
  options.lonsdaleite.net.ssh = (mkEnableFrom [ "net" ] "hardens ssh client")
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

  # TODO: merge with sshd
  config = mkIf cfg.enable {
    environment = mkMerge [
      {
        etc."ssh/sshd_revoked_host_keys".text =
          builtins.concatStringsSep "\n" cfg.revoked-keys;
      }
      (mkIf config.lonsdaleite.fs.impermanence.enable {
        persistence."/nix/persist".directories = [
          "/etc/ssh/sshd_revoked_host_keys"
          "/etc/ssh/authorized_keys.d"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
        ];
      })
    ];
    programs.ssh = mkMerge [
      {
        enableAskPassword = false;
        askPassword = "";
        startAgent = false;
        agentTimeout = "${toString (60 - (cfg.paranoia * 30))}m";
        forwardX11 = false;
        setXAuthLocation = false;
        extraConfig = ''
          ForwardX11Trusted no
          ForwardX11Timeout 1s
          ForwardAgent no
          GSSAPIAuthentication no
          HostbasedAuthentication no
          StrictHostKeyChecking ${if cfg.paranoia == 2 then "yes" else "ask"}
          UpdateHostKeys ${if cfg.paranoia == 2 then "no" else "ask"}
          ChannelTimeout global=${toString (9 - (cfg.paranoia * 3))}m
          VerifyHostKeyDNS yes
          ClearAllForwardings yes
          Compression yes
          FingerprintHash sha256
          KbdInteractiveAuthentication no
          LogLevel VERBOSE
          NumberOfPasswordPrompts ${toString (3 - cfg.paranoia)}
          ObscureKeystrokeTiming yes
          #TODO: CASignatureAlgorithms
          RevokedHostKeys /etc/ssh/sshd_revoked_host_keys
          ServerAliveCountMax ${toString (3 - cfg.paranoia)}
          ServerAliveInterval ${toString (300 - (cfg.paranoia * 100))}
          TCPKeepAlive no
          PubkeyAuthentication yes
        '';
      }
      (mkIf (cfg.paranoia >= 1) {
        extraConfig = ''
          Tunnel no
          SendEnv
          SetEnv
          PasswordAuthentication no
          PermitLocalCommand no
          RequiredRSASize 2048
        '';
      })
      (mkIf (cfg.paranoia == 2) {
        extraConfig = ''
          Match host ${concatMapStrings (h: "!${h},") cfg.allow-hosts}*
            Hostname null
          AddKeysToAgent no
          AddressFamily inet
          CheckHostIP yes
          HashKnownHosts yes
          RekeyLimit 500M
          VisualHostKey yes
        '';
        kexAlgorithms = [
          "curve25519-sha256"
          "curve25519-sha256@libssh.org"
          "diffie-hellman-group16-sha512"
          "diffie-hellman-group18-sha512"
          "diffie-hellman-group-exchange-sha256"
          "sntrup761x25519-sha512@openssh.com"
        ];
        macs = [
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256-etm@openssh.com"
          "umac-128-etm@openssh.com"
        ];
        ciphers = [ "aes256-ctr" "aes192-ctr" "aes128-ctr" ];
        hostKeyAlgorithms = [ "ssh-ed25519" "rsa-sha2-512" "rsa-sha2-256" ];
        pubkeyAcceptedKeyTypes =
          [ "ssh-ed25519" "rsa-sha2-512" "rsa-sha2-256" ];
      })
    ];
  };
}
