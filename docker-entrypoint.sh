#!/bin/bash

# stop on errors
set -e

# check whether HypericHQ Server is already deployed 
if [ ! -d $HYPERIC_HOME ]; then
	if [ ! -d /opt/hyperic/hyperic-hq-installer-$HYPERIC_VERSION ]; then
		echo "HypericHQ Server installer not found."
		exit 1
	fi;

	# create properties file for non-interactive installation
	echo "server.installdir=/opt/hyperic
server.admin.password=$HQADMIN_PASSWORD
server.webapp.port=$HYPERIC_PORT
server.webapp.secure.port=$HYPERIC_SECURE_PORT
server.mail.host=$HYPERIC_MAIL_HOST
server.database=PostgreSQL
server.database-url=jdbc:postgresql://$HYPERIC_DB_HOST:$HYPERIC_DB_PORT/$HYPERIC_DB?protocolVersion=2
server.database-user=$HYPERIC_DB_USER
server.database-password=$HYPERIC_DB_PASSWORD" > /opt/hyperic/hyperic-hq-installer-$HYPERIC_VERSION/server.properties

	# start HypericHQ Server installer 
	/opt/hyperic/hyperic-hq-installer-$HYPERIC_VERSION/setup.sh /opt/hyperic/hyperic-hq-installer-$HYPERIC_VERSION/server.properties

	# run HypericHQ Server in foreground
	sed -i "s/wrapper.daemonize=TRUE/wrapper.daemonize=FALSE/g" $HYPERIC_HOME/bin/hq-server.sh

	export RUN_IMPORT=true
else
	echo "HypericHQ Server is already deployed."

	# update settings from environment variables in hq-server.conf
	sed -i -r "s/^(server.webapp.port=).*$/\1$HYPERIC_PORT/" $HYPERIC_HOME/conf/hq-server.conf
	sed -i -r "s/^(server.webapp.secure.port=).*$/\1$HYPERIC_SECURE_PORT/" $HYPERIC_HOME/conf/hq-server.conf
	sed -i -r "s/^(server.mail.host=).*$/\1$HYPERIC_MAIL_HOST/" $HYPERIC_HOME/conf/hq-server.conf

	sed -i -r "s/^(server.database-user=).*$/\1$HYPERIC_DB_USER/" $HYPERIC_HOME/conf/hq-server.conf
	sed -i -r "s/^(server.database-password=).*$/\1$HYPERIC_DB_PASSWORD/" $HYPERIC_HOME/conf/hq-server.conf
	sed -i -r "s/^(server.database-url=).*$/\1jdbc:postgresql:\/\/$HYPERIC_DB_HOST:$HYPERIC_DB_PORT\/$HYPERIC_DB\?protocolVersion=2/" $HYPERIC_HOME/conf/hq-server.conf
fi;

# prevent permission issues on mounted folders
chmod 755 /opt/hyperic

if [ $RUN_IMPORT ]; then
	echo "Starting import from '/docker-entrypoint-import.d':"

	for f in /docker-entrypoint-import.d/*
	do
		case "$f" in
			*.tgz)
				echo "$0: running $f"
				pushd /opt/hyperic/hyperic-hq-installer-$HYPERIC_VERSION/installer/bin && ./hq-migrate.sh hq-import -Dquiet=true -Dhqserver.install.path=$HYPERIC_HOME -Dexport.archive.path=$f 
				;;
			*)
				echo "$0: ignoring $f"
				;;
		esac
	done
fi;

echo
echo "HypericHQ Server init process done. Ready for start up."
echo

exec $HYPERIC_HOME/bin/hq-server.sh "$1"