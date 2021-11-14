{ config, lib, pkgs, ... }:

{
  containers.gcc214 = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.39.26.214";
    localAddress = "10.39.26.1";

    forwardPorts = [
      {
        containerPort = 80;
        hostPort = 8080;
      }
    ];

    config = { config, lib, pkgs, ... }: {
      services.mysql = {
        enable = true;
        package = pkgs.mariadb;
      };

      services.phpfpm.pools.gcc214 = {
        user = "php";
        group = "php";
        phpPackage = pkgs.php;

        settings = {
          "listen.owner" = config.services.nginx.user;
          "pm" = "dynamic";
          "pm.max_children" = 32;
          "pm.max_requests" = 500;
          "pm.start_servers" = 2;
          "pm.min_spare_servers" = 2;
          "pm.max_spare_servers" = 5;
          "php_admin_value[error_log]" = "stderr";
          "php_admin_flag[log_errors]" = true;
          "catch_workers_output" = true;
        };
      };

      services.nginx = {
        enable = true;

        virtualHosts."_" = {
          locations."/" = {
            root = "/srv/http/gcc214";

            extraConfig = ''
              fastcgi_split_path_info ^(.+?\.php)(/.*)$;
              fastcgi_pass unix:${config.services.phpfpm.pools.gcc214.socket};
              fastcgi_index index.php;
              fastcgi_param HTTP_PROXY "";
              include ${pkgs.nginx}/conf/fastcgi_params;
              include ${pkgs.nginx}/conf/fastcgi.conf;
            '';
          };
        };
      };

      networking.firewall.trustedInterfaces = [ "eth0" ];

      users.users."php" = {
        isSystemUser = true;
        group = "php";
      };

      users.groups."php" = {};
    };
  };
}
