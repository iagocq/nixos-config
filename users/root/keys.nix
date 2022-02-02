rec {
  keys = {
    lasagna = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII4OA5f/3/LBqtwXHqYuR8F0eVFn2/z/k3SO4VTn5uW4";
    pie = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK/QMOTIYs7yS3umoxhQk8yu3kAWN117xxrOoBpO5LcR";
    moldy-lasagna = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINpayUqh0L0IJnHhgaLq5v2880MPcjuIQ/xHAa2eUtjA";
  };

  trusted = { };

  age = with keys; {
    internal = [ lasagna pie ];
    external = [ lasagna ];
  };
}
