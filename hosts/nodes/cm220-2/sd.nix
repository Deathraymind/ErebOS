# sd.nix — write-minimizing base for NixOS on an SD card / cheap flash.
# Generic: no host-specific values, import from any node's config.
{lib, ...}: {
  # --- /tmp in RAM -----------------------------------------------------
  # tmpfs, so /tmp churn never touches the card. Capped low on purpose:
  # the default is 50% of RAM. If a host stages big files in /tmp (qcow2
  # imports, restic restores) raise this per-host or send that work to a pool.
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = lib.mkDefault "2G";

  # --- No swap ---------------------------------------------------------
  # The one opinionated line. mkForce clears any swap that
  # hardware-configuration auto-generated. zram (compressed RAM swap)
  # writes nothing to the card — flip it on per-host for an OOM cushion;
  # it's the SD-safe kind of swap.
  swapDevices = lib.mkForce [];
  zramSwap.enable = lib.mkDefault false;

  # --- Logs to RAM -----------------------------------------------------
  # Storage=volatile keeps the journal in /run/log/journal (already tmpfs);
  # it never lands in /var/log/journal. RuntimeMaxUse caps the RAM ring.
  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=64M
  '';
  # Coredumps default to /var/lib/systemd/coredump on disk — drop them.
  systemd.coredump.enable = lib.mkDefault false;

  # --- Mount options ---------------------------------------------------
  # noatime is the biggest cheap write cut after journald: no metadata
  # write on every read. Merges into whatever hardware-configuration set.
  fileSystems."/".options = ["noatime"];

  # --- Store hygiene ---------------------------------------------------
  # On a small card, capacity exhaustion is a likelier death than wear —
  # every generation pins a closure. GC bounds it; auto-optimise hardlinks
  # duplicate store paths to claw back space.
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 14d";
  };
  nix.settings.auto-optimise-store = lib.mkDefault true;

  # Man/info/doc are dead weight in the closure on a headless node —
  # biggest single store-size win here.
  documentation.enable = lib.mkDefault false;
}
