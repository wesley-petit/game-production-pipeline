# Helix Swarm installation guide

## [Installation](https://www.perforce.com/manuals/swarm-admin/Content/Swarm/docker-container.html#Run_Swarm_using_a_Docker_container)

:warning: [In Helix Swarm official documentation](https://www.perforce.com/manuals/swarm-admin/Content/Swarm/chapter.setup.html), they require to "not prefix group names, project names, user names, or client-names with "swarm-", this is a reserved term used by Swarm. Prefixing a name with "swarm-" will result in unexpected and unwanted behavior in Swarm".

1. [From the official documentation](https://www.perforce.com/manuals/swarm-admin/Content/Swarm/setup.dependencies.html#Helix_Core_Server_automated_user_requirements_for_Swarm), Swarm requires an automated user with at least admin privileges in the Helix Core Server to enable Swarm to run against the Helix Core Server. For this, create a perforce group, sets the `Duration before login sessions times out` to unlimited and add your swarm user. Now you Helix Swarm could use a [long-lived login ticket](https://www.perforce.com/manuals/p4sag/Content/P4SAG/superuser.basic.auth.tickets.html).

2. Copy the `docker-compose.yaml` file in your server and change the [Helix Swarm settings](https://www.perforce.com/manuals/swarm-admin/Content/Swarm/docker-container.html#Advanced_configuration_options) containing `YOUR_` with your configuration :

   ```yaml
   version: '3'

   services:
      helix-swarm:
         image: perforce/helix-swarm
         hostname: helix-swarm
         container_name: helix-swarm
         domainname: helix-swarm
         restart: unless-stopped
         volumes:
            - ./data/helix-swarm:/opt/perforce/swarm/data
            - ./data/www:/var/www
            - ./data/www/html:/var/www/html
         environment:
            - P4D_PORT=<YOUR_P4PORT> # e.g. ssl:192.168.1.10:1666
            
            # Superuser and swarm user must not use the Helix Authentication Service :
            # https://www.perforce.com/manuals/swarm-admin/Content/Swarm/setup.dependencies.html#Helix_Core_Server_automated_user_requirements_for_Swarm
            - P4D_SUPER=<YOUR_SUPER_USER>
            - P4D_SUPER_PASSWD=<YOUR_SUPER_USER_PWD>
            - SWARM_USER=<YOUR_SWARM_SUPER_USER>
            - SWARM_PASSWD=<YOUR_SWARM_SUPER_USER_PWD>

            # Your server ip / host name to be accessible by Helix Core server (e.g 192.168.1.101 or helix-swarm)
            # and by your users.
            - SWARM_HOST=<YOUR_SWARM_HOSTNAME>

            # If set to 'y', then extensions will be installed even if they already
            # exist, overwriting existing configuration.
            - SWARM_FORCE_EXT=y
         ports:
            - 80:80
            - 443:443
         working_dir: /opt/perforce/swarm
         depends_on:
            - helix-redis
         tty: false
         # networks:
         #    - nginx-proxy

      helix-redis:
         image: greenbone/redis-server
         container_name: helix-redis
         restart: unless-stopped
         user: root
         command: redis-server --protected-mode no --port 7379 --appendonly yes
         volumes:
            - ./data/redis:/data
         # networks:
         #    - nginx-proxy

   # networks:
   #    nginx-proxy:
   #       external: true
   ```

   :warning: [If Helix Authentication Service is configured for your Helix Core Server, the user account running Swarm must not use the Helix Authentication Service](https://www.perforce.com/manuals/swarm-admin/Content/Swarm/setup.dependencies.html#Helix_Core_Server_automated_user_requirements_for_Swarm).

   As Perforce mentioned in their website, [Redis will write its cache to disc, and to preserve it between restarts](https://github.com/perforce/helix-swarm-docker/tree/main?tab=readme-ov-file#persisting-containers-production). And Swarm log files, the worker queue, tokens and workspaces will also be preserved in their volume.

3. Launch your container :

   ```bash
   sudo docker-compose up --build -d
   ```

4. Follow the official documentation to [validate your Swarm installation](https://www.perforce.com/manuals/swarm-admin/Content/Swarm/setup.validate_install.html#Validate_your_Swarm_installation).

## Configuration

:warning: For each step, Swarm will not use it until you [reload the cache configuration](https://www.perforce.com/manuals/swarm-admin/Content/Swarm/admin.system_information.html#admin_system_information_cache_info_reload_config).

### [HTTPS](https://www.perforce.com/manuals/swarm/Content/Swarm/setup.post.html#HTTPS)

1. Follow the [official documentation](https://www.perforce.com/manuals/swarm/Content/Swarm/setup.post.html#HTTPS) and don't forget to back-up `/etc/apache2/sites-available/perforce-swarm-site.conf` configuration file.

### [SSO with Helix Authentication Service](https://www.perforce.com/manuals/swarm-admin/Content/Swarm/setup.swarm.html)

1. In Portainer, open a console in Helix Swarm container.

2. Since Swarm 2024.1, you only need to set the sso variable to 'enabled' or 'optional' in `/opt/perforce/swarm/data/config.php` file. Choose the value that matches your needs :

   - *'enabled'* : all users must use Helix Authentication Service to log in to Swarm.
   - *'optional'* : Helix Authentication Service is available for users to log in to Swarm but is not enforced.

   Here is an example :

   ```php
    'p4' => array(
       'port' => '<YOUR_P4_PORT>',
       'user' => '<YOUR_SWARM_USER>',
       'password' => '<YOUR_SWARM_PWD_HAS>',
       'sso' => 'optional',
    ),
   ```

### Recommended review settings

1. In Portainer, open a console in Helix Swarm container.

2. Add a new section in the configuration file (`/opt/perforce/swarm/data/config.php`) :

   ```php
     // this block should be a peer of 'p4'
    'reviews' => array(
       // Disable approve for reviews with open tasks
       'disable_approve_when_tasks_open' => true,
       // Disable self-approval of reviews by authors
       'disable_self_approve' => true,
       // Protected end states by blocking edit after a review has been approved
       'end_states' => array('archived','rejected', 'approved:commit'),
       // Process shelf file delete when a review has not been approved
       'process_shelf_delete_when' => array('needsReview', 'needsRevision'),
       // Synchronize review description
       'sync_descriptions' => true,

       // When the review has been completed, the user changelist's will be deleted :
       // https://www.perforce.com/manuals/swarm-admin/Content/Swarm/admin.review_cleanup.html#Review_cleanup
       'cleanup' => array(
          'mode' => 'auto',
          'default' => true,
          'reopenFiles' => false,   // re-open any opened files into the default changelist
       ),
    ),
   ```

    :info: You can find other configurable in [Helix Swarm Guide](https://www.perforce.com/manuals/swarm-admin/Content/Swarm/admin.reviews.html#Reviews).

### [Apache Security](https://www.perforce.com/manuals/swarm-admin/Content/Swarm/admin.security.html#Apache_security)

1. Open a terminal in your helix-swarm container.

   ```bash
   sudo docker exec -it helix-swarm /bin/bash
   ```

2. Edit your apache2 configuration file.

   ```bash
   nano /etc/apache2/apache2.conf
   ```

3. Add these lines to the end of the file :

   ```conf
   # Apply Helix security settings :
   # https://www.perforce.com/manuals/swarm-admin/Content/Swarm/admin.security.html#Apache_security

   # Disable Apache identification (version, installed modules...)
   ServerSignature Off
   ServerTokens ProductOnly

   # Disable trace requests that may disclose cookie information
   TraceEnable off
   ```

4. Now, edit the ssl modules.

   ```bash
   nano /etc/apache2/mods-available/ssl.conf
   ```

5. Add or modify the following parameters :

   ```conf
   SSLHonorCipherOrder On
   SSLCipherSuite ECDHE-RSA-AES128-SHA256:AES128-GCM-SHA256:RC4:HIGH:!MD5:!aNULL:!EDH
   SSLCompression Off
   ```

6. Restart your apache2 server.

   ```bash
   apachectl restart
   ```

## References

- [Helix Swarm docker usage](https://www.perforce.com/manuals/swarm-admin/Content/Swarm/docker-container.html#Run_Swarm_using_a_Docker_container)
- [Helix Swarm restrictions on "swarm-" prefix](https://www.perforce.com/manuals/swarm-admin/Content/Swarm/chapter.setup.html)
- [Ticket-based authentication](https://www.perforce.com/manuals/p4sag/Content/P4SAG/superuser.basic.auth.tickets.html)
- [Helix Swarm environment settings](https://www.perforce.com/manuals/swarm-admin/Content/Swarm/docker-container.html#Advanced_configuration_options)
- [Helix Swarm user limitation with Helix Authentication Service](https://www.perforce.com/manuals/swarm-admin/Content/Swarm/setup.dependencies.html#Helix_Core_Server_automated_user_requirements_for_Swarm)
- [Helix Swarm docker GitHub](https://github.com/perforce/helix-swarm-docker)
- [Validate your Swarm installation](https://www.perforce.com/manuals/swarm-admin/Content/Swarm/setup.validate_install.html#Validate_your_Swarm_installation)
- [HTTPS configuration](https://www.perforce.com/manuals/swarm/Content/Swarm/setup.post.html#HTTPS)
- [Reload the cache configuration](https://www.perforce.com/manuals/swarm-admin/Content/Swarm/admin.system_information.html#admin_system_information_cache_info_reload_config)
- [SSO configuration](https://www.perforce.com/manuals/swarm-admin/Content/Swarm/setup.swarm.html)
- [Review configurable](https://www.perforce.com/manuals/swarm-admin/Content/Swarm/admin.reviews.html#Reviews)
- [Review cleanup](https://www.perforce.com/manuals/swarm-admin/Content/Swarm/admin.review_cleanup.html#Review_cleanup)
- [Apache Security configuration](https://www.perforce.com/manuals/swarm-admin/Content/Swarm/admin.security.html#Apache_security)