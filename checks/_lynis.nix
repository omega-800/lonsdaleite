{
  testScript = ''
    machine.wait_for_unit("default.target")
    result = machine.succeed("lynis audit system")
  '';
}
