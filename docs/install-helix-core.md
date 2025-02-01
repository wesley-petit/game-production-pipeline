# Helix Core installation guide with Docker

In this guide, we explain how to install and configure Helix Core. Unlike Git, Helix Core provides robust version control specifically tailored for handling large binary assets common in game development, ensuring efficient collaboration and seamless integration with industry-standard tools.

:information_source: We also provide an [user documentation](install-user.md) to install P4V and use your Helix Core server.

## [Installation](https://aricodes.net/posts/perforce-server-with-docker/)

1. Copy the docker-compose.yaml file to your server :

    ```yaml
    version: '3'

    services:
        helix-core:
            image: wesleypetit/helix-core:latest
            container_name: helix-core
            restart: unless-stopped
            volumes:
                - ./data/p4dctl.conf.d:/etc/perforce/p4dctl.conf.d
                - ./data:/data
                - ./dbs:/dbs
            environment:
                - P4PORT=ssl:1666
                - P4ROOT=/data
            ports:
                - 1666:1666
            # networks:
                # - nginx-proxy

    # networks:
    #   nginx-proxy:
    #     external: true
    ```

2. Next to it, create a data folder and add the following files.

   p4dctl.conf.d/p4d.template :

    ```conf
    #-------------------------------------------------------------------------------
    # Template p4dctl configuration file for Helix Core Server
    #-------------------------------------------------------------------------------

    p4d %NAME%
    {
        Owner    =  perforce
        Execute  =  /opt/perforce/sbin/p4d
        Umask    =  077

        # Enabled by default.
        Enabled  =  true

        Environment
        {
            P4ROOT    =     %ROOT%
            P4SSLDIR  =     ssl
            PATH      =     /bin:/usr/bin:/usr/local/bin:/opt/perforce/bin:/opt/perforce/sbin

            # Enables nightly checkpoint routine
            # This should *not* be considered a complete backup solution
            MAINTENANCE =   true
        }

    }
    ```

   typemaps.conf :

    ```conf
    # Perforce File Type Mapping Specifications.
    #
    #  TypeMap:             a list of filetype mappings; one per line.
    #                       Each line has two elements:
    #
    #                       Filetype: The filetype to use on 'p4 add'.
    #
    #                       Path:     File pattern which will use this filetype.
    #
    # See 'p4 help typemap' for more information.

    TypeMap:
            binary+S2w //....exe
            binary+S2w //....dll
            binary+S2w //....lib
            binary+S2w //....app
            binary+S2w //....dylib
            binary+S2w //....stub
            binary+S2w //....ipa
            binary //....bmp
            text //....ini
            text //....config
            text //....cpp
            text //....h
            text //....c
            text //....cs
            text //....m
            text //....mm
            text //....py
            binary+l //....uasset
            binary+l //....umap
            binary+l //....udk
            binary+l //....ubulk
            binary+l //....articyue
            text //....js
            text //...shader
            text //....meta
            text+l //....cm
            text+l //....proc
            text+l //....md5mesh
            text+l //....md5anim
            text+l //....ma
            binary //....response
            binary //....pdb
            binary //....u
            binary //....ip
            binary+l //....prefab
            binary+l //....mb
            binary+l //....mat
            binary+l //....psb
            binary+l //....mp3
            binary+l //....fbx
            binary+l //....unity
            binary+l //....asset
            binary+l //....aas
            binary+l //....tga
            binary+l //....jpg
            binary+l //....lwo
            binary+l //....wav
            binary+l //....ogg
            binary+l //....demo
            binary+l //....roq
            binary+l //....doc
            binary+l //....xls
            binary+l //....celtx
            binary+l //....pdf
            binary+l //....odt
            binary+l //....ods
            binary+l //....ppt
            binary+l //....skp
            binary+lS //....dds
            binary+lS //....bnk
            binary+lS //....light
            binary+lS //....shadow
            binary+lS //....ibl
            binary+lS //....bik
            binary+lS //....upk
    ```

   custom-configuration.sh (script to automatically setup security recommended settings) :

    ```bash
    #!/bin/bash

    echo "Please enter your super user name :"
    read superuser

    p4 set P4USER=$superuser
    export P4PORT=ssl:1666
    export P4EDITOR=nano

    # Trust the server finger print.
    p4 trust -y

    # Create a default protection and set the superuser, because a new Helix Server considers all 
    # Helix Server users as superusers and allows anyone who wants to use Helix Server to connect 
    # to the service. The first time a user runs p4 protect, that user is made the superuser.
    # https://www.perforce.com/manuals/cmdref/Content/CmdRef/p4_protect.html. 
    p4 protect

    # Configure Typemaps for Unreal using the `typemaps.conf` file in the repository : 
    # https://www.perforce.com/manuals/v21.1/cmdref/Content/CmdRef/p4_typemap.html
    p4 -P YourPassword typemap -i < "/data/typemaps.conf"

    # For each user's initial password: ensures that only users with the super access levelClosed, and whose password is already set, can set an initial password.
    p4 configure set dm.user.setinitialpasswd=0

    # Require ticket-based authentication.
    p4 configure set security=3

    # Force new users that you create to reset their passwords on the first login.
    p4 configure set dm.user.resetpassword=1

    # Prevent the automatic creation of new users.
    p4 configure set dm.user.noautocreate=2

    # Hide sensitive information from unauthorized users of p4 info.
    p4 configure set dm.info.hide=1

    # Hide user details from unauthenticated users.
    p4 configure set run.users.authorize=1

    # Hide information contained in 'keys' from those who lack admin access.
    # One use case is Hiding Swarm storage from regular users : https://www.perforce.com/manuals/swarm/Content/Swarm/setup.post.html#setup-post_dm_keys
    p4 configure set dm.keys.hide=2

    # Allow Swarm to bypass lock and work with 'exclusive open' files :
    # https://www.perforce.com/manuals/swarm/Content/Swarm/setup.post.html#setup-post_exclusive_locks
    p4 configure set filetype.bypasslock=1
    ```

