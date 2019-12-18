#!/bin/sh

. $(readlink -f $(dirname $0))/db_settings.sh

createdb -U $DB_USER -p $DB_PORT -h $DB_HOST $DB_NAME

psql -U $DB_USER -h $DB_HOST -p $DB_PORT -d $DB_NAME  << _EOF_
CREATE EXTENSION postgis;
CREATE ROLE ged4allusers NOLOGIN NOINHERIT;
CREATE ROLE ged4allviewer NOLOGIN INHERIT;
CREATE ROLE ged4allcontrib NOLOGIN INHERIT;
GRANT ged4allusers TO ged4allviewer;
GRANT ged4allviewer TO ged4allcontrib;
_EOF_

echo "$0: Don't forget to set passwords for ged4allviewer and ged4allcontrib" >&2
