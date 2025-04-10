{ flake, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs) system;
in
{

  systemd.services.prometheus-speedtest-collector = {
    description = "Prometheus Speedtest collector";
    environment = {
      PROMETHEUS_TEXTFILE_DIR = "/var/local/prometheus/node-exporter";
    };

    startAt = "*-*-* 06,18:23:00";
    serviceConfig = {
      ExecStart = ''
        ${flake.packages.${system}.default}/bin/prometheus-speedtest-collector
      '';
      Restart = "on-failure";

      User = "node-exporter";

      BindReadOnlyPaths = [
        "${
          config.environment.etc."ssl/certs/ca-certificates.crt".source
        }:/etc/ssl/certs/ca-certificates.crt"
        builtins.storeDir
        "-/etc/resolv.conf"
        "-/etc/nsswitch.conf"
        "-/etc/hosts"
        "-/etc/localtime"
      ];

      RestrictAddressFamilies = "AF_UNIX AF_INET";
      CapabilityBoundingSet = "";
      SystemCallFilter = [
        "@system-service"
        "~@privileged @setuid @keyring"
      ];
    };

    wantedBy = [ "multi-user.target" ];
  };

}
