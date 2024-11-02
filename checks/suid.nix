{
  # TODO: 
  testScript = ''
    result = machine.succeed("find / -type f \( -perm -4000 -o -perm -2000 \)")
    print(result)
  '';
  # To remove the setuid bit, execute:
  # chmod u-s $path_to_program
  # To remove the setgid bit, execute:
  # chmod g-s $path_to_program
  # To add a capability to the file instead, execute:
  # setcap $capability+ep $path_to_program
  # To remove an unnecessary capability, execute:
  # setcap -r $path_to_program
}
