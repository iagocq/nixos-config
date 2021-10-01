{ config, lib, pkgs, modulesPath, ... }:

let
  nixpkgs = lib.cleanSource pkgs.path;
in
{
  imports = [
    (modulesPath + "/installer/netboot/netboot-minimal.nix")
    (modulesPath + "/installer/netboot/netboot.nix")
  ];

  system.build = rec {
    image = pkgs.runCommand "image" { buildInputs = [ pkgs.nukeReferences ]; } ''
      mkdir $out
      cp ${config.system.build.kernel}/Image $out/kernel
      cp ${config.system.build.netbootRamdisk}/initrd $out/initrd
      nuke-refs $out/kernel
    '';

    kexec_script = pkgs.writeTextFile {
      executable = true;
      name = "kexec-nixos";
      text = ''
        #!${pkgs.stdenv.shell}
        set -e
        ${pkgs.kexectools}/bin/kexec -l ${image}/kernel --initrd=${image}/initrd --append="init=${builtins.unsafeDiscardStringContext config.system.build.toplevel}/init ${toString config.boot.kernelParams}"
        sync
        echo "executing kernel, filesystems will be improperly umonted"
        ${pkgs.kexectools}/bin/kexec -e
      '';
    };

    kexec_tarball = pkgs.callPackage "${nixpkgs}/nixos/lib/make-system-tarball.nix" {
      storeContents = [
        {
          object = config.system.build.kexec_script;
          symlink = "/kexec_nixos";
        }
      ];
      contents = [ ];
      compressCommand = "cat";
      compressionExtension = "";
    };
  };

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" ];
  boot.kernelParams = [
    "panic=30" "boot.panic_on_fail" # reboot the machine upon fatal boot issues
    "console=ttyS0" # enable serial console
    "console=tty1"
  ];

  environment.systemPackages = with pkgs; [ cryptsetup ];
  environment.variables.GC_INITIAL_HEAP_SIZE = "1M";

  services.getty.autologinUser = lib.mkForce "iago";

  security.sudo.wheelNeedsPassword = false;
}
