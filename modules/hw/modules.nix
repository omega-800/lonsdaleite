{
  # SOURCE: https://raw.githubusercontent.com/Kicksecure/security-misc/refs/heads/master/etc/modprobe.d/30_security-misc_blacklist.conf

  ## Copyright (C) 2012 - 2024 ENCRYPTED SUPPORT LP <adrelanos@whonix.org>
  ## See the file COPYING for copying conditions.

  ## See the following links for a community discussion and overview regarding the selections.
  ## https://forums.whonix.org/t/blacklist-more-kernel-modules-to-reduce-attack-surface/7989
  ## https://madaidans-insecurities.github.io/guides/linux-hardening.html#kasr-kernel-modules

  ## Blacklisting prevents kernel modules from automatically starting.
  ## Disabling prohibits kernel modules from starting.

  ## CD-ROM/DVD:
  ## Blacklist CD-ROM and DVD modules.
  ## Do not disable by default for potential future ISO plans.
  ##
  ## https://nvd.nist.gov/vuln/detail/CVE-2018-11506
  ## https://forums.whonix.org/t/blacklist-more-kernel-modules-to-reduce-attack-surface/7989/31
  ##
  cd = { "1" = [ "cdrom" "sr_mod" ]; };
  ##
  #install cdrom /usr/bin/disabled-cdrom-by-security-misc
  #install sr_mod /usr/bin/disabled-cdrom-by-security-misc

  ## Miscellaneous:

  ## GrapheneOS:
  ## Partial selection of their infrastructure blacklist.
  ## Duplicate and already disabled modules have been omitted.
  ##
  ## https://github.com/GrapheneOS/infrastructure/blob/main/modprobe.d/local.conf
  ##
  misc = {
    "0" = [ "cfg80211" "intel_agp" "ip_tables" "joydev" "mousedev" "psmouse" ];
  };
  ## TODO: Re-check in Debian trixie
  ## In GrapheneOS list, yes, "should" be out-commented here.
  ## But not actually out-commented.
  ## Breaks VirtualBox audio device ICH AC97, which is unfortunately still required by some users.
  ## https://www.kicksecure.com/wiki/Dev/audio
  ## https://github.com/Kicksecure/security-misc/issues/271
  virt = { "1" = [ "snd_intel8x0" "tls" "virtio_balloon" "virtio_console" ]; };

  # blacklist the microphone module; however, this can differ from system to system. To find the name of the module, look in /proc/asound/modules and blacklist it. 
  sound = { "1" = [ "snd_hda_intel" ]; };

  ## Ubuntu:
  ## Already disabled modules have been omitted.
  ##
  ## https://git.launchpad.net/ubuntu/+source/kmod/tree/debian/modprobe.d/blacklist.conf?h=ubuntu/disco
  ## https://git.launchpad.net/ubuntu/+source/kmod/tree/debian/modprobe.d/blacklist-ath_pci.conf?h=ubuntu/disco
  ##
  ubuntu = {
    "1" = [
      "amd76x_edac"
      "ath_pci"
      "evbug"
      "pcspkr"
      "snd_aw2"
      "snd_intel8x0m"
      "snd_pcsp"
    ];
  };

  # SOURCE: https://raw.githubusercontent.com/Kicksecure/security-misc/refs/heads/master/etc/modprobe.d/30_security-misc_disable.conf

  ## Copyright (C) 2012 - 2024 ENCRYPTED SUPPORT LP <adrelanos@whonix.org>
  ## See the file COPYING for copying conditions.

  ## See the following links for a community discussion and overview regarding the selections.
  ## https://forums.whonix.org/t/blacklist-more-kernel-modules-to-reduce-attack-surface/7989
  ## https://madaidans-insecurities.github.io/guides/linux-hardening.html#kasr-kernel-modules

  ## Blacklisting prevents kernel modules from automatically starting.
  ## Disabling prohibits kernel modules from starting.

  ## This configuration file is split into 4 sections:
  ## 1. Hardware
  ## 2. File Systems
  ## 3. Networking
  ## 4. Miscellaneous

  ## 1. Hardware:

  ## Bluetooth:
  ## Disable Bluetooth to reduce attack surface due to extended history of security vulnerabilities.
  ##
  ## https://en.wikipedia.org/wiki/Bluetooth#History_of_security_concerns
  ##
  ## Now replaced by a privacy and security preserving default Bluetooth configuration for better usability.
  ## https://github.com/Kicksecure/security-misc/pull/145
  ##
  bluetooth = {
    "1" = [
      "bluetooth"
      "bluetooth_6lowpan"
      "bt3c_cs"
      "btbcm"
      "btintel"
      "btmrvl"
      "btmrvl_sdio"
      "btmtk"
      "btmtksdio"
      "btmtkuart"
      "btnxpuart"
      "btqca"
      "btrsi"
      "btrtl"
      "btsdio"
      "virtio_bt"
    ];
  };

  ## FireWire (IEEE 1394):
  ## Disable IEEE 1394 (FireWire/i.LINK/Lynx) modules to prevent some DMA attacks.
  ##
  ## https://en.wikipedia.org/wiki/IEEE_1394#Security_issues
  ##
  firewire = {
    "1" = [
      "dv1394"
      "firewire-core"
      "firewire-ohci"
      "firewire-net"
      "firewire-sbp2"
      "ohci1394"
      "raw1394"
      "sbp2"
      "video1394"
    ];
  };

  ## Global Positioning Systems (GPS):
  ## Disable GPS-related modules like GNSS (Global Navigation Satellite System).
  ##
  gps = {
    "1" = [
      "garmin_gps"
      "gnss"
      "gnss-mtk"
      "gnss-serial"
      "gnss-sirf"
      "gnss-ubx"
      "gnss-usb"
    ];
  };

  ## Intel Management Engine (ME):
  ## Partially disable the Intel ME interface with the OS.
  ## ME functionality has increasing become more intertwined with basic Intel system operation.
  ## Disabling may lead to breakages in numerous places without clear debugging/error messages.
  ## May cause issues with firmware updates, security, power management, display, and DRM.
  ##
  ## https://www.kernel.org/doc/html/latest/driver-api/mei/mei.html
  ## https://en.wikipedia.org/wiki/Intel_Management_Engine#Security_vulnerabilities
  ## https://www.kicksecure.com/wiki/Out-of-band_Management_Technology#Intel_ME_Disabling_Disadvantages
  ## https://github.com/Kicksecure/security-misc/pull/236#issuecomment-2229092813
  ## https://github.com/Kicksecure/security-misc/issues/239
  ##
  me = {
    "2" = [
      "mei"
      "mei-gsc"
      "mei_gsc_proxy"
      "mei_hdcp"
      "mei-me"
      "mei_phy"
      "mei_pxp"
      "mei-txe"
      "mei-vsc"
      "mei-vsc-hw"
      "mei_wdt"
      "microread_mei"
    ];
  };

  ## Intel Platform Monitoring Technology (PMT) Telemetry:
  ## Disable some functionality of the Intel PMT components.
  ##
  ## https://github.com/intel/Intel-PMT
  ##
  pmt = { "0" = [ "pmt_class" "pmt_crashlog" "pmt_telemetry" ]; };

  ## Thunderbolt:
  ## Disables Thunderbolt modules to prevent some DMA attacks.
  ##
  ## https://en.wikipedia.org/wiki/Thunderbolt_(interface)#Security_vulnerabilities
  ##
  thunderbolt = {
    "0" = [ "intel-wmi-thunderbolt" "thunderbolt" "thunderbolt_net" ];
  };

  ## 2. File Systems:

  ## File Systems:
  ## Disable uncommon file systems to reduce attack surface.
  ## HFS/HFS+ are legacy Apple file systems that may be required depending on the EFI partition format.
  ##
  fs = {
    "0" = [
      # already disabled by nixpkgs/nixos/modules/profiles/hardened.nix
      # "cramfs" "freevxfs" "hfs" "jfs" "adfs" "affs" "bfs" "befs" "efs" "erofs" "exofs" "f2fs" "hpfs" "minix" "nilfs2" "ntfs" "omfs" "qnx4" "qnx6" "sysv" "ufs"
      "hfsplus"
      "jffs2"
      # I dare you to look up the story on reiserfs, it's wild
      "reiserfs"
      "udf"
      "squashfs"
    ];
  };

  ## Network File Systems:
  ## Disable uncommon network file systems to reduce attack surface.
  ##
  uncommon = { "0" = [ "gfs2" "ksmbd" ]; };
  ##
  ## Common Internet File System (CIFS):
  ##
  cifs = { "0" = [ "cifs" "cifs_arc4" "cifs_md4" ]; };
  ##
  ## Network File System (NFS):
  ##
  nfs = {
    "0" = [
      "nfs"
      "nfs_acl"
      "nfs_layout_nfsv41_files"
      "nfs_layout_flexfiles"
      "nfsd"
      "nfsv2"
      "nfsv3"
      "nfsv4"
    ];
  };

  ## 2. Networking:

  ## Network Protocols:
  ## Disables rare and unneeded network protocols that are a common source of unknown vulnerabilities.
  ## Previously had blacklisted eepro100 and eth1394.
  ##
  ## https://tails.boum.org/blueprint/blacklist_modules/
  ## https://fedoraproject.org/wiki/Security_Features_Matrix#Blacklist_Rare_Protocols
  ## https://git.launchpad.net/ubuntu/+source/kmod/tree/debian/modprobe.d/blacklist-rare-network.conf?h=ubuntu/disco
  ## https://github.com/Kicksecure/security-misc/pull/234#issuecomment-2230732015
  ##
  protocols = {
    "2" = [ "brcm80211" ];
    "0" = [
      # already disabled by nixpkgs/nixos/modules/profiles/hardened.nix
      # "ax25" "netrom" "rose"
      "af_802154"
      "appletalk"
      "decnet"
      "dccp"
      "econet"
      "eepro100" # replaced by e100
      "eth1394"
      "ipx"
      "n-hdlc"
      "p8022"
      "p8023"
      "psnap"
      "x25"
      "llc"
    ];
  };
  ##
  ## Asynchronous Transfer Mode (ATM):
  ##
  atm = { "0" = [ "atm" "ueagle-atm" "usbatm" "xusbatm" ]; };
  ##
  ## Controller Area Network (CAN) Protocol:
  ##
  cam = {
    "0" = [
      "c_can"
      "c_can_pci"
      "c_can_platform"
      "can"
      "can-bcm"
      "can-dev"
      "can-gw"
      "can-isotp"
      "can-raw"
      "can-j1939"
      "can327"
      "ifi_canfd"
      "janz-ican3"
      "m_can"
      "m_can_pci"
      "m_can_platform"
      "phy-can-transceiver"
      "slcan"
      "ucan"
      "vxcan"
      "vcan"
    ];
  };
  ##
  ## Transparent Inter Process Communication (TIPC):
  ##
  tipc = { "0" = [ "tipc" "tipc_diag" ]; };
  ##
  ## Reliable Datagram Sockets (RDS):
  ##

  rds = { "0" = [ "rds" "rds_rdma" "rds_tcp" ]; };
  ##
  ## Stream Control Transmission Protocol (SCTP):
  ##
  sctp = { "0" = [ "sctp" "sctp_diag" ]; };

  ## 4. Miscellaneous:

  ## Amateur Radios:
  ##
  radio = { "0" = [ "hamradio" ]; };

  ## CPU Model-Specific Registers (MSRs):
  ## Disable CPU MSRs as they can be abused to write to arbitrary memory.
  ##
  ## https://security.stackexchange.com/questions/119712/methods-root-can-use-to-elevate-itself-to-kernel-mode
  ## https://github.com/Kicksecure/security-misc/issues/215
  ##
  msr = { "2" = [ "msr" ]; };

  ## Floppy Disks:
  ##
  floppy = { "0" = [ "floppy" ]; };

  ## Framebuffer (fbdev):
  ## Video drivers are known to be buggy, cause kernel panics, and are generally only used by legacy devices.
  ## These were all previously blacklisted.
  ##
  ## https://docs.kernel.org/fb/index.html
  ## https://en.wikipedia.org/wiki/Linux_framebuffer
  ## https://git.launchpad.net/ubuntu/+source/kmod/tree/debian/modprobe.d/blacklist-framebuffer.conf?h=ubuntu/disco
  ##
  fbdev = {
    "0" = [
      "aty128fb"
      "atyfb"
      "cirrusfb"
      "cyber2000fb"
      "cyblafb"
      "gx1fb"
      "hgafb"
      "i810fb"
      "intelfb"
      "kyrofb"
      "lxfb"
      "matroxfb_bases"
      "neofb"
      "nvidiafb"
      "pm2fb"
      "radeonfb"
      "rivafb"
      "s1d13xxxfb"
      "savagefb"
      "sisfb"
      "sstfb"
      "tdfxfb"
      "tridentfb"
      "vesafb"
      "vfb"
      "viafb"
      "vt8623fb"
      "udlfb"
    ];
  };

  ## Replaced Modules:
  ## These legacy drivers have all been entirely replaced and superseded by newer drivers.
  ## These were all previously blacklisted.
  ##
  ## https://git.launchpad.net/ubuntu/+source/kmod/tree/debian/modprobe.d/blacklist.conf?h=ubuntu/disco
  ##
  legacy = { "0" = [ "asus_acpi" "bcm43xx" "de4x5" "prism54" ]; };

  ## USB Video Device Class:
  ## Disables the USB-based video streaming driver for devices like some webcams and digital camcorders.
  ##
  uvcvideo = { "2" = [ "uvcvideo" ]; };

  ## Vivid:
  ## Disables the vivid kernel module since it has been the cause of multiple vulnerabilities.
  ##
  ## https://forums.whonix.org/t/kernel-recompilation-for-better-hardening/7598/233
  ## https://www.openwall.com/lists/oss-security/2019/11/02/1
  ## https://github.com/a13xp0p0v/kconfig-hardened-check/commit/981bd163fa19fccbc5ce5d4182e639d67e484475
  ##
  vivid = { "0" = [ "vivid" ]; };

  # SOURCE: nixosConfiguration.options.boot.blacklistedKernelModules.default
  def."0" = [ "i2c_piix4" ];

}
