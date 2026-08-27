{
  config,
  lib,
  pkgs,
  ...
}: {
  # ------------------------------------------------------------------
  # node1 as a single Incus host (KVM VMs + system containers) on ZFS.
  #
  # THREE THINGS YOU MUST FILL IN before building (marked FIXME):
  #   1. <PHYS_IFACE>  -- node1's real NIC name (run `ip -br link`)
  #   2. node1's static IP / gateway (kept identical to today so
  #      nothing else on the LAN has to change)
  #   3. The zpool must already exist: `zpool create -o ashift=12 \
  #      vmpool /dev/disk/by-id/<ssd>` before first boot. Incus creates
  #      the `vmpool/incus` dataset itself from the preseed below; you
  #      just provide the pool.
  #
  # DECLARATIVE BOUNDARY -- read this once so it's not a surprise later:
  #   This module manages the Incus *daemon* and its INITIAL storage
  #   pool / network / profile via preseed (applied when the daemon is
  #   first initialized -- exactly right for a fresh node1). It does
  #   NOT manage individual instances. VMs/containers are created and
  #   moved with the `incus` CLI and live in Incus's own database, not
  #   in this flake. That's the one place Incus is less declarative
  #   than your hand-rolled setup -- instance lifecycle is imperative.
  # ------------------------------------------------------------------
  networking.nftables.enable = true;
  boot.supportedFilesystems = ["zfs"];

  # --- Host LAN bridge -------------------------------------------------
  # Incus instances attach to THIS host bridge (nictype=bridged, parent=br0
  # in the profile below), so they land on the physical LAN and pull IPs
  # the same way your current bridged VMs do -- NOT behind Incus's default
  # NAT bridge. Because node1 is a fresh install, we bake the bridge in from
  # first boot: no live cutover, no risk of dropping your SSH session moving
  # the host IP onto the bridge (which is how bridging bites people).
  networking.useDHCP = false;
  networking.bridges.br0.interfaces = ["enp3s0f0"]; # FIXME: e.g. eno1
  networking.interfaces.br0 = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "192.168.1.99"; # FIXME: node1's static IP (unchanged)
        prefixLength = 24;
      }
    ];
  };
  networking.defaultGateway = "192.168.1.1"; # FIXME
  networking.nameservers = ["192.168.1.1"]; # FIXME

  # --- Incus ------------------------------------------------------------
  virtualisation.incus = {
    enable = true;

    # Built-in web UI (the thing you missed). Served by the daemon on the
    # https_address set in preseed below -> https://192.168.1.100:8443
    # (verify this option exists in your nixpkgs; on older channels drop it
    #  and the API/UI still work once core.https_address is set.)
    ui.enable = true;

    preseed = {
      config = {
        # Expose the API + UI on the LAN. Without this, incus is
        # local-socket only and you get no web UI.
        "core.https_address" = ":8443";
      };

      # ZFS storage pool named "default", living in a dataset Incus
      # creates and owns under your existing vmpool. Keeping it in a
      # dedicated child dataset means the zpool stays yours -- Incus
      # manages vmpool/incus, you manage the rest.
      storage_pools = [
        {
          name = "default";
          driver = "zfs";
          config = {
            source = "vmpool/incus";
          };
        }
      ];

      # No Incus-managed network here: instances use the HOST br0 bridge
      # (defined above) via the profile's nic device, so they're on the
      # real LAN. (If you ever want an isolated NAT network instead, you'd
      # add a `networks` entry of type bridge and point the nic at it.)
      networks = [];

      profiles = [
        {
          name = "default";
          devices = {
            root = {
              type = "disk";
              path = "/";
              pool = "default";
            };
            eth0 = {
              type = "nic";
              name = "eth0";
              nictype = "bridged";
              parent = "br0";
            };
          };
        }
      ];
    };
  };

  # UI/API port. (Instance traffic rides the bridge and isn't filtered by
  # the host firewall; this is only for reaching Incus itself.)
  networking.firewall.allowedTCPPorts = [8443];

  # Handy to have the disk tooling around for the qcow2 import step.
  environment.systemPackages = with pkgs; [qemu-utils];
}
