#!/bin/bash

# Start Cassandra in the background
/usr/local/bin/docker-entrypoint.sh cassandra -R &

# Initial wait to give Cassandra time to start
sleep 30

# Wait until Cassandra is available
until cqlsh -u "$CASSANDRA_USER" -p "$CASSANDRA_PASSWORD" -e 'DESC KEYSPACES'; do
  >&2 echo "Cassandra is unavailable - sleeping"
  sleep 5
done

# Execute the CQL commands
cqlsh -u "$CASSANDRA_USER" -p "$CASSANDRA_PASSWORD" -f /data.cql

>&2 echo "Cassandra is up - executed CQL script"

# Keep the container running
tail -f /dev/null
