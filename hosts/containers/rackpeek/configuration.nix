{...}: {
  # Docker backend (Podman is NixOS's default and works as a drop-in if you'd rather).
  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";

  virtualisation.oci-containers.containers.rackpeek = {
    image = "aptacode/rackpeek:latest";

    ports = ["8080:8080"];

    # Named volume — the backend creates "rackpeek-config" on first run,
    # so there's no separate top-level `volumes:` block to declare.
    volumes = ["rackpeek-config:/app/config"];

    autoStart = true;

    # No first-class healthcheck option in the module, so the flags go
    # straight to `docker run` via extraOptions.
    extraOptions = [
      "--health-cmd=curl -fsS http://localhost:8080/health"
      "--health-interval=30s"
      "--health-timeout=5s"
      "--health-start-period=15s"
      "--health-retries=3"
    ];
  };
}
