let
  root = (import ../../users/root/keys.nix).age.external;
in
rec {
  secrets = {
    "acme-credentials.age".publicKeys = root;
  };

  age =
    let
      files = {
        "acme-credentials".file = ./acme-credentials.age;
      };
    in
      f: { ${f} = files.${f}; };
}
