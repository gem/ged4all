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
Import an exposure model in NRML format into the GED4ALL Database
level 2 schema.  Level 2 in this context means that building counts and
values are supplied as part of the model and not derived from a global
population grid.
"""
import sys

from openquake.hazardlib.nrml import read
from django.db import connections
from django.conf import settings

import db_settings
settings.configure(DATABASES=db_settings.DATABASES)

VERBOSE = False


def verbose_message(msg):
    """
    Display message if we are in verbose mode
    """
    if VERBOSE:
        sys.stderr.write(msg)


def _get_area(ex):
    """
    Obtain area type and unit from exposure model node, if present
    """
    area_unit = None
    area_type = None
    try:
        area_unit = ex.conversions.area['unit']
        area_type = ex.conversions.area['type'][0]
    except Exception:
        # area is optional, ignore errors
        pass

    return area_type, area_unit


MODEL_QUERY = """
INSERT INTO level2.exposure_model (
    name, description, taxonomy_source,
    category, area_type, area_unit
)
VALUES (%s,%s,%s,%s,%s,%s)
RETURNING id
"""


def _import_model(cursor, ex):
    """
    Import model into exposure_model table, returning DB id
    """
    area = _get_area(ex)
    cursor.execute(MODEL_QUERY, [
        ex.attrib.get('id'),
        ex.description.text,
        ex.attrib.get('taxonomySource'),
        ex.attrib.get('category'),
        area[0],
        area[1]
    ])
    return cursor.fetchone()[0]

COST_TYPE_QUERY = """
INSERT INTO level2.model_cost_type(
    unit, cost_type_name, aggregation_type, exposure_model_id)
VALUES (%s,%s,%s,%s)
RETURNING id"""


def _import_cost_type(cursor, cost_type, cost_name, model_id):
    """
    Import cost_type information into model_cost_type table
    """
    # I don't understand why cost_type_name is a list, expecting string
    cost_type_name = cost_type['type'][0]
    cursor.execute(COST_TYPE_QUERY, [
        cost_type.attrib.get('unit'),
        cost_name,
        cost_type_name,
        model_id])
    return cursor.fetchone()[0]


def _import_cost_types(cursor, ex, model_id):
    """
    Import all cost types present in model
    """
    # Dictionary mapping Cost Type name to ID in DB
    type_ids = {}
    for cost_type in ex.conversions.costTypes:
        cost_name = cost_type['name']
        cost_type_id = _import_cost_type(
            cursor, cost_type, cost_name, model_id)
        # Store cost_type id for use when inserting into cost table below
        type_ids[cost_name] = cost_type_id
    return type_ids

ASSET_QUERY = """
INSERT INTO level2.asset (
  exposure_model_id,asset_ref,taxonomy,number_of_units,area,the_geom)
VALUES (
 %s,%s,%s,%s,%s,ST_SetSRID(ST_MakePoint(%s,%s),4326)
)
RETURNING id"""


def _import_asset(cursor, asset, model_id):
    """
    Import a single asset returning the newly assigned DB id
    """
    loc = asset.location
    cursor.execute(ASSET_QUERY, [
        model_id,
        asset.attrib.get('id'),  # id attribute -> asset_ref
        asset.attrib.get('taxonomy'),
        asset.attrib.get('number'),
        asset.attrib.get('area'),
        loc['lon'], loc['lat']
    ])
    return cursor.fetchone()[0]

COST_QUERY = """INSERT INTO level2.cost (cost_type_id, value, asset_id)
VALUES (%s,%s,%s)"""

OCC_QUERY = """INSERT INTO level2.occupancy (
    period, occupants, asset_id)
VALUES (%s,%s,%s)"""


def _get_occupancies(asset):
    """
    Get occupancy nodes or empty list if not present
    """
    occs = []
    try:
        occs = asset.occupancies
    except Exception:
        # ignore errors
        pass
    return occs


def _get_costs(asset):
    """
    Get asset cost nodes or empty list if not present
    """
    occs = []
    try:
        occs = asset.costs
    except Exception:
        # ignore errors
        pass
    return occs


def _import_assets(cursor, ex, ctd, model_id):
    """
    Import all assets and related cost and occupancy information
    """
    asset_count = 1

    num_assets = len(ex.assets)
    for asset in ex.assets:
        verbose_message('Considering asset {0} of {1}, {2}%\n'.format(
            asset_count, num_assets, asset_count * 100 / num_assets
        ))
        asset_count += 1
        asset_id = _import_asset(cursor, asset, model_id)

        for cost in _get_costs(asset):
            cursor.execute(COST_QUERY, [
                # Why is the type attribute a list?
                # Get cost type id from dict
                ctd[cost['type'][0]],
                cost['value'],
                asset_id
            ])

        for occ in _get_occupancies(asset):
            cursor.execute(OCC_QUERY, [
                occ.attrib.get('period'),
                occ['occupants'],
                asset_id
            ])


def import_exposure_model(ex):
    """
    Import exposure from an exposure model node
    """
    verbose_message("Model contains {0} assets\n" .format(len(ex.assets)))

    with connections['gedcontrib'].cursor() as cursor:
        model_id = _import_model(cursor, ex)
        verbose_message('Inserted model, id={0}\n'.format(model_id))
        ctd = _import_cost_types(cursor, ex, model_id)
        _import_assets(cursor, ex, ctd, model_id)
        return model_id


def import_exposure_file(nrml_file):
    """
    Import exposure from a NRML file
    """
    return import_exposure_model(read(nrml_file).exposureModel)


if __name__ == '__main__':
    if len(sys.argv) == 1:
        sys.stderr.write('Usage {0} <filename>\n'.format(sys.argv[0]))
        exit(1)

    for fname in sys.argv[1:]:
        verbose_message("Importing {0}\n".format(fname))
        imported_id = import_exposure_file(fname)
        verbose_message("Imported model DB id = {0}\n".format(
            imported_id))
