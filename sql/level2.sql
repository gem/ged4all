--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.16
-- Dumped by pg_dump version 9.5.16

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: level2; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA level2;


--
-- Name: category_enum; Type: TYPE; Schema: level2; Owner: -
--

CREATE TYPE level2.category_enum AS ENUM (
    'buildings',
    'indicators',
    'infrastructure',
    'crops, livestock and forestry'
);


SET default_with_oids = false;

--
-- Name: asset; Type: TABLE; Schema: level2; Owner: -
--

CREATE TABLE level2.asset (
    id integer NOT NULL,
    exposure_model_id integer NOT NULL,
    asset_ref character varying NOT NULL,
    taxonomy character varying NOT NULL,
    number_of_units double precision,
    area double precision,
    the_geom public.geometry(Point,4326) NOT NULL,
    full_geom public.geometry(Geometry,4326),
    CONSTRAINT area_value CHECK ((area >= (0.0)::double precision)),
    CONSTRAINT units_value CHECK ((number_of_units >= (0.0)::double precision))
);


--
-- Name: cost; Type: TABLE; Schema: level2; Owner: -
--

CREATE TABLE level2.cost (
    id integer NOT NULL,
    asset_id integer NOT NULL,
    cost_type_id integer NOT NULL,
    value double precision NOT NULL,
    deductible double precision,
    insurance_limit double precision,
    CONSTRAINT converted_cost_value CHECK ((value >= (0.0)::double precision))
);


--
-- Name: model_cost_type; Type: TABLE; Schema: level2; Owner: -
--

CREATE TABLE level2.model_cost_type (
    id integer NOT NULL,
    exposure_model_id integer NOT NULL,
    cost_type_name character varying NOT NULL,
    aggregation_type character varying NOT NULL,
    unit character varying,
    CONSTRAINT aggregation_type_value CHECK ((((aggregation_type)::text = 'per_asset'::text) OR ((aggregation_type)::text = 'per_area'::text) OR ((aggregation_type)::text = 'aggregated'::text)))
);


--
-- Name: occupancy; Type: TABLE; Schema: level2; Owner: -
--

CREATE TABLE level2.occupancy (
    id integer NOT NULL,
    asset_id integer NOT NULL,
    period character varying NOT NULL,
    occupants double precision NOT NULL
);


--
-- Name: all_exposure; Type: VIEW; Schema: level2; Owner: -
--

CREATE VIEW level2.all_exposure AS
 SELECT a.asset_ref,
    a.taxonomy,
    a.number_of_units,
    a.area,
    a.exposure_model_id,
    occ.period,
    occ.occupants,
    c.value,
    mct.cost_type_name,
    mct.aggregation_type,
    mct.unit,
    public.st_x(a.the_geom) AS lon,
    public.st_y(a.the_geom) AS lat
   FROM (((level2.asset a
     LEFT JOIN level2.cost c ON ((c.asset_id = a.id)))
     LEFT JOIN level2.model_cost_type mct ON ((mct.id = c.cost_type_id)))
     LEFT JOIN level2.occupancy occ ON ((occ.asset_id = a.id)));


--
-- Name: asset_id_seq; Type: SEQUENCE; Schema: level2; Owner: -
--

CREATE SEQUENCE level2.asset_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: asset_id_seq; Type: SEQUENCE OWNED BY; Schema: level2; Owner: -
--

ALTER SEQUENCE level2.asset_id_seq OWNED BY level2.asset.id;


--
-- Name: contribution; Type: TABLE; Schema: level2; Owner: -
--

CREATE TABLE level2.contribution (
    id integer NOT NULL,
    exposure_model_id integer NOT NULL,
    model_source character varying NOT NULL,
    model_date date NOT NULL,
    notes text,
    license_id integer NOT NULL,
    version character varying,
    purpose text
);


--
-- Name: contribution_id_seq; Type: SEQUENCE; Schema: level2; Owner: -
--

CREATE SEQUENCE level2.contribution_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contribution_id_seq; Type: SEQUENCE OWNED BY; Schema: level2; Owner: -
--

ALTER SEQUENCE level2.contribution_id_seq OWNED BY level2.contribution.id;


--
-- Name: cost_id_seq; Type: SEQUENCE; Schema: level2; Owner: -
--

CREATE SEQUENCE level2.cost_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cost_id_seq; Type: SEQUENCE OWNED BY; Schema: level2; Owner: -
--

ALTER SEQUENCE level2.cost_id_seq OWNED BY level2.cost.id;


--
-- Name: exposure_model; Type: TABLE; Schema: level2; Owner: -
--

