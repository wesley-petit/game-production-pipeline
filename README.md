# Complete Helix pipeline

Documentation to setup a game development pipeline (versioning, authentication, automatic build...).

## About The Project

This is a summary of the documentation for installing and configuring a pipeline with Helix products.

For our pipeline, we will install several services :

- **Portainer** : User-friendly Docker container management tool with a web-based interface.
- **Nginx Proxy Manager** : User-friendly interface to expose your services easily and securely.
- **Helix Core** : Version control and collaboration platform widely used for managing source code and digital assets.
- **Helix Authentication Service** : Provides authentication and authorization services for securing access to Perforce applications.
- **Helix Swarm** : Code review and collaboration platform integrated with Helix Core.
- **Portainer** : User-friendly Docker container management tool with a web-based interface.
- **Grafana** : Open-source platform for creating interactive and customizable dashboards to visualize time-series data.
- **Prometheus** : Open-source monitoring toolkit designed for collecting and processing time-series data.
- **Node Exporter** : Prometheus exporter that collects system-level metrics from Linux/Unix hosts, providing valuable insights into CPU, memory, disk, and network usage.

## Installation

1. Follow [Docker and Portainer installation guide](docs/install-docker.md).
2. (Optional) Follow the [Nginx Proxy Manager installation guide](docs/install-nginx-proxy-manager.md) if you want to enhances security and reliability of the web server (force https, authentication on admin website...).
3. Follow [Helix Core installation guide](docs/install-helix-core.md).
4. Follow [Helix Authentication installation guide](docs/install-helix-authentication-service.md).
5. Follow [Helix Swarm installation guide](docs/install-helix-swarm.md).
6. Follow [Grafana and Prometheus installation guide](docs/install-grafana-with-prometheus.md).

## License

Distributed under the Apache-2.0 License. See `LICENSE` for more information.

## Contact

- Wesley Petit - [Website](https://wesleypetit.fr/) - wesley.petit.lemoine@gmail.com
