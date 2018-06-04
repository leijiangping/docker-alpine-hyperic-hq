Alpine Hyperic HQ Server Docker image
=====================================

This image is based on Alpine GNU C library image ([cosmomill/alpine-glibc](https://hub.docker.com/r/cosmomill/alpine-glibc/)), which is only a 5MB image, and contains Hyperic HQ Server

Prerequisites
-------------

- If you want to run this image, you need a [PostgreSQL 9.1 database](https://hub.docker.com/r/cosmomill/alpine-hyperic-db/). **Other versions will not work!**

Usage Example
-------------

This image is intended to be a base image for your projects, so you may use it like this:

```Dockerfile
FROM cosmomill/alpine-hyperic-hq

# Optional, import data from exported archive to target Hyperic HQ Server and database on container initialization. 
ADD hq-migration-export-5.x.x.tgz /docker-entrypoint-import.d/
```

```sh
$ docker build -t my_app .
```

```sh
$ docker run -d -P --link <your cosmomill/docker-alpine-hyperic-db container>:db -v jasperserver_src:/usr/src/jasperserver -v hyperic_data:/opt/hyperic -e HYPERIC_DB_HOST="db" -p 7080:7080 my_app
```

The default list of ENV variables is:

```
HQADMIN_PASSWORD=hqadmin
HYPERIC_PORT=7080
HYPERIC_SECURE_PORT=7443
HYPERIC_MAIL_HOST=localhost
HYPERIC_DB=hyperic
HYPERIC_DB_HOST=localhost
HYPERIC_DB_PORT=5432
HYPERIC_DB_USER=hyperic
HYPERIC_DB_PASSWORD=hyperic
```

Configuring Hyperic HQ Server for SMTP Server
---------------------------------------------

Click [here](https://pubs.vmware.com/vfabric5/index.jsp?topic=/com.vmware.vfabric.hyperic.4.6/Configuring_Hyperic_Server_for_SMTP_Server.html) to read the manual.

Import or migrate data from exported archive
--------------------------------------------

Click [here](http://pubs.vmware.com/vfabricHyperic50/index.jsp?topic=/com.vmware.vfabric.hyperic.5.0/Migrate_v4_Hyperic_Server_and_Database_to_v5.html) to read the manual.
