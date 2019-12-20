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
-- Name: ged4all; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA ged4all;


--
-- Name: category_enum; Type: TYPE; Schema: ged4all; Owner: -
--

CREATE TYPE ged4all.category_enum AS ENUM (
    'buildings',
    'indicators',
    'infrastructure',
    'crops, livestock and forestry'
);


SET default_with_oids = false;

--
-- Name: asset; Type: TABLE; Schema: ged4all; Owner: -
--

CREATE TABLE ged4all.asset (
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
-- Name: cost; Type: TABLE; Schema: ged4all; Owner: -
--

CREATE TABLE ged4all.cost (
    id integer NOT NULL,
    asset_id integer NOT NULL,
    cost_type_id integer NOT NULL,
    value double precision NOT NULL,
    deductible double precision,
    insurance_limit double precision,
    CONSTRAINT converted_cost_value CHECK ((value >= (0.0)::double precision))
);


--
-- Name: model_cost_type; Type: TABLE; Schema: ged4all; Owner: -
--

CREATE TABLE ged4all.model_cost_type (
    id integer NOT NULL,
    exposure_model_id integer NOT NULL,
    cost_type_name character varying NOT NULL,
    aggregation_type character varying NOT NULL,
    unit character varying,
    CONSTRAINT aggregation_type_value CHECK ((((aggregation_type)::text = 'per_asset'::text) OR ((aggregation_type)::text = 'per_area'::text) OR ((aggregation_type)::text = 'aggregated'::text)))
);


--
-- Name: occupancy; Type: TABLE; Schema: ged4all; Owner: -
--

CREATE TABLE ged4all.occupancy (
    id integer NOT NULL,
    asset_id integer NOT NULL,
    period character varying NOT NULL,
    occupants double precision NOT NULL
);


--
-- Name: all_exposure; Type: VIEW; Schema: ged4all; Owner: -
--

CREATE VIEW ged4all.all_exposure AS
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
   FROM (((ged4all.asset a
     LEFT JOIN ged4all.cost c ON ((c.asset_id = a.id)))
     LEFT JOIN ged4all.model_cost_type mct ON ((mct.id = c.cost_type_id)))
     LEFT JOIN ged4all.occupancy occ ON ((occ.asset_id = a.id)));


--
-- Name: asset_id_seq; Type: SEQUENCE; Schema: ged4all; Owner: -
--

CREATE SEQUENCE ged4all.asset_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: asset_id_seq; Type: SEQUENCE OWNED BY; Schema: ged4all; Owner: -
--

ALTER SEQUENCE ged4all.asset_id_seq OWNED BY ged4all.asset.id;


--
-- Name: contribution; Type: TABLE; Schema: ged4all; Owner: -
--

CREATE TABLE ged4all.contribution (
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
-- Name: contribution_id_seq; Type: SEQUENCE; Schema: ged4all; Owner: -
--

CREATE SEQUENCE ged4all.contribution_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contribution_id_seq; Type: SEQUENCE OWNED BY; Schema: ged4all; Owner: -
--

ALTER SEQUENCE ged4all.contribution_id_seq OWNED BY ged4all.contribution.id;


--
-- Name: cost_id_seq; Type: SEQUENCE; Schema: ged4all; Owner: -
--

CREATE SEQUENCE ged4all.cost_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cost_id_seq; Type: SEQUENCE OWNED BY; Schema: ged4all; Owner: -
--

ALTER SEQUENCE ged4all.cost_id_seq OWNED BY ged4all.cost.id;


--
-- Name: exposure_model; Type: TABLE; Schema: ged4all; Owner: -
--

CREATE TABLE ged4all.exposure_model (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    taxonomy_source character varying,
    category ged4all.category_enum NOT NULL,
    area_type character varying,
    area_unit character varying,
    tag_names character varying,
    use cf_common.occupancy_enum,
    CONSTRAINT area_type_value CHECK (((area_type IS NULL) OR ((area_type)::text = 'per_asset'::text) OR ((area_type)::text = 'aggregated'::text)))
);


--
-- Name: exposure_model_id_seq; Type: SEQUENCE; Schema: ged4all; Owner: -
--

CREATE SEQUENCE ged4all.exposure_model_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exposure_model_id_seq; Type: SEQUENCE OWNED BY; Schema: ged4all; Owner: -
--

ALTER SEQUENCE ged4all.exposure_model_id_seq OWNED BY ged4all.exposure_model.id;


--
-- Name: model_cost_type_id_seq; Type: SEQUENCE; Schema: ged4all; Owner: -
--

CREATE SEQUENCE ged4all.model_cost_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: model_cost_type_id_seq; Type: SEQUENCE OWNED BY; Schema: ged4all; Owner: -
--

ALTER SEQUENCE ged4all.model_cost_type_id_seq OWNED BY ged4all.model_cost_type.id;


--
-- Name: occupancy_id_seq; Type: SEQUENCE; Schema: ged4all; Owner: -
--

CREATE SEQUENCE ged4all.occupancy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: occupancy_id_seq; Type: SEQUENCE OWNED BY; Schema: ged4all; Owner: -
--

ALTER SEQUENCE ged4all.occupancy_id_seq OWNED BY ged4all.occupancy.id;


--
-- Name: tags; Type: TABLE; Schema: ged4all; Owner: -
--

CREATE TABLE ged4all.tags (
    id integer NOT NULL,
    asset_id integer NOT NULL,
    name character varying NOT NULL,
    value character varying NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: ged4all; Owner: -
--

CREATE SEQUENCE ged4all.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: ged4all; Owner: -
--

ALTER SEQUENCE ged4all.tags_id_seq OWNED BY ged4all.tags.id;


--
-- Name: id; Type: DEFAULT; Schema: ged4all; Owner: -
--

ALTER TABLE ONLY ged4all.asset ALTER COLUMN id SET DEFAULT nextval('ged4all.asset_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ged4all; Owner: -
--

ALTER TABLE ONLY ged4all.contribution ALTER COLUMN id SET DEFAULT nextval('ged4all.contribution_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ged4all; Owner: -
--

ALTER TABLE ONLY ged4all.cost ALTER COLUMN id SET DEFAULT nextval('ged4all.cost_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ged4all; Owner: -
--

ALTER TABLE ONLY ged4all.exposure_model ALTER COLUMN id SET DEFAULT nextval('ged4all.exposure_model_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ged4all; Owner: -
--

ALTER TABLE ONLY ged4all.model_cost_type ALTER COLUMN id SET DEFAULT nextval('ged4all.model_cost_type_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ged4all; Owner: -
--

ALTER TABLE ONLY ged4all.occupancy ALTER COLUMN id SET DEFAULT nextval('ged4all.occupancy_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: ged4all; Owner: -
--

ALTER TABLE ONLY ged4all.tags ALTER COLUMN id SET DEFAULT nextval('ged4all.tags_id_seq'::regclass);


--
-- Name: asset_exposure_model_id_asset_ref_key; Type: CONSTRAINT; Schema: ged4all; Owner: -
--

ALTER TABLE ONLY ged4all.asset
    ADD CONSTRAINT asset_exposure_model_id_asset_ref_key UNIQUE (exposure_model_id, asset_ref);


--
-- Name: asset_pkey; Type: CONSTRAINT; Schema: ged4all; Owner: -
--

ALTER TABLE ONLY ged4all.asset
    ADD CONSTRAINT asset_pkey PRIMARY KEY (id);


--
-- Name: contribution_pkey; Type: CONSTRAINT; Schema: ged4all; Owner: -
--

ALTER TABLE ONLY ged4all.contribution
    ADD CONSTRAINT contribution_pkey PRIMARY KEY (id);


--
-- Name: cost_asset_id_cost_type_id_key; Type: CONSTRAINT; Schema: ged4all; Owner: -
--

ALTER TABLE ONLY ged4all.cost
    ADD CONSTRAINT cost_asset_id_cost_type_id_key UNIQUE (asset_id, cost_type_id);


--
-- Name: cost_pkey; Type: CONSTRAINT; Schema: ged4all; Owner: -
--

ALTER TABLE ONLY ged4all.cost
    ADD CONSTRAINT cost_pkey PRIMARY KEY (id);


--
-- Name: exposure_model_pkey; Type: CONSTRAINT; Schema: ged4all; Owner: -
--

ALTER TABLE ONLY ged4all.exposure_model
    ADD CONSTRAINT exposure_model_pkey PRIMARY KEY (id);


--
-- Name: model_cost_type_pkey; Type: CONSTRAINT; Schema: ged4all; Owner: -
--

ALTER TABLE ONLY ged4all.model_cost_type
    ADD CONSTRAINT model_cost_type_pkey PRIMARY KEY (id);


--
-- Name: occupancy_pkey; Type: CONSTRAINT; Schema: ged4all; Owner: -
--

ALTER TABLE ONLY ged4all.occupancy
    ADD CONSTRAINT occupancy_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: ged4all; Owner: -
--

ALTER TABLE ONLY ged4all.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: asset_exposure_model_id_idx; Type: INDEX; Schema: ged4all; Owner: -
--

CREATE INDEX asset_exposure_model_id_idx ON ged4all.asset USING btree (exposure_model_id);


--
-- Name: asset_full_geom_idx; Type: INDEX; Schema: ged4all; Owner: -
--

CREATE INDEX asset_full_geom_idx ON ged4all.asset USING gist (full_geom);


--
-- Name: asset_the_geom_gist; Type: INDEX; Schema: ged4all; Owner: -
--

CREATE INDEX asset_the_geom_gist ON ged4all.asset USING gist (the_geom);


--
-- Name: cost_asset_id_idx; Type: INDEX; Schema: ged4all; Owner: -
--

CREATE INDEX cost_asset_id_idx ON ged4all.cost USING btree (asset_id);


--
-- Name: occupancy_asset_id_idx; Type: INDEX; Schema: ged4all; Owner: -
--

CREATE INDEX occupancy_asset_id_idx ON ged4all.occupancy USING btree (asset_id);


--
-- Name: tags_asset_id_idx; Type: INDEX; Schema: ged4all; Owner: -
--

CREATE INDEX tags_asset_id_idx ON ged4all.tags USING btree (asset_id);


--
-- Name: asset_exposure_model_id_fk; Type: FK CONSTRAINT; Schema: ged4all; Owner: -
--

ALTER TABLE ONLY ged4all.asset
    ADD CONSTRAINT asset_exposure_model_id_fk FOREIGN KEY (exposure_model_id) REFERENCES ged4all.exposure_model(id) ON DELETE CASCADE;


--
-- Name: contribution_exposure_model_id_fkey; Type: FK CONSTRAINT; Schema: ged4all; Owner: -
--

ALTER TABLE ONLY ged4all.contribution
    ADD CONSTRAINT contribution_exposure_model_id_fkey FOREIGN KEY (exposure_model_id) REFERENCES ged4all.exposure_model(id) ON DELETE CASCADE;


--
-- Name: contribution_license_fkey; Type: FK CONSTRAINT; Schema: ged4all; Owner: -
--

ALTER TABLE ONLY ged4all.contribution
    ADD CONSTRAINT contribution_license_fkey FOREIGN KEY (license_id) REFERENCES cf_common.license(id);


--
-- Name: cost_asset_id_fk; Type: FK CONSTRAINT; Schema: ged4all; Owner: -
--

ALTER TABLE ONLY ged4all.cost
    ADD CONSTRAINT cost_asset_id_fk FOREIGN KEY (asset_id) REFERENCES ged4all.asset(id) ON DELETE CASCADE;


--
-- Name: cost_cost_type_id_fkey; Type: FK CONSTRAINT; Schema: ged4all; Owner: -
--

ALTER TABLE ONLY ged4all.cost
    ADD CONSTRAINT cost_cost_type_id_fkey FOREIGN KEY (cost_type_id) REFERENCES ged4all.model_cost_type(id);


--
-- Name: model_cost_type_exposure_model_id_fk; Type: FK CONSTRAINT; Schema: ged4all; Owner: -
--

ALTER TABLE ONLY ged4all.model_cost_type
    ADD CONSTRAINT model_cost_type_exposure_model_id_fk FOREIGN KEY (exposure_model_id) REFERENCES ged4all.exposure_model(id) ON DELETE CASCADE;


--
-- Name: occupancy_asset_id_fk; Type: FK CONSTRAINT; Schema: ged4all; Owner: -
--

ALTER TABLE ONLY ged4all.occupancy
    ADD CONSTRAINT occupancy_asset_id_fk FOREIGN KEY (asset_id) REFERENCES ged4all.asset(id) ON DELETE CASCADE;


--
-- Name: tags_asset_id_fkey; Type: FK CONSTRAINT; Schema: ged4all; Owner: -
--

ALTER TABLE ONLY ged4all.tags
    ADD CONSTRAINT tags_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES ged4all.asset(id) ON DELETE CASCADE;


--
-- Name: SCHEMA ged4all; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA ged4all FROM PUBLIC;
GRANT USAGE ON SCHEMA ged4all TO ged4allusers;


--
-- Name: TABLE asset; Type: ACL; Schema: ged4all; Owner: -
--

REVOKE ALL ON TABLE ged4all.asset FROM PUBLIC;
GRANT ALL ON TABLE ged4all.asset TO ged4allcontrib;
GRANT SELECT ON TABLE ged4all.asset TO ged4allusers;


--
-- Name: TABLE cost; Type: ACL; Schema: ged4all; Owner: -
--

REVOKE ALL ON TABLE ged4all.cost FROM PUBLIC;
GRANT ALL ON TABLE ged4all.cost TO ged4allcontrib;
GRANT SELECT ON TABLE ged4all.cost TO ged4allusers;


--
-- Name: TABLE model_cost_type; Type: ACL; Schema: ged4all; Owner: -
--

REVOKE ALL ON TABLE ged4all.model_cost_type FROM PUBLIC;
GRANT ALL ON TABLE ged4all.model_cost_type TO ged4allcontrib;
GRANT SELECT ON TABLE ged4all.model_cost_type TO ged4allusers;


--
-- Name: TABLE occupancy; Type: ACL; Schema: ged4all; Owner: -
--

REVOKE ALL ON TABLE ged4all.occupancy FROM PUBLIC;
GRANT ALL ON TABLE ged4all.occupancy TO ged4allcontrib;
GRANT SELECT ON TABLE ged4all.occupancy TO ged4allusers;


--
-- Name: TABLE all_exposure; Type: ACL; Schema: ged4all; Owner: -
--

REVOKE ALL ON TABLE ged4all.all_exposure FROM PUBLIC;
GRANT SELECT ON TABLE ged4all.all_exposure TO ged4allusers;
GRANT ALL ON TABLE ged4all.all_exposure TO ged4allcontrib;


--
-- Name: SEQUENCE asset_id_seq; Type: ACL; Schema: ged4all; Owner: -
--

REVOKE ALL ON SEQUENCE ged4all.asset_id_seq FROM PUBLIC;
GRANT ALL ON SEQUENCE ged4all.asset_id_seq TO ged4allcontrib;
GRANT SELECT,USAGE ON SEQUENCE ged4all.asset_id_seq TO ged4allusers;


--
-- Name: TABLE contribution; Type: ACL; Schema: ged4all; Owner: -
--

REVOKE ALL ON TABLE ged4all.contribution FROM PUBLIC;
GRANT ALL ON TABLE ged4all.contribution TO ged4allcontrib;
GRANT SELECT ON TABLE ged4all.contribution TO ged4allusers;


--
-- Name: SEQUENCE contribution_id_seq; Type: ACL; Schema: ged4all; Owner: -
--

REVOKE ALL ON SEQUENCE ged4all.contribution_id_seq FROM PUBLIC;
GRANT ALL ON SEQUENCE ged4all.contribution_id_seq TO ged4allcontrib;
GRANT SELECT,USAGE ON SEQUENCE ged4all.contribution_id_seq TO ged4allusers;


--
-- Name: SEQUENCE cost_id_seq; Type: ACL; Schema: ged4all; Owner: -
--

REVOKE ALL ON SEQUENCE ged4all.cost_id_seq FROM PUBLIC;
GRANT ALL ON SEQUENCE ged4all.cost_id_seq TO ged4allcontrib;
GRANT SELECT,USAGE ON SEQUENCE ged4all.cost_id_seq TO ged4allusers;


--
-- Name: TABLE exposure_model; Type: ACL; Schema: ged4all; Owner: -
--

REVOKE ALL ON TABLE ged4all.exposure_model FROM PUBLIC;
GRANT ALL ON TABLE ged4all.exposure_model TO ged4allcontrib;
GRANT SELECT ON TABLE ged4all.exposure_model TO ged4allusers;


--
-- Name: SEQUENCE exposure_model_id_seq; Type: ACL; Schema: ged4all; Owner: -
--

REVOKE ALL ON SEQUENCE ged4all.exposure_model_id_seq FROM PUBLIC;
GRANT ALL ON SEQUENCE ged4all.exposure_model_id_seq TO ged4allcontrib;
GRANT SELECT,USAGE ON SEQUENCE ged4all.exposure_model_id_seq TO ged4allusers;


--
-- Name: SEQUENCE model_cost_type_id_seq; Type: ACL; Schema: ged4all; Owner: -
--

REVOKE ALL ON SEQUENCE ged4all.model_cost_type_id_seq FROM PUBLIC;
GRANT ALL ON SEQUENCE ged4all.model_cost_type_id_seq TO ged4allcontrib;
GRANT SELECT,USAGE ON SEQUENCE ged4all.model_cost_type_id_seq TO ged4allusers;


--
-- Name: SEQUENCE occupancy_id_seq; Type: ACL; Schema: ged4all; Owner: -
--

REVOKE ALL ON SEQUENCE ged4all.occupancy_id_seq FROM PUBLIC;
GRANT ALL ON SEQUENCE ged4all.occupancy_id_seq TO ged4allcontrib;
GRANT SELECT,USAGE ON SEQUENCE ged4all.occupancy_id_seq TO ged4allusers;


--
-- Name: TABLE tags; Type: ACL; Schema: ged4all; Owner: -
--

REVOKE ALL ON TABLE ged4all.tags FROM PUBLIC;
GRANT ALL ON TABLE ged4all.tags TO ged4allcontrib;
GRANT SELECT ON TABLE ged4all.tags TO ged4allusers;


--
-- Name: SEQUENCE tags_id_seq; Type: ACL; Schema: ged4all; Owner: -
--

REVOKE ALL ON SEQUENCE ged4all.tags_id_seq FROM PUBLIC;
GRANT ALL ON SEQUENCE ged4all.tags_id_seq TO ged4allcontrib;


--
-- PostgreSQL database dump complete
--

