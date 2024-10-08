{
  lonsdaleite = {
    enable = true;
    paranoia = 2;
  };
  system.stateVersion = "24.05";
  boot.loader.grub.devices = [ "/dev/sda" ];
}
