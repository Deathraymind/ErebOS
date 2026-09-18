# hosts.nix
#
# ─────────────────────────────────────────────────────────────────────────
# HOST OPTIONS — every key a host attrset can carry (the module reads these
# off `host.*`; anything not listed here isn't read)
# ─────────────────────────────────────────────────────────────────────────
#   hostname         string    machine's hostname. Must match the attr name.
#   incus            bool      Incus GUEST agent (true for containers/VMs)
#   incusHost        bool      Incus DAEMON (true for bare-metal nodes)
#   timeZone         string    e.g. "Asia/Tokyo"
#   defaultGateway   string    single default route, one per host
#   nameservers      list      e.g. ["192.168.1.1"] — LIST, not a bare string
#   allowedTCPPorts  list      firewall, e.g. [80 443]
#   allowedUDPPorts  list      firewall, e.g. [53]
#   interfaces       attrset   keyed BY interface name; each value is
#                                { address = "x.x.x.x"; prefixLength = N; }
#   bridges          attrset   keyed BY bridge name; value is a LIST of NICs
#                                enslaved to it, e.g. { br0 = ["eno1"]; }.
#                                The bridge's IP lives in interfaces.<bridge>;
#                                enslaved NICs must NOT appear in interfaces.
#
# ─────────────────────────────────────────────────────────────────────────
# WRITING A HOST — just spread `defaults` and override what differs
# ─────────────────────────────────────────────────────────────────────────
# `defaults` covers the boring shared keys. Each host states only what's
# interesting: its name, its IP (on whichever interface), and any port/flag
# it changes. `//` replaces a whole key, so listing allowedTCPPorts drops
# the default list entirely (that's intended).
#
#   Container / VM:
#     foo = defaults // {
#       hostname = "foo";
#       interfaces.enp5s0 = { address = "192.168.1.99"; prefixLength = 24; };
#     };
#
#   Bare-metal Incus node (IP on br0, one NIC enslaved):
#     node = defaults // {
#       hostname = "node";
#       incus = false; incusHost = true;
#       allowedTCPPorts = [8443];
#       interfaces.br0 = { address = "192.168.1.100"; prefixLength = 24; };
#       bridges.br0 = ["eno1"];
#     };
#
# The enslaved NIC lives ONLY in `bridges`, never in `interfaces` — the IP
# rides the bridge, not the raw member.
#
# ─────────────────────────────────────────────────────────────────────────
# ⚠ BACKEND CAVEAT for the bare-metal nodes
# ─────────────────────────────────────────────────────────────────────────
# This module uses the SCRIPTED backend (networking.bridges/interfaces). The
# nodes also carry the 10GbE inter-node link via MAC-matched networkd. Two
# backends on one host is fragile — before deploying br0 to a headless node,
# confirm they coexist, or move the LAN bridge into networkd and drop it here.
# ─────────────────────────────────────────────────────────────────────────
let
  # Shared defaults. Each host spreads these and overrides what differs.
  defaults = {
    nameservers = ["192.168.1.1"];
    defaultGateway = "192.168.1.1";
    timeZone = "Asia/Tokyo";
    allowedTCPPorts = [];
    allowedUDPPorts = [];
    incus = true; # guest agent (container/VM) — nodes flip this
    incusHost = false;
  };
