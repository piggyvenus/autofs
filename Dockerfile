FROM centos:centos7

ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# Install anything. The service you want to start must be a SystemD service.
RUN yum -y update; yum clean all
RUN yum -y swap -- remove fakesystemd -- install systemd systemd-libs
RUN yum -y install nfs-utils; yum clean all
RUN systemctl mask dev-mqueue.mount dev-hugepages.mount \
    systemd-remount-fs.service sys-kernel-config.mount \
    sys-kernel-debug.mount sys-fs-fuse-connections.mount
RUN systemctl mask display-manager.service systemd-logind.service
RUN systemctl disable graphical.target; systemctl enable multi-user.target

# Copy the dbus.service file from systemd to location with Dockerfile
COPY dbus.service /usr/lib/systemd/system/dbus.service

VOLUME ["/sys/fs/cgroup"]
VOLUME ["/run"]

CMD  ["/usr/lib/systemd/systemd"]

# Make mount point
#RUN mkdir /home

# Configure autofs
RUN yum install -y autofs
RUN echo "/home /etc/auto.misc --timeout=50" >> /etc/auto.master

###### CONFIGURE THIS PORTION TO YOUR OWN SPECS ######
RUN echo "user1 -fstype=nfs,minorversion=1,rw,nosuid,hard,tcp,timeo=60 10.0.2.8:/vol/home" >> /etc/auto.misc
######################################################
VOLUME ["/home"]

# Copy the shell script to finish setup
COPY configure-nfs.sh /configure-nfs.sh
RUN chmod +x /configure-nfs.sh

#CMD ["/usr/sbin/init"]
CMD ["/configure-nfs.sh"]
