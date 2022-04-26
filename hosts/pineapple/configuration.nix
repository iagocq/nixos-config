{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")

    ./device.nix
    ./wireguard.nix
  ];

  boot = {
    kernelParams = [ "boot.shell_on_fail" ];
    initrd.availableKernelModules = [ "virtio_pci" "usbhid" ];
    binfmt.emulatedSystems = [ "x86_64-linux" ];
  };

  networking.nat.enable = true;
  networking.nameservers = [ "1.1.1.1" ];

  srv.acme = {
    enable = true;
    email = "18238046+iagocq@users.noreply.github.com";
    domain = "velha.casa";
    credentials = config.age.secrets."acme-credentials".path;
    provider = "cloudflare";
  };

  srv.nginx = {
    enable = true;
    domain = "velha.casa";
    dynamicResolving = false;
  };

  srv.nginx.vhosts."velha.casa" = {
    root = "/srv/www/velha.casa";
    locations."/" = {
      tryFiles = "$uri $uri/index.html =404";
    };
    locations."/mc/s/" = {
      proxyPass = "http://127.0.0.1:8100/";
    };
    locations."/mc/c/" = {
      proxyPass = "http://127.0.0.1:8101/";
    };
    locations."/static" = {
      tryFiles = "$uri /agrega$uri =404";
    };
    locations."/agrega" = {
      tryFiles = "$uri /agrega/index.html";
    };
    locations."/agrega/api/" = {
      proxyPass = "http://127.0.0.1:3001/";
    };
  };

  device.zfs.eyd.persist.directories = [ "/srv/www/velha.casa" ];

  age.secrets = (import ./age.nix).age "acme-credentials";

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };

  services.gitlab-runner = {
    enable = true;
    services = {
      # runner for building in docker via host's nix-daemon
      # nix store will be readable in runner, might be insecure
      nix = {
        # File should contain at least these two variables:
        # `CI_SERVER_URL`
        # `REGISTRATION_TOKEN`
        registrationConfigFile = "/persist/secrets/gitlab-runner-registration";
        dockerImage = "alpine";
        dockerVolumes = [
          "/nix/store:/nix/store:ro"
          "/nix/var/nix/db:/nix/var/nix/db:ro"
          "/nix/var/nix/daemon-socket:/nix/var/nix/daemon-socket:ro"
        ];
        dockerDisableCache = true;
        preBuildScript = pkgs.writeScript "setup-container" ''
          mkdir -p -m 0755 /nix/var/log/nix/drvs
          mkdir -p -m 0755 /nix/var/nix/gcroots
          mkdir -p -m 0755 /nix/var/nix/profiles
          mkdir -p -m 0755 /nix/var/nix/temproots
          mkdir -p -m 0755 /nix/var/nix/userpool
          mkdir -p -m 1777 /nix/var/nix/gcroots/per-user
          mkdir -p -m 1777 /nix/var/nix/profiles/per-user
          mkdir -p -m 0755 /nix/var/nix/profiles/per-user/root
          mkdir -p -m 0700 "$HOME/.nix-defexpr"

          . ${pkgs.nixUnstable}/etc/profile.d/nix.sh

          ${pkgs.nixUnstable}/bin/nix-env -i ${lib.concatStringsSep " " (with pkgs; [ nixUnstable cacert git openssh ])}

          ${pkgs.nixUnstable}/bin/nix-channel --add https://nixos.org/channels/nixpkgs-unstable
          ${pkgs.nixUnstable}/bin/nix-channel --update nixpkgs
        '';
        environmentVariables = {
          ENV = "/etc/profile";
          USER = "root";
          NIX_REMOTE = "daemon";
          PATH = "/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/bin:/sbin:/usr/bin:/usr/sbin";
          NIX_SSL_CERT_FILE = "/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt";
        };
        tagList = [ "nix" ];
      };
    };
  };
}
