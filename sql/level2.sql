--
-- EXPERIMENTAL Schema for GED4ALL database 
-- Based on but not identical to GED4GEM level2 (not derived from population) 
-- schema which in turn is based on OpenQuake NRML exposure model
--
SET client_encoding = 'UTF8';

--
-- TODO rename schemas and tablespaces for GED4ALL, level nomenclature not 
-- really appropriate
--
CREATE SCHEMA level2;
ALTER SCHEMA level2 OWNER TO ged4all_owner;

SET search_path = level2, pg_catalog;
SET default_tablespace = ged4all_ts;

--
-- Exposure model - a collection of Asset with associated cost types and 
-- taxonomy system
--
CREATE TABLE exposure_model (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    taxonomy_source character varying,
    category character varying NOT NULL,
    area_type character varying,
    area_unit character varying,
    CONSTRAINT area_type_value CHECK ((
		(area_type IS NULL) OR 
		((area_type)::text = 'per_asset'::text) OR 
		((area_type)::text = 'aggregated'::text)
	))
);

--
-- Meta-data for contributed exposure model 
-- TODO update import/export code to use this table
-- TODO add optional URL field
--
CREATE TABLE contribution (
    id integer NOT NULL,
    exposure_model_id integer NOT NULL,
    model_source character varying NOT NULL,
    model_date character varying NOT NULL,
    notes text
);
ALTER TABLE ONLY contribution
    ADD CONSTRAINT contribution_exposure_model_id_fkey 
		FOREIGN KEY (exposure_model_id) 
		REFERENCES exposure_model(id) ON DELETE CASCADE;

--
-- Cost types for Assets in a given model 
-- cost type name is user defined examples include "structural", "contents", 
-- "business interruption"... 
-- aggregation type is one of: per_asset / per_area / aggregated
-- unit is typically a currency ISO code such as USD or EUR
--
--
CREATE TABLE model_cost_type (
    id integer NOT NULL,
    exposure_model_id integer NOT NULL,
    cost_type_name character varying NOT NULL,
    aggregation_type character varying NOT NULL,
    unit character varying,
    CONSTRAINT aggregation_type_value CHECK ((
		((aggregation_type)::text = 'per_asset'::text) OR 
		((aggregation_type)::text = 'per_area'::text) OR 
		((aggregation_type)::text = 'aggregated'::text)
	))
);
ALTER TABLE ONLY model_cost_type
    ADD CONSTRAINT model_cost_type_exposure_model_id_fk 
		FOREIGN KEY (exposure_model_id) 
		REFERENCES exposure_model(id) ON DELETE CASCADE;

--
-- Asset - an item of value (building, aggregated collection of buildings, 
--         structure, field etc.)
--
-- TODO - add support for optional NRML 'tag' tags (coming soon) 
-- TODO - add support for optional arbitrary geometry (in addition to point; 
--        for example footprints/areas/networks )
-- TODO - add support for optional external reference (Census track number, 
--        CRESTA id, HASC code...) 
--        maybe we can use NRML 'tag' tags for all optional data
--
CREATE TABLE asset (
    id integer NOT NULL,
    exposure_model_id integer NOT NULL,
    asset_ref character varying,
    taxonomy character varying NOT NULL,
    number_of_units double precision,
    area double precision,
    the_geom public.geometry(Point,4326) NOT NULL,
    CONSTRAINT area_value CHECK ((area >= (0.0)::double precision)),
    CONSTRAINT units_value CHECK ((number_of_units >= (0.0)::double precision))
);
-- Delete asset when parent exposure model is deleted
ALTER TABLE ONLY asset
    ADD CONSTRAINT asset_exposure_model_id_fk FOREIGN KEY (exposure_model_id) 
		REFERENCES exposure_model(id) ON DELETE CASCADE;
ALTER TABLE ONLY asset
    ADD CONSTRAINT asset_exposure_model_id_asset_ref_key 
		UNIQUE (exposure_model_id, asset_ref);

--
-- Cost of a specified Asset, refers to model_cost_type
--
CREATE TABLE cost (
    id integer NOT NULL,
    asset_id integer NOT NULL,
    cost_type_id integer NOT NULL,
    value double precision NOT NULL,
    CONSTRAINT converted_cost_value CHECK ((value >= (0.0)::double precision))
);
ALTER TABLE ONLY cost
    ADD CONSTRAINT cost_asset_id_fk FOREIGN KEY (asset_id) 
		REFERENCES asset(id) ON DELETE CASCADE;
