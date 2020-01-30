--
-- SQL code to update the GED4ALL database as part of Challenge Fund Schema
-- revision. 
--
START TRANSACTION;

-- Extend contribution table to include license, purpose & version
--
ALTER TABLE level2.contribution 
	ADD COLUMN license_id INTEGER REFERENCES cf_common.license(id),
		-- TODO make NOT NULL once we have set license for all contributions
	ADD COLUMN version VARCHAR,
	ADD COLUMN purpose TEXT
;
--
-- TODO Once you have set license_id for all contribitions, execute: 
--
-- ALTER TABLE level2.contribution ALTER COLUMN license_id SET NOT NULL;
--

--
-- Create enumerated type for Category.  We have one entry for each type 
-- of GED4ALL Taxonomy (see D2)
--
CREATE TYPE level2.category_enum AS ENUM (
	'buildings',
	'indicators',	
	'infrastructure',
	'crops, livestock and forestry'
);

--
-- Change 'road_network' entries to 'infrastructure' to match enum 
--
UPDATE level2.exposure_model SET category='infrastructure' 
	WHERE category='road_network';

--
-- Convert category varchar to enum
--
ALTER TABLE level2.exposure_model 
  ALTER COLUMN category TYPE level2.category_enum 
	USING category::level2.category_enum;

-- 
-- NOTE that another way of doing this would be to rename the type after
-- the ALTER TABLE command instead of using the UPDATE SET... command before
--
-- ALTER TYPE level2.category_enum RENAME ATTRIBUTE road_network TO network;


--
-- Convert model_date from varchar to DATE type
--
ALTER TABLE level2.contribution ALTER COLUMN model_date TYPE DATE 
	USING to_date(model_date, 'YYYY-MM-DD');



--
-- Commit changes to DB
--
COMMIT;
