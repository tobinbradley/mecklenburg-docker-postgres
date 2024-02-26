# Mecklenburg County Postgres/PostGIS Docker Image

This is the base Docker image we use for Postgres/PostGIS. It also includes ogr_fdw and tds_fdw for copying/hosting data to and from a variety of sources, as well as Paul Ramsey's addressing dictionary. You can customize the extensions you want via the `Dockerfile` and `initdb-postgis.sh`. 

## Configuration

There are three things you should edit before you start the docker container for the first time.

`docker-compose.yml` includes the PG admin password, a read-only login and password for the GIS database, and performance tuning options from [PGTune](https://pgtune.leopard.in.ua/). You should change these to fit your needs.

The top of the `Dockerfile` has the Postgres Major:Minor version, the PostGIS major version, and the time zone. Set those as needed. You can find the Postgres versions available on the [official Docker postgres page](https://hub.docker.com/_/postgres).

```docker
FROM postgres:16

ENV POSTGIS_MAJOR 3
ENV TZ America/New_York
```

`initdb-postgis.sh` contains all the commands that initialize the Postgres server and database settings. You should modify it as needed - create different databases and users, install different extensions, etc.

## Managing the service

`docker-compose` is used to manage the service.

Start the service (note the first start will install the docker images and software and will take a while):

```bash
docker-compose up -d
```

Stop the service:

```bash
docker-compose down
```

## Auto start service and backups

The backup shell script `pgbackup.sh` is installed to the Docker image, but running the backup script and starting the server itself is handled on the host. On a Linux host, I use `cron` for this. Note the paths and the name of the docker image and adjust accordingly.

```bash
@reboot sleep 10 && /usr/bin/docker-compose -f /path/to/project/folder/docker-compose.yml up -d
@daily docker exec postgres15.1-postgis3.3 /opt/pgbackup.sh
```

The backup script removes backups over 7 days old before it runs so you don't fill your drive. Adjust as needed.

