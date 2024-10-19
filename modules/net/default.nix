{ lon-lib, ... }: {
  imports = [
    ./ssh.nix
    ./sshd.nix
    ./kerberos.nix
    ./macchanger.nix
    ./firewall.nix
    ./misc.nix
    ./networkmanager.nix
  ];
  options.lonsdaleite.net = (lon-lib.mkEnableFrom [ ] "hardens networking")
    // (lon-lib.mkParanoiaFrom [ ] [ ]);
}
