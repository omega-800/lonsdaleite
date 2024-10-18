{
  testScript = ''
    machine.wait_for_unit("default.target")
    result = machine.succeed("systemd-analyze security")
    for status in ["UNSAFE", "EXPOSED", "MEDIUM"]:
      if status in result:
        print(machine.execute("systemd-analyze security | grep "+status+" | cut -d\" \"  -f1"))
        raise Exception("Not hard enough: Systemd services with status "+status+" exist")
  '';
}
