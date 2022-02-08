let
  root = (import ../../users/root/keys.nix).age.internal;
in
rec {
  secrets = {
    "acme-credentials.age".publicKeys = root;
    "zone-iago-casa-internal.age".publicKeys = root;
    "zone-iago-casa-external.age".publicKeys = root;
  };

  age =
    let
      files = {
        "acme-credentials".file = ./acme-credentials.age;
        "zone-iago-casa-internal" = { file = ./zone-iago-casa-internal.age; owner = "named"; };
        "zone-iago-casa-external" = { file = ./zone-iago-casa-external.age; owner = "named"; };
      };
    in
      f: { ${f} = files.${f}; };
}
