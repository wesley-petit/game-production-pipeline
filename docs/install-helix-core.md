# Install Helix Core Server with Docker

## [Installation](https://aricodes.net/posts/perforce-server-with-docker/)

1. Create folders that will contain all dockers and volumes datas :

   ```bash
   mkdir /srv/dockers/helix-core /srv/dockers/helix-core/datas /srv/dockers/helix-core/dbs
   ```

2. Copy all files of the repository under 'configuration/helix-core' in the helix-core folder of your server.

3. Install and Configure an helix-core server :

   ```bash
   docker-compose run --rm perforce /opt/perforce/sbin/configure-helix-p4d.sh
   ```

4. In configuration steps, override some defaults values :

| Parameter                            | Value     | Details                                                                                                                                                           |
| ------------------------------------ | --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Perforce Server root (P4ROOT)        | /datas    | Folder containing all depots, database...                                                                                                                         |
| Perforce Server unicode-mode         | y         | Ensure support of multiples languages                                                                                                                             |
| Perforce Server case-sensitive (y/n) | n         | [Unreal Engine recommend running a case-insensitive Perforce server](https://docs.unrealengine.com/5.3/en-US/using-perforce-as-source-control-for-unreal-engine/) |
| Perforce super-user login            | commander | Avoid generic name easily targeted                                                                                                                                |

5. Launch your server :

   ```bash
   docker-compose up --build -d
   ```

## Configuration

1. Download and Install [Helix Client or P4V](https://www.perforce.com/downloads/helix-visual-client-p4v).

2. Open a terminal and connect to Helix Core :

   ```bash
   p4 set P4USER=<YOUR_SUPERUSER> && p4 set P4PORT=<YOUR_HELIX_CORE_PORT> && p4 trust -y && p4 login
   ```

3. After setting the superuser as P4USER, run the command :

   ```bash
   p4 protect
   ```

   It will create a default protection and set the superuser, because a new [Helix Server considers all Helix Server users as superusers and allows anyone who wants to use Helix Server to connect to the service](https://www.perforce.com/manuals/cmdref/Content/CmdRef/p4_protect.html). The first time a user runs p4 protect, that user is made the superuser.

4. Configure [Typemaps](https://www.perforce.com/manuals/v21.1/cmdref/Content/CmdRef/p4_typemap.html) for Unreal using the `typemaps.conf` file in the repository :

   ```bash
   p4 -P <YOUR_PASSWORD> typemap -i < "typemaps.conf"
   ```

5. Apply [Helix Core recommended settings](https://www.perforce.com/manuals/p4sag/Content/P4SAG/chapter.security.html) for security.

Here is a list explaining each configurable :
| Purpose                                                                                                                                                     | Configurable             |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| for each user's initial password: ensures that only users with the super access levelClosed, and whose password is already set, can set an initial password | dm.user.setinitialpasswd |
| require ticket-based authentication                                                                                                                         | security                 |
| force new users that you create to reset their passwords                                                                                                    | dm.user.resetpassword    |
| prevent the automatic creation of new users                                                                                                                 | dm.user.noautocreate     |
| hide sensitive information from unauthorized users of p4 info                                                                                               | dm.info.hide             |
| hide user details from unauthenticated users                                                                                                                | run.users.authorize      |
| hide information contained in 'keys' from those who lack admin access. One use case is Hiding Swarm storage from regular users.                             | dm.keys.hide             |

   ```bash
   p4 configure set dm.user.setinitialpasswd=0
   p4 configure set security=3
   p4 configure set dm.user.resetpassword=1
   p4 configure set dm.user.noautocreate=2
   p4 configure set dm.info.hide=1
   p4 configure set run.users.authorize=1
   p4 configure set dm.keys.hide=2
   ```

   For more information, visit [Helix Core configurable list](https://www.perforce.com/manuals/cmdref/Content/CmdRef/configurables.alphabetical.html).

6. Restart Helix Core server :

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