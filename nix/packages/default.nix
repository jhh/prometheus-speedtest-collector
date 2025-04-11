{ pkgs, ... }:
let
  python = pkgs.python3.withPackages (ps: [ ps.prometheus-client ]);
  inherit (pkgs.stdenv) mkDerivation;
  inherit (pkgs) lib;
in
mkDerivation {
  name = "prometheus-speedtest-collector";
  version = "1.0.0";
  src = ../..;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp main.py  $out/bin/prometheus-speedtest-collector
    chmod +x $out/bin/prometheus-speedtest-collector
    speedtest_go=${lib.getExe pkgs.speedtest-go} python=${lib.getExe python} \
        substituteAllInPlace $out/bin/prometheus-speedtest-collector
    runHook postInstall
  '';
}
