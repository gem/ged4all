--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.8
-- Dumped by pg_dump version 9.5.8

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: level2; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA level2;


SET search_path = level2, pg_catalog;

SET default_tablespace = ged2_ts;

SET default_with_oids = false;

--
-- Name: asset; Type: TABLE; Schema: level2; Owner: -; Tablespace: ged2_ts
--

CREATE TABLE asset (
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
-- Name: cost; Type: TABLE; Schema: level2; Owner: -; Tablespace: ged2_ts
--

CREATE TABLE cost (
    id integer NOT NULL,
    asset_id integer NOT NULL,
    cost_type_id integer NOT NULL,
    value double precision NOT NULL,
    deductible double precision,
    insurance_limit double precision,
    CONSTRAINT converted_cost_value CHECK ((value >= (0.0)::double precision))
);


--
-- Name: model_cost_type; Type: TABLE; Schema: level2; Owner: -; Tablespace: ged2_ts
--

CREATE TABLE model_cost_type (
    id integer NOT NULL,
    exposure_model_id integer NOT NULL,
    cost_type_name character varying NOT NULL,
    aggregation_type character varying NOT NULL,
    unit character varying,
    CONSTRAINT aggregation_type_value CHECK ((((aggregation_type)::text = 'per_asset'::text) OR ((aggregation_type)::text = 'per_area'::text) OR ((aggregation_type)::text = 'aggregated'::text)))
);


--
-- Name: occupancy; Type: TABLE; Schema: level2; Owner: -; Tablespace: ged2_ts
--

CREATE TABLE occupancy (
    id integer NOT NULL,
    asset_id integer NOT NULL,
    period character varying NOT NULL,
    occupants double precision NOT NULL
);


--
-- Name: all_exposure; Type: VIEW; Schema: level2; Owner: -
--

CREATE VIEW all_exposure AS
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
   FROM (((asset a
     LEFT JOIN cost c ON ((c.asset_id = a.id)))
     LEFT JOIN model_cost_type mct ON ((mct.id = c.cost_type_id)))
     LEFT JOIN occupancy occ ON ((occ.asset_id = a.id)));


--
-- Name: asset_id_seq; Type: SEQUENCE; Schema: level2; Owner: -
--

CREATE SEQUENCE asset_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: asset_id_seq; Type: SEQUENCE OWNED BY; Schema: level2; Owner: -
--

ALTER SEQUENCE asset_id_seq OWNED BY asset.id;


--
-- Name: contribution; Type: TABLE; Schema: level2; Owner: -; Tablespace: ged2_ts
--

CREATE TABLE contribution (
    id integer NOT NULL,
    exposure_model_id integer NOT NULL,
    model_source character varying NOT NULL,
    model_date character varying NOT NULL,
    notes text
);


--
-- Name: contribution_id_seq; Type: SEQUENCE; Schema: level2; Owner: -
--

CREATE SEQUENCE contribution_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contribution_id_seq; Type: SEQUENCE OWNED BY; Schema: level2; Owner: -
--

ALTER SEQUENCE contribution_id_seq OWNED BY contribution.id;


--
-- Name: cost_id_seq; Type: SEQUENCE; Schema: level2; Owner: -
--

CREATE SEQUENCE cost_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cost_id_seq; Type: SEQUENCE OWNED BY; Schema: level2; Owner: -
--

ALTER SEQUENCE cost_id_seq OWNED BY cost.id;


--
-- Name: exposure_model; Type: TABLE; Schema: level2; Owner: -; Tablespace: ged2_ts
--

CREATE TABLE exposure_model (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    taxonomy_source character varying,
    category character varying NOT NULL,
    area_type character varying,
    area_unit character varying,
    tag_names character varying,
    CONSTRAINT area_type_value CHECK (((area_type IS NULL) OR ((area_type)::text = 'per_asset'::text) OR ((area_type)::text = 'aggregated'::text)))
);


--
-- Name: exposure_model_id_seq; Type: SEQUENCE; Schema: level2; Owner: -
--

CREATE SEQUENCE exposure_model_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exposure_model_id_seq; Type: SEQUENCE OWNED BY; Schema: level2; Owner: -
--

ALTER SEQUENCE exposure_model_id_seq OWNED BY exposure_model.id;


--
-- Name: model_cost_type_id_seq; Type: SEQUENCE; Schema: level2; Owner: -
--

CREATE SEQUENCE model_cost_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: model_cost_type_id_seq; Type: SEQUENCE OWNED BY; Schema: level2; Owner: -
--

ALTER SEQUENCE model_cost_type_id_seq OWNED BY model_cost_type.id;


--
-- Name: occupancy_id_seq; Type: SEQUENCE; Schema: level2; Owner: -
--

CREATE SEQUENCE occupancy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: occupancy_id_seq; Type: SEQUENCE OWNED BY; Schema: level2; Owner: -
--

ALTER SEQUENCE occupancy_id_seq OWNED BY occupancy.id;


--
-- Name: tags; Type: TABLE; Schema: level2; Owner: -; Tablespace: ged2_ts
--

CREATE TABLE tags (
    id integer NOT NULL,
    asset_id integer NOT NULL,
    name character varying NOT NULL,
    value character varying NOT NULL
);


--
-- Name: id; Type: DEFAULT; Schema: level2; Owner: -
--

ALTER TABLE ONLY asset ALTER COLUMN id SET DEFAULT nextval('asset_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: level2; Owner: -
--

ALTER TABLE ONLY contribution ALTER COLUMN id SET DEFAULT nextval('contribution_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: level2; Owner: -
--

ALTER TABLE ONLY cost ALTER COLUMN id SET DEFAULT nextval('cost_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: level2; Owner: -
--

ALTER TABLE ONLY exposure_model ALTER COLUMN id SET DEFAULT nextval('exposure_model_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: level2; Owner: -
--

ALTER TABLE ONLY model_cost_type ALTER COLUMN id SET DEFAULT nextval('model_cost_type_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: level2; Owner: -
--

ALTER TABLE ONLY occupancy ALTER COLUMN id SET DEFAULT nextval('occupancy_id_seq'::regclass);


SET default_tablespace = '';

--
-- Name: asset_exposure_model_id_asset_ref_key; Type: CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY asset
    ADD CONSTRAINT asset_exposure_model_id_asset_ref_key UNIQUE (exposure_model_id, asset_ref);


--
-- Name: asset_pkey; Type: CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY asset
    ADD CONSTRAINT asset_pkey PRIMARY KEY (id);


--
-- Name: contribution_pkey; Type: CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY contribution
    ADD CONSTRAINT contribution_pkey PRIMARY KEY (id);


--
-- Name: cost_asset_id_cost_type_id_key; Type: CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY cost
    ADD CONSTRAINT cost_asset_id_cost_type_id_key UNIQUE (asset_id, cost_type_id);


--
-- Name: cost_pkey; Type: CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY cost
    ADD CONSTRAINT cost_pkey PRIMARY KEY (id);


--
-- Name: exposure_model_pkey; Type: CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY exposure_model
    ADD CONSTRAINT exposure_model_pkey PRIMARY KEY (id);


--
-- Name: model_cost_type_pkey; Type: CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY model_cost_type
    ADD CONSTRAINT model_cost_type_pkey PRIMARY KEY (id);


--
-- Name: occupancy_pkey; Type: CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY occupancy
    ADD CONSTRAINT occupancy_pkey PRIMARY KEY (id);


SET default_tablespace = ged2_ts;

--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: level2; Owner: -; Tablespace: ged2_ts
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


SET default_tablespace = '';

--
-- Name: asset_exposure_model_id_idx; Type: INDEX; Schema: level2; Owner: -
--

CREATE INDEX asset_exposure_model_id_idx ON asset USING btree (exposure_model_id);


--
-- Name: asset_full_geom_idx; Type: INDEX; Schema: level2; Owner: -
--

CREATE INDEX asset_full_geom_idx ON asset USING gist (full_geom);


--
-- Name: asset_the_geom_gist; Type: INDEX; Schema: level2; Owner: -
--

CREATE INDEX asset_the_geom_gist ON asset USING gist (the_geom);


--
-- Name: cost_asset_id_idx; Type: INDEX; Schema: level2; Owner: -
--

CREATE INDEX cost_asset_id_idx ON cost USING btree (asset_id);


--
-- Name: occupancy_asset_id_idx; Type: INDEX; Schema: level2; Owner: -
--

CREATE INDEX occupancy_asset_id_idx ON occupancy USING btree (asset_id);


--
-- Name: tags_asset_id_idx; Type: INDEX; Schema: level2; Owner: -
--

CREATE INDEX tags_asset_id_idx ON tags USING btree (asset_id);


--
-- Name: asset_exposure_model_id_fk; Type: FK CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY asset
    ADD CONSTRAINT asset_exposure_model_id_fk FOREIGN KEY (exposure_model_id) REFERENCES exposure_model(id) ON DELETE CASCADE;


--
-- Name: contribution_exposure_model_id_fkey; Type: FK CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY contribution
    ADD CONSTRAINT contribution_exposure_model_id_fkey FOREIGN KEY (exposure_model_id) REFERENCES exposure_model(id);


--
-- Name: cost_asset_id_fk; Type: FK CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY cost
    ADD CONSTRAINT cost_asset_id_fk FOREIGN KEY (asset_id) REFERENCES asset(id) ON DELETE CASCADE;


--
-- Name: cost_cost_type_id_fkey; Type: FK CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY cost
    ADD CONSTRAINT cost_cost_type_id_fkey FOREIGN KEY (cost_type_id) REFERENCES model_cost_type(id);


--
-- Name: model_cost_type_exposure_model_id_fk; Type: FK CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY model_cost_type
    ADD CONSTRAINT model_cost_type_exposure_model_id_fk FOREIGN KEY (exposure_model_id) REFERENCES exposure_model(id) ON DELETE CASCADE;


--
-- Name: occupancy_asset_id_fk; Type: FK CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY occupancy
    ADD CONSTRAINT occupancy_asset_id_fk FOREIGN KEY (asset_id) REFERENCES asset(id) ON DELETE CASCADE;


--
-- Name: tags_asset_id_fkey; Type: FK CONSTRAINT; Schema: level2; Owner: -
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES asset(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