ALTER TABLE ONLY cost
    ADD CONSTRAINT cost_cost_type_id_fkey FOREIGN KEY (cost_type_id) 
		REFERENCES model_cost_type(id);
--
-- Occupancy of a given Asset
--
CREATE TABLE occupancy (
    id integer NOT NULL,
    asset_id integer NOT NULL,
    period character varying NOT NULL,
    occupants double precision NOT NULL
);
ALTER TABLE ONLY occupancy
    ADD CONSTRAINT occupancy_asset_id_fk FOREIGN KEY (asset_id) 
	REFERENCES asset(id) ON DELETE CASCADE;

--
-- Indices - it is particularly important to be able to locate assets by
-- exposure_model_id in order to perform ON DELETE CASCADE in reasonable time
--
CREATE INDEX asset_exposure_model_id_idx ON asset 
	USING btree (exposure_model_id);

CREATE INDEX cost_asset_id_idx ON cost USING btree (asset_id);

CREATE INDEX occupancy_asset_id_idx ON occupancy USING btree (asset_id);

CREATE INDEX asset_the_geom_gist ON asset USING GIST(the_geom);


--
-- End of data-model 
--
--
ALTER TABLE exposure_model OWNER TO ged4all_owner;
ALTER TABLE asset OWNER TO ged4all_owner;

--
-- Name: asset_id_seq; Type: SEQUENCE; Schema: level2; Owner: ged4all_owner
--

CREATE SEQUENCE asset_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE asset_id_seq OWNER TO ged4all_owner;

--
-- Name: asset_id_seq; Type: SEQUENCE OWNED BY; Schema: level2; Owner: ged4all_owner
--

ALTER SEQUENCE asset_id_seq OWNED BY asset.id;




ALTER TABLE contribution OWNER TO ged4all_owner;

--
-- Name: contribution_id_seq; Type: SEQUENCE; Schema: level2; Owner: ged4all_owner
--

CREATE SEQUENCE contribution_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE contribution_id_seq OWNER TO ged4all_owner;

--
-- Name: contribution_id_seq; Type: SEQUENCE OWNED BY; Schema: level2; Owner: ged4all_owner
--

ALTER SEQUENCE contribution_id_seq OWNED BY contribution.id;




ALTER TABLE cost OWNER TO ged4all_owner;

--
-- Name: cost_id_seq; Type: SEQUENCE; Schema: level2; Owner: ged4all_owner
--

CREATE SEQUENCE cost_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cost_id_seq OWNER TO ged4all_owner;

--
-- Name: cost_id_seq; Type: SEQUENCE OWNED BY; Schema: level2; Owner: ged4all_owner
--

ALTER SEQUENCE cost_id_seq OWNED BY cost.id;



--
-- Name: exposure_model_id_seq; Type: SEQUENCE; Schema: level2; Owner: ged4all_owner
--

CREATE SEQUENCE exposure_model_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE exposure_model_id_seq OWNER TO ged4all_owner;

--
-- Name: exposure_model_id_seq; Type: SEQUENCE OWNED BY; Schema: level2; Owner: ged4all_owner
--

ALTER SEQUENCE exposure_model_id_seq OWNED BY exposure_model.id;




ALTER TABLE model_cost_type OWNER TO ged4all_owner;

--
-- Name: model_cost_type_id_seq; Type: SEQUENCE; Schema: level2; Owner: ged4all_owner
--

CREATE SEQUENCE model_cost_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE model_cost_type_id_seq OWNER TO ged4all_owner;

--
-- Name: model_cost_type_id_seq; Type: SEQUENCE OWNED BY; Schema: level2; Owner: ged4all_owner
--

ALTER SEQUENCE model_cost_type_id_seq OWNED BY model_cost_type.id;




ALTER TABLE occupancy OWNER TO ged4all_owner;

--
-- Name: occupancy_id_seq; Type: SEQUENCE; Schema: level2; Owner: ged4all_owner
--

CREATE SEQUENCE occupancy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE occupancy_id_seq OWNER TO ged4all_owner;

--
-- Name: occupancy_id_seq; Type: SEQUENCE OWNED BY; Schema: level2; Owner: ged4all_owner
--

ALTER SEQUENCE occupancy_id_seq OWNED BY occupancy.id;


--
-- Name: id; Type: DEFAULT; Schema: level2; Owner: ged4all_owner
--

