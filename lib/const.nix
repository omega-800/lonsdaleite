{
  # https://lincolnloop.com/insights/sandboxing-services-systemd/
  # man 7 capabilities
  # TODO
  systemd = {
    def = {
      ProtectSystem = "strict";
      PrivateTmp = true;
      ProtectHome = true;
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      PrivateDevices = true;
      SystemCallArchitectures = "native";
      CapabilityBoundingSet = "~CAP_SYS_ADMIN";
    };
    usr = {
      DynamicUser = true;
      #TODO: implement
      SupplementaryGroups = "adm";
      ConfigurationDirectory = "margie";
      LockPersonality = true;
      UMask = "0077";
      NoNewPrivileges = true;
    };
    net = { };
  };
}
