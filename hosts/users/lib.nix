{ lib ? null, pkgs ? null }:
rec {
  loadUsers = users: user-list:
    builtins.listToAttrs
      (map (x: rec { name = x; value = users.${x} or users.default; }) user-list);

  listOf = attrname: users:
    builtins.attrValues (attrsOf attrname users);

  attrsOf = attrname: users:
    lib.attrsets.filterAttrs (n: v: v != {})
      (lib.attrsets.mapAttrs (n: v: v.${attrname} or {}) users);

  mkKeyFile = key:
    let k = { pub = key; desc = builtins.elemAt (builtins.split " " key) 4; };
    in pkgs.writeText k.desc k.pub;

  mkKeys = module: module // {
    files =
      lib.attrsets.mapAttrsRecursive
        (p: v: if builtins.isList v then map (x: mkKeyFile x) v else mkKeyFile v)
        module;
  };
}