CREATE TABLE level2.exposure_model (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    taxonomy_source character varying,
    category level2.category_enum NOT NULL,
    area_type character varying,
    area_unit character varying,
    tag_names character varying,
    use cf_common.occupancy_enum,
    CONSTRAINT area_type_value CHECK (((area_type IS NULL) OR ((area_type)::text = 'per_asset'::text) OR ((area_type)::text = 'aggregated'::text)))
);


--
-- Name: exposure_model_id_seq; Type: SEQUENCE; Schema: level2; Owner: -
--

CREATE SEQUENCE level2.exposure_model_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exposure_model_id_seq; Type: SEQUENCE OWNED BY; Schema: level2; Owner: -
--

ALTER SEQUENCE level2.exposure_model_id_seq OWNED BY level2.exposure_model.id;


--
-- Name: model_cost_type_id_seq; Type: SEQUENCE; Schema: level2; Owner: -
--

CREATE SEQUENCE level2.model_cost_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: model_cost_type_id_seq; Type: SEQUENCE OWNED BY; Schema: level2; Owner: -
--

ALTER SEQUENCE level2.model_cost_type_id_seq OWNED BY level2.model_cost_type.id;


--
-- Name: occupancy_id_seq; Type: SEQUENCE; Schema: level2; Owner: -
--

CREATE SEQUENCE level2.occupancy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: occupancy_id_seq; Type: SEQUENCE OWNED BY; Schema: level2; Owner: -
--

ALTER SEQUENCE level2.occupancy_id_seq OWNED BY level2.occupancy.id;


--
-- Name: tags; Type: TABLE; Schema: level2; Owner: -
--

