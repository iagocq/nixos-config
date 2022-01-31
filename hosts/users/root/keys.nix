rec {
  keys = {
    desktop-iago = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII4OA5f/3/LBqtwXHqYuR8F0eVFn2/z/k3SO4VTn5uW4 root@desktop-iago";
    raspberrypi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK/QMOTIYs7yS3umoxhQk8yu3kAWN117xxrOoBpO5LcR root@raspberrypi";
    desktop-iago-win = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINpayUqh0L0IJnHhgaLq5v2880MPcjuIQ/xHAa2eUtjA root@desktop-iago-win";
  };

  trusted = { };

  age = with keys; {
    internal = [ desktop-iago raspberrypi ];
    external = [ desktop-iago ];
  };
}
