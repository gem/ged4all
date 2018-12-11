--
-- Common elements for all Challenge Fund Database Schemas
-- Hazard enumeration (copied from MOVER)
-- License table
--
CREATE SCHEMA IF NOT EXISTS cf_common;
COMMENT ON SCHEMA cf_common IS 
	'Common elements for all Challenge Fund Database Schemas';

--
-- Enumerated type for supported hazards (aka perils)
--
-- This will fail if the enum already exists.
--
CREATE TYPE cf_common.hazard_enum AS ENUM (
    'Earthquake',
    'Tsunami',
    'Flood',
    'Wind',
    'Landslide',
    'Storm Surge',
    'Volcanic Ash',
    'Drought',
    'Multi-hazard'
);

--
-- Supported licenses
--
CREATE TABLE IF NOT EXISTS cf_common.license (
	id		SERIAL	PRIMARY KEY,
	code	VARCHAR NOT NNULL,
	name	VARCHAR	NOT NULL,
	notes	TEXT,
	url		VARCHAR NOT NULL
);
COMMENT ON TABLE cf_common.license IS
	'List of supported licenses'

