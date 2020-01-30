# -*- coding: utf-8 -*-
# vim: tabstop=4 shiftwidth=4 softtabstop=4
#
# Copyright (c) 2020, GEM Foundation.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.
# If not, see <https://www.gnu.org/licenses/agpl.html>.
#
import psycopg2


def db_connections(db_confs):
    conns = {}
    for k in db_confs.keys():
        db_conf = db_confs[k]
        kwargs = {}
        if 'OPTIONS' in db_conf:
            if 'sslmode' in db_conf['OPTIONS']:
                kwargs['sslmode'] = db_conf['OPTIONS']['sslmode']

        conns[k] = psycopg2.connect(user=db_conf['USER'],
                                    password=db_conf['PASSWORD'],
                                    host=db_conf['HOST'],
                                    port=db_conf['PORT'],
                                    database=db_conf['NAME'],
                                    **kwargs)

    return conns
