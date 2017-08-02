WITH tax AS (
SELECT

CASE building_structure
 WHEN 'cement_blocks'
 THEN 'MUR+CB99'
 WHEN 'concrete_frame_and_cement_blocks'
 THEN 'MCF+CB99'
 WHEN 'coralstone_and_lime'
 THEN 'MUR+ST99+MOL'
 WHEN 'makeshift'
 THEN 'MATO'
 ELSE NULL
END AS mat,

CASE building_levels
 WHEN NULL 
 THEN NULL
 ELSE 'HEX:' || building_levels
END AS height,
*
FROM test.osm
)
SELECT 
full_id AS id,
ST_X(ST_Centroid(the_geom)) AS lon, 
ST_Y(ST_Centroid(the_geom)) AS lat, 
COALESCE(
tax.mat || '/' || tax.height,
tax.mat, tax.height
) AS taxonomy,
1 AS number

  FROM tax
WHERE building_levels IS NOT NULL OR building_structure IS NOT NULL