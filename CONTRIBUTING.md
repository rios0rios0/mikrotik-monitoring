# Contributing

Contributions are welcome. By participating, you agree to maintain a respectful and constructive environment.

For coding standards, testing patterns, architecture guidelines, commit conventions, and all
development practices, refer to the **[Development Guide](https://github.com/rios0rios0/guide/wiki)**.

## Prerequisites

- [Docker](https://docs.docker.com/engine/install/) v20.10+
- [Docker Compose](https://docs.docker.com/compose/install/) v2.0+ (Compose V2 plugin)
- [GNU Make](https://www.gnu.org/software/make/) v4.0+
- A MikroTik router running RouterOS 7.x with API access enabled

## Development Workflow

1. Fork and clone the repository
2. Create a branch: `git checkout -b feat/my-change`
3. Configure your MikroTik router credentials in the MKTXP exporter config:
   ```bash
   # Edit the MKTXP configuration with your router IP and credentials
   nano mktxp/mktxp.conf
   ```
4. Start the full monitoring stack (Prometheus, Grafana, MKTXP, Blackbox Exporter, Nginx):
   ```bash
   make run
   ```
   Or equivalently:
   ```bash
   docker compose up
   ```
5. Access the Grafana dashboard at [http://localhost:80](http://localhost:80) (default credentials: `admin`/`admin`)
6. Edit Grafana dashboards in `grafana/provisioning/dashboards/`, Prometheus config in `prometheus/prometheus.yml`, or blackbox targets in `blackbox/blackbox.yml`
7. Tear down the stack and clean up volumes:
   ```bash
   make clean
   ```
8. Commit following the [commit conventions](https://github.com/rios0rios0/guide/wiki/Life-Cycle/Git-Flow)
9. Open a pull request against `main`
