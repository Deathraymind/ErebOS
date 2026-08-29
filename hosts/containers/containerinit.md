{ modulesPath,lib, ... }: { imports = [
"${modulesPath}/virtualisation/lxc-container.nix" ./incus.nix ]; nix.settings =
{ # Allow falling back to non-sandboxed builds if the kernel rejects it sandbox
= "relaxed"; # or false to turn it completely off sandbox-fallback = lib.mkForce
true; }; networking = { dhcpcd.enable = false; useDHCP = false;
useHostResolvConf = false; };

systemd.network = { enable = true; networks."50-eth0" = { matchConfig.Name =
"eth0"; networkConfig = { DHCP = "ipv4"; IPv6AcceptRA = true; };
linkConfig.RequiredForOnline = "routable"; }; };

# SSH, root login on

services.openssh = { enable = true; settings.PermitRootLogin = "yes"; };

# root needs a password or sshd accepts every login attempt and then rejects it

users.users.root.password = "changeme";

system.stateVersion = "26.05"; }

add that in nano /etc/nixos/configuration.nix

then run

sudo nixos-rebuild switch --option sandbox false

then you have a container you can remote build on.
