{lib, ...}: {
  # /tmp in RAM (tmpfs, defaults to 50% of RAM)
  boot.tmp.useTmpfs = true;
  # boot.tmp.tmpfsSize = "25%"; # see caveat below re: VM imports

  # no swap — mkForce clears anything hardware.nix auto-generated
  swapDevices = lib.mkForce [];
  zramSwap.enable = false;

  # journald to RAM only — logs land in /run/log/journal (tmpfs), never /var
  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=64M
  '';
}
