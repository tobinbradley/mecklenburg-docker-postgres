set -e

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

# system tuning
psql -c "ALTER SYSTEM SET max_connections = '$MAX_CONNECTIONS';"
psql -c "ALTER SYSTEM SET shared_buffers = '$SHARED_BUFFERS';"
psql -c "ALTER SYSTEM SET effective_cache_size = '$EFFECTIVE_CACHE_SIZE';"
psql -c "ALTER SYSTEM SET maintenance_work_mem = '$MAINTENANCE_WORK_MEM';"
psql -c "ALTER SYSTEM SET checkpoint_completion_target = '$CHECKPOINT_COMPLETION_TARGET';"
psql -c "ALTER SYSTEM SET wal_buffers = '$WAL_BUFFERS';"
psql -c "ALTER SYSTEM SET default_statistics_target = '$DEFAULT_STATISTICS_TARGET';"
psql -c "ALTER SYSTEM SET random_page_cost = '$RANDOM_PAGE_COST';"
psql -c "ALTER SYSTEM SET effective_io_concurrency = '$EFFECTIVE_IO_CONCURRENCY';"
psql -c "ALTER SYSTEM SET work_mem = '$WORK_MEM';"
psql -c "ALTER SYSTEM SET min_wal_size = '$MIN_WAL_SIZE';"
psql -c "ALTER SYSTEM SET max_wal_size = '$MAX_WAL_SIZE';"

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
