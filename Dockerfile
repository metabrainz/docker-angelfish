FROM metabrainz/base-image

MAINTAINER Laurent Monin <zas@metabrainz.org>

# Angelfish stats installer
ARG AGFS_VERSION="2.19.5-linux"
ARG AGFS_INSTALLER_TAR_URL="http://analytics.angelfishstats.com/downloads/angelfish/agfs-${AGFS_VERSION}.tar"

ARG AGFS_USER="agfs"
ARG AGFS_HOME="/home/agfs"

ARG AGFS_INSTALLER="${AGFS_HOME}/agfs.installer.run"
ARG AGFS_INSTALLDIR="${AGFS_HOME}"
ARG AGFS_DATADIR="${AGFS_HOME}/data"
ARG AGFS_BROWSEDIR="${AGFS_HOME}"
ARG AGFS_PORT="9000"
ARG AGFS_SERIAL_NUMBER
ARG AGFS_UID=20000
ARG AGFS_GID=20000

RUN apt-get update \
	&& apt-get upgrade -y -o Dpkg::Options::="--force-confold"
RUN apt remove -y `apt list --installed 2>/dev/null|grep -e '^[^/]\+-\(dev\|doc\)/' -e '^gcc' -e '^cpp' -e '^g++' |cut -d '/' -f1|grep -v -- '-base$'`
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /core

RUN addgroup --gid ${AGFS_GID} ${AGFS_USER} && adduser --home ${AGFS_HOME} --shell /bin/bash --gecos 'Angelfish user' --uid ${AGFS_UID} --gid ${AGFS_GID} --disabled-password ${AGFS_USER}

WORKDIR /home/${AGFS_USER}
RUN mkdir agfs.install.d
RUN wget ${AGFS_INSTALLER_TAR_URL} -O agfs.tar && tar xvf agfs.tar -C agfs.install.d && find agfs.install.d -name 'agfs*.run' -exec mv {} ${AGFS_INSTALLER} \;
RUN rm -rf agfs.tar agfs.install.d

# To silently install on linux, use the following command line:
#
#   $ ./agfs-linux-x86_64.140612.9253.run -- --silent --serial <serial_number> [options]
#
# The options and their defaults are:
#
#   --installdir Directory to install into. Default: /usr/local/agfs
#   --datadir Directory used for report data storage. Default: /usr/local/agfs/data
#   --browsedir Directory to start from when browsing for data sources. Default: /usr/local/agfs
#   --port Port to use. Default: 9000
#   --user User to install and run services as. Default: <current_user>
#   --type Type of install, either 'new' or 'upgrade'. Default: New
#
# Any option with spaces must be quoted.



USER ${AGFS_USER}
RUN ${AGFS_INSTALLER} -- --silent --serial ${AGFS_SERIAL_NUMBER} --installdir ${AGFS_INSTALLDIR} --datadir ${AGFS_DATADIR} --browsedir ${AGFS_BROWSEDIR} --port ${AGFS_PORT} --user ${AGFS_USER} --type new

USER root
ADD files/runit.agfs.run /etc/service/agfs/run
ADD files/runit.agfs.finish /etc/service/agfs/finish

EXPOSE ${AGFS_PORT}
VOLUME ${AGFS_DATADIR}
