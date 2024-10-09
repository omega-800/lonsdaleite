{
  lonsdaleite = {
    enable = true;
    paranoia = 2;
    trustedUser = "alice";
  };
  users.users.alice = {
    isNormalUser = true;
    initialPassword = "test";
    extraGroups = [ "wheel" ];
  };
  boot.loader.grub.devices = [ "/dev/sda" ];
  system.stateVersion = "24.05";
}
