--
-- SQL code to update the GED4ALL database as part of Challenge Fund Schema
-- revision. 
--
START TRANSACTION;

DROP TYPE IF EXISTS cf_common.hazard_enum;

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

-- Add "use" column of occupancy_enum type.  Note that we do not use the term
-- occupancy here since we have an occupancy table which refers to occupants
-- while here we mean what use the asset is put to (Residential, Industrial...)
--
ALTER TABLE level2.exposure_model ADD COLUMN use cf_common.occupancy_enum;



--
-- Commit changes to DB
--
COMMIT;
