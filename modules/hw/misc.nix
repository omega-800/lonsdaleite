{
  # Microcode updates are important. They can fix CPU vulnerabilities such the Meltdown and Spectre bugs. 
  hardware.cpu = {
    amd.updateMicrocode = true;
    intel.updateMicrocode = true;
  };
}