CREATE TABLE level2.tags (
    id integer NOT NULL,
    asset_id integer NOT NULL,
    name character varying NOT NULL,
    value character varying NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: level2; Owner: -
--

CREATE SEQUENCE level2.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: level2; Owner: -
--

ALTER SEQUENCE level2.tags_id_seq OWNED BY level2.tags.id;


--
-- Name: id; Type: DEFAULT; Schema: level2; Owner: -
--

ALTER TABLE ONLY level2.asset ALTER COLUMN id SET DEFAULT nextval('level2.asset_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: level2; Owner: -
--

ALTER TABLE ONLY level2.contribution ALTER COLUMN id SET DEFAULT nextval('level2.contribution_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: level2; Owner: -
--

ALTER TABLE ONLY level2.cost ALTER COLUMN id SET DEFAULT nextval('level2.cost_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: level2; Owner: -
--

ALTER TABLE ONLY level2.exposure_model ALTER COLUMN id SET DEFAULT nextval('level2.exposure_model_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: level2; Owner: -
--

ALTER TABLE ONLY level2.model_cost_type ALTER COLUMN id SET DEFAULT nextval('level2.model_cost_type_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: level2; Owner: -
--

ALTER TABLE ONLY level2.occupancy ALTER COLUMN id SET DEFAULT nextval('level2.occupancy_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: level2; Owner: -
--

ALTER TABLE ONLY level2.tags ALTER COLUMN id SET DEFAULT nextval('level2.tags_id_seq'::regclass);


--
-- Name: asset_exposure_model_id_asset_ref_key; Type: CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY level2.asset
    ADD CONSTRAINT asset_exposure_model_id_asset_ref_key UNIQUE (exposure_model_id, asset_ref);


--
-- Name: asset_pkey; Type: CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY level2.asset
    ADD CONSTRAINT asset_pkey PRIMARY KEY (id);


--
-- Name: contribution_pkey; Type: CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY level2.contribution
    ADD CONSTRAINT contribution_pkey PRIMARY KEY (id);


--
-- Name: cost_asset_id_cost_type_id_key; Type: CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY level2.cost
    ADD CONSTRAINT cost_asset_id_cost_type_id_key UNIQUE (asset_id, cost_type_id);


--
-- Name: cost_pkey; Type: CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY level2.cost
    ADD CONSTRAINT cost_pkey PRIMARY KEY (id);


--
-- Name: exposure_model_pkey; Type: CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY level2.exposure_model
    ADD CONSTRAINT exposure_model_pkey PRIMARY KEY (id);


--
-- Name: model_cost_type_pkey; Type: CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY level2.model_cost_type
    ADD CONSTRAINT model_cost_type_pkey PRIMARY KEY (id);


--
-- Name: occupancy_pkey; Type: CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY level2.occupancy
    ADD CONSTRAINT occupancy_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY level2.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: asset_exposure_model_id_idx; Type: INDEX; Schema: level2; Owner: -
--

CREATE INDEX asset_exposure_model_id_idx ON level2.asset USING btree (exposure_model_id);


--
-- Name: asset_full_geom_idx; Type: INDEX; Schema: level2; Owner: -
--

CREATE INDEX asset_full_geom_idx ON level2.asset USING gist (full_geom);


--
-- Name: asset_the_geom_gist; Type: INDEX; Schema: level2; Owner: -
--

CREATE INDEX asset_the_geom_gist ON level2.asset USING gist (the_geom);


--
-- Name: cost_asset_id_idx; Type: INDEX; Schema: level2; Owner: -
--

CREATE INDEX cost_asset_id_idx ON level2.cost USING btree (asset_id);


--
-- Name: occupancy_asset_id_idx; Type: INDEX; Schema: level2; Owner: -
--

CREATE INDEX occupancy_asset_id_idx ON level2.occupancy USING btree (asset_id);


--
-- Name: tags_asset_id_idx; Type: INDEX; Schema: level2; Owner: -
--

CREATE INDEX tags_asset_id_idx ON level2.tags USING btree (asset_id);


--
-- Name: asset_exposure_model_id_fk; Type: FK CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY level2.asset
    ADD CONSTRAINT asset_exposure_model_id_fk FOREIGN KEY (exposure_model_id) REFERENCES level2.exposure_model(id) ON DELETE CASCADE;


--
-- Name: contribution_exposure_model_id_fkey; Type: FK CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY level2.contribution
    ADD CONSTRAINT contribution_exposure_model_id_fkey FOREIGN KEY (exposure_model_id) REFERENCES level2.exposure_model(id) ON DELETE CASCADE;


--
-- Name: contribution_license_fkey; Type: FK CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY level2.contribution
    ADD CONSTRAINT contribution_license_fkey FOREIGN KEY (license_id) REFERENCES cf_common.license(id);


--
-- Name: cost_asset_id_fk; Type: FK CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY level2.cost
    ADD CONSTRAINT cost_asset_id_fk FOREIGN KEY (asset_id) REFERENCES level2.asset(id) ON DELETE CASCADE;


--
-- Name: cost_cost_type_id_fkey; Type: FK CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY level2.cost
    ADD CONSTRAINT cost_cost_type_id_fkey FOREIGN KEY (cost_type_id) REFERENCES level2.model_cost_type(id);


--
-- Name: model_cost_type_exposure_model_id_fk; Type: FK CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY level2.model_cost_type
    ADD CONSTRAINT model_cost_type_exposure_model_id_fk FOREIGN KEY (exposure_model_id) REFERENCES level2.exposure_model(id) ON DELETE CASCADE;


--
-- Name: occupancy_asset_id_fk; Type: FK CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY level2.occupancy
    ADD CONSTRAINT occupancy_asset_id_fk FOREIGN KEY (asset_id) REFERENCES level2.asset(id) ON DELETE CASCADE;


--
-- Name: tags_asset_id_fkey; Type: FK CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY level2.tags
    ADD CONSTRAINT tags_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES level2.asset(id) ON DELETE CASCADE;


--
-- Name: SCHEMA level2; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA level2 FROM PUBLIC;
GRANT USAGE ON SCHEMA level2 TO gedusers;


--
-- Name: TABLE asset; Type: ACL; Schema: level2; Owner: -
--

REVOKE ALL ON TABLE level2.asset FROM PUBLIC;
GRANT ALL ON TABLE level2.asset TO ged2admin;
GRANT SELECT ON TABLE level2.asset TO gedusers;
GRANT ALL ON TABLE level2.asset TO contributor;


--
-- Name: TABLE cost; Type: ACL; Schema: level2; Owner: -
--

REVOKE ALL ON TABLE level2.cost FROM PUBLIC;
GRANT ALL ON TABLE level2.cost TO ged2admin;
GRANT SELECT ON TABLE level2.cost TO gedusers;
GRANT ALL ON TABLE level2.cost TO contributor;


--
-- Name: TABLE model_cost_type; Type: ACL; Schema: level2; Owner: -
--

REVOKE ALL ON TABLE level2.model_cost_type FROM PUBLIC;
GRANT ALL ON TABLE level2.model_cost_type TO ged2admin;
GRANT SELECT ON TABLE level2.model_cost_type TO gedusers;
GRANT ALL ON TABLE level2.model_cost_type TO contributor;


--
-- Name: TABLE occupancy; Type: ACL; Schema: level2; Owner: -
--

REVOKE ALL ON TABLE level2.occupancy FROM PUBLIC;
GRANT ALL ON TABLE level2.occupancy TO ged2admin;
GRANT SELECT ON TABLE level2.occupancy TO gedusers;
GRANT ALL ON TABLE level2.occupancy TO contributor;


--
-- Name: TABLE all_exposure; Type: ACL; Schema: level2; Owner: -
--

REVOKE ALL ON TABLE level2.all_exposure FROM PUBLIC;
GRANT SELECT ON TABLE level2.all_exposure TO gedusers;
GRANT ALL ON TABLE level2.all_exposure TO ged2admin;


--
-- Name: SEQUENCE asset_id_seq; Type: ACL; Schema: level2; Owner: -
--

REVOKE ALL ON SEQUENCE level2.asset_id_seq FROM PUBLIC;
GRANT ALL ON SEQUENCE level2.asset_id_seq TO ged2admin;
GRANT SELECT,USAGE ON SEQUENCE level2.asset_id_seq TO gedusers;


--
-- Name: TABLE contribution; Type: ACL; Schema: level2; Owner: -
--

REVOKE ALL ON TABLE level2.contribution FROM PUBLIC;
GRANT ALL ON TABLE level2.contribution TO ged2admin;
GRANT SELECT ON TABLE level2.contribution TO gedusers;
GRANT ALL ON TABLE level2.contribution TO contributor;


--
-- Name: SEQUENCE contribution_id_seq; Type: ACL; Schema: level2; Owner: -
--

REVOKE ALL ON SEQUENCE level2.contribution_id_seq FROM PUBLIC;
GRANT ALL ON SEQUENCE level2.contribution_id_seq TO ged2admin;
GRANT SELECT,USAGE ON SEQUENCE level2.contribution_id_seq TO gedusers;


--
-- Name: SEQUENCE cost_id_seq; Type: ACL; Schema: level2; Owner: -
--

REVOKE ALL ON SEQUENCE level2.cost_id_seq FROM PUBLIC;
GRANT ALL ON SEQUENCE level2.cost_id_seq TO ged2admin;
GRANT SELECT,USAGE ON SEQUENCE level2.cost_id_seq TO gedusers;


--
-- Name: TABLE exposure_model; Type: ACL; Schema: level2; Owner: -
--

REVOKE ALL ON TABLE level2.exposure_model FROM PUBLIC;
GRANT ALL ON TABLE level2.exposure_model TO ged2admin;
GRANT SELECT ON TABLE level2.exposure_model TO gedusers;
GRANT ALL ON TABLE level2.exposure_model TO contributor;


--
-- Name: SEQUENCE exposure_model_id_seq; Type: ACL; Schema: level2; Owner: -
--

REVOKE ALL ON SEQUENCE level2.exposure_model_id_seq FROM PUBLIC;
GRANT ALL ON SEQUENCE level2.exposure_model_id_seq TO ged2admin;
GRANT SELECT,USAGE ON SEQUENCE level2.exposure_model_id_seq TO gedusers;


--
-- Name: SEQUENCE model_cost_type_id_seq; Type: ACL; Schema: level2; Owner: -
--

REVOKE ALL ON SEQUENCE level2.model_cost_type_id_seq FROM PUBLIC;
GRANT ALL ON SEQUENCE level2.model_cost_type_id_seq TO ged2admin;
GRANT SELECT,USAGE ON SEQUENCE level2.model_cost_type_id_seq TO gedusers;


--
-- Name: SEQUENCE occupancy_id_seq; Type: ACL; Schema: level2; Owner: -
--

REVOKE ALL ON SEQUENCE level2.occupancy_id_seq FROM PUBLIC;
GRANT ALL ON SEQUENCE level2.occupancy_id_seq TO ged2admin;
GRANT SELECT,USAGE ON SEQUENCE level2.occupancy_id_seq TO gedusers;


--
-- Name: TABLE tags; Type: ACL; Schema: level2; Owner: -
--

REVOKE ALL ON TABLE level2.tags FROM PUBLIC;
GRANT ALL ON TABLE level2.tags TO ged2admin;
GRANT SELECT ON TABLE level2.tags TO gedusers;


--
-- Name: SEQUENCE tags_id_seq; Type: ACL; Schema: level2; Owner: -
--

REVOKE ALL ON SEQUENCE level2.tags_id_seq FROM PUBLIC;
GRANT ALL ON SEQUENCE level2.tags_id_seq TO ged2admin;


--
-- PostgreSQL database dump complete
--

