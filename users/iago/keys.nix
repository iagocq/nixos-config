rec {
  keys = {
    desktop-iago = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFNF4O2358JTCGFeFnp9SRRmYA60fK5ExGST0UQu+X3p iago@desktop-iago";
    desktop-iago-win = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINgcAAi2pyRznmVuWs0SdqFDJkiqnjRgakWn4gKJYdSl iago@desktop-iago-win";
    raspberrypi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIvd5NhEaaXhs7RhYkYoI6eAE5x/jsILDYZYh8IhprNo iago@raspberrypi";
    termius-cbbaaa = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEc2oQ6l9irWLl7Yw0O4o5q1crHANPxyEwKey7wxRgel termius@cbbaaa";
    termbot-j1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOQi8kz+yLnkN/nxAeb9tjHeon10mqCJqh18WHCjGKF9 termbot@j1";
  };

  trusted = {
    desktop-iago = with keys; [ desktop-iago desktop-iago-win raspberrypi termius-cbbaaa termbot-j1 ];
    desktop-iago-win = trusted.desktop-iago;
    raspberrypi = trusted.desktop-iago;
    amogus = trusted.desktop-iago;
    generic = trusted.desktop-iago;
    lap-1 = trusted.desktop-iago;
  };

  age = with keys; [ desktop-iago desktop-iago-win raspberrypi ];
}
