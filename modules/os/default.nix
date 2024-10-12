{ lonLib, ... }: {
  imports = [
    ./pam.nix
    ./random.nix
    ./tty.nix
    ./systemd.nix
    ./privilege.nix
    ./audit.nix
    ./antivirus.nix
  ];
  options.lonsdaleite.os =
    lonLib.mkEnableFrom [ ] "hardens general os components";
}
