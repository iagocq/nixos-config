let
  users = import ../users { };
  root = users.root.keys.age;
in
rec {
  secrets = {
    "acme-credentials.age".publicKeys = root;
    "zone-iago-casa-internal.age".publicKeys = root;
    "zone-iago-casa-external.age".publicKeys = root;
  };

  age = {
    "acme-credentials".file = ./acme-credentials.age;
    "zone-iago-casa-internal" = { file = ./zone-iago-casa-internal.age; owner = "named"; };
    "zone-iago-casa-external" = { file = ./zone-iago-casa-external.age; owner = "named"; };
  };
}
