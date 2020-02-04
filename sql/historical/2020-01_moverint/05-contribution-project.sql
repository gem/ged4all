START TRANSACTION;

-- Add a project field
ALTER TABLE ged4all.contribution ADD COLUMN IF NOT EXISTS project VARCHAR;
UPDATE ged4all.contribution SET project = 'SWIO RAFI' 
 WHERE model_source LIKE '%SWIO%';

-- Add a contributed_at timestamp (with time zone)
ALTER TABLE ged4all.contribution ADD COLUMN IF NOT EXISTS 
	contributed_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW();
UPDATE ged4all.contribution SET contributed_at = '2019-04-01 00:00:00+0' 
 WHERE model_source LIKE '%SWIO%';

COMMIT;
