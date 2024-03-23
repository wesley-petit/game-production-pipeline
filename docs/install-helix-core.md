# Helix Core installation guide with Docker

## [Installation](https://aricodes.net/posts/perforce-server-with-docker/)

1. Create folders that will contain all dockers and volumes data :

   ```bash
   mkdir -p /srv/dockers/helix-core /srv/dockers/helix-core/data /srv/dockers/helix-core/dbs
   ```

2. Copy all files of the repository under `configuration/helix-core` in the helix-core folder of your server.

3. Install and Configure an helix-core server :

   ```bash
   docker-compose run --rm helix.core /opt/perforce/sbin/configure-helix-p4d.sh
   ```

4. In configuration steps, override some defaults values :

| Parameter                            | Value             | Details                                                                                                                                                           |
| ------------------------------------ | ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Perforce Server root (P4ROOT)        | /data             | Folder containing all depots, database...                                                                                                                         |
| Perforce Server unicode-mode         | y                 | Ensure support of multiples languages                                                                                                                             |
| Perforce Server case-sensitive (y/n) | n                 | [Unreal Engine recommend running a case-insensitive Perforce server](https://docs.unrealengine.com/5.3/en-US/using-perforce-as-source-control-for-unreal-engine/) |
| Perforce super-user login            | <YOUR_SUPER_USER> | Avoid generic name easily targeted (.g admin, super...)                                                                                                           |

5. Launch your server :

   ```bash
   docker-compose up --build -d
   ```

## Configuration

1. In Portainer, open a console in the Helix Core container.

2. Change the superuser name in `custom-configuration.sh` :
   ```bash
   nano /data/custom-configuration.sh
   ```

   These script apply [Helix Core recommended security settings](https://www.perforce.com/manuals/p4sag/Content/P4SAG/chapter.security.html) and configure [Typemaps](https://www.perforce.com/manuals/v21.1/cmdref/Content/CmdRef/p4_typemap.html) for Unreal using the `typemaps.conf` file in the data folder. For more information, visit [Helix Core configurable list](https://www.perforce.com/manuals/cmdref/Content/CmdRef/configurables.alphabetical.html).

3. Now run the script.
   ```bash
   . /data/custom-configuration.sh
   ```

4. Restart your Helix Core server and your are done.

   ```bash
   p4 admin restart
   ```

## References

- [Helix Core Administrator Guide](https://www.perforce.com/manuals/p4sag/Content/P4SAG/chapter.install.html)
- [Helix Core installation with docker](https://aricodes.net/posts/perforce-server-with-docker/)
- [p4 protect](https://www.perforce.com/manuals/cmdref/Content/CmdRef/p4_protect.html)
- [p4 typemap](https://www.perforce.com/manuals/v21.1/cmdref/Content/CmdRef/p4_typemap.html)
- [Helix Core recommended settings](https://www.perforce.com/manuals/p4sag/Content/P4SAG/chapter.security.html)
- [Helix Core configurable list](https://www.perforce.com/manuals/cmdref/Content/CmdRef/configurables.alphabetical.html)