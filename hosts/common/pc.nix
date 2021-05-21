{ ... }:

{
  imports = [
    ./configuration.nix
  ];

  hardware.opengl.driSupport32Bit = true;
  
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
    };
  };

  programs.gnupg.agent.enable = true;

  common.audio.enable = true;
}