ALTER TABLE ONLY asset ALTER COLUMN id SET DEFAULT nextval('asset_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: level2; Owner: ged4all_owner
--

ALTER TABLE ONLY contribution ALTER COLUMN id SET DEFAULT nextval('contribution_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: level2; Owner: ged4all_owner
--

ALTER TABLE ONLY cost ALTER COLUMN id SET DEFAULT nextval('cost_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: level2; Owner: ged4all_owner
--

ALTER TABLE ONLY exposure_model ALTER COLUMN id SET DEFAULT nextval('exposure_model_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: level2; Owner: ged4all_owner
--

ALTER TABLE ONLY model_cost_type ALTER COLUMN id SET DEFAULT nextval('model_cost_type_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: level2; Owner: ged4all_owner
--

ALTER TABLE ONLY occupancy ALTER COLUMN id SET DEFAULT nextval('occupancy_id_seq'::regclass);


SET default_tablespace = '';

--
-- Name: asset_exposure_model_id_asset_ref_key; Type: CONSTRAINT; Schema: level2; Owner: ged4all_owner
--



--
-- Name: asset_pkey; Type: CONSTRAINT; Schema: level2; Owner: ged4all_owner
--

ALTER TABLE ONLY asset
    ADD CONSTRAINT asset_pkey PRIMARY KEY (id);


--
-- Name: contribution_pkey; Type: CONSTRAINT; Schema: level2; Owner: ged4all_owner
--

ALTER TABLE ONLY contribution
    ADD CONSTRAINT contribution_pkey PRIMARY KEY (id);


--
-- Name: cost_asset_id_cost_type_id_key; Type: CONSTRAINT; Schema: level2; Owner: ged4all_owner
--

ALTER TABLE ONLY cost
    ADD CONSTRAINT cost_asset_id_cost_type_id_key UNIQUE (asset_id, cost_type_id);


--
-- Name: cost_pkey; Type: CONSTRAINT; Schema: level2; Owner: ged4all_owner
--

ALTER TABLE ONLY cost
    ADD CONSTRAINT cost_pkey PRIMARY KEY (id);


--
-- Name: exposure_model_pkey; Type: CONSTRAINT; Schema: level2; Owner: ged4all_owner
--

ALTER TABLE ONLY exposure_model
    ADD CONSTRAINT exposure_model_pkey PRIMARY KEY (id);


--
-- Name: model_cost_type_pkey; Type: CONSTRAINT; Schema: level2; Owner: ged4all_owner
--

ALTER TABLE ONLY model_cost_type
    ADD CONSTRAINT model_cost_type_pkey PRIMARY KEY (id);


--
-- Name: occupancy_pkey; Type: CONSTRAINT; Schema: level2; Owner: ged4all_owner
--

ALTER TABLE ONLY occupancy
    ADD CONSTRAINT occupancy_pkey PRIMARY KEY (id);





--
-- Name: level2; Type: ACL; Schema: -; Owner: ged4all_owner
--

REVOKE ALL ON SCHEMA level2 FROM PUBLIC;
REVOKE ALL ON SCHEMA level2 FROM ged4all_owner;
GRANT ALL ON SCHEMA level2 TO ged4all_owner;
GRANT USAGE ON SCHEMA level2 TO gedusers;


--
-- Name: asset; Type: ACL; Schema: level2; Owner: ged4all_owner
--

REVOKE ALL ON TABLE asset FROM PUBLIC;
REVOKE ALL ON TABLE asset FROM ged4all_owner;
GRANT ALL ON TABLE asset TO ged4all_owner;
GRANT ALL ON TABLE asset TO ged2admin;
GRANT SELECT ON TABLE asset TO gedusers;
GRANT ALL ON TABLE asset TO contributor;


--
-- Name: asset_id_seq; Type: ACL; Schema: level2; Owner: ged4all_owner
--

REVOKE ALL ON SEQUENCE asset_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE asset_id_seq FROM ged4all_owner;
GRANT ALL ON SEQUENCE asset_id_seq TO ged4all_owner;
GRANT ALL ON SEQUENCE asset_id_seq TO ged2admin;
GRANT SELECT,USAGE ON SEQUENCE asset_id_seq TO gedusers;


--
-- Name: contribution; Type: ACL; Schema: level2; Owner: ged4all_owner
--

REVOKE ALL ON TABLE contribution FROM PUBLIC;
REVOKE ALL ON TABLE contribution FROM ged4all_owner;
GRANT ALL ON TABLE contribution TO ged4all_owner;
GRANT ALL ON TABLE contribution TO ged2admin;
GRANT SELECT ON TABLE contribution TO gedusers;
GRANT ALL ON TABLE contribution TO contributor;


--
-- Name: contribution_id_seq; Type: ACL; Schema: level2; Owner: ged4all_owner
--

REVOKE ALL ON SEQUENCE contribution_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE contribution_id_seq FROM ged4all_owner;
GRANT ALL ON SEQUENCE contribution_id_seq TO ged4all_owner;
GRANT ALL ON SEQUENCE contribution_id_seq TO ged2admin;
GRANT SELECT,USAGE ON SEQUENCE contribution_id_seq TO gedusers;


--
-- Name: cost; Type: ACL; Schema: level2; Owner: ged4all_owner
--

REVOKE ALL ON TABLE cost FROM PUBLIC;
REVOKE ALL ON TABLE cost FROM ged4all_owner;
GRANT ALL ON TABLE cost TO ged4all_owner;
GRANT ALL ON TABLE cost TO ged2admin;
GRANT SELECT ON TABLE cost TO gedusers;
GRANT ALL ON TABLE cost TO contributor;


--
-- Name: cost_id_seq; Type: ACL; Schema: level2; Owner: ged4all_owner
--

REVOKE ALL ON SEQUENCE cost_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE cost_id_seq FROM ged4all_owner;
GRANT ALL ON SEQUENCE cost_id_seq TO ged4all_owner;
GRANT ALL ON SEQUENCE cost_id_seq TO ged2admin;
GRANT SELECT,USAGE ON SEQUENCE cost_id_seq TO gedusers;


--
-- Name: exposure_model; Type: ACL; Schema: level2; Owner: ged4all_owner
--

REVOKE ALL ON TABLE exposure_model FROM PUBLIC;
REVOKE ALL ON TABLE exposure_model FROM ged4all_owner;
GRANT ALL ON TABLE exposure_model TO ged4all_owner;
GRANT ALL ON TABLE exposure_model TO ged2admin;
GRANT SELECT ON TABLE exposure_model TO gedusers;
GRANT ALL ON TABLE exposure_model TO contributor;


--
-- Name: exposure_model_id_seq; Type: ACL; Schema: level2; Owner: ged4all_owner
--

REVOKE ALL ON SEQUENCE exposure_model_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE exposure_model_id_seq FROM ged4all_owner;
GRANT ALL ON SEQUENCE exposure_model_id_seq TO ged4all_owner;
GRANT ALL ON SEQUENCE exposure_model_id_seq TO ged2admin;
GRANT SELECT,USAGE ON SEQUENCE exposure_model_id_seq TO gedusers;


--
-- Name: model_cost_type; Type: ACL; Schema: level2; Owner: ged4all_owner
--

REVOKE ALL ON TABLE model_cost_type FROM PUBLIC;
REVOKE ALL ON TABLE model_cost_type FROM ged4all_owner;
GRANT ALL ON TABLE model_cost_type TO ged4all_owner;
GRANT ALL ON TABLE model_cost_type TO ged2admin;
GRANT SELECT ON TABLE model_cost_type TO gedusers;
GRANT ALL ON TABLE model_cost_type TO contributor;


--
-- Name: model_cost_type_id_seq; Type: ACL; Schema: level2; Owner: ged4all_owner
--

REVOKE ALL ON SEQUENCE model_cost_type_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE model_cost_type_id_seq FROM ged4all_owner;
GRANT ALL ON SEQUENCE model_cost_type_id_seq TO ged4all_owner;
GRANT ALL ON SEQUENCE model_cost_type_id_seq TO ged2admin;
GRANT SELECT,USAGE ON SEQUENCE model_cost_type_id_seq TO gedusers;


--
-- Name: occupancy; Type: ACL; Schema: level2; Owner: ged4all_owner
--

REVOKE ALL ON TABLE occupancy FROM PUBLIC;
REVOKE ALL ON TABLE occupancy FROM ged4all_owner;
GRANT ALL ON TABLE occupancy TO ged4all_owner;
GRANT ALL ON TABLE occupancy TO ged2admin;
GRANT SELECT ON TABLE occupancy TO gedusers;
GRANT ALL ON TABLE occupancy TO contributor;


--
-- Name: occupancy_id_seq; Type: ACL; Schema: level2; Owner: ged4all_owner
--

REVOKE ALL ON SEQUENCE occupancy_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE occupancy_id_seq FROM ged4all_owner;
GRANT ALL ON SEQUENCE occupancy_id_seq TO ged4all_owner;
GRANT ALL ON SEQUENCE occupancy_id_seq TO ged2admin;
GRANT SELECT,USAGE ON SEQUENCE occupancy_id_seq TO gedusers;


--
-- PostgreSQL database dump complete
--

