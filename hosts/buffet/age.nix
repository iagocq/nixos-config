let
  root = (import ../../users/root/keys.nix).age.router;
in
rec {
  secrets = {
    "pppd-credentials.age".publicKeys = root;
    "wpa-psk.age".publicKeys = root;
  };

  age = {
    "pppd-credentials".file = ./pppd-credentials.age;
    "wpa-psk".file = ./wpa-psk.age;
  };
}
