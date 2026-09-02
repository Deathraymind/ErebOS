# hosts.nix
#
# ─────────────────────────────────────────────────────────────────────────
# HOST OPTIONS — every key a host attrset can carry
# ─────────────────────────────────────────────────────────────────────────
# The module reads these off `host.*`. Anything not listed here isn't read.
#
#   hostname         string    machine's hostname (mkHost sets this from the
#                              attr name for you; don't pass it manually)
#   incus            bool      enable the Incus guest agent (true for all
#                              containers here)
#   timeZone         string    e.g. "Asia/Tokyo"
#   defaultGateway   string    single default route, host-global, one per host
#                              even on multi-NIC boxes
#   nameservers      list      resolver list, e.g. ["192.168.1.1"] — LIST, not
#                              a bare string (module passes it through unwrapped)
#   allowedTCPPorts  list      firewall, e.g. [80 443]
#   allowedUDPPorts  list      firewall, e.g. [53]
#   interfaces       attrset   keyed BY interface name; each value is
#                                { address = "x.x.x.x"; prefixLength = N; }
#
# ─────────────────────────────────────────────────────────────────────────
# mkHost — sugar for the common single-NIC case
# ─────────────────────────────────────────────────────────────────────────
# Takes `ip`, `interface`, `prefixLength` as flat scalars and folds them into
# a one-entry `interfaces` attrset. Everything unspecified comes from
# `defaults`. Only pass the keys that DIFFER from defaults:
#
#   foo = mkHost "foo" { ip = "192.168.1.99"; };              # fully standard
#   bar = mkHost "bar" { ip = "192.168.1.98";                 # overrides ports
#                        allowedTCPPorts = [22]; };
#
# ─────────────────────────────────────────────────────────────────────────
# MULTI-INTERFACE host — bypass mkHost, write `interfaces` directly
# ─────────────────────────────────────────────────────────────────────────
# mkHost is single-NIC by design. For a box with 2+ NICs, merge `defaults`
# yourself and give `interfaces` explicitly. Omit ip/interface/prefixLength —
# they only exist to feed mkHost. Still ONE defaultGateway.
#
#   gateway = defaults // {
#     hostname = "gateway";
#     interfaces = {
#       eth0 = { address = "192.168.1.1"; prefixLength = 24; };
#       eth1 = { address = "10.0.0.1";    prefixLength = 24; };
#     };
#     defaultGateway = "192.168.1.1";      # still just one
#     allowedTCPPorts = [22 80 443];
#   };
#
# (The leftover `interface`/`prefixLength` scalars from `defaults` linger on
#  the result but are harmless — the module never reads them, only reads
#  `interfaces`. removeAttrs them if you want it tidy.)
# ─────────────────────────────────────────────────────────────────────────
let
  # Shared defaults. Per-host attrs override these.
  defaults = {
    prefixLength = 24;
    nameservers = ["192.168.1.1"];
    defaultGateway = "192.168.1.1";
    timeZone = "Asia/Tokyo";
    allowedTCPPorts = [8080 2022 80 443];
    allowedUDPPorts = [];
    incus = true;
    interface = "enp5s0";
  };

  # Merge defaults, fold ip/interface/prefixLength into interfaces,
  # then drop those scalar keys from the result.
  mkHost = name: attrs: let
    merged = defaults // attrs;
  in
    (removeAttrs merged ["ip" "interface" "prefixLength"])
    // {
      hostname = name;
      interfaces.${merged.interface} = {
        address = merged.ip;
        inherit (merged) prefixLength;
      };
    };
in {
  caddy = mkHost "caddy" {ip = "192.168.1.10";};
  pelican = mkHost "pelican" {ip = "192.168.1.50";};
  pelican-wings = mkHost "pelican-wings" {ip = "192.168.1.51";};
  vaultwarden = mkHost "vaultwarden" {ip = "192.168.1.53";};

  coredns = mkHost "coredns" {
    ip = "192.168.1.15";
    interface = "eth0";
    allowedTCPPorts = [53];
    allowedUDPPorts = [53];
  };

  teleport = mkHost "teleport" {
    ip = "192.168.1.11";
    interface = "eth0";
    allowedTCPPorts = [80 3080 443];
    allowedUDPPorts = [80 3080 443];
  };
  cm220-1 = mkHost "cm220-1" {
    ip = "192.168.1.98";
    interface = "enp1s0f0";
    allowedTCPPorts = [];
    allowedUDPPorts = [];
  };
  cm220-2 = mkHost "cm220-2" {
    ip = "192.168.1.97";
    interface = "enp1s0f0";
    allowedTCPPorts = [];
    allowedUDPPorts = [];
  };
  node1 = mkHost "node1" {
    ip = "192.168.1.100";
    interface = "eno1";
    allowedTCPPorts = [];
    allowedUDPPorts = [];
  };
  node2 = mkHost "node2" {
    ip = "192.168.1.99";
    interface = "1enp3s0f0";
    allowedTCPPorts = [];
    allowedUDPPorts = [];
  };
}