in {
  # ── Containers (guest agent, single NIC) ────────────────────────────────
  caddy =
    defaults
    // {
      hostname = "caddy";
      interfaces = {
        enp5s0 = {
          address = "192.168.1.10";
          prefixLength = 24;
          allowedTCPPorts = [443]; # ssh, LAN only
        }; # native VLAN, untagged
        net50 = {
          address = "192.168.50.20";
          prefixLength = 24;
          allowedTCPPorts = [443];
        }; # tagged VLAN 20
      };
      vlans = {
        net50 = {
          id = 50;
          interface = "enp5s0";
        };
      };
    }; # ← this closer was missing

  pelican =
    defaults
    // {
      hostname = "pelican";
      interfaces = {
        enp5s0 = {
          address = "192.168.1.50";
          prefixLength = 24;
          allowedTCPPorts = [];
        };
        net50 = {
          address = "192.168.50.10";
          prefixLength = 24;
          allowedTCPPorts = [80 443];
        };
      };
      vlans = {
        net50 = {
          id = 50;
          interface = "enp5s0";
        };
      };
    };
  pelican-wings =
    defaults
    // {
      hostname = "pelican-wings";
      interfaces = {
        enp5s0 = {
          address = "192.168.1.51";
          prefixLength = 24;
          allowedTCPPorts = [];
        };
        net50 = {
          address = "192.168.50.11";
          prefixLength = 24;
          allowedTCPPorts = [2022 8080];
        };
      };
      vlans = {
        net50 = {
          id = 50;
          interface = "enp5s0";
        };
      };
    };

  homeassistant =
    defaults
    // {
      hostname = "homeassistant";
      interfaces = {
        enp5s0 = {
          address = "192.168.1.53";
          prefixLength = 24;
          allowedTCPPorts = [22]; # ssh, LAN only
        }; # native VLAN, untagged
        net20 = {
          address = "192.168.20.2";
          prefixLength = 24;
          allowedTCPPorts = [8123 6052];
        }; # tagged VLAN 20
      };
      vlans = {
        net20 = {
          id = 20;
          interface = "enp5s0";
        };
      };
    }; # ← this closer was missing
  vaultwarden =
    defaults
    // {
      hostname = "homeassistant";
      interfaces = {
        enp5s0 = {
          address = "192.168.1.54";
          prefixLength = 24;
          allowedTCPPorts = []; # ssh, LAN only
        }; # native VLAN, untagged
        net20 = {
          address = "192.168.50.12";
          prefixLength = 24;
          allowedTCPPorts = [8443];
        }; # tagged VLAN 20
      };
      vlans = {
        net50 = {
          id = 50;
          interface = "enp5s0";
        };
      };
    }; # ← this closer was missing

  coredns =
    defaults
    // {
      hostname = "coredns";
      interfaces.eth0 = {
        address = "192.168.1.15";
        prefixLength = 24;
      };
      allowedTCPPorts = [53];
      allowedUDPPorts = [53];
    };

  teleport =
    defaults
    // {
      hostname = "teleport";
      interfaces.eth0 = {
        address = "192.168.1.11";
        prefixLength = 24;
      };
      allowedTCPPorts = [80 3080 443];
      allowedUDPPorts = [80 3080 443];
    };

  # ── Bare-metal Incus cluster nodes (daemon, LAN-bridged via br0) ─────────
  node1 =
    defaults
    // {
      hostname = "node1";
      incus = false;
      incusHost = true;
      allowedTCPPorts = [8443];
      interfaces.br0 = {
        address = "192.168.1.100";
        prefixLength = 24;
      };
      bridges.br0 = ["eno1"];
    };

  node2 =
    defaults
    // {
      hostname = "node2";
      incus = false;
      incusHost = true;
      allowedTCPPorts = [8443];
      interfaces.br0 = {
        address = "192.168.1.99";
        prefixLength = 24;
      };
      bridges.br0 = ["FIXME"]; # ip link on node2 — real LAN NIC name (was "" = bug)
    };
  cm220-1 =
    defaults
    // {
      hostname = "cm220-1";
      incus = false;
      incusHost = true;
      allowedTCPPorts = [8443];
      interfaces.br0 = {
        address = "192.168.1.98";
        prefixLength = 24;
      };
      bridges.br0 = ["enp1s0f0"];
    };

  cm220-2 =
    defaults
    // {
      hostname = "cm220-2";
      incus = false;
      incusHost = true;
      allowedTCPPorts = [8443];
      interfaces.br0 = {
        address = "192.168.1.97";
        prefixLength = 24;
      };
      bridges.br0 = ["enp1s0f0"];
    };
}
