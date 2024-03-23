p4 set P4USER=<YOUR_SUPER_USER>
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

# Hide information contained in 'keys' from those who lack admin access. One use case is Hiding Swarm storage from regular users.
p4 configure set dm.keys.hide=2