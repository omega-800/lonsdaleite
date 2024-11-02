{ lib, lon-lib, ... }:
let
  cfg = {
    enable = false;
    TODO = "implement/merge with kernel";
  };
  inherit (lib) mkIf;
  inherit (lon-lib) mkLowerForce;
in
{
  config = mkIf cfg.enable {
    boot.kernel.sysctl = {
      # TODO: attribute sources
      # https://theprivacyguide1.github.io/linux_hardening_guide
      # https://github.com/cynicsketch/nix-mineral
      # https://madaidans-insecurities.github.io/guides/linux-hardening.html
      # grapheneos

      # Unprivileged userns has a large attack surface and has been the cause
      # of many privilege escalation vulnerabilities, but can cause breakage.
      # This may break some sandboxing programs such as bubblewrap. These can 
      # be fixed by making the sandbox binaries setuid. 
      # already set by nixpkgs/nixos/modules/profiles/hardened.nix
      # "kernel.unprivileged_userns_clone" = "0";
      # You can alternatively disable user namespaces completely (including for 
      # root) by setting 
      # "user.max_user_namespaces" = "0";

      # Disables magic sysrq key (0) or makes it so that a user can only use 
      # the secure attention key (4), 
      "kernel.sysrq" = if cfg.paranoia == 0 then "4" else "0";

      # Disable binfmt. Breaks Roseta, see overrides file.
      "fs.binfmt_misc.status" = "0";

      # Disable io_uring. May be desired for Proxmox, but is responsible
      # for many vulnerabilities and is disabled on Android + ChromeOS.
      "kernel.io_uring_disabled" = if cfg.paranoia == 2 then "2" else "1";

      # Disable ip forwarding to reduce attack surface. May be needed for
      # VM networking. See overrides file.
      "net.ipv4.ip_forward" = "0";
      "net.ipv4.conf.all.forwarding" = "0";
      "net.ipv4.conf.default.forwarding" = "0";
      "net.ipv6.conf.all.forwarding" = "0";
      "net.ipv6.conf.default.forwarding" = "0";

      # This disables kexec which can be used to replace the running kernel. 
      # nixpkgs hardened profile sets this already through 
      # security.protectKernelImage
      # "kernel.kexec_load_disabled" = "1";

      # This makes it so that only root can use the BPF JIT compiler and to 
      # harden it. A JIT compiler opens up the possibility for an attacker to 
      # exploit many vulnerabilities such as JIT spraying. 
      "kernel.unprivileged_bpf_disabled" = "1";
      "net.core.bpf_jit_harden" = "2";
      # nixpkgs hardened profile sets this already
      # "net.core.bpf_jit_enable" = false;

      # This setting attempts to prevent any kernel pointer leaks via various 
      # methods (such as in /proc/kallsyms or dmesg). nixpkgs hardened profile
      # sets this to 2
      # 1 = users with CAP_SYSLOG, 2 = nobody can see them
      "kernel.kptr_restrict" =
        mkLowerForce (if cfg.paranoia == 0 then "1" else "2");

      # Disables ftrace debugging. nixpkgs hardened profile sets this already
      # "kernel.ftrace_enabled" = false;

      # This blocks users other than root from being able to see the kernel 
      # logs. 

      "kernel.dmesg_restrict" = "1";
      # Despite the value of dmesg_restrict, the kernel log will still be 
      # displayed in the console during boot. This option prevents those 
      # information leaks. 
      "kernel.printk" = "3 3 3 3";

      # TCP timestamps also leak the system time. The kernel attempted to fix this by using a random offset for each connection, but this is not enough to fix the issue. Thus, TCP timestamps should be disabled. This can be done by setting the following with sysctl:
      "net.ipv4.tcp_timestamps" = if cfg.paranoia == 2 then "0" else "1";

      # These disable ICMP redirect acceptance. If these settings are not set 
      # then an attacker can redirect an ICMP request to anywhere they want. 
      # (man-in-the-middle attacks). nixpkgs hardened profile sets this already
      # "net.ipv6.conf.all.accept_redirects" = "0";
      # "net.ipv6.conf.default.accept_redirects" = "0";
      # "net.ipv4.conf.all.accept_redirects" = "0";
      # "net.ipv4.conf.default.accept_redirects" = "0";
      # "net.ipv4.conf.all.secure_redirects" = "0";
      # "net.ipv4.conf.default.secure_redirects" = "0";

      # These disable ICMP redirect sending when on a non-router. 
      # nixpkgs hardened profile sets this already
      # "net.ipv4.conf.all.send_redirects" = "0";
      # "net.ipv4.conf.default.send_redirects" = "0";

      # Ignore all ICMP requests to avoid smurf attacks, make the device more 
      # difficult to enumerate on the network and prevent clock fingerprinting 
      # through ICMP timestamps.
      "net.ipv4.icmp_echo_ignore_all" = "1";
      "net.ipv6.icmp_echo_ignore_all" = "1";
      # Source routing is a mechanism that allows users to redirect network 
      # traffic. As this can be used to perform man-in-the-middle attacks in 
      # which the traffic is redirected for nefarious purposes, the above 
      # settings disable this functionality.
      "net.ipv4.conf.all.accept_source_route" = "0";
      "net.ipv4.conf.default.accept_source_route" = "0";
      "net.ipv6.conf.all.accept_source_route" = "0";
      "net.ipv6.conf.default.accept_source_route" = "0";

      # These enable source validation of packets received from all interfaces 
      # of the machine. This protects against IP spoofing methods in which an 
      # attacker can send a packet with a fake IP address. 
      # nixpkgs hardened profile sets this already
      # "net.ipv4.conf.default.rp_filter" = "1";
      # "net.ipv4.conf.all.rp_filter" = "1";

      # This helps protect against SYN flood attacks which is a form of denial 
      # of service attack where an attacker sends a lot of SYN requests in an 
      # attempt to consume enough resources to make the system unresponsive to 
      # legitimate traffic.  
      "net.ipv4.tcp_syncookies" = "1";
      # This protects against time-wait assassination. It drops RST packets for 
      # sockets in the time-wait state. 
      "net.ipv4.tcp_rfc1337" = "1";

      # This disables TCP SACK. SACK is commonly exploited and not needed for 
      # many circumstances so it should be disabled if you don't need it. To 
      # learn if SACK is needed for you or not, see 
      # https://serverfault.com/questions/10955/when-to-turn-tcp-sack-off.  
      # https://datatracker.ietf.org/doc/html/rfc2018
      "net.ipv4.tcp_sack" = "0";
      "net.ipv4.tcp_dsack" = "0";
      "net.ipv4.tcp_fack" = "0";

      # log packets with impossible addresses to kernel log
      # No active security benefit, just makes it easier to spot a DDOS/DOS by 
      # giving extra logs. nixpkgs hardened profile sets this already
      # "net.ipv4.conf.all.log_martians" = "1";
      # "net.ipv4.conf.default.log_martians" = "1";

      # disable sending and receiving of shared media redirects
      # this setting overwrites net.ipv4.conf.all.secure_redirects
      # refer to RFC1620
      "net.ipv4.conf.default.shared_media" = "0";
      "net.ipv4.conf.all.shared_media" = "0";

      # always use the best local address for announcing local IP via ARP
      # Seems to be most restrictive option
      "net.ipv4.conf.default.arp_announce" = "2";
      "net.ipv4.conf.all.arp_announce" = "2";

      # reply only if the target IP address is local address configured on the 
      # incoming interface
      "net.ipv4.conf.default.arp_ignore" = "1";
      "net.ipv4.conf.all.arp_ignore" = "1";

      # drop Gratuitous ARP frames to prevent ARP poisoning
      # this can cause issues when ARP proxies are used in the network
      "net.ipv4.conf.default.drop_gratuitous_arp" = "1";
      "net.ipv4.conf.all.drop_gratuitous_arp" = "1";

      # ignore all ICMP echo and timestamp requests sent to broadcast/multicast
      # nixpkgs hardened profile sets this already
      # "net.ipv4.icmp_echo_ignore_broadcasts" = "1";

      # number of Router Solicitations to send until assuming no routers are present
      "net.ipv6.conf.default.router_solicitations" = "0";
      "net.ipv6.conf.all.router_solicitations" = "0";

      # Malicious IPv6 router advertisements can result in a man-in-the-middle 
      # attack, so they should be disabled.
      "net.ipv6.conf.all.accept_ra" = "0";
      "net.ipv6.default.accept_ra" = "0";

      # do not accept Router Preference from RA
      "net.ipv6.conf.default.accept_ra_rtr_pref" = "0";
      "net.ipv6.conf.all.accept_ra_rtr_pref" = "0";

      # learn prefix information in router advertisement
      "net.ipv6.conf.default.accept_ra_pinfo" = "0";
      "net.ipv6.conf.all.accept_ra_pinfo" = "0";

      # setting controls whether the system will accept Hop Limit settings from 
      # a router advertisement
      "net.ipv6.conf.default.accept_ra_defrtr" = "0";
      "net.ipv6.conf.all.accept_ra_defrtr" = "0";

      # router advertisements can cause the system to assign a global unicast 
      # address to an interface
      "net.ipv6.conf.default.autoconf" = "0";
      "net.ipv6.conf.all.autoconf" = "0";

      # number of neighbor solicitations to send out per address
      "net.ipv6.conf.default.dad_transmits" = "0";
      "net.ipv6.conf.all.dad_transmits" = "0";

      # number of global unicast IPv6 addresses can be assigned to each interface
      "net.ipv6.conf.default.max_addresses" = "1";
      "net.ipv6.conf.all.max_addresses" = "1";

      # enable IPv6 Privacy Extensions (RFC3041) and prefer the temporary address
      # https://grapheneos.org/features#wifi-privacy
      # GrapheneOS devs seem to believe it is relevant to use IPV6 privacy
      # extensions alongside MAC randomization, so that's why we do both
      # Commented, as this is already explicitly defined by default in NixOS
      # (in option networking.tempAddresses)
      # "net.ipv6.conf.default.use_tempaddr" = "2";
      # "net.ipv6.conf.all.use_tempaddr" = "2";

      # ignore all ICMPv6 echo requests
      "net.ipv6.icmp.echo_ignore_all" = "1";
      "net.ipv6.icmp.echo_ignore_anycast" = "1";
      "net.ipv6.icmp.echo_ignore_multicast" = "1";

      # Yama restricts ptrace, which allows processes to read and modify the
      # memory of other processes. This has obvious security implications.
      "kernel.yama.ptrace_scope" = if cfg.paranoia == 2 then "3" else "2";

      # These settings are set to the highest value to improve ASLR effectiveness 
      # for mmap. 
      # https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1040995.html
      # FIXME: The values of these sysctls must be set in relation to the CPU architecture. The above values are compatible with x86, but other architectures may differ.
      "vm.mmap_rnd_bits" = "32";
      "vm.mmap_rnd_compat_bits" = "16";

      # do not allow mmap in lower addresses
      "vm.mmap_min_addr" = "65536";

      # enable ASLR
      # turn on protection and randomize stack, vdso page and mmap + randomize 
      # brk base address
      "kernel.randomize_va_space" = "2";

      # restrict perf subsystem usage (activity) further
      "kernel.perf_cpu_time_max_percent" = "1";
      "kernel.perf_event_max_sample_rate" = "1";

      # Core dumps contain the recorded state of the working memory of a program at a specific time, usually when that program has crashed. These can contain very important information such as passwords and encryption keys. 
      # With sysctl, systemd and ulimit. The sysctl way may not properly disable core dumps as systemd overrides it. 
      "kernel.core_pattern" = "|/bin/false";
      # Process that run with elevated privileges (setuid) may still dump their memory even after these settings. To prevent them from doing this:
      "fs.suid_dumpable" = "0";
      # Similar to core dumps, swapping or paging copies parts of memory to disk, which can contain sensitive information. The kernel should be configured to only swap if absolutely necessary with this sysctl:
      "vm.swappiness" = "1";

      # This restricts loading TTY line disciplines to the CAP_SYS_MODULE 
      # capability to prevent unprivileged attackers from loading vulnerable 
      # line disciplines with the TIOCSETD ioctl
      "dev.tty.ldisc_autoload" = "0";

      # The userfaultfd() syscall is often abused to exploit use-after-free 
      # flaws. Due to this, this sysctl is used to restrict this syscall to 
      # the CAP_SYS_PTRACE capability.
      "vm.unprivileged_userfaultfd" = "0";

      # This restricts all usage of performance events to the CAP_PERFMON 
      # capability (CAP_SYS_ADMIN on kernel versions prior to 5.8).
      "kernel.perf_event_paranoid" = "3";

      # These prevent creating files in potentially attacker-controlled environments, such as world-writable directories, to make data spoofing attacks more difficult.
      "fs.protected_fifos" = "2";
      "fs.protected_regular" = "2";

      # This only permits symlinks to be followed when outside of a world-writable sticky directory, when the owner of the symlink and follower match or when the directory owner matches the symlink's owner. This also prevents hardlinks from being created by users that do not have read/write access to the source file. Both of these prevent many common TOCTOU races.
      "fs.protected_hardlinks" = "1";
      "fs.protected_symlinks" = "1";

      # disables loading of new modules
      # https://github.com/Kicksecure/security-misc/blob/3af2684134279ba6f5b18b40986f02a50baa5604/usr/libexec/security-misc/disable-kernel-module-loading
      "kernel.modules_disabled" = "1";

      # FIXME: only if hardened_malloc == true
      # https://madaidans-insecurities.github.io/guides/linux-hardening.html#hardened-malloc
      # You should also set the following with sysctl to accommodate the large number of guard pages created by hardened_malloc:
      "vm.max_map_count" = 1048576;

      # TODO: attribute sources

      # Network
      "net.core.default_qdisc" = "fq";
      "net.core.netdev_max_backlog" = "250000";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_synack_retries" = "5";
      "net.ipv4.ip_local_port_range" = "1024 65535";
      "net.ipv4.tcp_adv_win_scale" = "1";
      "net.ipv4.tcp_mtu_probing" = "1";
      "net.ipv4.tcp_base_mss" = "1024";
      "net.ipv4.tcp_rmem" = "4096 87380 8388608";
      "net.ipv4.tcp_wmem" = "4096 87380 8388608";
      "net.ipv4.tcp_window_scaling" = "0";

      # IPv6
      "net.ipv6.conf.all.disable_ipv6" = "0";
      "net.ipv6.conf.default.disable_ipv6" = "0";
      "net.ipv6.conf.lo.disable_ipv6" = "0";

      # Kernel
      "kernel.core_uses_pid" = "1";
      "kernel.pid_max" = "32768";
      "kernel.panic" = "20";

      # File System
      "fs.file-max" = "9223372036854775807";
      "fs.inotify.max_user_watches" = "524288";

      "net.ipv4.icmp_ignore_bogus_error_responses" = "1";
    };
  };
}
