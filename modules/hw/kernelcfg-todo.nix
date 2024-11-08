{

  archMap = {
    "i686" = "X86_32";
    "x86_64" = "X86_64";
    "aarch64" = "ARM64";
    "armv7l" = "ARM";
    "armv7a" = "ARM";
    "armv6l" = "ARM";
    "armv5tel" = "ARM";
    # TODO: research
    # "riscv32" = "ARM";
    # "riscv62" = "ARM64";
    # "loongarch" = "ARM";
  };
  # https://www.timesys.com/security/securing-your-linux-configuration-kernel-hardening/
  kernelConfigs = {

    /*
      The latter two options can help to protect against exploits which have not yet been discovered or released into the
      public domain (e.g. zero-day exploits) by reducing your kernel’s exploitable attack surface.
      Analyzing, understanding, and modifying the kernel configuration with these tasks in mind is not trivial. Furthermore,
      in a large project it may not be clear exactly who is using which kernel configuration option. This can result in
      iterative backstepping until you arrive at a final configuration which works for your entire team.
      There’s also a maintenance burden once you have created your final configuration. When you upgrade your kernel, many of
      the configuration options will have been removed and renamed. This will require another assessment and configuration
      period. Keeping your kernel up to date is extremely important, as security features are continuously added and revised
      in newer kernels. Starting a project with a long term stable (LTS) kernel is recommended, as an LTS kernel provides
      smaller (and sometimes backported) version increments to resolve security flaws (e.g upgrading from 5.0.x to 5.0.y).
      Such patches are provided until the long term stable support period ends.

      Not all configuration items provide the same cost-benefit as others. To some extent, most options will have an impact in
      these key areas:
    */

    # TODO: research
    # Fill the pages with poison patterns after free_pages() and verify the patterns before alloc_pages. The filling of the memory helps reduce the risk of information leaks from freed data. This must be enabled from the boot cmdline with page_poison=1
    # already enabled in commonConfig. hardenedConfig also provides _{NO_SANITY,ZERO}
    # "PAGE_POISONING y" = [ "ARM" "ARM64" "X86_32" "X86_64" ]; # 4.6-4.20, 5.0-5.17

    # Make sure this is not enabled, as it could provide an attacker sensitive kernel backtrace information on BUG() conditions
    "# DEBUG_BUGVERBOSE is not set" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 2.6.9-2.6.39, 3.0-3.19, 4.0-4.20, 5.0-5.17

    # Randomized locations for stack, mmap, brk, and ET_DYN
    "ARCH_HAS_ELF_RANDOMIZE y" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 4.1-4.20, 5.0-5.17

    # More expensive form of INIT_ON_ALLOC_DEFAULT_ON. The primary difference is that data lifetime in memory is reduced, as anything freed is wiped immediately, making live forensics or cold boot memory attacks unable to recover freed memory contents.
    # already included in hardenedConfig
    # "INIT_ON_FREE_DEFAULT_ON y" = [ "ARM" "ARM64" "X86_32" "X86_64" ]; # 5.3-5.17

    # All page allocator and slab allocator memory will be zeroed when freed, eliminating many kinds of “uninitialized heap memory” flaws, especially heap content exposures.
    # already included in commonConfig
    # "INIT_ON_ALLOC_DEFAULT_ON y" = [ "ARM" "ARM64" "X86_32" "X86_64" ]; # 5.3-5.17

    # Enable some costly sanity checks in virtual to page code. This can catch mistakes with virt_to_page() and friends.
    # already included in hardenedConfig
    # "DEBUG_VIRTUAL y" = [ "ARM" "ARM64" "X86_32" "X86_64" ]; # 2.6.28-2.6.39, 3.0-3.19, 4.0-4.20, 5.0-5.17

    /*
      Using multiple kernel configurations (development and production) can be an option. While it is wise to develop on a
      prototype system that most closely resembles a production system (as to not cause unforeseen bugs in changing timing
      conditions and loads between configurations), some security options be too cumbersome to reasonably develop on. If
      you’re writing a kernel driver and you need to use a tracing tool or read a core dump, then certainly enable them while
      developing.

      In the Timesys Kernel Hardening Analysis Tool, the kernel security options have been divided into various groups. This
      categorization is by no means a definitive separation; some options could be further categorized or applied to multiple
      categories.

      Memory exploits are classes of attack in which an entity is able to retrieve or modified privileged information about
      the system. These can be further categorized into:
      <ul style = "padding-top: 0;" >
      Stack Overflow Protections: These are security features which seek to prevent access to and tampering of stack
        variables in memory. A stack canary (an arbitrary value sitting at the top of the stack, which, if modified, alerts
      the kernel of tampering) is sometimes mentioned in these protections.
      </ul>
    */
    # Initializes everything on the stack with a zero value. This is intended to eliminate all classes of uninitialized stack variable exploits and information exposures, even variables that were warned to have been left uninitialized. (Strongest, safest)
    "INIT_STACK_ALL_ZERO y" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 5.9-5.17

    # Generates a separate stack canary value for each task, so if one task’s canary value is leaked it does not cause all other tasks to become vulnerable.
    "GCC_PLUGIN_ARM_SSP_PER_TASK y" = [ "ARM" ]; # 5.2-5.17

    # This option turns on the “stack-protector” GCC feature. This feature puts, at the beginning of functions, a canary value on the stack just before the return address, and validates the value just before actually returning. Stack based buffer overflows (that need to overwrite this return address) now also overwrite the canary, which gets detected and the attack is then neutralized via a kernel panic.
    "STACKPROTECTOR y" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 4.18-4.20, 5.0-5.17

    # FIXME: research
    # FIXME: hardenedConfig includes CC_STACKPROTECTOR_{REGULAR,STRONG} but only < 4.18
    # Adds the CONFIG_STACKPROTECTOR canary logic to additional conditions related to variable assignment.
    "STACKPROTECTOR_STRONG y" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 4.18-4.20, 5.0-5.17

    # Use a different stack canary value for each task
    "STACKPROTECTOR_PER_TASK y" = [
      "ARM"
      "ARM64"
    ]; # 5.0-5.17

    # Enable this if you want the use virtually-mapped kernel stacks with guard pages. This causes kernel stack overflows to be caught immediately.
    "VMAP_STACK y" = [ "ARM64" ]; # 4.9-4.20, 5.0-5.17

    # Additional validation check on commonly targeted structure. Detect stack corruption on calls to schedule()
    # {common,hardened}Config include this already
    # "SCHED_STACK_END_CHECK y" = [ "ARM" "ARM64" "X86_32" "X86_64" ]; # 3.18-3.19, 4.0-4.20, 5.0-5.17

    # If this is set, STACKLEAK metrics for every task are available in the /proc file system.
    "# STACKLEAK_METRICS is not set" = [
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 5.2-5.17

    # If set, allows runtime disabling of kernel stack erasing
    "# STACKLEAK_RUNTIME_DISABLE is not set" = [
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 5.2-5.17

    # FIXME: research, hardenedConfig oncludes this > 4.20
    # This blocks most uninitialized stack variable attacks, with the performance impact being driven by the depth of the stack usage, rather than the function calling complexity. The performance impact on a single CPU system kernel compilation sees a 1% slowdown.
    "GCC_PLUGIN_STACKLEAK y" = [
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 5.2-5.17

    /*
      <ul style = "padding-top: 0;" >
      Heap Overflow: These are security features which seek to prevent heap memory exposure and
        modification.</ul>
    */
    # If this is set, kernel text and rodata memory will be made read-only, and non-text memory will be made non-executable. This provides protection against certain security exploits (e.g. executing the heap or modifying text)
    # already included in commonConfig
    # "STRICT_KERNEL_RWX y" = [ "ARM" "ARM64" "X86_32" "X86_64" ]; # 4.11-4.20, 5.0-5.17

    # Harden slab freelist metadata: Many kernel heap attacks try to target slab cache metadata and other infrastructure. This options makes minor performance sacrifices to harden the kernel slab allocator against common freelist exploit methods. Some slab implementations have more sanity-checking than others. This option is most effective with CONFIG_SLUB.
    # already included in commonConfig
    # "SLAB_FREELIST_HARDENED y" = [ "ARM" "ARM64" "X86_32" "X86_64" ]; # 4.14-4.20, 5.0-5.17

    # Randomizes the freelist order used on creating new pages. This security feature reduces the predictability of the kernel slab allocator against heap overflows.
    # already included in commonConfig
    # "SLAB_FREELIST_RANDOM y" = [ "ARM" "ARM64" "X86_32" "X86_64" ]; # 4.7-4.20, 5.0-5.17

    # Do not disable heap randomization
    "# COMPAT_BRK is not set" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 2.6.25-2.6.39, 3.0-3.19, 4.0-4.20, 5.0-5.17

    # Do not allow INET socket monitoring interface. Assists heap memory attacks
    # already included in hardenedConfig
    # "# INET_DIAG is not set" = [ "ARM" "ARM64" "X86_32" "X86_64" ]; # 2.6.14-2.6.39, 3.0-3.19, 4.0-4.20, 5.0-5.17

    /*
      <ul style = "padding-top: 0;" >
      User Copy Protection: These are security features which seek to prevent memory exploitation during kernel and userspace memory transfer
        transactions.</ul>
    */
    # This option checks for obviously wrong memory regions when copying memory to/from the kernel (via copy_to_user() and copy_from_user() functions) by rejecting memory ranges that are larger than the specified heap object, span multiple separately allocated pages, are not on the process stack, or are part of the kernel text. This kills entire classes of heap overflow exploits and similar kernel memory exposures.
    # already included in commonConfig
    # "HARDENED_USERCOPY y" = [ "ARM" "ARM64" "X86_32" "X86_64" ]; # 4.8-4.20, 5.0-5.17

    # TODO: research
    # This is a temporary option that allows missing usercopy whitelists to be discovered via a WARN() to the kernel log, instead of rejecting the copy, falling back to non-whitelisted hardened usercopy that checks the slab allocation size instead of the whitelist size.
    "# HARDENED_USERCOPY_FALLBACK is not set" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 4.16-4.20, 5.0-5.15

    # TODO: research
    # When a multi-page allocation is done without __GFP_COMP, hardened usercopy will reject attempts to copy it. There are, however, several cases of this in the kernel that have not all been removed. This config is intended to be used only while trying to find such users.
    "# HARDENED_USERCOPY_PAGESPAN is not set" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 4.8-4.20, 5.0-5.17

    # FIXME:
    # The heap allocator implements __check_heap_object() for validating memory ranges against heap object sizes.
    # "HAVE_HARDENED_USERCOPY_ALLOCATOR y" = [ "ARM" "ARM64" "X86_32" "X86_64" ]; # 4.8-4.20, 5.0-5.17

    /*
      <ul style = "padding-top: 0;" >
      Information exposure: Options which are selected to limit exposure to privileged
        information.</ul>
    */
    # If enabled, a general protection fault is issued if the SGDT, SLDT, SIDT, SMSW or STR instructions are executed in user mode. These instructions unnecessarily expose information about the hardware state.
    "X86_UMIP y" = [
      "X86_32"
      "X86_64"
    ]; # 5.5-5.17

    # Do not expose process memory utilization via /proc interfaces
    "# PROC_PAGE_MONITOR is not set" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 2.6.28-2.6.39, 3.0-3.19, 4.0-4.20, 5.0-5.17

    # Do not export the dump image of crashed kernel
    "# PROC_VMCORE is not set" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 2.6.37-2.6.39, 3.0-3.19, 4.0-4.20, 5.0-5.17

    # Do not enable debugfs, as it may expose vulnerabilities
    "# DEBUG_FS is not set" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 2.6.11-2.6.39, 3.0-3.19, 4.0-4.20, 5.0-5.17

    /*
      <ul style = "padding-top: 0;" >
      Kernel Address Space Layout Randomization (KASLR): A security method by which kernel memory structures are randomized
      in order to prevent repeat or replay-style attacks.
      </ul>
    */

    # In support of Kernel Address Space Layout Randomization (KASLR), this randomizes the physical address at which the kernel image is decompressed and the virtual address where the kernel image is mapped, as a security feature that deters exploit attempts relying on knowledge of the location of kernel code internals.
    # already included in commonConfig
    "RANDOMIZE_BASE y" = [
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 4.7-4.20, 5.0-5.17

    # Randomizes the base virtual address of kernel memory sections (physical memory mapping, vmalloc &amp; vmemmap). This security feature makes exploits relying on predictable memory locations less reliable.
    "RANDOMIZE_MEMORY y" = [ "X86_64" ]; # 4.8-4.20, 5.0-5.17

    # FIXME: research, hardenedConfig sets this < 5.19
    # Randomizes layout of sensitive kernel structures
    # "GCC_PLUGIN_RANDSTRUCT y" = [ "ARM" "ARM64" "X86_32" "X86_64" ]; # 4.13-4.20, 5.0-5.17

    /*
      These are configuration options which can be selected to reduce the potential for exposure to unknown zero-day attacks
      by limiting the attack surface as much as we can. These are options that reduce the amount of information exposure and
      compiled-firmware attack surface (Again: If you don’t need it, disable it).
      <ul style = "padding-top: 0;" >
      Kernel Replacement Attacks: Methods in which a kernel binary could be replaced during runtime.
      </ul>
    */
    # Do not support hibernation. Allows replacement of running kernel.
    "# HIBERNATION is not set" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 2.6.23-2.6.39, 3.0-3.19, 4.0-4.20, 5.0-5.17

    # TODO: look into commonConfig, as it sets _{JUMP,FILE}
    # Do not allow system to boot another Linux kernel
    "# KEXEC is not set" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 2.6.16-2.6.39, 3.0-3.19, 4.0-4.20, 5.0-5.17

    # Do not allow system to boot another Linux kernel
    "# KEXEC_FILE is not set" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 3.17-3.19, 4.0-4.20, 5.0-5.17

    /*
      <ul style = "padding-top: 0;" >
      Module Security Attacks: These are attacks which can be performed by loading a tainted, custom, module in to a system
      or maliciously modifying a pre-existing module’s memory. The mitigations for this mostly consist of restricting
      execution regions, making such regions read-only, and signature checking prior to loading modules.
      </ul>
    */
    # TODO: research as this can break things ig?
    # You should not allow for modules to be loaded unless you have the proper signing and signature checks enabled. Allowing the kernel to load unsigned modules can be dangerous
    "# MODULES is not set" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ];

    # Module text and rodata memory will be made read-only, and non-text memory will be made non-executable. This provides protection against certain security exploits (e.g. writing to text)
    # already included in commonConfig
    # "STRICT_MODULE_RWX y" = [ "ARM" "ARM64" "X86_32" "X86_64" ]; # 4.11-4.20, 5.0-5.17

    # Enable module signature verification
    # FIXME: commonConfig sets this to no, override it to y
    "MODULE_SIG y" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 3.7-3.19, 4.0-4.20, 5.0-5.17

    # Automatically sign all modules during modules_install (so we don’t have to do this manually)
    "MODULE_SIG_ALL y" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 3.9-3.19, 4.0-4.20, 5.0-5.17

    # Sign modules with SHA-512 algorithm
    "MODULE_SIG_SHA512 y" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 3.7-3.19, 4.0-4.20, 5.0-5.17

    # Require modules to be validly signed
    "MODULE_SIG_FORCE y" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 3.7-3.19, 4.0-4.20, 5.0-5.17

    /*
      <ul style = "padding-top: 0;" >
      Reducing Syscall Exposure: Syscalls are interfaces in which user-space and kernel-space can communicate and access
      each other. Some legacy syscalls may be exploitable and are generally not required on modern systems. Disabling
      syscalls when possible is a good way to reduce your attack surface.
      </ul>
    */
    # This kernel feature is useful for number crunching applications that may need to compute untrusted bytecode during their execution. By using pipes or other transports made available to the process as file descriptors supporting the read/write syscalls, it’s possible to isolate those applications in their own address space using seccomp. Once seccomp is enabled via prctl(PR_SET_SECCOMP), it cannot be disabled and the task is only allowed to execute a few safe syscalls defined by each seccomp mode.
    # already included in commonConfig
    # "SECCOMP y" = [ "ARM" "ARM64" "X86_32" "X86_64" ]; # Varies depending on architecture

    # If enabled, this allows the libc5 and earlier dynamic linker usblib syscall. Should no longer be needed.
    "# USELIB is not set" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 4.5-4.20, 5.0-5.17

    # Linux can allow user programs to install a per-process x86 Local Descriptor Table (LDT) using the modify_ldt(2) system call. This is required to run 16-bit or segmented code such as DOSEMU or some Wine programs. It is also used by some very old threading libraries. Enabling this feature adds a small amount of overhead to context switches and increases the low-level kernel attack surface. Disabling it removes the modify_ldt(2) system call.
    "# MODIFY_LDT_SYSCALL is not set" = [
      "X86_32"
      "X86_64"
    ]; # 4.3-4.20, 5.0-5.17

    # There will be no vsyscall mapping at all. This will eliminate any risk of ASLR bypass due to the vsyscall fixed address mapping. Attempts to use the vsyscalls will be reported to dmesg, so that either old or malicious userspace programs can be identified.
    # already included in hardenedConfig
    # "LEGACY_VSYSCALL_NONE y" = [ "X86_32" "X86_64" ]; # 4.4-4.20, 5.0-5.17

    # If set, this enables emulation of the legacy vsyscall page.
    "# X86_VSYSCALL_EMULATION is not set" = [
      "X86_32"
      "X86_64"
    ]; # 3.19, 4.0-4.20, 5.0-5.17

    /*
      <ul style = "padding-top: 0;" >
      Security Policy Attacks: These are attacks which attempt to gain elevated (root) privileges within a system, generally
      through the use or execution of a misconfigured binary or file. Mitigations for this mostly rely on Linux Security
      Modules (LSMs) which extend discretionary access control (DAC) or implement mandatory access control (MAC,
      Security-Enhanced Linux).
      </ul>
    */
    # This allows you to choose different security modules to be configured into your kernel.
    "SECURITY y" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 2.5.50-2.5.75, 2.6.0-2.6.39, 3.0-3.19, 4.0-4.20, 5.0-5.17

    # This selects Yama, which extends DAC support with additional system-wide security settings beyond regular Linux discretionary access controls. Currently available is ptrace scope restriction. Like capabilities, this security module stacks with other LSMs. Further information can be found in Documentation/admin-guide/LSM/Yama.rst.
    # already included in commonConfig
    # "SECURITY_YAMA y" = [ "ARM" "ARM64" "X86_32" "X86_64" ]; # 3.4-3.19, 4.0-4.20, 5.0-5.17

    # If SECURITY_SELINUX_DISABLE must be set, make sure this is not set. Subsequent patches will add RO hardening to LSM hooks, however, SELinux still needs to be able to perform runtime disablement after init to handle architectures where init-time disablement via boot parameters is not feasible. Introduce a new kernel configuration parameter CONFIG_SECURITY_WRITABLE_HOOKS, and a helper macro __lsm_ro_after_init, to handle this case.
    # already included in commonConfig
    # "# SECURITY_WRITABLE_HOOKS is not set" = [ "ARM" "ARM64" "X86_32" "X86_64" ]; # 4.12-4.20, 5.0-5.17

    # Do not allow NSA SELinux runtime disable
    # already included in hardenedConfig
    # "# SECURITY_SELINUX_DISABLE is not set" = [ "ARM" "ARM64" "X86_32" "X86_64" ]; # 2.6.6-2.6.39, 3.0-3.19, 4.0-4.20, 5.0-5.17

    # Enables the lockdown LSM, which enables you to set the lockdown=integrity or lockdown=confidentiality modes during boot. Integrity attempts to block userspace from modifying the running kernel, while confidentiality also restricts reading of confidential material.
    # FIXME: commonConfig sets this to no, override it to y
    "SECURITY_LOCKDOWN_LSM y" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 5.4-5.17

    # Enable lockdown LSM early in init
    "SECURITY_LOCKDOWN_LSM_EARLY y" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 5.4-5.17

    # The kernel runs in confidentiality mode by default. Features that allow the kernel to be modified at runtime or that permit userland code to read confidential material held inside the kernel are disabled.
    "LOCK_DOWN_KERNEL_FORCE_CONFIDENTIALITY y" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 5.4-5.17

    # SafeSetID is an LSM module that gates the setid family of syscalls to restrict UID/GID transitions from a given UID/GID to only those approved by a system-wide whitelist. These restrictions also prohibit the given UIDs/GIDs from obtaining auxiliary privileges associated with CAP_SET{U/G}ID, such as allowing a user to set up user namespace UID mappings.
    # already included in hardenedConfig
    # "SECURITY_SAFESETID y" = [ "ARM" "ARM64" "X86_32" "X86_64" ]; # 5.1-5.17

    # Any files read through the kernel file reading interface (kernel modules, firmware, kexec images, security policy) can be pinned to the first filesystem used for loading. When enabled, any files that come from other filesystems will be rejected. This is best used on systems without an initrd that have a root filesystem backed by a read-only device such as dm-verity or a CDROM.
    "SECURITY_LOADPIN y" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 4.7-4.20, 5.0-5.17

    # If selected, LoadPin will enforce pinning at boot. If not selected, it can be enabled at boot with the kernel parameter “loadpin.enforce=1”.
    "SECURITY_LOADPIN_ENFORCE y" = [
      "ARM"
      "ARM64"
      "X86_32"
      "X86_64"
    ]; # 4.20, 5.0-5.17

    /*
      Many security features are architecture specific because of a specific hardware level reason (differing instruction set,
      caches, branch predictors, and more) or merely because they have not been implemented on a specific architecture.
      Looking at DEBUG_SET_MODULE_RONX, we find that it was a relatively recent addition for "ARM" and "ARM64" architectures.
    */
    # FIXME:
    # # Helps catch unintended modifications to loadable kernel module’s text and read-only data. It also prevents execution of module data.
    # "DEBUG_SET_MODULE_RONX y" = [
    #   "ARM64" # 3.18-3.19, 4.0-4.10
    #   "ARM" # 3.14-3.19, 4.0-4.10
    #   "X86_32"
    #   "X86_64"
    # ]; # 2.6.38-2.6.39, 3.0-3.19, 4.0-4.10
  };

}
