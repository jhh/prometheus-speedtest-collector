#!@python@

import json
import os
import subprocess
from datetime import datetime

from prometheus_client import CollectorRegistry, Gauge, write_to_textfile

SPEEDTEST_JSON = "SPEEDTEST_JSON"


def run_speedtest() -> dict | None:
    try:
        output = subprocess.check_output(
            ["@speedtest_go@", "--multi", "--json"], stderr=subprocess.STDOUT
        )
        return json.loads(output)
    except subprocess.CalledProcessError as e:
        print(f"Error running speedtest: {e.output}")
        return None
    except json.JSONDecodeError as e:
        print(f"Error decoding JSON: {e}")
        return None


def get_env_var_as_json(var_name: str) -> dict | None:
    value = os.getenv(var_name)
    if value:
        try:
            return json.loads(value)
        except json.JSONDecodeError as e:
            print(f"Error decoding JSON from environment variable '{var_name}': {e}")
    return None


def parse_timestamp_to_unix_epoch(timestamp: str) -> float:
    dt = datetime.strptime(timestamp, "%Y-%m-%d %H:%M:%S.%f")
    return dt.timestamp()


LABELS = ["id", "name", "sponsor", "distance"]


def parse_metrics(data: dict) -> CollectorRegistry:
    registry = CollectorRegistry()

    id = data["servers"][0]["id"]
    name = data["servers"][0]["name"]
    sponsor = data["servers"][0]["sponsor"]
    distance = data["servers"][0]["distance"]

    speedtest_timestamp_seconds = Gauge(
        "speedtest_timestamp_seconds",
        "Speedtest last run time.",
        LABELS,
        registry=registry,
    )
    speedtest_timestamp_seconds.labels(id, name, sponsor, distance).set(
        parse_timestamp_to_unix_epoch(data["timestamp"])
    )

    speedtest_download_megabits_per_second = Gauge(
        "speedtest_download_megabits_per_second",
        "Speedtest download speed in Mbps.",
        LABELS,
        registry=registry,
    )
    speedtest_download_megabits_per_second.labels(id, name, sponsor, distance).set(
        (data["servers"][0]["dl_speed"] * 8) / 1_000_000
    )

    speedtest_upload_megabits_per_second = Gauge(
        "speedtest_upload_megabits_per_second",
        "Speedtest upload speed in Mbps.",
        LABELS,
        registry=registry,
    )
    speedtest_upload_megabits_per_second.labels(id, name, sponsor, distance).set(
        (data["servers"][0]["ul_speed"] * 8) / 1_000_000
    )

    speedtest_latency_seconds = Gauge(
        "speedtest_latency_seconds",
        "Speedtest latency in seconds.",
        LABELS,
        registry=registry,
    )
    speedtest_latency_seconds.labels(id, name, sponsor, distance).set(
        data["servers"][0]["latency"] / 1_000_000_000
    )

    return registry


def main():
    if SPEEDTEST_JSON in os.environ:
        data = get_env_var_as_json(SPEEDTEST_JSON)
    else:
        data = run_speedtest()

    if data:
        write_to_textfile(
            os.environ["PROMETHEUS_TEXTFILE_DIR"] + "/speedtest.prom",
            parse_metrics(data),
        )


if __name__ == "__main__":
    main()
