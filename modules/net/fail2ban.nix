{ options, config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.net.fail2ban;
  svc = cfg.integrations;
  inherit (lib) mkIf mkMerge mkOption mkDefault mkAfter genAttrs;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom mkEnableDef;
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
      integrations = genAttrs [ "gitlab" "nginx" "grafana" "openssh" ] (s:
        mkEnableDef config.services.${s}.enable
        "Creates fail2ban rules for ${s}");
      #TODO: add apache, common, dante, mysqld, mongodb, monitorix, squid, traefik, bitwarden
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
          overalljails = cfg.paranoia == 2;
        };
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
      environment = mkMerge [
        {
          etc = {
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
        }
        (mkIf config.lonsdaleite.fs.impermanence.enable {
          persistence."/nix/persist" = {
            directories = [ "/etc/fail2ban" ];
            files = [ "/var/lib/fail2ban/fail2ban.sqlite3" ];
          };
        })
      ];
      # Limit stack size to reduce memory usage
      systemd.services.fail2ban.serviceConfig.LimitSTACK = 256 * 1024;
    }

    (mkIf svc.openssh {
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

    (mkIf svc.grafana {
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

    (mkIf svc.gitlab {
      services.fail2ban.jails.gitlab-login-fail.settings = {
        enabled = true;
        filter = "gitlab-login-fail";
        logpath = "/var/log/gitlab/gitlab-rails/application.log";
      };
    })

    (mkIf svc.nginx {
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
    })
  ]);
}
