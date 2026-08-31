# hosts.nix
{
  caddy = {
    hostname = "caddy";
    ip = "192.168.1.10";
    prefex = "24";
    nameservers = "192.168.1.1";
  };
  nyx = {
  };
  # ...13 more
}
