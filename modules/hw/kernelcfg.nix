{ pkgs, version }:
let
  inherit (pkgs) lib stdenv;
  inherit (lib) optionalAttrs mkForce;
  inherit (lib.kernel)
    yes
    no
    module
    unset
    freeform
    ;
  inherit (lib.kernel.whenHelpers version) whenAtLeast whenOlder whenBetween;
  inherit (stdenv.hostPlatform)
    isAarch
    isAarch64
    isAarch32
    isx86
    isx86_64
    isx86_32
    ;
in
# TODO: does common-config.nix always get merged with custom ones? if not, prepend those configs
  # TODO: merge some of these options with sysctl or make them configurable
  # but i'd rather have them defined here than in sysctl. runtime makes me scared
{
  # https://wiki.gentoo.org/wiki/Dm-crypt#Kernel_Configuration
  # Filesystem Hardening (Block Level Encryption via dm-crypt) – Requires userspace support
  DM_CRYPT = module; # 2.6.4-2.6.39, 3.0-3.19, 4.0-4.20, 5.0-5.17
  # https://tldp.org/HOWTO/Security-HOWTO/kernel-security.html#AEN735
  # This option should be on if you intend to run any firewalling or masquerading
  FIREWALL = yes;
  # If enabled, this adds USB networking subsystem support to the kernel
  USB_USBNET = unset;
  # Report BUG() conditions and kill the offending process.
  BUG = yes;
  # Make sure kernel page tables have safe permissions.
  DEBUG_KERNEL = whenOlder "4.11" yes;
  DEBUG_RODATA = whenOlder "4.11" yes;
  STRICT_KERNEL_RWX = whenAtLeast "4.11" yes;
  # Report any dangerous memory permissions (not available on all archs).
  DEBUG_WX = yes;
  # Use -fstack-protector-strong (gcc 4.9+) for best stack canary coverage.
  STACKPROTECTOR = whenAtLeast "4.18" yes;
  STACKPROTECTOR_STRONG = whenAtLeast "4.18" yes;
  CC_STACKPROTECTOR = whenOlder "4.18" yes;
  CC_STACKPROTECTOR_STRONG = whenOlder "4.18" yes;
  # FIXME: research, look into hardenedConfig
  # Do not allow direct physical memory access (but if you must have it, at least enable STRICT mode...)
  DEVMEM = mkForce unset;
  STRICT_DEVMEM = mkForce yes;
  IO_STRICT_DEVMEM = mkForce yes;
  # Provides some protections against SYN flooding.
  SYN_COOKIES = yes;
  # Perform additional validation of various commonly targeted structures.
  LIST_HARDENED = yes;
  DEBUG_CREDENTIALS = yes;
  DEBUG_NOTIFIERS = yes;
  DEBUG_LIST = yes;
  DEBUG_SG = yes;
  DEBUG_VIRTUAL = yes;
  BUG_ON_DATA_CORRUPTION = yes;
  SCHED_STACK_END_CHECK = yes;
  # Provide userspace with seccomp BPF API for syscall attack surface reduction.
  SECCOMP = yes;
  SECCOMP_FILTER = yes;
  # Make sure line disciplines can't be autoloaded 
  LDISC_AUTOLOAD = whenAtLeast "5.1" unset;
  # Provide userspace with ptrace ancestry protections. Make sure that "yama" is also present in the "CONFIG_LSM = yes;ama,..." list.
  SECURITY = yes;
  SECURITY_YAMA = yes;
  # Provide userspace with Landlock MAC interface. Make sure that "landlock" is also present in the "CONFIG_LSM=landlock,..." list.
  SECURITY_LANDLOCK = yes;
  # Make sure SELinux cannot be disabled trivially.
  SECURITY_SELINUX_BOOTPARAM = unset;
  SECURITY_SELINUX_DEVELOP = unset;
  SECURITY_SELINUX_DEBUG = unset;
  # already set in hardenedConfig
  # SECURITY_WRITABLE_HOOKS = unset;
  # Enable "lockdown" LSM for bright line between the root user and kernel memory.
  SECURITY_LOCKDOWN_LSM = mkForce yes;
  SECURITY_LOCKDOWN_LSM_EARLY = yes;
  LOCK_DOWN_KERNEL_FORCE_CONFIDENTIALITY = yes;
  # Perform usercopy bounds checking. (And disable fallback to gain full whitelist enforcement.)
  HARDENED_USERCOPY = yes;
  HARDENED_USERCOPY_FALLBACK = unset;
  HARDENED_USERCOPY_PAGESPAN = unset;
  # Randomize allocator freelists, harden metadata.
  SLAB_FREELIST_RANDOM = yes;
  SLAB_FREELIST_HARDENED = yes;
  RANDOM_KMALLOC_CACHES = yes;
  # Make cross-slab heap attacks not as trivial when object sizes are the same. (Same as slab_nomerge boot param.)
  SLAB_MERGE_DEFAULT = unset;
  # Allow for randomization of high-order page allocation freelist. Must be enabled with the "page_alloc.shuffle=1" command line below).
  SHUFFLE_PAGE_ALLOCATOR = yes;
  # Sanity check userspace page table mappings 
  PAGE_TABLE_CHECK = whenAtLeast "5.17" yes;
  PAGE_TABLE_CHECK_ENFORCED = whenAtLeast "5.17" yes;
  # Allow allocator validation checking to be enabled (see "slub_debug=P" below).
  SLUB_DEBUG = yes;
  # Wipe higher-level memory allocations when they are freed (needs "page_poison=1" command line below). This kernel feature was removed in v5.11. Starting from v5.11 CONFIG_PAGE_POISONING unconditionally checks the 0xAA poison pattern on allocation.
  PAGE_POISONING_ZERO = whenOlder "5.11" yes;
  # Wipe slab and page allocations. Instead of "slub_debug=P" and "page_poison=1", a single place can control memory allocation wiping now.
  INIT_ON_ALLOC_DEFAULT_ON = whenAtLeast "5.3" yes;
  # Wipe slab and page allocations. The init_on_free is only needed if there is concern about minimizing stale data lifetime.
  INIT_ON_FREE_DEFAULT_ON = whenAtLeast "5.3" yes;
  # Initialize all stack variables on function entry. (Clang and GCC 12+ builds only. For earlier GCC, see CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL = yes; below)
  INIT_STACK_ALL_ZERO = yes;
  # Adds guard pages to kernel stacks (not all architectures support this yet).
  VMAP_STACK = yes;
  # Perform extensive checks on reference counting.
  REFCOUNT_FULL = yes;
  # Check for memory copies that might overflow a structure in str*() and mem*() functions both at build-time and run-time.
  FORTIFY_SOURCE = yes;
  # Avoid kernel memory address exposures via dmesg (sets sysctl kernel.dmesg_restrict initial value to 1)
  SECURITY_DMESG_RESTRICT = yes;
  # Enable trapping bounds checking of array indexes. All the other UBSAN checks should be disabled.
  UBSAN = whenAtLeast "5.11" yes;
  UBSAN_TRAP = whenAtLeast "5.11" yes;
  UBSAN_BOUNDS = whenAtLeast "5.11" yes;
  UBSAN_SANITIZE_ALL = whenAtLeast "5.11" yes;
  UBSAN_SHIFT = whenAtLeast "5.11" unset;
  UBSAN_DIV_ZERO = whenAtLeast "5.11" unset;
  UBSAN_UNREACHABLE = whenAtLeast "5.11" unset;
  UBSAN_SIGNED_WRAP = whenAtLeast "5.11" unset;
  UBSAN_BOOL = whenAtLeast "5.11" unset;
  UBSAN_ENUM = whenAtLeast "5.11" unset;
  UBSAN_ALIGNMENT = whenAtLeast "5.11" unset;
  # This is only available on Clang builds, and is likely already enabled if CONFIG_UBSAN_BOUNDS = yes; is set:
  UBSAN_LOCAL_BOUNDS = yes;
  # Enable sampling-based overflow detection (since v5.12). This is similar to KASAN coverage, but with almost zero runtime overhead.
  KFENCE = whenAtLeast "5.12" yes;
  KFENCE_SAMPLE_INTERVAL = whenAtLeast "5.12" (freeform "100");
  # Randomize kernel stack offset on syscall entry (since v5.13).
  RANDOMIZE_KSTACK_OFFSET_DEFAULT = whenAtLeast "5.13" yes;
  # Do not ignore compile-time warnings (since v5.15)
  WERROR = mkForce (whenAtLeast "5.15" yes);
  # Disable DMA between EFI hand-off and the kernel's IOMMU setup.
  EFI_DISABLE_PCI_DMA = yes;
  # Force IOMMU TLB invalidation so devices will never be able to access stale data contents (or set "iommu.passthrough=0 iommu.strict=1" at boot)
  IOMMU_SUPPORT = yes;
  IOMMU_DEFAULT_DMA_STRICT = yes;
  IOMMU_DEFAULT_PASSTHROUGH = unset;
  # Enable feeding RNG entropy from TPM, if available.
  HW_RANDOM_TPM = yes;
  # Get as much entropy as possible from external sources. The Chacha mixer isn't vulnerable to injected entropy, so even malicious sources should not cause problems.
  RANDOM_TRUST_BOOTLOADER = yes;
  RANDOM_TRUST_CPU = yes;
  # Randomize the layout of system structures. This may have dramatic performance impact, so use with caution. If using GCC, you can check if using CONFIG_RANDSTRUCT_PERFORMANCE = yes; is better.
  RANDSTRUCT_FULL = yes;
  # Make scheduler aware of SMT Cores. Program needs to opt-in to using this feature with prctl(PR_SCHED_CORE).
  SCHED_CORE = yes;
  # Wipe all caller-used registers on exit from the function (reduces available ROP gadgets and minimizes stale data in registers). 
  ZERO_CALL_USED_REGS = whenAtLeast "5.15" yes;
  # Wipe RAM at reboot via EFI. For more details, see: https://trustedcomputinggroup.org/resource/pc-client-work-group-platform-reset-attack-mitigation-specification/ https://bugzilla.redhat.com/show_bug.cgi?id=1532058
  RESET_ATTACK_MITIGATION = yes;
  # This needs userspace support, and will break "regular" distros. See: https://github.com/tych0/huldufolk
  STATIC_USERMODEHELPER = yes;

  # Dangerous; enabling this allows direct physical memory writing.
  # already defined in hardenedConfig
  # ACPI_CUSTOM_METHOD = unset;

  # Dangerous; enabling this disables brk ASLR.
  COMPAT_BRK = unset;
  # Dangerous; enabling this allows direct kernel memory writing.
  DEVKMEM = unset;

  # Dangerous; exposes kernel text image layout.
  # already set in hardenedConfig
  # PROC_KCORE = unset;

  # Dangerous; enabling this allows replacement of running kernel.
  KEXEC = unset;
  # Dangerous; enabling this allows replacement of running kernel.
  HIBERNATION = unset;

  # Prior to v4.1, assists heap memory attacks; best to keep interface disabled.
  # already set in hardenedConfig
  # INET_DIAG = unset;

  # Easily confused by misconfigured userspace, keep off.
  # already set in commonConfig
  BINFMT_MISC = mkForce unset;
  # Use the modern PTY interface (devpts) only.
  LEGACY_PTYS = unset;
  # Block TTY stuffing attacks (this will break screen readers, see "dev.tty.legacy_tiocsti" sysctl).
  LEGACY_TIOCSTI = unset;
  # If SELinux can be disabled at runtime, the LSM structures cannot be read-only; keep off.
  SECURITY_SELINUX_DISABLE = unset;
  # Reboot devices immediately if kernel experiences an Oops.
  PANIC_ON_OOPS = yes;
  PANIC_TIMEOUT = freeform "-1";
  # FIXME: 
  # Limit sysrq to sync,unmount,reboot. For more details see the sysrq bit field table: https://docs.kernel.org/admin-guide/sysrq.html
  MAGIC_SYSRQ_DEFAULT_ENABLE = freeform "176";
  # Keep root from altering kernel memory via loadable modules.
  MODULES = unset;
  # But if CONFIG_MODULE = yes; is needed, at least they must be signed with a per-build key. See also kernel.modules_disabled sysctl.
  DEBUG_SET_MODULE_RONX = whenOlder "4.11" yes;
  STRICT_MODULE_RWX = whenAtLeast "4.11" yes;
  MODULE_SIG = mkForce yes;
  MODULE_SIG_FORCE = yes;
  MODULE_SIG_ALL = yes;
  MODULE_SIG_SHA512 = yes;
  MODULE_SIG_HASH = freeform "sha512";
  MODULE_SIG_KEY = freeform "certs/signing_key.pem";
  MODULE_FORCE_LOAD = unset;
  # TODO: how to disable gcc completely
  #### GCC ####
  # Enable GCC Plugins
  GCC_PLUGINS = yes;
  # Gather additional entropy at boot time for systems that may not have appropriate entropy sources.
  GCC_PLUGIN_LATENT_ENTROPY = yes;
  # Force all structures to be initialized before they are passed to other functions. When building with GCC:
  GCC_PLUGIN_STRUCTLEAK = yes;
  GCC_PLUGIN_STRUCTLEAK_BYREF_ALL = yes;
  # Wipe stack contents on syscall exit (reduces stale data lifetime in stack)
  GCC_PLUGIN_STACKLEAK = yes;
  STACKLEAK_METRICS = unset;
  STACKLEAK_RUNTIME_DISABLE = unset;
}
// (optionalAttrs isx86 {
  # Disallow allocating the first 64k of memory for x86
  DEFAULT_MMAP_MIN_ADDR = freeform "65536";
  # Dangerous; enabling this disables vDSO ASLR on X86_64 and X86_32. On ARM64 this option has different meaning.
  COMPAT_VDSO = unset;
  # Disable Model-Specific Register writes.
  X86_MSR = unset;
  # Randomize position of kernel and memory.
  RANDOMIZE_BASE = yes;
  # Enable chip-specific IOMMU support. 
  INTEL_IOMMU = yes;
  INTEL_IOMMU_DEFAULT_ON = yes;
  # Enable Kernel Page Table Isolation to remove an entire class of cache timing side-channels.
  MITIGATION_PAGE_TABLE_ISOLATION = yes;
  # Don't allow for 16-bit program emulation and associated LDT tricks.
  MODIFY_LDT_SYSCALL = unset;
})
// (optionalAttrs isx86_64 {
  # Avoid speculative indirect branches in kernel (Spectre Mitigation)
  RETPOLINE = whenBetween "5.0" "5.17" yes;
  # Full 64-bit means PAE and NX bit.
  X86_64 = yes;
  # Randomize position of kernel and memory.
  RANDOMIZE_MEMORY = yes;
  # Modern libc no longer needs a fixed-position mapping in userspace, remove it as a possible target.
  X86_VSYSCALL_EMULATION = unset;
  LEGACY_VSYSCALL_NONE = yes;
  # Enforce CET Indirect Branch Tracking in the kernel.
  X86_KERNEL_IBT = whenAtLeast "5.18" yes;
  # Support userspace CET Shadow Stack
  X86_USER_SHADOW_STACK = yes;
  # Remove additional (32-bit) attack surface, unless you really need them.
  COMPAT = unset;
  IA32_EMULATION = unset;
  X86_X32 = unset;
  X86_X32_ABI = unset;
  # Enable chip-specific IOMMU support. 
  INTEL_IOMMU_SVM = yes;
  AMD_IOMMU = yes;
  AMD_IOMMU_V2 = yes;
  # Straight-Line-Speculation
  MITIGATION_SLS = yes;
  # Enable Control Flow Integrity 
  CFI_CLANG = whenAtLeast "6.1" yes;
  CFI_PERMISSIVE = whenAtLeast "6.1" unset;
})
// (optionalAttrs isx86_32 {
  # Avoid speculative indirect branches in kernel (Spectre Mitigation)
  RETPOLINE = whenBetween "4.15" "4.20" yes;
  # On 32-bit kernels, require PAE for NX bit support.
  M486 = unset;
  HIGHMEM4G = unset;
  HIGHMEM64G = yes;
  X86_PAE = yes;
})
// (optionalAttrs isAarch {
  # Looking at the Spectre and Meltdown variants, there are differing options depending on architecture as well:
  # (Spectre related) Speculation attacks against some high-performance processors rely on being able to manipulate the branch predictor for a victim context by executing aliasing branches in the attacker context. Such attacks can be partially mitigated against by clearing internal branch predictor state and limiting the prediction logic in some situations.
  HARDEN_BRANCH_PREDICTOR = yes; # 4.16-4.20, 5.0-5.17
  # Disallow allocating the first 32k of memory for arm (cannot be 64k due to ARM loader)
  DEFAULT_MMAP_MIN_ADDR = freeform "32768";
})
// (optionalAttrs isAarch64 {
  # Randomize position of kernel (requires UEFI RNG or bootloader support for /chosen/kaslr-seed DT property).
  RANDOMIZE_BASE = yes;
  # Remove arm32 support to reduce syscall attack surface.
  COMPAT = unset;
  # Make sure PAN emulation is enabled.
  ARM64_SW_TTBR0_PAN = yes;
  # Enable Kernel Page Table Isolation to remove an entire class of cache timing side-channels.
  UNMAP_KERNEL_AT_EL0 = yes;
  # Enable Software Shadow Stack when hardware Pointer Authentication (PAC) isn't available.
  SHADOW_CALL_STACK = yes;
  UNWIND_PATCH_PAC_INTO_SCS = yes;
  # Pointer authentication (ARMv8.3 and later). If hardware actually supports it, one can turn off CONFIG_STACKPROTECTOR_STRONG with this enabled.
  ARM64_PTR_AUTH = yes;
  ARM64_PTR_AUTH_KERNEL = yes;
  # Available in ARMv8.5 and later.
  ARM64_BTI = yes;
  ARM64_BTI_KERNEL = yes;
  ARM64_MTE = yes;
  KASAN_HW_TAGS = yes;
  ARM64_E0PD = yes;
  # Available in ARMv8.7 and later.
  ARM64_EPAN = yes;
  # Enable Control Flow Integrity
  CFI_CLANG = yes;
  CFI_PERMISSIVE = unset;
})
  // (optionalAttrs isAarch32 {
  # For maximal userspace memory area (and maximum ASLR).
  VMSPLIT_3G = yes;
  # If building an old out-of-tree Qualcomm kernel, this is similar to CONFIG_STRICT_KERNEL_RWX.
  STRICT_MEMORY_RWX = yes;
  # Make sure PXN/PAN emulation is enabled.
  CPU_SW_DOMAIN_PAN = yes;
  # Dangerous; old interfaces and needless additional attack surface.
  OABI_COMPAT = unset;
})
