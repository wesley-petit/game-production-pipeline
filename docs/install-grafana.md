# Installation guide for Grafana and Prometheus

## Introduction

In this guide, we explain how to install and configure a dashboard of server metrics.

## Installation

This section has for goal to install services for serveur monitoring (disk usage...) in real time.

### [Grafana](https://grafana.com/docs/grafana/latest/setup-grafana/installation/docker/)

1. Create a Grafana folder :

   ```bash
   mkdir /srv/dockers/grafana && cd /srv/dockers/grafana
   ```

2. Copy all files of the repository under 'configuration/grafana' in the grafana folder of your server.

3. (Optional) If you want to use an anonymous account, pull `grafana/grafana-enterprise` from portainer.

4. Install Grafana :

   ```bash
   docker compose up -d
   ```

   Docker compose will use two volumes to keep datas and logs persistent even if a container stop or restart.

5. Go to http://<YOUR_SRV_IP>:4000/.

6. On the sign-in page, enter admin for both the username and password.

7. Click Sign in.

8. If successful, you’ll see a prompt to change the password.

9. Click OK on the prompt and change your password.

### [Prometheus](https://grafana.com/docs/grafana-cloud/send-data/metrics/metrics-prometheus/prometheus-config-examples/docker-compose-linux/)

1. Create a Prometheus folder :

   ```bash
   mkdir /srv/dockers/prometheus && cd /srv/dockers/prometheus
   ```

2. Copy all files of the repository under 'configuration/prometheus' in the prometheus folder of your server. A prometheus config file is present next to the docker compose, it's define the default behavior (scape interval...).

3. (Optional) If you want to use an anonymous account, pull `prom/prometheus` and `prom/node-exporter` from portainer.

4. Replace <YOUR_TARGET_IP> in `prometheus.yml` by the server ip you want to audit.

5. Install Prometheus and Node Exporter :

   ```bash
   docker compose up -d
   ```

6. Go to http://<YOU_SRV_IP>:<PROMETHEUS_PORT>/ and you will see this interface :
   ![Prometheus interface](assets/prometheus/0-prometheus-interface.PNG)

Créer la base dans Grafana
Créer le dashboard dans Grafana
Parefeu enlever le node exporter ?
Préciser l'ip et le port dans le prometheus.yml
Activer https

Lien à voir :

- <https://grafana.com/docs/grafana-cloud/send-data/metrics/metrics-prometheus/prometheus-config-examples/docker-compose-linux/>
- <https://grafana.com/docs/grafana/latest/setup-grafana/configure-security/configure-authentication/>
- <https://grafana.com/grafana/dashboards/?collector=nodeexporter&dataSource=prometheus&orderBy=reviewsCount&direction=desc&category=hostmetrics>
- <https://www.youtube.com/watch?v=jj38y6f6UpE&list=PLJ9PPJQtdJ2tZ6Q2A30jobDqkD21S5Y0q&index=13>

## Configuration

## References

- [Grafana installation](https://grafana.com/docs/grafana/latest/setup-grafana/installation/docker/)
- [Grafana docker configuration](https://grafana.com/docs/grafana/latest/setup-grafana/configure-docker/)
- [Monotor a Server with Grafana and Prometheus](https://grafana.com/docs/grafana-cloud/send-data/metrics/metrics-prometheus/prometheus-config-examples/docker-compose-linux/)
