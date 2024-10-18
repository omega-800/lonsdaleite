{ modulesPath, lib, pkgs, ... }: {
  imports = [ "${modulesPath}/virtualisation/qemu-vm.nix" ];
  lonsdaleite = {
    enable = false;
    paranoia = 2;
    trustedUser = "alice";
    os = {
      enable = false;
      privilege.enable = true;
      random.enable = true;
      pam.enable = true;
      tty.enable = true;
      antivirus.enable = true;
      systemd.enable = false;
      audit.enable = false;
      secureboot.enable = false;
    };
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
    # woah didn't realize qemu can do serial "forwarding"
    # openssh.settings.PasswordAuthentication = lib.mkForce true;
  };
  environment.systemPackages = with pkgs; [ lynis vulnix ];

  boot.loader.grub.devices = [ "/dev/sda" ];
  system.stateVersion = "24.05";
}
