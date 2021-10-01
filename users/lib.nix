{ lib ? null, pkgs ? null }:
rec {
  loadUsers = users: user-list:
    builtins.listToAttrs
      (map (x: rec { name = x; a = if users ? ${x} then x else "default"; value = users.${a}; }) user-list);

  listOf = attrname: users:
    builtins.attrValues (attrsOf attrname users);

  attrsOf = attrname: users:
    lib.attrsets.filterAttrs (n: v: v != {})
      (lib.attrsets.mapAttrs (n: v: if v ? ${attrname} then v.${attrname} else {}) users);

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
