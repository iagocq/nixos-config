rec {
  keys = {
    lasagna = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFNF4O2358JTCGFeFnp9SRRmYA60fK5ExGST0UQu+X3p";
    moldy-lasagna = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINgcAAi2pyRznmVuWs0SdqFDJkiqnjRgakWn4gKJYdSl";
    pie = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIvd5NhEaaXhs7RhYkYoI6eAE5x/jsILDYZYh8IhprNo";
    pineapple = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKILijSSL1msdszj1yUVuKn1PuRvaNoWN5BlMu2cQbTP";
    apple = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEc2oQ6l9irWLl7Yw0O4o5q1crHANPxyEwKey7wxRgel";
    termbot-j1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOQi8kz+yLnkN/nxAeb9tjHeon10mqCJqh18WHCjGKF9";
  };

  trusted = {
    lasagna = with keys; [ lasagna moldy-lasagna pie pineapple apple termbot-j1 ];
    moldy-lasagna = trusted.lasagna;
    pie = trusted.lasagna;
    pineapple = trusted.lasagna;
    generic = trusted.lasagna;
    lap-1 = trusted.lasagna;
  };

  age = with keys; [ lasagna moldy-lasagna pie pineapple ];
}
