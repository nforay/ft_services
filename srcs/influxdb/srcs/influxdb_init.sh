#!/bin/bash

EXEC="influx -host 127.0.0.1 -execute "
$EXEC "CREATE DATABASE metrics"
$EXEC "CREATE USER \"telegraf\" WITH PASSWORD 'password'"
$EXEC "CREATE USER \"grafana\" WITH PASSWORD 'password'"
$EXEC "CREATE USER \"admin\" WITH PASSWORD 'password'"
$EXEC "GRANT ALL PRIVILEGES TO \"admin\""
$EXEC "REVOKE ALL PRIVILEGES FROM \"grafana\""
$EXEC "REVOKE ALL PRIVILEGES FROM \"telegraf\""
$EXEC "GRANT READ ON \"metrics\" TO \"grafana\""
$EXEC "GRANT WRITE ON \"metrics\" TO \"telegraf\""
