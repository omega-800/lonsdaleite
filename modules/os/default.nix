{ lon-lib, ... }: {
  imports = [
    ./pam.nix
    ./random.nix
    ./tty.nix
    ./systemd.nix
    ./privilege.nix
    ./audit.nix
    ./antivirus.nix
    ./secureboot.nix
  ];
  options.lonsdaleite.os =
    lon-lib.mkEnableFrom [ ] "hardens general os components";
}
