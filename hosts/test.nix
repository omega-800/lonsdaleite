{ modulesPath, pkgs, ... }:
{
  imports = [ "${modulesPath}/virtualisation/qemu-vm.nix" ];

  lonsdaleite = {
    enable = false;
  /*
    paranoia = 2;
    trustedUser = "alice";
    decapitated = false;
    os = {
      enable = false;
      antivirus.enable = true;
      audit.enable = false;
      boot.enable = false;
      nixos.enable = true;
      # pam.enable = true;
      privilege.enable = true;
      random.enable = true;
      # secureboot.enable = true;
      systemd = {
        enable = false;
        confineAll = {
          enable = false;
          fullUnit = false;
        };
      };
      tty.enable = false;
      update.enable = true;
      users.enable = false;
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
      kernel.enable = false;
      modules.enable = false;
    };
  */
  };
  users.users = {
    alice = {
      isNormalUser = true;
      initialPassword = "test";
      extraGroups = [ "wheel" ];
    };
    bob = {
      isNormalUser = true;
      initialPassword = "test";
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
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  environment.systemPackages = with pkgs; [
    lynis
    vulnix
    chipsec
    vim
  ];

  boot.loader.grub.devices = [ "/dev/sda" ];
  system.stateVersion = "24.05";
}