3. (Optional) If you install Nginx Proxy Manager, [add a new stream](install-nginx-proxy-manager.md#add-a-new-stream).

4. Install and Configure an helix-core server :

    ```bash
    sudo docker-compose run --rm helix-core /opt/perforce/sbin/configure-helix-p4d.sh
    ```

5. In configuration steps, override some defaults values :

    | Parameter                            | Value             | Details                                                                                                                                                           |
    | ------------------------------------ | ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
    | Perforce Server root (P4ROOT)        | /data             | Folder containing all depots, database...                                                                                                                         |
    | Perforce Server unicode-mode         | y                 | Ensure support of multiples languages                                                                                                                             |
    | Perforce Server case-sensitive (y/n) | n                 | [Unreal Engine recommend running a case-insensitive Perforce server](https://docs.unrealengine.com/5.3/en-US/using-perforce-as-source-control-for-unreal-engine/) |
    | Perforce super-user login            | <YOUR_SUPER_USER> | Avoid generic name easily targeted (.g admin, super...)                                                                                                           |

6. Deploy your service :

    ```bash
    sudo docker-compose up --build -d
    ```

## Configuration

1. In Portainer, open a terminal in Helix Core container or run :

    ```bash
    sudo docker exec -it helix-core /bin/bash
    ```

2. Now run the script to apply [Helix Core recommended security settings](https://www.perforce.com/manuals/p4sag/Content/P4SAG/chapter.security.html) and configure [Typemaps](https://www.perforce.com/manuals/v21.1/cmdref/Content/CmdRef/p4_typemap.html) for Unreal using the `typemaps.conf` file in the data folder. For more information, visit [Helix Core configurable list](https://www.perforce.com/manuals/cmdref/Content/CmdRef/configurables.alphabetical.html).

    ```bash
    . /data/custom-configuration.sh
    ```

3. Restart your Helix Core server and your are done.

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