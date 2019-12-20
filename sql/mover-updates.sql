-- SQL statements to be applied to the CF ged4all database 

ALTER SCHEMA level2 RENAME TO ged4all;

-- Add a project field
ALTER TABLE ged4all.contribution ADD COLUMN IF NOT EXISTS project VARCHAR;
-- Provide project name for SWIO RAFI project contributions
UPDATE ged4all.contribution SET project = 'SWIO RAFI' 
  WHERE model_source LIKE '%SWIO RAFI%';

-- Add a contributed_at timestamp 
ALTER TABLE ged4all.contribution ADD COLUMN IF NOT EXISTS 
	contributed_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW();
UPDATE ged4all.contribution SET contributed_at = '2019-04-01 00:00:00+0' 
  WHERE project='SWIO RAFI';
