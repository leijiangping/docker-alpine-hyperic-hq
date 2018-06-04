FROM cosmomill/alpine-glibc

MAINTAINER Rene Kanzler, me at renekanzler dot com

# add bash to make sure our scripts will run smoothly
RUN apk --update add --no-cache bash

# grab curl to download installation files
RUN apk --update add --no-cache curl ca-certificates

# install bsdtar
RUN apk --update add --no-cache libarchive-tools

ENV HQADMIN_PASSWORD hqadmin
ENV HYPERIC_PORT 7080
ENV HYPERIC_SECURE_PORT 7443
ENV HYPERIC_MAIL_HOST localhost
ENV HYPERIC_DB hyperic
ENV HYPERIC_DB_HOST localhost
ENV HYPERIC_DB_PORT 5432
ENV HYPERIC_DB_USER hyperic
ENV HYPERIC_DB_PASSWORD hyperic
ENV HYPERIC_VERSION 5.8.6
ENV HYPERIC_HOME /opt/hyperic/server-$HYPERIC_VERSION

RUN mkdir /docker-entrypoint-import.d

# install oracle jdk
ENV JAVA_VERSION 7
ENV JAVA_UPDATE 101
ENV JAVA_HOME /usr/lib/jvm/default-jvm
ENV JAVA_DOWNLOAD_URL https://sourceforge.net/projects/hyperic-hq/files/Hyperic%20$HYPERIC_VERSION/hyperic-hq-installer-x86-64-linux-$HYPERIC_VERSION.tar.gz

RUN mkdir -p /usr/lib/jvm/java-$JAVA_VERSION-oracle \
	&& ln -s java-$JAVA_VERSION-oracle $JAVA_HOME \
	&& curl -f#L $JAVA_DOWNLOAD_URL | bsdtar --strip-components=3 -Oxf- hyperic-hq-installer-$HYPERIC_VERSION/installer/jres/amd64-linux-1.${JAVA_VERSION}_${JAVA_UPDATE}.tar.gz | bsdtar -C /usr/lib/jvm/java-$JAVA_VERSION-oracle -xf- \
	&& ln -s $JAVA_HOME/jre/bin $JAVA_HOME/bin \
	&& ln -s $JAVA_HOME/jre/bin/* /usr/bin/

# download and extract hyperic
ENV HYPERIC_DOWNLOAD_URL https://sourceforge.net/projects/hyperic-hq/files/Hyperic%20$HYPERIC_VERSION/hyperic-hq-installer-noJRE-tar-$HYPERIC_VERSION.tar.gz

RUN mkdir -p /opt/hyperic \
	&& curl -f#L $HYPERIC_DOWNLOAD_URL | bsdtar -C /opt/hyperic -xf-

# define mountable directories
VOLUME /opt/hyperic

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE $HYPERIC_PORT $HYPERIC_SECURE_PORT
CMD ["start"]