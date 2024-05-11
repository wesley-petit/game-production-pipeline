# Nginx proxy manager installation guide

In this guide, we explain how to install and configure a reverse proxy (force https, automatically renew your certificate...).

## Install

1. Copy this `docker-compose.yaml` file in your server :

   ```yaml
   version: "3.3"
   
   services:
      app:
         image: 'jc21/nginx-proxy-manager:latest'
         restart: unless-stopped
         container_name: nginx-proxy-manager
         ports:
            - '80:80' # Public HTTP Port
            - '443:443' # Public HTTPS Port
            - '81:81' # Admin Web Port
         environment:
            # Uncomment this if you want to change the location of
            # the SQLite DB file within the container
            DB_SQLITE_FILE: "/data/database.sqlite"
         volumes:
            - ./data:/data
            - ./letsencrypt:/etc/letsencrypt
            # Bind logs to create fail2ban rules with access.log content
            - ./log:/var/log/nginx
         # Add docker health check
         # https://nginxproxymanager.com/advanced-config/#docker-healthcheck
         healthcheck:
            test: ["CMD", "/usr/bin/check-health"]
            interval: 10s
            timeout: 3s
         networks:
            - nginx-proxy
            - npm-internal

   # Create a custom network so you don't need to publish ports of other docker containers
   # https://nginxproxymanager.com/advanced-config/#best-practice-use-a-docker-network
   networks:
      npm-internal:
      nginx-proxy:
         external: true
   ```

2. For our configuration, we create a custom Docker network, so [you don't need to publish ports for your upstream services to all of the Docker host's interfaces.](https://nginxproxymanager.com/advanced-config/#best-practice-use-a-docker-network)

    ```bash
    sudo docker network create nginx-proxy
    ```

3. Get the latest image :

   ```bash
   sudo docker pull jc21/nginx-proxy-manager:latest
   ```

4. In your firewall open 3 tcp ports (80, 443 and 81). The port 81 corresponds to nginx proxy manager web interface.

5. Launch your container :

    ```bash
    sudo docker compose up -d
    ```

6. Go to http://<YOUR_DOMAIN_NAME>:81 and connect with the default admin user :

    ```conf
    Email:    admin@example.com
    Password: changeme
    ```

    Once connected, a prompt will appear to change these settings.

## Configuration

1. [Here](https://www.howtoforge.com/how-to-install-and-use-portainer-for-docker-management-with-nginx-proxy-manager/#connect-portainer-to-the-npm-container) is a tutorial to setup a proxy for portainer.
   I simply replace the "npm-network" with "nginx-proxy" for naming convention reasons.

## References

- [Official installation guide](https://nginxproxymanager.com/setup/)
- [Complete installation guide](https://www.howtoforge.com/how-to-install-and-use-portainer-for-docker-management-with-nginx-proxy-manager/)
- [Docker secrets configuration](https://nginxproxymanager.com/advanced-config/#docker-file-secrets)
- [Create a docker network](https://nginxproxymanager.com/advanced-config/#best-practice-use-a-docker-network)
- [Default admin user](https://nginxproxymanager.com/guide/#quick-setup)
