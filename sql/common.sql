--
-- Common elements for all Challenge Fund Database Schemas
-- Hazard enumeration (Based on discussions with Stuart Fraser, GFDRR)
-- License table
--
START TRANSACTION;

CREATE SCHEMA IF NOT EXISTS cf_common;
COMMENT ON SCHEMA cf_common IS 
	'Common elements for all Challenge Fund Database Schemas';

--
-- Remove old Enumerated type for supported hazards (aka perils) 
--
DROP TYPE IF EXISTS cf_common.hazard_enum;


--
-- Valid hazard types
--
CREATE TABLE cf_common.hazard_type (
    code    VARCHAR PRIMARY KEY,
    name    VARCHAR NOT NULL
);
COMMENT ON TABLE cf_common.hazard_type IS 'Valid Hazard types';
ALTER TABLE cf_common.hazard_type OWNER TO ged2admin;

DELETE FROM cf_common.hazard_type;
COPY cf_common.hazard_type (code, name) FROM stdin;
CS	Convective Storm
EQ	Earthquake
TS	Tsunami
VO	Volcanic
CF	Coastal Flood
FL	Flood
LS	Landslide
WI	Strong Wind
ET	Extreme Temperature
DR	Drought
WF	Wildfire
MH	Multi-Hazard
\.

--
-- Process Types by Hazard type
--
CREATE TABLE cf_common.process_type (
    code        VARCHAR PRIMARY KEY,
    hazard_code VARCHAR NOT NULL,
    name        VARCHAR NOT NULL
);
ALTER TABLE cf_common.process_type OWNER TO ged2admin;

DELETE FROM cf_common.process_type;
COPY cf_common.process_type (code, hazard_code, name) FROM stdin;
QLI	EQ	Liquefaction
QGM	EQ	Ground Motion
Q1R	EQ	Primary Rupture
Q2R	EQ	Secondary Rupture
TSI	TS	Tsunami
VAF	VO	Ashfall
VLH	VO	Lahar
VPF	VO	Pyroclastic Flow
VBL	VO	Ballistics
VLV	VO	Lava
VFH	VO	Proximal hazards
FSS	CF	Storm Surge
FCF	CF	Coastal Flood
FFF	FL	Fluvial Flood
FPF	FL	Pluvial Flood
LAV	LS	Snow Avalanche
LSL	LS	Landslide (general)
TCY	WI	Tropical cyclone
ETC	WI	Extratropical cyclone
EHT	ET	Extreme heat
ECD	ET	Extreme cold
DTS	DR	Socio-economic Drought
DTM	DR	Meteorological Drought
DTH	DR	Hydrological Drought
DTA	DR	Agricultural Drought
WFI	WF	Wildfire
TOR	CS	Tornado
\.

--
-- Enumerated type for occupancy/use categories
--
CREATE TYPE cf_common.occupancy_enum AS ENUM (
	'Residential',
	'Commercial',
	'Industrial',
	'Infrastructure',
	'Healthcare',
	'Educational',
	'Government',
	'Crop',
	'Livestock',
	'Forestry',
	'Mixed'
);
COMMENT ON TYPE cf_common.occupancy_enum 
	IS 'Types of Occupancy or building/structure use';

--
-- Supported licenses
--
CREATE TABLE IF NOT EXISTS cf_common.license (
	id		SERIAL	PRIMARY KEY,
	code	VARCHAR NOT NULL,
	name	VARCHAR	NOT NULL,
	notes	TEXT,
	url		VARCHAR NOT NULL
);
COMMENT ON TABLE cf_common.license IS
	'List of supported licenses';
ALTER TABLE cf_common.process_type OWNER TO ged2admin;

DELETE FROM cf_common.license;
COPY cf_common.license (code,name,notes,url)
	FROM STDIN
	WITH (FORMAT csv);
CC0,Creative Commons CCZero (CC0),Dedicate to the Public Domain (all rights waived),https://creativecommons.org/publicdomain/zero/1.0/
PDDL,Open Data Commons Public Domain Dedication and Licence (PDDL),Dedicate to the Public Domain (all rights waived),https://opendatacommons.org/licenses/pddl/index.html
CC-BY-4.0,Creative Commons Attribution 4.0 (CC-BY-4.0),,https://creativecommons.org/licenses/by/4.0/
ODC-BY,Open Data Commons Attribution License(ODC-BY),Attribution for data(bases),https://opendatacommons.org/licenses/by/summary/
CC-BY-SA-4.0,Creative Commons Attribution Share-Alike 4.0 (CC-BY-SA-4.0),,http://creativecommons.org/licenses/by-sa/4.0/
ODbL,Open Data Commons Open Database License (ODbL),Attribution-ShareAlike for data(bases),https://opendatacommons.org/licenses/odbl/summary/
\.

COMMIT;

GRANT USAGE ON SCHEMA cf_common TO gedusers;
GRANT SELECT ON ALL TABLES IN SCHEMA cf_common TO gedusers;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA cf_common TO ged2admin;

-- Magic Vim comment to use 4 space tabs
-- vim: set ts=4:sw=4
