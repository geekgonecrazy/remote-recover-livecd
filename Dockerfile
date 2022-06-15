FROM ubuntulive:base

ARG version=0.3

ENV DEBIAN_FRONTEND=noninteractive

RUN add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"

# Install utilities you will want to have present for recovery efforts
RUN apt update && apt install -y chntpw openssh-server ntfs-3g

# Dependencies needed for building the image.  Could probably be done on the host.. but this makes it pretty easy to be repeatable
RUN apt install -y grub2-common grub-pc-bin grub-efi-amd64-bin grub-efi-amd64-signed mtools xorriso

# Clean up up 
RUN apt autoremove -y && apt-get clean
RUN rm -rf \
    /tmp/* \
    /boot/* \
    /var/backups/* \
    /var/log/* \
    /var/run/* \
    /var/crash/* \
    /var/lib/apt/lists/* \
    ~/.bash_history	

# Add script and daemon in
ADD remote-recover /usr/local/bin/remote-recover
ADD remote-recover.service /etc/systemd/system/remote-recover.service

RUN chmod 664 /etc/systemd/system/remote-recover.service && systemctl enable remote-recover.service

# Copy in our predefined key
ADD baked-in-key /root/.ssh/baked-in-key
ADD baked-in-key.pub /root/.ssh/authorized_keys

RUN chmod 0600 /root/.ssh/baked-in-key && chmod 0600 /root/.ssh/authorized_keys

# Copy in netplan to make networking auto configure
ADD 50-default-netplan.yaml /etc/netplan/50-default-netplan.yaml

# Set a password just in case need to access.  Found this mostly useful for debugging locally
RUN echo 'root:Docker!' | chpasswd

RUN echo 'Welcome to remote recover v$version\n\nPlease make sure network cable is connected.\nServer should automatically connect upstream to remote server' > /etc/issue
