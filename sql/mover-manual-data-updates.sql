-- Run mover-updates.sql first

-- "Manually" selected updates to provide sensible(ish) values for
-- project and contributed_at for pre-existing datasets

--
-- GED4ALL contributions
--
UPDATE ged4all.contribution 
	SET project='GED4ALL', 
	contributed_at='2018-04-01 00:00:00'  
 WHERE id IN (1,8,10,18,19,20,21,22,23,24,25,28,30);

--
-- Other older contributions, not linked to a specific project
--
UPDATE ged4all.contribution SET 
	contributed_at='2018-04-01 00:00:00'  
 WHERE id IN (4,27,35)


