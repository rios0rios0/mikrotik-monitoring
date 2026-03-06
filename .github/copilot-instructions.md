# Copilot Instructions

## Project Overview

MikroTik Monitoring is a ready-to-use, Docker Compose-based observability stack for MikroTik routers running RouterOS 7.x.
It collects router metrics via the MikroTik API, stores them in Prometheus, and visualises them in Grafana.
The stack is designed to run on a Raspberry Pi 4 (ARM 64-bit, Ubuntu Server) but works on any `linux/amd64` or `linux/arm64` host.

## Project Structure

```
.
├── blackbox/               # Prometheus Blackbox Exporter config (ICMP latency probes)
│   └── blackbox.yml
├── docker-armor/           # AppArmor profile for hardened deployments
├── doc/                    # Screenshot assets used in README.md
├── grafana/
│   └── provisioning/
│       ├── dashboards/     # Auto-provisioned Grafana dashboard JSON files
│       └── datasources/    # Auto-provisioned Prometheus datasource definition
├── mktxp/                  # MKTXP exporter config (router credentials & metric flags)
│   ├── mktxp.conf          # Per-router and default metric settings
│   └── _mktxp.conf         # Internal MKTXP defaults (do not edit)
├── nginx/                  # Nginx reverse-proxy config and TLS certificates
├── prometheus/
│   └── prometheus.yml      # Prometheus scrape jobs and retention settings
├── .env                             # Runtime environment variables (admin credentials)
├── docker-compose.yml               # Standard stack
├── docker-compose-armored.yml       # Hardened stack with AppArmor profiles
└── Makefile                         # Developer convenience targets
```

## Build & Development Commands

```bash
# Start the full monitoring stack (Prometheus, Grafana, MKTXP, Blackbox, Nginx)
make run           # equivalent to: docker compose up

# Tear down all containers and remove named volumes
make clean         # equivalent to: docker compose down + volume cleanup

# Start with AppArmor hardening
docker compose -f docker-compose-armored.yml up -d
```

After `make run`, the Grafana dashboard is available at <http://localhost:80> (default credentials: `admin` / `admin`).

## Architecture

The stack follows a **pipeline / scrape-and-visualise** pattern with no custom application code:

```
MikroTik Router  ──API──▶  MKTXP Exporter (:49090)  ─┐
                                                        ├─▶  Prometheus  ──▶  Grafana  ──▶  Nginx (reverse proxy)
External IPs ──ICMP──▶  Blackbox Exporter (:9115)    ─┘
```

| Component | Image | Role |
|---|---|---|
| `prometheus` | `prom/prometheus` | Time-series database; scrapes MKTXP and Blackbox |
| `grafana` | `grafana/grafana` | Dashboard visualisation; auto-provisioned from `grafana/provisioning/` |
| `mktxp` | `ghcr.io/akpw/mktxp` | Prometheus exporter for MikroTik RouterOS API |
| `blackbox` | `prom/blackbox-exporter` | ICMP latency and packet-loss probes |
| `nginx` | `nginx` | Reverse proxy; terminates TLS (optional) |

All services communicate on a private Docker bridge network (`default`). Only Nginx exposes ports 80 and 443 to the host.

## Configuration

- **Router credentials**: edit `mktxp/mktxp.conf` — set `hostname`, `username`, `password` under `[default]` or per-device sections.
- **Prometheus retention**: set `--storage.tsdb.retention.time` in `docker-compose.yml` (default: 1 year).
- **Blackbox targets**: edit `blackbox/blackbox.yml` to add or change ICMP probe targets.
- **Environment variables**: copy `.env` and override `ADMIN_USER` / `ADMIN_PASSWORD` for Grafana.
- **HTTPS**: replace `nginx/nginx.conf` with the SSL server block and regenerate the self-signed certificate (see README).

## Coding Conventions

- All configuration files use YAML or INI format; follow the indentation and comment style already present in each file.
- Docker Compose service names use lowercase kebab-case (e.g., `mikrotik-prometheus`, `mikrotik-grafana`).
- Grafana dashboards are maintained as JSON in `grafana/provisioning/dashboards/mikrotik/`.
- Prometheus scrape jobs are named after the exporter they target (e.g., `mikrotik`, `blackbox`).
- Use pinned image tags in `docker-compose.yml` (e.g., `prom/prometheus:v3.4.1`) to ensure reproducible deployments. Only `nginx` uses `latest` as a deliberate exception.
- Keep secrets out of version control; use the `.env` file or environment variables.

## Testing

This project is an infrastructure/configuration repository with no application source code.
There is no automated test suite.
Functional verification is done manually:

1. Run `make run` and check that all containers reach a healthy state (`docker compose ps`).
2. Confirm Prometheus scrapes are succeeding at <http://localhost:9090/targets>.
3. Verify the Grafana dashboard loads data at <http://localhost:80>.
4. Check MKTXP logs for API connection errors: `docker compose logs mktxp`.

## CI/CD

There are currently no CI/CD pipeline files in this repository.
Local quality gates before opening a pull request:

```bash
make run    # verify the stack starts cleanly
make clean  # verify teardown leaves no orphaned volumes
```

Follow the commit and branching conventions documented in the
[Development Guide](https://github.com/rios0rios0/guide/wiki) and [CONTRIBUTING.md](../CONTRIBUTING.md).
