{ host, ... }:

{
  users.users.root = {
    openssh.authorizedKeys.keys = (import ./keys.nix).trusted.${host} or [];
  };
}
