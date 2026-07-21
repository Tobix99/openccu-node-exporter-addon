# OpenCCU Prometheus Node Exporter AddOn

Prometheus monitoring AddOn for [OpenCCU](https://github.com/OpenCCU/OpenCCU) (formerly RaspberryMatic).

## What it does

- Runs the upstream [Prometheus node_exporter](https://github.com/prometheus/node_exporter) on port `9100`.
- Exposes standard Linux system metrics (CPU, memory, disk, network, load, etc.).
- Adds a Homematic-specific metric via the node_exporter textfile collector:
  - `hm_service_messages` — active service messages

## Compatibility

x86_64 OpenCCU only (e.g. the official OVA VM image). Other architectures are not supported.

## Installation

1. Download `openccu-prometheus-node-exporter-<version>.tar.gz` from the [latest release](https://github.com/Tobias-Heinze_dtag/openccu-prometheus-node-exporter/releases/latest).
2. Open the OpenCCU WebUI and go to `Systemsteuerung → Zusatzsoftware`.
3. Upload the tarball and install it.
4. The addon starts automatically. Prometheus can now scrape `http://<openccu>:9100/metrics`.

## Security note

The exporter listens on `0.0.0.0:9100` without authentication. Only run it on a trusted LAN or firewall the port.

## Prometheus scrape config

```yaml
scrape_configs:
  - job_name: 'openccu'
    static_configs:
      - targets: ['openccu:9100']
```

## Homematic textfile collector

`bin/collect-hm-metrics.tcl` runs every 60 seconds via the rc.d service and writes Homematic-specific
metrics (e.g. `hm_service_messages`) to a node_exporter textfile collector directory, so they are
automatically merged into the `/metrics` output alongside standard system metrics.

## Development

Requirements: `make`, `curl`, `tar`, `sha256sum` (coreutils), `shellcheck`.

```bash
make build   # creates dist/openccu-prometheus-node-exporter-*.tar.gz
make verify  # builds and checks tarball contents
make clean   # removes build/ and dist/
```

## Architecture

- `update_script` — installs the addon to `/usr/local/addons/node_exporter`.
- `rc.d/node_exporter` — start/stop service script registered in `/usr/local/etc/config/rc.d/`.
- `bin/node_exporter` — upstream static binary.
- `bin/collect-hm-metrics.tcl` — refreshes Homematic metrics every 60 seconds.

## License

MIT
