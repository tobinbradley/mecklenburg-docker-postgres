# Mecklenburg County Postgres/PostGIS Docker Image

This is the base Docker image we use for Postgres/PostGIS. It also includes ogr_fdw and tds_fdw for copying/hosting data to and from a variety of sources, as well as Paul Ramsey's addressing dictionary. You can customize the extensions you want via the `Dockerfile` and `initdb-postgis.sh`. 

## Configuration

There are three things you should edit before you start the docker container for the first time.

`docker-compose.yml` includes the PG admin password as well as a read-only login and password for the GIS database. You should change these.

```yaml 
environment:
  - POSTGRES_PASSWORD=adminpassword
  - READ_LOGIN=reader
  - READ_PASSWORD=readerpassword
```

The top of the `Dockerfile` has the Postgres Major:Minor version, the PostGIS major version, and the time zone. Set those as needed. 

```dockerfile 
FROM postgres:15.1

ENV POSTGISV 3
ENV TZ America/New_York
```

`initdb-postgis.sh` contains all the commands that initialize the Postgres server and database settings. Included in that is server configuration tweaks based on your hardware. If you don't know what you're doing here, I'd recommend using [PGtune](https://pgtune.leopard.in.ua/).

```bash
# https://pgtune.leopard.in.ua/
# DB Version: 15
# OS Type: linux
# DB Type: web
# Total Memory (RAM): 4 GB
# CPUs num: 2
# Connections num: 75
# Data Storage: ssd
psql -c "ALTER SYSTEM SET max_connections = '75';"
psql -c "ALTER SYSTEM SET shared_buffers = '1GB';"
psql -c "ALTER SYSTEM SET effective_cache_size = '3GB';"
psql -c "ALTER SYSTEM SET maintenance_work_mem = '256MB';"
psql -c "ALTER SYSTEM SET checkpoint_completion_target = '0.9';"
psql -c "ALTER SYSTEM SET wal_buffers = '16MB';"
psql -c "ALTER SYSTEM SET default_statistics_target = '100';"
psql -c "ALTER SYSTEM SET random_page_cost = '1.1';"
psql -c "ALTER SYSTEM SET effective_io_concurrency = '200';"
psql -c "ALTER SYSTEM SET work_mem = '6990kB';"
psql -c "ALTER SYSTEM SET min_wal_size = '1GB';"
psql -c "ALTER SYSTEM SET max_wal_size = '4GB';"
```

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

