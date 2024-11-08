{
  # TODO: 
  testScript = ''
    kernel_res = machine.succeed("kernel-hardening-checker -c /proc/config.gz")
    sysctl_res = machine.succeed("sysctl -a > s && kernel-hardening-checker -s s")
  '';
}
