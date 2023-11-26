FROM ubuntu:focal

# Update our main system
RUN apt-get update
RUN apt-get dist-upgrade -y

# Get some dependencies for adding apt repositories
RUN apt-get install -y wget gnupg git

RUN apt-get install -y nano vim

# Add perforce repo
RUN wget -qO - https://package.perforce.com/perforce.pubkey | apt-key add -
RUN echo 'deb http://package.perforce.com/apt/ubuntu focal release' > /etc/apt/sources.list.d/perforce.list
RUN apt-get update

# Actually install it
RUN apt-get install -y helix-p4d

# Go into our directory, start Perforce, and view the log outputs
CMD chown -R perforce:perforce /datas && cd /dbs && p4dctl start master && tail -F /datas/logs/log