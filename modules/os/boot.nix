{ lib, ... }:
let inherit (lib) mkForce;
in {
  # https://github.com/NiXium-org/NiXium/blob/central/src/nixos/modules/security/security.nix
  boot.loader.systemd-boot.editor = mkForce
    false; # Do not allow systemd-boot editor as it's set `true` by default for user convicience and can be used to inject root commands to the system

}
