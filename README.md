# Speedtest Prometheus Exporter

## Overview

The Speedtest Prometheus Exporter is a NixOS module that periodically runs [speedtest-go](https://github.com/showwin/speedtest-go) network speed tests and exports the results to be used with the Prometheus [node-exporter](https://github.com/prometheus/node_exporter) [textfile collector](https://github.com/prometheus/node_exporter?tab=readme-ov-file#textfile-collector). It gathers data like download and upload speeds, latency, and the time the test was executed, then formats and saves this data in a way that Prometheus can scrape.

## Metrics

The following metrics will be available for Prometheus to scrape:

- `speedtest_timestamp_seconds`: UNIX epoch time of the last speed test.
- `speedtest_download_megabits_per_second`: Download speed in megabits per second.
- `speedtest_upload_megabits_per_second`: Upload speed in megabits per second.
- `speedtest_latency_seconds`: Latency in seconds.

### Labels

All metrics are labeled with:
- `id`: Unique identifier of the server assigned by [speedtest.net](https://www.speedtest.net).
- `name`: Name of the server.
- `sponsor`: The sponsor of the server.
- `distance`: Distance to the server (in kilometers).

## Usage

To use this as a NixOS module, a bare-minimum `flake.nix` would be as follows:

```nix
{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    speedtest.url = "github:jhh/prometheus-speedtest-collector";
    speedtest.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, speedtest, ... }: {
    nixosConfigurations = {
      hostname = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          speedtest.nixosModules.default
          {
            j3ff.watchtower.speedtest.enable = true;
            # optionally set
            # j3ff.watchtower.speedtest.interval = "4h";
            # j3ff.watchtower.speedtest.collectionDir = "/path/to/dir";
          }
        ];
      };
    };
  };
}
```
