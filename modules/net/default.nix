{ lonLib, ... }: {
  imports = [
    ./ssh.nix
    ./sshd.nix
    ./kerberos.nix
    ./macchanger.nix
    ./firewall.nix
    ./misc.nix
    ./networkmanager.nix
  ];
  options.lonsdaleite.net = (lonLib.mkEnableFrom [ ] "hardens networking")
    // (lonLib.mkParanoiaFrom [ ] [ ]);
}
