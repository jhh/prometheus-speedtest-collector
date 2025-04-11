{ flake, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.j3ff.watchtower.exporters.speedtest;
  inherit (pkgs) system;
in
{

  options = {
    j3ff.watchtower.exporters.speedtest = {
      enable = lib.mkEnableOption "Prometheus speedtest collection";

      interval = lib.mkOption {
        type = lib.types.str;
        default = "24h";
        description = ''
          OnUnitActiveSec specification for collection.
        '';
      };

      collectionDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/local/prometheus/node-exporter";
        description = ''
          Directory that prometheus-node-exporter collects textfiles from.
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
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      environment = {
        PROMETHEUS_TEXTFILE_DIR = cfg.collectionDir;
      };

      serviceConfig = {
        Type = "oneshot";
        Restart = "no";
        ExecStart = ''
          ${flake.packages.${system}.default}/bin/prometheus-speedtest-collector
        '';

        User = "node-exporter";
        Group = "node-exporter";

        # Basic security hardening
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = cfg.collectionDir;
        NoNewPrivileges = true;

        # Process isolation
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        PrivateDevices = true;
        RestrictAddressFamilies = "AF_INET AF_INET6";
        RestrictNamespaces = true;

        # System call filtering
        SystemCallFilter = "@system-service";
        SystemCallErrorNumber = "EPERM";
        SystemCallArchitectures = "native";

        # Resource limits
        LimitNOFILE = 1024;
        MemoryMax = "256M";
        CPUQuota = "20%";

        # Network access controls
        IPAddressAllow = "any";
        RestrictSUIDSGID = true;
        ProtectClock = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictRealtime = true;
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE CAP_NET_RAW";

        # Filesystem restrictions
        ReadOnlyPaths = "/";
        InaccessiblePaths = "/boot";
      };
    };
  };

}
