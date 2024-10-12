{ sys, lib, ... }:
let cfg.TODO = "implement/merge with kernel";
in {
  config = lib.mkIf sys.hardened {
    boot.kernel.sysctl = {
      # TODO: attribute sources

      # Unprivileged userns has a large attack surface and has been the cause
      # of many privilege escalation vulnerabilities, but can cause breakage.
      "kernel.unprivileged_userns_clone" = "0";

      # Yama restricts ptrace, which allows processes to read and modify the
      # memory of other processes. This has obvious security implications.
      "kernel.yama.ptrace_scope" = if cfg.paranoia == 2 then "3" else "2";

      # Disables magic sysrq key. See overrides file regarding SAK (Secure
      # attention key).
      "kernel.sysrq" = "0";

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

      "net.ipv4.tcp_timestamps" = if cfg.paranoia == 2 then "0" else "1";

      "dev.tty.ldisc_autoload" = "0";
      "fs.protected_fifos" = "2";
      "fs.protected_regular" = "2";
      "fs.protected_hardlinks" = "1";
      "fs.protected_symlinks" = "1";
      "fs.suid_dumpable" = "0";
      "kernel.dmesg_restrict" = "1";
      "kernel.kexec_load_disabled" = "1";
      "kernel.kptr_restrict" = "2";
      "kernel.perf_event_paranoid" = "3";
      "kernel.printk" = "3 3 3 3";
      "kernel.unprivileged_bpf_disabled" = "1";
      "net.core.bpf_jit_harden" = "2";

      "net.ipv4.conf.all.accept_redirects" = "0";
      "net.ipv4.conf.all.accept_source_route" = "0";
      "net.ipv4.conf.all.rp_filter" = "1";
      "net.ipv4.conf.all.secure_redirects" = "0";
      "net.ipv4.conf.all.send_redirects" = "0";
      "net.ipv4.conf.default.accept_redirects" = "0";
      "net.ipv4.conf.default.accept_source_route" = "0";
      "net.ipv4.conf.default.rp_filter" = "1";
      "net.ipv4.conf.default.secure_redirects" = "0";
      "net.ipv4.conf.default.send_redirects" = "0";
      "net.ipv4.icmp_echo_ignore_all" = "1";
      "net.ipv6.icmp_echo_ignore_all" = "1";
      "net.ipv4.tcp_dsack" = "0";
      "net.ipv4.tcp_fack" = "0";
      "net.ipv4.tcp_rfc1337" = "1";
      "net.ipv4.tcp_sack" = "0";
      "net.ipv4.tcp_syncookies" = "1";
      "net.ipv6.conf.all.accept_ra" = "0";
      "net.ipv6.conf.all.accept_redirects" = "0";
      "net.ipv6.conf.all.accept_source_route" = "0";
      "net.ipv6.conf.default.accept_redirects" = "0";
      "net.ipv6.conf.default.accept_source_route" = "0";
      "net.ipv6.default.accept_ra" = "0";
      "kernel.core_pattern" = "|/bin/false";
      "vm.mmap_rnd_bits" = "32";
      "vm.mmap_rnd_compat_bits" = "16";
      "vm.unprivileged_userfaultfd" = "0";
      "net.ipv4.icmp_ignore_bogus_error_responses" = "1";

      # enable ASLR
      # turn on protection and randomize stack, vdso page and mmap + randomize brk base address
      "kernel.randomize_va_space" = "2";

      # restrict perf subsystem usage (activity) further
      "kernel.perf_cpu_time_max_percent" = "1";
      "kernel.perf_event_max_sample_rate" = "1";

      # do not allow mmap in lower addresses
      "vm.mmap_min_addr" = "65536";

      # log packets with impossible addresses to kernel log
      # No active security benefit, just makes it easier to spot a DDOS/DOS by giving
      # extra logs
      "net.ipv4.conf.default.log_martians" = "1";
      "net.ipv4.conf.all.log_martians" = "1";

      # disable sending and receiving of shared media redirects
      # this setting overwrites net.ipv4.conf.all.secure_redirects
      # refer to RFC1620
      "net.ipv4.conf.default.shared_media" = "0";
      "net.ipv4.conf.all.shared_media" = "0";

      # always use the best local address for announcing local IP via ARP
      # Seems to be most restrictive option
      "net.ipv4.conf.default.arp_announce" = "2";
      "net.ipv4.conf.all.arp_announce" = "2";

      # reply only if the target IP address is local address configured on the incoming interface
      "net.ipv4.conf.default.arp_ignore" = "1";
      "net.ipv4.conf.all.arp_ignore" = "1";

      # drop Gratuitous ARP frames to prevent ARP poisoning
      # this can cause issues when ARP proxies are used in the network
      "net.ipv4.conf.default.drop_gratuitous_arp" = "1";
      "net.ipv4.conf.all.drop_gratuitous_arp" = "1";

      # ignore all ICMP echo and timestamp requests sent to broadcast/multicast
      "net.ipv4.icmp_echo_ignore_broadcasts" = "1";

      # number of Router Solicitations to send until assuming no routers are present
      "net.ipv6.conf.default.router_solicitations" = "0";
      "net.ipv6.conf.all.router_solicitations" = "0";

      # do not accept Router Preference from RA
      "net.ipv6.conf.default.accept_ra_rtr_pref" = "0";
      "net.ipv6.conf.all.accept_ra_rtr_pref" = "0";

      # learn prefix information in router advertisement
      "net.ipv6.conf.default.accept_ra_pinfo" = "0";
      "net.ipv6.conf.all.accept_ra_pinfo" = "0";

      # setting controls whether the system will accept Hop Limit settings from a router advertisement
      "net.ipv6.conf.default.accept_ra_defrtr" = "0";
      "net.ipv6.conf.all.accept_ra_defrtr" = "0";

      # router advertisements can cause the system to assign a global unicast address to an interface
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
      # "net.ipv6.conf.default.use_tempaddr" = "2";
      # "net.ipv6.conf.all.use_tempaddr" = "2";

      # ignore all ICMPv6 echo requests
      "net.ipv6.icmp.echo_ignore_all" = "1";
      "net.ipv6.icmp.echo_ignore_anycast" = "1";
      "net.ipv6.icmp.echo_ignore_multicast" = "1";

      # TODO: attribute sources

      # Network
      "net.core.default_qdisc" = "fq";
      "net.core.bpf_jit_enable" = false;
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
      "kernel.ftrace_enabled" = false;
      "kernel.core_uses_pid" = "1";
      "kernel.pid_max" = "32768";
      "kernel.panic" = "20";
      "kernel.modules_disabled" = "1";

      # File System
      "fs.file-max" = "9223372036854775807";
      "fs.inotify.max_user_watches" = "524288";
    };
  };
}
