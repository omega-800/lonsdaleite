{ lon-lib, ... }:
{
  imports = [
    ./pam.nix
    ./users.nix
    ./boot.nix
    ./nixos.nix
    ./update.nix
    ./random.nix
    ./tty.nix
    ./systemd.nix
    ./privilege.nix
    ./audit.nix
    ./antivirus.nix
    ./secureboot.nix
  ];
  options.lonsdaleite.os = lon-lib.mkEnableFrom [ ] "hardens general os components";
}
