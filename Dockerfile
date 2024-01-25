FROM postgres:15.1

ENV POSTGISV 3
ENV TZ America/New_York

# add addressing dictionary
RUN mkdir -p /opt/apps

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  postgresql-$PG_MAJOR-postgis-$POSTGISV \
  postgresql-$PG_MAJOR-postgis-$POSTGISV-scripts \
  postgresql-server-dev-$PG_MAJOR \
  postgresql-$PG_MAJOR-ogr-fdw \
  ca-certificates \
  libsybdb5 freetds-dev freetds-common \
  gnupg gcc make unzip wget git \
  && cd /opt/apps \
  && git clone https://github.com/pramsey/pgsql-addressing-dictionary.git \
  && cd pgsql-addressing-dictionary \
  && make install \
  && cd .. \
  && export TDS_FDW_VERSION="2.0.3" \
  && wget https://github.com/tds-fdw/tds_fdw/archive/v${TDS_FDW_VERSION}.tar.gz \
  && tar -xvzf v${TDS_FDW_VERSION}.tar.gz \
  && cd tds_fdw-${TDS_FDW_VERSION}/ \
  && make USE_PGXS=1 \
  && make USE_PGXS=1 install \
  && apt-get purge -y --auto-remove postgresql-server-dev-$PG_MAJOR gnupg gcc make unzip wget

# set time zone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# add bakcup job
RUN mkdir -p /opt/backups
COPY ./pgbackup.sh /opt/pgbackup.sh
RUN chmod +x /opt/pgbackup.sh

# add init script
RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/postgis.sh
RUN chmod +x /docker-entrypoint-initdb.d/postgis.sh

# create volume for backups
VOLUME ["/opt/backups"]
