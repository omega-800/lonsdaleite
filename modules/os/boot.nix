{ lib, ... }:
let inherit (lib) mkForce;
in {
  # TODO: https://theprivacyguide1.github.io/linux_hardening_guide#bootloaders
  # harden grub, syslinux and systemd-boot
  # https://github.com/NiXium-org/NiXium/blob/central/src/nixos/modules/security/security.nix
  boot = {
    # Do not allow systemd-boot editor as it's set `true` by default for user convicience and can be used to inject root commands to the system
    loader.systemd-boot.editor = mkForce false;

    # Netfilter's automatic conntrack helper assignment is dangerous as it enables a lot of code in the kernel that parses incoming network packets which is potentially unsafe. 
    # https://home.regit.org/netfilter-en/secure-use-of-helpers/
    extraModprobeConfig = ''
      options nf_conntrack nf_conntrack_helper=0 
    '';
    # TODO: attribute sources
    # https://madaidans-insecurities.github.io/guides/linux-hardening.html#boot-parameters
    # https://theprivacyguide1.github.io/linux_hardening_guide
    kernelParams = [
      # This disables slab merging, which significantly increases the difficulty of heap exploitation by preventing overwriting objects from merged caches and by making it harder to influence slab cache layout.
      "slab_nomerge"
      # enable sanity checks (F) and redzoning (Z). Sanity checks make sure that memory has been overwritten correctly. Redzoning adds extra areas around slabs that detect when a slab is overwritten past its real size, which can help detect overflows. 
      "slub_debug=FZ"
      # This zeroes memory during allocation and free time to prevent leaking secrets in memory and help mitigate use-after-free vulnerabilities.
      "init_on_alloc=1"
      "init_on_free=1"
      # This option randomises page allocator freelists, improving security by making page allocations less predictable. This also *improves* performance.
      "page_alloc.shuffle=1"
      # This causes the kernel to panic on uncorrectable errors in ECC memory which could be exploited. This is not needed for systems without ECC memory. 
      "mce=0"
      # This option randomises the kernel stack offset on each syscall, which makes attacks that rely on deterministic kernel stack layout significantly more difficult, such as the exploitation of CVE-2019-18683.
      "randomize_kstack_offset=on"
      # This enables Kernel Page Table Isolation which mitigates Meltdown and prevents some KASLR bypasses. 
      "pti=on"
      # This disables vsyscalls, as they are obsolete and have been replaced with vDSO. vsyscalls are also at fixed addresses in memory, making them a potential target for ROP attacks.
      "vsyscall=none"
      # This disables debugfs, which exposes a lot of sensitive information about the kernel.
      "debugfs=off"
      # enable all mitigations for the MDS vulnerability and disable SMT. This may have a significant performance decrease as it disables hyperthreading. 
      "mds=full,nosmt"
      # This only allows kernel modules signed with a valid key to be loaded. This prevents all out-of-tree kernel modules, including DKMS modules from being loaded unless you have signed them, meaning that modules such as the VirtualBox or Nvidia drivers may not be usable
      "module.sig_enforce=1"
      # The kernel lockdown LSM can eliminate many methods that user space code could abuse to escalate to kernel privileges and extract sensitive information. This LSM is necessary to implement a clear security boundary between user space and the kernel. 
      "lockdown=confidentiality"
      # This causes the kernel to panic on oopses. This prevents the kernel from continuing to run a flawed process which can be exploited. Sometimes, buggy drivers cause harmless oopses which will result in your system crashing so this boot parameter can only be used on certain hardware. 
      "oops=panic"

      # It is best to enable all CPU mitigations that are applicable to your CPU as to ensure that you are not affected by known vulnerabilities. This is a list that enables all built-in mitigations:
      # TODO: You must research the CPU vulnerabilities that your system is affected by and apply a selection of the above mitigations accordingly.
      "sectre_v2=on"
      "spec_store_bypass_disable=on"
      "tsx=off"
      "tsx_async_abort=full,nosmt"
      "mds=full,nosmt"
      "l1tf=full,force"
      "nosmt=force"
      "kvm.nx_huge_pages=force"

      # TODO: logging option
      # These parameters prevent information leaks during boot and must be used in combination with the kernel.printk sysctl 
      "quiet"
      "loglevel=0"

      # TODO: sync with sysctl
      "ipv6.disable=1"
      # TODO: research (should be default?)
      "systemd.restore_state=1"
      # TODO: make configurable
      "nousb"
      # TODO: set either of these to true depending on cpu
      # You should enable IOMMU in your BIOS and by these boot parameters to enforce isolation between devices. 
      "intel_iommu=on"
      "amd_iommu=on"
    ];
  };
}
