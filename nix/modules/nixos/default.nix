{ flake, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.j3ff.watchtower.prometheus-speedtest-collector;
  inherit (pkgs) system;
in
{

  options = {
    j3ff.watchtower.prometheus-speedtest-collector = {
      enable = lib.mkEnableOption "Prometheus speedtest collection";

      interval = lib.mkOption {
        type = lib.types.str;
        default = "24h";
        description = ''
          OnUnitActiveSec specification for collection.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.timers.prometheus-speedtest-collector = {
      description = "Run Prometheus speedtest collector periodically";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnUnitActiveSec = cfg.interval;
        OnBootSec = "30m";
      };
    };

    systemd.services.prometheus-speedtest-collector = {
      description = "Prometheus speedtest collector";
      environment = {
        PROMETHEUS_TEXTFILE_DIR = "/var/local/prometheus/node-exporter";
      };

      serviceConfig = {
        Type = "oneshot";
        Restart = "no";
        ExecStart = ''
          ${flake.packages.${system}.default}/bin/prometheus-speedtest-collector
        '';

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
    };
  };

}
