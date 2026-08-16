# vm-restic-restore.nix
#
# The pull side of vm-restic-backup. Given a VM name it:
#   1. finds the newest restic snapshot that actually CONTAINS that VM's staged
#      <vm>.qcow2 (skip the search with -s to pin a snapshot id). This matters
#      in a shared repo: `latest` may be the peer node's snapshot, which won't
#      have your VM in it.
#   2. restic-restores just that VM's <vm>.qcow2 + <vm>.xml into a scratch dir
#   3. hands the restored dir to qemu-live-import, which verifies, inflates,
#      repoints the disk path, and (with -D) re-defines the domain.
#
# Repo / secret / staging settings default to whatever programs.vm-restic-backup
# is using, so there's one source of truth; override any of them per-option.
#
# Depends on programs.qemu-live-import: it takes that module's wrapped binary
# straight from its `package` option (so it works even if qemu-live-import isn't
# separately enabled) and relies on that module's `disk` option for the -D
# disk-path repoint.
#
# Secrets live OUTSIDE the Nix store (the same files the backup uses):
#   passwordFile      restic repo password (one line)                  chmod 600
#   environmentFile   AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY for R2  chmod 600
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.vm-restic-restore;
  backup = config.programs.vm-restic-backup;

  restoreScript = pkgs.writeShellApplication {
    name = "vm-restic-restore";
    runtimeInputs = with pkgs;
      [restic coreutils gnugrep jq]
      ++ [config.programs.qemu-live-import.package];

    text = ''
      REPO="${cfg.repository}"
      PASSFILE="${cfg.passwordFile}"
      ENVFILE="${cfg.environmentFile}"
      STAGING="${cfg.stagingDir}"
      IMAGES_PARENT="${cfg.imagesParent}"
      TMPBASE="${cfg.scratchDir}"

      SNAP=""
      DEST=""
      NEWNAME=""
      DO_DEFINE=0
      FORCE=0
      KEEP=0

      usage() {
        cat <<EOF
      Usage: vm-restic-restore [options] <vm>
        Pulls a VM's staged image out of the restic (R2) repo and imports it.

        -s SNAP  restic snapshot id to restore from (default: newest containing <vm>)
        -d DIR   directory to create the disk in (default: $IMAGES_PARENT/<vm>)
        -n NAME  import under a different VM name
        -D       define the domain from the restored XML (disaster-recovery restore)
        -f       overwrite an existing destination image
        -K       keep the restic scratch copy (default: cleaned up on exit)
        -h       this help
      EOF
      }

      while getopts "s:d:n:DfKh" opt; do
        case "$opt" in
          s) SNAP="$OPTARG" ;;
          d) DEST="$OPTARG" ;;
          n) NEWNAME="$OPTARG" ;;
          D) DO_DEFINE=1 ;;
          f) FORCE=1 ;;
          K) KEEP=1 ;;
          h) usage; exit 0 ;;
          \?) echo "bad option; -h for help" >&2; exit 1 ;;
        esac
      done
      shift $((OPTIND - 1))

      if [ "$(id -u)" -ne 0 ]; then
        echo "run as root: sudo vm-restic-restore ..." >&2
        exit 1
      fi
      if [ "$#" -lt 1 ]; then
        echo "no VM given. Usage: vm-restic-restore [options] <vm>. -h for help." >&2
        exit 1
      fi
      VM="$1"

      [ -f "$PASSFILE" ] || { echo "missing restic password file: $PASSFILE" >&2; exit 1; }
      [ -f "$ENVFILE" ]  || { echo "missing R2 env file: $ENVFILE" >&2; exit 1; }

      [ -n "$DEST" ] || DEST="$IMAGES_PARENT/$VM"

      export RESTIC_REPOSITORY="$REPO"
      export RESTIC_PASSWORD_FILE="$PASSFILE"
      set -a
      # shellcheck disable=SC1090
      . "$ENVFILE"
      set +a

      WANT="$STAGING/$VM.qcow2"

      # ---- pick the snapshot (newest that actually holds this VM) ----
      if [ -z "$SNAP" ]; then
        echo "Finding newest snapshot containing $WANT ..."
        ids="$(restic snapshots --json --tag vm-backup | jq -r 'sort_by(.time) | reverse | .[].short_id')"
        for id in $ids; do
          if restic ls "$id" 2>/dev/null | grep -qF -- "$WANT"; then
            SNAP="$id"; break
          fi
        done
        if [ -z "$SNAP" ]; then
          echo "ERROR: no snapshot contains $WANT." >&2
          echo "See what's in the repo with: restic snapshots --tag vm-backup" >&2
          exit 1
        fi
      fi
      echo "Using snapshot: $SNAP"

      # ---- restore just this VM's files into scratch ----
      TMP="$TMPBASE/$VM.$$"
      rm -rf "$TMP"; mkdir -p "$TMP"
      cleanup() { [ "$KEEP" -eq 1 ] || rm -rf "$TMP"; }
      trap cleanup EXIT

      echo "Restoring $VM.qcow2 + $VM.xml from $SNAP ..."
      restic restore "$SNAP" --target "$TMP" \
        --include "$STAGING/$VM.qcow2" \
        --include "$STAGING/$VM.xml"

      # restic recreates the full absolute path under --target
      RDIR="$TMP''${STAGING}"
      if [ ! -f "$RDIR/$VM.qcow2" ]; then
        echo "ERROR: expected $RDIR/$VM.qcow2 after restore but it isn't there." >&2
        exit 1
      fi
      [ -f "$RDIR/$VM.xml" ] || echo "NOTE: no $VM.xml in snapshot; -D define will be skipped by the importer."

      # ---- hand off to qemu-live-import (it verifies/inflates/defines) ----
      args=(-d "$DEST")
      [ "$DO_DEFINE" -eq 1 ] && args+=(-D)
      [ "$FORCE" -eq 1 ] && args+=(-f)
      [ -n "$NEWNAME" ] && args+=(-n "$NEWNAME")
      args+=("$RDIR")

      echo "Importing: qemu-live-import ''${args[*]}"
      qemu-live-import "''${args[@]}"
    '';
  };
in {
  options.programs.vm-restic-restore = {
    enable = mkEnableOption "Pull + import a VM image from the restic (R2) repo (companion to vm-restic-backup)";

    repository = mkOption {
      type = types.str;
      default = backup.repository;
      description = "restic repository URL. Defaults to programs.vm-restic-backup.repository.";
    };
    passwordFile = mkOption {
      type = types.str;
      default = backup.passwordFile;
      description = "restic repo password file. Defaults to the backup module's.";
    };
    environmentFile = mkOption {
      type = types.str;
      default = backup.environmentFile;
      description = "File exporting AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY for R2. Defaults to the backup module's.";
    };
    stagingDir = mkOption {
      type = types.str;
      default = backup.stagingDir;
      description = "Staging path the backup used; image paths inside the snapshots live under here. Defaults to the backup module's.";
    };
    imagesParent = mkOption {
      type = types.str;
      default = "/var/lib/libvirt/images";
      description = "Parent dir for restored disks. Default dest is <imagesParent>/<vm>, matching the backup layout.";
    };
    scratchDir = mkOption {
      type = types.str;
      default = "/var/lib/vm-restic-restore";
      description = "Scratch dir the snapshot is restored into before import. Per-run subdir, wiped on exit unless -K.";
    };
    package = mkOption {
      type = types.package;
      readOnly = true;
      default = restoreScript;
      description = "The restore script package, for use by other modules.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [restoreScript];
  };
}
