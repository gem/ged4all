START TRANSACTION;
-- Remove test data and examples with broken taxonomy strings
DELETE FROM ged4all.exposure_model WHERE id IN (51,105, 148,150);
-- Update taxonomy source for models using GEM Taxonomy > 2.0
UPDATE ged4all.exposure_model SET taxonomy_source='GEM Taxonomy v3beta' 
	WHERE id IN (49, 108, 143, 146, 147);
COMMIT;
