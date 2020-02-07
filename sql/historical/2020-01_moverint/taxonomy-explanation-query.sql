WITH tax AS (
	SELECT DISTINCT(a.taxonomy) 
	  FROM ged4all.asset a 
	  JOIN ged4all.exposure_model e ON e.id=a.exposure_model_id 
     WHERE e.taxonomy_source='GEM taxonomy' ORDER BY 1 
)  
SELECT tax.*, cf_common.taxonomy2human(tax.taxonomy) AS explanation FROM tax
