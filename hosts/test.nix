{ modulesPath, lib, pkgs, ... }: {
  imports = [ "${modulesPath}/virtualisation/qemu-vm.nix" ];

  lonsdaleite = {
    enable = false;
    paranoia = 2;
    trustedUser = "alice";
    decapitated = false;
    os = {
      enable = false;
      # privilege.enable = true;
      random.enable = true;
      # pam.enable = true;
      tty.enable = true;
      antivirus.enable = true;
      systemd.enable = true;
      # TODO
      audit.enable = false;
      secureboot.enable = false;
    };
    net = {
      ssh.enable = true;
      sshd.enable = true;
      firewall.enable = true;
      macchanger.enable = true;
      networkmanager.enable = true;
      misc.enable = true;
    };
    # sw = { apparmor.enable = true; };
    hw = {
      enable = false;
      # kernel.enable = true;
      modules.enable = true;
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
  environment.systemPackages = with pkgs; [ lynis vulnix vim ];

  boot.loader.grub.devices = [ "/dev/sda" ];
  system.stateVersion = "24.05";
}
