START TRANSACTION;

--
-- Minor license code changes to align with respective websites
--
UPDATE cf_common.license SET code = 'ODC-By' WHERE code='ODC-BY';
UPDATE cf_common.license SET code = 'CC BY 4.0' WHERE code='CC-BY-4.0';
UPDATE cf_common.license SET code = 'CC BY-SA 4.0' WHERE code='CC-BY-SA-4.0';

ALTER TABLE cf_common.license ADD CONSTRAINT license_pkey PRIMARY KEY (code);
ALTER TABLE cf_common.license DROP CONSTRAINT IF EXISTS unique_code; 

ALTER TABLE ged4all.contribution 
  ADD COLUMN license_code VARCHAR REFERENCES cf_common.license(code);

UPDATE ged4all.contribution c
   SET license_code=l.code
  FROM cf_common.license l 
 WHERE c.license_id=l.id;

ALTER TABLE ged4all.contribution ALTER COLUMN license_code SET NOT NULL;
ALTER TABLE ged4all.contribution DROP COLUMN IF EXISTS license_id;

ALTER TABLE cf_common.license DROP COLUMN IF EXISTS id;

COMMIT;
