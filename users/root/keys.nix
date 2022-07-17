let
  iago-keys = import ../iago/keys.nix;
in
rec {
  keys = {
    lasagna = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII4OA5f/3/LBqtwXHqYuR8F0eVFn2/z/k3SO4VTn5uW4";
    pie = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK/QMOTIYs7yS3umoxhQk8yu3kAWN117xxrOoBpO5LcR";
    moldy-lasagna = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINpayUqh0L0IJnHhgaLq5v2880MPcjuIQ/xHAa2eUtjA";
    pineapple = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDDxt4yEapODaeOhF0cKbKtUW4lJ7ahiEfP166VX0QxD";
    buffet = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB2kNHBQDS2S+v/nfVQNqAYgjHwahDJvzK0e//HXYrEK";
  };

  trusted = {
    buffet = with iago-keys.keys; [ lasagna moldy-lasagna ];
  };

  age = with keys; {
    internal = [ lasagna pie moldy-lasagna buffet ];
    external = [ lasagna pineapple ];
    router = trusted.buffet ++ age.internal;
  };
}
