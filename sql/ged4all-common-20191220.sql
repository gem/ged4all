--
-- PostgreSQL database dump
--

-- Dumped from database version 11.5 (Debian 11.5-3.pgdg100+1)
-- Dumped by pg_dump version 11.5 (Debian 11.5-3.pgdg100+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: cf_common; Type: SCHEMA; Schema: -; Owner: ged4allcontrib
--

CREATE SCHEMA cf_common;


ALTER SCHEMA cf_common OWNER TO ged4allcontrib;

--
-- Name: SCHEMA cf_common; Type: COMMENT; Schema: -; Owner: ged4allcontrib
--

COMMENT ON SCHEMA cf_common IS 'Common elements for all Challenge Fund Database Schemas';


--
-- Name: occupancy_enum; Type: TYPE; Schema: cf_common; Owner: ged4allcontrib
--

CREATE TYPE cf_common.occupancy_enum AS ENUM (
    'Residential',
    'Commercial',
    'Industrial',
    'Infrastructure',
    'Healthcare',
    'Educational',
    'Government',
    'Crop',
    'Livestock',
    'Forestry',
    'Mixed'
);


ALTER TYPE cf_common.occupancy_enum OWNER TO ged4allcontrib;

--
-- Name: TYPE occupancy_enum; Type: COMMENT; Schema: cf_common; Owner: ged4allcontrib
--

COMMENT ON TYPE cf_common.occupancy_enum IS 'Types of Occupancy or building/structure use';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: hazard_type; Type: TABLE; Schema: cf_common; Owner: ged4allcontrib
--

CREATE TABLE cf_common.hazard_type (
    code character varying NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE cf_common.hazard_type OWNER TO ged4allcontrib;

--
-- Name: TABLE hazard_type; Type: COMMENT; Schema: cf_common; Owner: ged4allcontrib
--

COMMENT ON TABLE cf_common.hazard_type IS 'Valid Hazard types';


--
-- Name: license; Type: TABLE; Schema: cf_common; Owner: ged4allcontrib
--

CREATE TABLE cf_common.license (
    id integer NOT NULL,
    code character varying NOT NULL,
    name character varying NOT NULL,
    notes text,
    url character varying NOT NULL
);


ALTER TABLE cf_common.license OWNER TO ged4allcontrib;

--
-- Name: TABLE license; Type: COMMENT; Schema: cf_common; Owner: ged4allcontrib
--

COMMENT ON TABLE cf_common.license IS 'List of supported licenses';


--
-- Name: license_id_seq; Type: SEQUENCE; Schema: cf_common; Owner: ged4allcontrib
--

CREATE SEQUENCE cf_common.license_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cf_common.license_id_seq OWNER TO ged4allcontrib;

--
-- Name: license_id_seq; Type: SEQUENCE OWNED BY; Schema: cf_common; Owner: ged4allcontrib
--

ALTER SEQUENCE cf_common.license_id_seq OWNED BY cf_common.license.id;


--
-- Name: process_type; Type: TABLE; Schema: cf_common; Owner: ged4allcontrib
--

CREATE TABLE cf_common.process_type (
    code character varying NOT NULL,
    hazard_code character varying NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE cf_common.process_type OWNER TO ged4allcontrib;

--
-- Name: license id; Type: DEFAULT; Schema: cf_common; Owner: ged4allcontrib
--

ALTER TABLE ONLY cf_common.license ALTER COLUMN id SET DEFAULT nextval('cf_common.license_id_seq'::regclass);


--
-- Name: hazard_type hazard_type_pkey; Type: CONSTRAINT; Schema: cf_common; Owner: ged4allcontrib
--

ALTER TABLE ONLY cf_common.hazard_type
    ADD CONSTRAINT hazard_type_pkey PRIMARY KEY (code);


--
-- Name: license license_pkey; Type: CONSTRAINT; Schema: cf_common; Owner: ged4allcontrib
--

ALTER TABLE ONLY cf_common.license
    ADD CONSTRAINT license_pkey PRIMARY KEY (id);


--
-- Name: process_type process_type_pkey; Type: CONSTRAINT; Schema: cf_common; Owner: ged4allcontrib
--

ALTER TABLE ONLY cf_common.process_type
    ADD CONSTRAINT process_type_pkey PRIMARY KEY (code);


--
-- Name: SCHEMA cf_common; Type: ACL; Schema: -; Owner: ged4allcontrib
--

GRANT USAGE ON SCHEMA cf_common TO ged4allusers;


--
-- Name: TABLE hazard_type; Type: ACL; Schema: cf_common; Owner: ged4allcontrib
--

GRANT SELECT ON TABLE cf_common.hazard_type TO ged4allusers;


--
-- Name: TABLE license; Type: ACL; Schema: cf_common; Owner: ged4allcontrib
--

GRANT SELECT ON TABLE cf_common.license TO ged4allusers;


--
-- Name: TABLE process_type; Type: ACL; Schema: cf_common; Owner: ged4allcontrib
--

GRANT SELECT ON TABLE cf_common.process_type TO ged4allusers;


--
-- PostgreSQL database dump complete
--

