-- HOWTO use it:
--  . install oq-platform-taxtweb python package system-wide
--  . load this function once in the database
DROP FUNCTION IF EXISTS cf_common.taxonomy2human;
CREATE EXTENSION IF NOT EXISTS plpython3u;
CREATE OR REPLACE FUNCTION cf_common.taxonomy2human (taxonomy text) RETURNS text AS 
    $$
        from openquake.taxonomy.taxonomy2human import taxonomy2human

        return taxonomy2human(taxonomy)
    $$ 
	LANGUAGE plpython3u 
	IMMUTABLE 
	SECURITY INVOKER 
	RETURNS NULL ON NULL INPUT
	PARALLEL SAFE;

COMMENT ON FUNCTION cf_common.taxonomy2human IS 
	'Returns an English language description of the given string in the GEM Taxonomy v2.0 format.';
