set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

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

# add postgrereader user
psql -c "CREATE USER $READ_LOGIN WITH PASSWORD '$READ_PASSWORD';"

# create databases
psql -c "CREATE DATABASE gis;"

# grant reader login rights
psql gis -c "GRANT pg_read_all_data TO $READ_LOGIN;"

# add extensions to databases
psql gis -c "CREATE EXTENSION IF NOT EXISTS postgis;"
psql gis -c "CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;"
psql gis -c "CREATE EXTENSION IF NOT EXISTS addressing_dictionary;"
psql gis -c "CREATE EXTENSION IF NOT EXISTS ogr_fdw;"
psql gis -c "CREATE EXTENSION IF NOT EXISTS tds_fdw;"
