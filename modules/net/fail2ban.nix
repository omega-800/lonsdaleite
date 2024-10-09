{ options, config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.net.fail2ban;
  inherit (lib) mkIf mkMerge concatMapStrings mkOption mkDefault mkAfter;
  inherit (lib.types) listOf nonEmptyStr;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom;
  f2bGitUrl =
    "https://raw.githubusercontent.com/fail2ban/fail2ban/9a558589d7e67bfd553641bd9c074f85f97c50f4";
  fetchF2bFilter = name: sha256:
    builtins.fetchurl {
      url = "${f2bGitUrl}/config/filter.d/${name}.conf";
      inherit sha256;
    };
  fetchF2bAction = name: sha256:
    builtins.fetchurl {
      url = "${f2bGitUrl}/config/action.d/${name}.conf";
      inherit sha256;
    };
in {
  #TODO: harden / research
  #TODO: fetch filters from fail2ban repo?
  #TODO: move service definitions to their respective configs?
  options.lonsdaleite.net.fail2ban = (mkEnableFrom [ "net" ] "Enables fail2ban")
    // (mkParanoiaFrom [ "net" ] [ "" "" "" ]) // {
      ignore-ip = mkOption {
        inherit (options.services.fail2ban.ignoreIP) description default type;
      };
    };

  config = mkIf cfg.enable (mkMerge [
    {
      services.fail2ban = {
        enable = true;
        bantime = "${toString (3 - cfg.paranoia)}h";
        bantime-increment = {
          enable = true;
          factor = "4";
          formula =
            "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
          maxtime = "${toString (48 + (12 * cfg.paranoia))}h";
          rndtime = "8m";
        };
        ignoreIP = cfg.ignore-ip;
        maxretry = 5 - cfg.paranoia;
        jails = {
          port-scan.settings = {
            filter = "port-scan";
            action = "iptables-allports[name=port-scan]";
            maxretry = 3 - cfg.paranoia;
            bantime = 7200 + (cfg.paranoia * 3600);
            enabled = true;
          };
        };
      };
      environment.etc = {
        # Define an action that will trigger a Ntfy push notification upon the issue of every new ban
        "fail2ban/action.d/ntfy.local".text = mkDefault (mkAfter ''
          [Definition]
          norestored = true # Needed to avoid receiving a new notification after every restart
          actionban = curl -H "Title: <ip> has been banned" -d "<name> jail has banned <ip> from accessing $(hostname) after <failures> attempts of hacking the system." https://ntfy.sh/Fail2banNotifications
        '');
        "fail2ban/filter.d/port-scan.conf".text = ''
          [Definition]
          failregex = rejected connection: .* SRC=<HOST>
        '';
      };
      # Limit stack size to reduce memory usage
      systemd.services.fail2ban.serviceConfig.LimitSTACK = 256 * 1024;
    }

    # TODO: research
    (mkIf false {
      services.fail2ban.jails.apache-nohome-iptables.settings = {
        # Block an IP address if it accesses a non-existent
        # home directory more than 5 times in 10 minutes,
        # since that indicates that it's scanning.
        filter = "apache-nohome";
        action = ''iptables-multiport[name=HTTP, port="http,https"]'';
        logpath = "/var/log/httpd/error_log*";
        backend = "auto";
        findtime = 600 + (cfg.paranoia * 300);
        bantime = 600 + (cfg.paranoia * 300);
        maxretry = 5 - cfg.paranoia;
      };
    })

    (mkIf config.services.openssh.enable {
      services.fail2ban.jails = {
        sshd.settings = {
          filter = "sshd";
          action = "iptables[name=ssh, port=ssh, protocol=tcp]";
          maxretry = 4 - cfg.paranoia;
          enabled = true;
        };
        sshd-ddos.settings = {
          filter = "sshd-ddos";
          action = "iptables[name=ssh, port=ssh, protocol=tcp]";
          maxretry = 3 - cfg.paranoia;
          enabled = true;
        };
      };
    })

    (mkIf config.services.grafana.enable {
      services.fail2ban.jails.grafana-unauthorized.settings = {
        enabled = true;
        filter = "grafana-unauthorized";
        logpath = "/var/log/grafana/grafana.log";
        # TODO: research
        # action = ''
        #   %(action_)s[blocktype=DROP]
        #                    ntfy'';
        # backend =
        #   "auto"; # Do not forget to specify this if your jail uses a log file
        # maxretry = 5 - cfg.paranoia;
        # findtime = 600 + (cfg.paranoia * 300);
      };

      environment.etc."fail2ban/filter.d/grafana-unauthorized.conf".text =
        mkDefault (mkAfter ''
          [Init]
          datepattern = ^t=%%Y-%%m-%%dT%%H:%%M:%%S%%z

          [Definition]
          failregex = ^(?: lvl=err?or)? msg="Invalid username or password"(?: uname=(?:"<F-ALT_USER>[^"]+</F-ALT_USER>"|<F-USER>\S+</F-USER>)| error="<F-ERROR>[^"]+</F-ERROR>"| \S+=(?:\S*|"[^"]+"))* remote_addr=<ADDR>$
        '');
    })

    (mkIf config.services.gitlab.enable {
      services.fail2ban.jails.gitlab-login-fail.settings = {
        enabled = true;
        filter = "gitlab-login-fail";
        logpath = "/var/log/gitlab/gitlab-rails/application.log";
        # TODO: research
        # action = ''
        #   %(action_)s[blocktype=DROP]
        #                    ntfy'';
        # backend =
        #   "auto"; # Do not forget to specify this if your jail uses a log file
        # maxretry = 5 - cfg.paranoia;
        # findtime = 600 + (cfg.paranoia * 300);
      };

      environment.etc."fail2ban/filter.d/gitlab-login-fail.conf".text =
        mkDefault (mkAfter ''
          [Definition]
          failregex = ^: Failed Login: username=<F-USER>.+</F-USER> ip=<HOST>$
        '');
    })

    (mkIf config.services.nginx.enable {
      services.fail2ban.jails.ngnix-url-probe.settings = {
        enabled = true;
        filter = "nginx-url-probe";
        logpath = "/var/log/nginx/access.log";
        action = ''
          %(action_)s[blocktype=DROP]
                           ntfy'';
        backend =
          "auto"; # Do not forget to specify this if your jail uses a log file
        maxretry = 5 - cfg.paranoia;
        findtime = 600 + (cfg.paranoia * 300);
      };
      # Defines a filter that detects URL probing by reading the Nginx access log
      environment.etc = {
        "fail2ban/filter.d/nginx-botsearch.conf".text = mkDefault (mkAfter ''
          [INCLUDES]

          # Load regexes for filtering
          before = botsearch-common.conf

          [Definition]

          failregex = ^<HOST> \- \S+ \[\] \"(GET|POST|HEAD) \/<block> \S+\" 404 .+$
                      ^ \[error\] \d+#\d+: \*\d+ (\S+ )?\"\S+\" (failed|is not found) \(2\: No such file or directory\), client\: <HOST>\, server\: \S*\, request: \"(GET|POST|HEAD) \/<block> \S+\"\, .*?$

          ignoreregex = 

          datepattern = {^LN-BEG}%%ExY(?P<_sep>[-/.])%%m(?P=_sep)%%d[T ]%%H:%%M:%%S(?:[.,]%%f)?(?:\s*%%z)?
                        ^[^\[]*\[({DATE})
                        {^LN-BEG}

          journalmatch = _SYSTEMD_UNIT=nginx.service + _COMM=nginx

          # DEV Notes:
          # Based on apache-botsearch filter
          # 
          # Author: Frantisek Sumsal
        '');

        "fail2ban/filter.d/nginx-bad-request.conf".text = mkDefault (mkAfter ''
          [Definition]

          # The request often doesn't contain a method, only some encoded garbage
          # This will also match requests that are entirely empty
          failregex = ^<HOST> - \S+ \[\] "[^"]*" 400

          datepattern = {^LN-BEG}%%ExY(?P<_sep>[-/.])%%m(?P=_sep)%%d[T ]%%H:%%M:%%S(?:[.,]%%f)?(?:\s*%%z)?
                        ^[^\[]*\[({DATE})
                        {^LN-BEG}

          journalmatch = _SYSTEMD_UNIT=nginx.service + _COMM=nginx

          # Author: Jan Przybylak
        '');

        "fail2ban/filter.d/nginx-url-probe.local".text = mkDefault (mkAfter ''
          [Definition]
          failregex = ^<HOST>.*(GET /(wp-|admin|boaform|phpmyadmin|\.env|\.git)|\.(dll|so|cfm|asp)|(\?|&)(=PHPB8B5F2A0-3C92-11d3-A3A9-4C7B08C10000|=PHPE9568F36-D428-11d2-A769-00AA001ACF42|=PHPE9568F35-D428-11d2-A769-00AA001ACF42|=PHPE9568F34-D428-11d2-A769-00AA001ACF42)|\\x[0-9a-zA-Z]{2})
        '');
      };
    })

  ]);
}
