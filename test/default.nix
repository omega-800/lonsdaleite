{ modulesPath, lib, ... }: {
  imports = [ "${modulesPath}/virtualisation/qemu-vm.nix" ];
  lonsdaleite = {
    enable = false;
    paranoia = 2;
    trustedUser = "alice";
    net.enable = true;
  };
  users.users = {
    alice = {
      isNormalUser = true;
      initialPassword = "test";
      extraGroups = [ "wheel" ];
    };
    root.initialPassword = "test";
  };
  services = {
    # gitlab = {
    #   enable = true;
    #   initialRootPasswordFile = ./secret;
    #   secrets = {
    #     secretFile = ./secret;
    #     dbFile = ./secret;
    #     otpFile = ./secret;
    #     jwsFile = ./secret;
    #   };
    # };
    # grafana.enable = true;
    # so that i can one log in to a headless vm
    openssh.settings.PasswordAuthentication = lib.mkForce true;
  };

  boot.loader.grub.devices = [ "/dev/sda" ];
  system.stateVersion = "24.05";
}
