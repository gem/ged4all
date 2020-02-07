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
Import an exposure model in NRML format into the GED4ALL Database
level 2 schema.  Level 2 in this context means that building counts and
values are supplied as part of the model and not derived from a global
population grid.
"""
import sys

from openquake.hazardlib.nrml import read
from openquake.commonlib import readinput
from database import db_connections
import db_settings

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
        area_type = ex.conversions.area['type']
    except Exception:
        # area is optional, ignore errors
        pass

    return area_type, area_unit


def _get_tag_names(ex):
    """
    Return the content of the tagNames tag or None if not found
    """
    try:
        tag_names = ''
        count = 0
        for name in ex.tagNames.text:
            tag_names += name
            if count > 0:
                tag_names += ' '
            count += 1
        return tag_names
    except Exception:
        return None


MODEL_QUERY = """
INSERT INTO ged4all.exposure_model (
    name, description, taxonomy_source,
    category, area_type, area_unit, tag_names
)
VALUES (%s,%s,%s,%s,%s,%s,%s)
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
        area[1],
        _get_tag_names(ex)
    ])
    return cursor.fetchone()[0]


COST_TYPE_QUERY = """
INSERT INTO ged4all.model_cost_type(
    unit, cost_type_name, aggregation_type, exposure_model_id)
VALUES (%s,%s,%s,%s)
RETURNING id"""


def _import_cost_type(cursor, cost_type, cost_name, model_id):
    """
    Import cost_type information into model_cost_type table
    """
    cost_type_name = cost_type['type']
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


CONTRIBUTION_QUERY = """
INSERT INTO ged4all.contribution(
    model_source, model_date, notes,
    license_code, purpose, version,
    exposure_model_id
)
VALUES (
    %s,%s,%s,
    %s,%s,%s,
    %s
)
RETURNING id"""


def _get_contribution(ex):
    """
    Get contribution node if preset
    """
    try:
        return ex.contribution
    except AttributeError:
        # Ignore exception - optional node
        return None


def _get_optional_child_text(node, child):
    """
    The text contained in the specified child node or None if not present
    """
    try:
        return getattr(node, child).text
    except AttributeError:
        # Ignore exception - optional node
        pass


def _import_contribution(cursor, ex, model_id):
    """
    Import contribution meta-data if present
    """
    cntr = _get_contribution(ex)
    if cntr is None:
        return

    lc = _get_optional_child_text(cntr, 'license_code')
    if lc is not None:
        lc = lc.strip()

    cursor.execute(CONTRIBUTION_QUERY, [
        _get_optional_child_text(cntr, 'model_source'),
        _get_optional_child_text(cntr, 'model_date'),
        _get_optional_child_text(cntr, 'notes'),
        lc,
        _get_optional_child_text(cntr, 'purpose'),
        _get_optional_child_text(cntr, 'version'),
        model_id])
    return cursor.fetchone()[0]


def _get_full_geom(asset):
    """
    Return the WKT geometry string or None if not present
    """
    try:
        return asset.geometry.text
    except Exception:
        # Ignore exception - optional node
        return None


ASSET_QUERY = """
INSERT INTO ged4all.asset (
  exposure_model_id,asset_ref,taxonomy,number_of_units,area,
  the_geom,full_geom)
VALUES (
 %s,%s,%s,%s,%s,
 ST_SetSRID(ST_MakePoint(%s,%s),4326),
 ST_GeomFromText(%s, 4326)
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
        loc['lon'], loc['lat'],
        _get_full_geom(asset)
    ])
    return cursor.fetchone()[0]


COST_QUERY = """INSERT INTO ged4all.cost (
    cost_type_id, value, deductible, insurance_limit, asset_id)
VALUES (%s,%s,%s,%s,%s)"""

OCC_QUERY = """INSERT INTO ged4all.occupancy (
    period, occupants, asset_id)
VALUES (%s,%s,%s)"""

TAGS_QUERY = """INSERT INTO ged4all.tags (
    name, value, asset_id)
VALUES (%s,%s,%s)"""


def _get_tags(asset):
    """
    Get tag dictionary, empty if not present
    """
    tags = {}
    try:
        tags = asset.tags.attrib
    except Exception:
        # ignore errors
        pass
    return tags


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


def _import_assets(cursor, ex, ctd, model_id, nrml_file):
    """
    Import all assets and related cost and occupancy information
    """
    asset_count = 1
    num_assets = len(ex.assets)

    if num_assets == 0:
        al = list(readinput.Exposure.read(nrml_file, asset_nodes=True))
        num_assets = len(al)
    else:
        al = ex.assets

    for asset in al:
        verbose_message('Considering asset {0} of {1}, {2}%\n'.format(
            asset_count, num_assets, asset_count * 100 / num_assets
        ))
        asset_count += 1
        asset_id = _import_asset(cursor, asset, model_id)

        for cost in _get_costs(asset):
            cursor.execute(COST_QUERY, [
                ctd[cost['type']],
                cost['value'],
                cost.attrib.get('deductible'),
                cost.attrib.get('insuranceLimit'),
                asset_id
            ])

        for occ in _get_occupancies(asset):
            cursor.execute(OCC_QUERY, [
                occ.attrib.get('period'),
                occ['occupants'],
                asset_id
            ])

        for tag_name, tag_value in _get_tags(asset).items():
            cursor.execute(TAGS_QUERY, [
                tag_name,
                tag_value,
                asset_id
            ])


def import_exposure_model(ex, nrml_file):
    """
    Import exposure from an exposure model node
    """
    verbose_message("Model contains {0} assets\n" .format(len(ex.assets)))
    connections = db_connections(db_settings.db_confs)
    connection = connections['gedcontrib']

    with connection.cursor() as cursor:
        model_id = _import_model(cursor, ex)
        _import_contribution(cursor, ex, model_id)
        verbose_message('Inserted model, id={0}\n'.format(model_id))
        ctd = _import_cost_types(cursor, ex, model_id)
        _import_assets(cursor, ex, ctd, model_id, nrml_file)
        connection.commit()
        return model_id


def import_exposure_file(nrml_file):
    """
    Import exposure from a NRML file
    """
    return import_exposure_model(read(nrml_file).exposureModel, nrml_file)


if __name__ == '__main__':
    if len(sys.argv) == 1:
        sys.stderr.write('Usage {0} <filename>\n'.format(sys.argv[0]))
        exit(1)

    for fname in sys.argv[1:]:
        verbose_message("Importing {0}\n".format(fname))
        imported_id = import_exposure_file(fname)
        sys.stderr.write("Imported model DB id = {0}\n".format(
            imported_id))
