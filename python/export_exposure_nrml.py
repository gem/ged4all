#!/usr/bin/env python
# -*- coding: utf-8 -*-
# vim: tabstop=4 shiftwidth=4 softtabstop=4

# Copyright (c) 2017, GEM Foundation.
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
"""
Export an exposure model in NRML format from the GED4ALL Database
level 2 schema.  Level 2 in this context means that building counts and
values are supplied as part of the model and not derived from a global
population grid.
"""
import sys
from xml.etree import ElementTree as etree

from openquake.baselib.node import tostring
from django.db import connections
from django.conf import settings


import db_settings
settings.configure(DATABASES=db_settings.DATABASES)

VERBOSE = True


def verbose_message(msg):
    """
    Display message if we are in verbose model
    """
    if VERBOSE:
        sys.stderr.write(msg)


def dictfetchall(cursor):
    "Return all rows from a cursor as a dict"
    columns = [col[0] for col in cursor.description]
    return [
        dict(zip(columns, row))
        for row in cursor.fetchall()
    ]


def dictfetchone(cursor):
    "Return first row from a cursor as a dict"
    row = cursor.fetchone()
    if row is None or len(row) == 0:
        return None
    else:
        columns = [col[0] for col in cursor.description]
        return dict(zip(columns, row))

MODEL_QUERY = 'SELECT * FROM level2.exposure_model WHERE id=%s'

COST_TYPE_QUERY = """
SELECT * FROM level2.model_cost_type WHERE exposure_model_id=%s
"""

ASSET_QUERY = """
SELECT id, exposure_model_id, asset_ref, taxonomy, number_of_units, area,
       ST_Y(the_geom) AS lat, ST_X(the_geom) AS lon,
       ST_AsText(full_geom) AS full_geom
  FROM level2.asset
 WHERE exposure_model_id=%s
 ORDER BY id
"""

COST_QUERY = """
SELECT * FROM level2.cost WHERE asset_id=%s
"""

OCC_QUERY = """
SELECT * FROM level2.occupancy WHERE asset_id=%s
"""

TAGS_QUERY = """
SELECT * FROM level2.tags WHERE asset_id=%s
"""


def _handle_cost_types(cursor, model_id, conv):
    ctd = {}
    ctn = etree.SubElement(conv, 'costTypes')
    cursor.execute(COST_TYPE_QUERY, [model_id])
    rows = dictfetchall(cursor)
    for row in rows:
        ctd[row['id']] = row['cost_type_name']
        etree.SubElement(ctn, 'costType', {
            'name': row['cost_type_name'],
            'type': row['aggregation_type'],
            'unit': row['unit']
        })
    return ctd


def _handle_costs(anode, cursor, asset, ctd):
    costs_node = etree.SubElement(anode, 'costs')
    cursor.execute(COST_QUERY, [asset['id']])
    cost_rows = dictfetchall(cursor)
    for cost in cost_rows:
        attr = {
            'type': ctd[cost['cost_type_id']],
            'value': '{:.5F}'.format(cost['value'])
        }
        if cost['deductible'] is not None:
            attr['deductible'] = '{:.5F}'.format(cost['deductible'])
        if cost['insurance_limit'] is not None:
            attr['insuranceLimit'] = '{:.5F}'.format(
                cost['insurance_limit'])
        etree.SubElement(costs_node, 'cost', attr)


def _handle_occupancy(anode, cursor, asset):
    occs_node = etree.SubElement(anode, 'occupancies')
    cursor.execute(OCC_QUERY, [asset['id']])
    occ_rows = dictfetchall(cursor)
    for occ in occ_rows:
        etree.SubElement(occs_node, 'occupancy', {
            'period': occ['period'],
            'occupants': '{:g}'.format(occ['occupants'])
        })


def _handle_tags(anode, cursor, asset):
    tags_node = etree.SubElement(anode, 'tags')
    cursor.execute(TAGS_QUERY, [asset['id']])
    tag_rows = dictfetchall(cursor)
    tag_dict = {}
    for tag in tag_rows:
        tags_node.attrib[tag['name']] = tag['value']


def _build_tree(model_id, model_dict, cursor):
    nrml = etree.Element(
        'nrml', {'xmlns': 'http://openquake.org/xmlns/nrml/0.5'})
    em_dict = {
            'id': model_dict['name'],
            'category': model_dict['category'],
            'taxonomySource': model_dict['taxonomy_source']
    }
    exm = etree.SubElement(nrml, 'exposureModel', em_dict)
    etree.SubElement(exm, 'description').text = \
        model_dict['description']
    conv = etree.SubElement(exm, 'conversions')
    if model_dict['tag_names'] is not None:
        etree.SubElement(exm, 'tagNames').text = \
            model_dict['tag_names']
    if model_dict['area_type'] is not None:
        etree.SubElement(conv, 'area', {
            'type': model_dict['area_type'],
            'unit': model_dict['area_unit']
        })

    ctd = _handle_cost_types(cursor, model_id, conv)

    assets = etree.SubElement(exm, 'assets')
    cursor.execute(ASSET_QUERY, [model_id])
    asset_rows = dictfetchall(cursor)
    for asset in asset_rows:
        anode = etree.SubElement(assets, 'asset', {
            'id': asset['asset_ref'],
            'number': '{:g}'.format(asset['number_of_units']),
            'taxonomy': asset['taxonomy']
        })
        if asset['area'] is not None:
            anode.set('area', '{:g}'.format(asset['area']))
        loc_node = etree.SubElement(anode, 'location', {
            'lon': '{:g}'.format(asset['lon']),
            'lat': '{:g}'.format(asset['lat'])
        })
        if asset['full_geom'] is not None:
            etree.SubElement(anode, 'geometry').text = asset['full_geom']
            # etree.SubElement(anode, 'geometry', {
            #    'wkt': asset['full_geom']
            # c})
        _handle_costs(anode, cursor, asset, ctd)
        _handle_occupancy(anode, cursor, asset)
        _handle_tags(anode, cursor, asset)
    return nrml


def exposure_to_nrml(model_id):
    """
    Return a NRML XML tree for the exposure model with the specified id
    """
    with connections['geddb'].cursor() as cursor:
        cursor.execute(MODEL_QUERY, [model_id])
        model_dict = dictfetchone(cursor)
        if model_dict is None:
            return None
        return _build_tree(model_id, model_dict, cursor)


if __name__ == '__main__':
    if len(sys.argv) == 1:
        sys.stderr.write('Usage {0} <exposure model id>\n'.format(sys.argv[0]))
        exit(1)

    for xmodel_id in sys.argv[1:]:
        xnrml = exposure_to_nrml(xmodel_id)
        if xnrml is None:
            exit('Exposure model {0} not found'.format(
                xmodel_id))

        verbose_message("Exporting {0}\n".format(xmodel_id))
        sys.stdout.write('<?xml version="1.0" encoding="UTF-8"?>\n')
        sys.stdout.write(tostring(xnrml))
