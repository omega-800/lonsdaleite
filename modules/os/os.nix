{ lib, config, ... }: {
  # override nixos/modules/profiles/hardened
  nix.settings.allowed-users = lib.mkForce [ config.lonsdaleite.trustedUser ];
}
