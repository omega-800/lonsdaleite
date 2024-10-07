{
  config = {
    lonsdaleite.enable = true;
    system.stateVersion = "24.05";
    boot.loader.grub.devices = [ "/dev/sda" ];
  };
}
