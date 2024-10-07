{ config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.net.ssh;
  inherit (lib) mkIf mkMerge mkDefault mkEnableOption;
  inherit (lonLib) mkEnableFrom mkParanoiaOption;
in
{
  options.lonsdaleite.net.ssh = (mkEnableFrom [ "net" ] "hardens ssh client")
    // {
    algorithms = mkParanoiaOption [ "" "" "enforces secure algorithms" ];
  };

  config = mkIf cfg.enable {
    programs.ssh = mkMerge [
      {
        enableAskPassword = false;
        askPassword = "";
        forwardX11 = false;
        setXAuthLocation = false;
        startAgent = false;
      }
      (mkIf (cfg.paranoia == 2) {
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
    environment.persistence =
      lib.mkIf config.lonsdaleite.fs.impermanence.enable {
        "/nix/persist".directories = [
          "/etc/ssh/authorized_keys.d"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
        ];
      };
  };
}
