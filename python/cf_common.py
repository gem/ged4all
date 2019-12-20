#
# -*- coding: utf-8 -*-
# vim: tabstop=4 shiftwidth=4 softtabstop=4
#
# Copyright (c) 2019, GEM Foundation.
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

import sys


class License():
    """
    License codes and ids present in DB
    """
    _LICENSE_ID_QUERY = "SELECT id, code FROM cf_common.license"
    _LICENSE_DICT = {}

    "Call once to load licenses into memory"
    @classmethod
    def load_licenses(cls, cursor):
        cursor.execute(License._LICENSE_ID_QUERY)
        for row in cursor.fetchall():
            License._LICENSE_DICT[row[1]] = row[0]

    """
    ID for license code or None if not present.
    Call load_licenses before use
    """
    @classmethod
    def get_license_id(cls, code):
        return License._LICENSE_DICT.get(code)


class Contribution():
    """
    Meta-Data description a contribution: date, source, etc.

    :param model_id:
    :param model_source:
    :param model_date:
    :param license_id:
    :param notes:
    :param version:
    :param purpose:
    """
    def __init__(self, model_id, model_source, model_date, license_id,
                 notes=None, version=None, purpose=None):
        self.model_id = model_id
        self.model_source = model_source
        self.model_date = model_date
        self.license_id = license_id
        self.notes = notes
        self.version = version
        self.purpose = purpose

    """
    Create a Contribution from a meta-data dictionary.  Maps license
    codes to IDs automatically
    """
    @classmethod
    def from_md(cls, md):
        lc = md.get('license_code')
        if lc is not None:
            lid = License.get_license_id(lc)
            sys.stderr.write(
                "Replaced license code {0} with id {1}\n".format(lc, lid))
            md["license_id"] = lid
        return Contribution(
            None,
            md.get('model_source'),
            md.get('model_date'),
            md.get('license_id'),
            md.get('notes'),
            md.get('version'),
            md.get('purpose'))
