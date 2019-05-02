#!/bin/sh
DB_NAME=ged4all

createdb $DB_NAME

psql -d $DB_NAME << _EOF_
CREATE EXTENSION postgis;
CREATE ROLE gedusers NOLOGIN NOINHERIT;
CREATE ROLE ged2admin NOLOGIN INHERIT;
GRANT gedusers TO ged2admin;
_EOF_

echo "$0: Don't forget to set passwords for gedviewer and contributor" >&2
