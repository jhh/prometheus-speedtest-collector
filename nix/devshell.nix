{
  inputs,
  pkgs,
  system,
}:
let
  inherit (inputs.self.checks.${system}) pre-commit;
  python = pkgs.python3.withPackages (ps: [ ps.prometheus-client ]);
in
pkgs.mkShell {
  packages =
    with pkgs;
    [
      just
      nil
      nix-output-monitor
      nixfmt-rfc-style
      python
    ]
    ++ pre-commit.enabledPackages;

  env = {
    SPEEDTEST_JSON = ''
      {
        "timestamp": "2025-04-10 11:42:59.413",
        "user_info": {
          "IP": "69.234.60.148",
          "Lat": "42.271",
          "Lon": "-85.542",
          "Isp": "AT&T Internet"
        },
        "servers": [
          {
            "url": "http://speedtest.lagrangeremcisp.net:8080/speedtest/upload.php",
            "lat": "41.6289",
            "lon": "-85.3963",
            "name": "LaGrange, IN",
            "country": "United States",
            "sponsor": "LaGrange County REMC",
            "id": "48317",
            "host": "speedtest.lagrangeremcisp.net.prod.hosts.ooklaserver.net:8080",
            "distance": 72.48892090875606,
            "latency": 31474179,
            "max_latency": 31992259,
            "min_latency": 30898865,
            "jitter": 317382,
            "dl_speed": 87876260.2360556,
            "ul_speed": 142518690.69404846,
            "test_duration": {
              "ping": 2550052620,
              "download": null,
              "upload": null,
              "total": 2550052620
            },
            "packet_loss": {
              "sent": 0,
              "dup": 0,
              "max": 0
            }
          }
        ]
      }
    '';
  };

  shellHook = ''
    ${pre-commit.shellHook}
  '';
}
