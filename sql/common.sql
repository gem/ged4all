--
-- PostgreSQL database dump
--

-- Dumped from database version 11.6 (Debian 11.6-1.pgdg100+1)
-- Dumped by pg_dump version 11.6 (Debian 11.6-1.pgdg100+1)

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
-- Name: cf_common; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA cf_common;


--
-- Name: SCHEMA cf_common; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA cf_common IS 'Common elements for all Challenge Fund Database Schemas';


--
-- Name: occupancy_enum; Type: TYPE; Schema: cf_common; Owner: -
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


--
-- Name: TYPE occupancy_enum; Type: COMMENT; Schema: cf_common; Owner: -
--

COMMENT ON TYPE cf_common.occupancy_enum IS 'Types of Occupancy or building/structure use';

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: hazard_type; Type: TABLE; Schema: cf_common; Owner: -
--

CREATE TABLE cf_common.hazard_type (
    code character varying NOT NULL,
    name character varying NOT NULL
);


--
-- Name: TABLE hazard_type; Type: COMMENT; Schema: cf_common; Owner: -
--

COMMENT ON TABLE cf_common.hazard_type IS 'Valid Hazard types';


--
-- Name: imt; Type: TABLE; Schema: cf_common; Owner: -
--

CREATE TABLE cf_common.imt (
    process_code character varying NOT NULL,
    hazard_code character varying NOT NULL,
    im_code character varying NOT NULL,
    description character varying NOT NULL,
    units character varying NOT NULL
);


--
-- Name: license; Type: TABLE; Schema: cf_common; Owner: -
--

CREATE TABLE cf_common.license (
    code character varying NOT NULL,
    name character varying NOT NULL,
    notes text,
    url character varying NOT NULL
);


--
-- Name: TABLE license; Type: COMMENT; Schema: cf_common; Owner: -
--

COMMENT ON TABLE cf_common.license IS 'List of supported licenses';


--
-- Name: process_type; Type: TABLE; Schema: cf_common; Owner: -
--

CREATE TABLE cf_common.process_type (
    code character varying NOT NULL,
    hazard_code character varying NOT NULL,
    name character varying NOT NULL
);


--
-- Data for Name: hazard_type; Type: TABLE DATA; Schema: cf_common; Owner: -
--

COPY cf_common.hazard_type (code, name) FROM stdin;
CS	Convective Storm
EQ	Earthquake
TS	Tsunami
VO	Volcanic
CF	Coastal Flood
FL	Flood
LS	Landslide
WI	Strong Wind
ET	Extreme Temperature
DR	Drought
WF	Wildfire
MH	Multi-Hazard
\.


--
-- Data for Name: imt; Type: TABLE DATA; Schema: cf_common; Owner: -
--

COPY cf_common.imt (process_code, hazard_code, im_code, description, units) FROM stdin;
QGM	EQ	PGA:g	Peak ground acceleration in g	g
QGM	EQ	PGA:m/s2	Peak ground acceleration in m/s2 (meters per second squared)	m/s2
QGM	EQ	PGV:m/s	Peak ground velocity in m/s	m/s
QGM	EQ	SA(0.2):g	Spectral acceleration with 0.2s period	g
QGM	EQ	SA(0.3):g	Spectral acceleration with 0.3s period	g
QGM	EQ	SA(1.0):g	Spectral acceleration with 1.0s period	g
QGM	EQ	SA(3.0):g	Spectral acceleration with 3.0s period	g
QGM	EQ	SA(0.2):m/s2	Spectral acceleration with 0.2s period	m/s2
QGM	EQ	SA(0.3):m/s2	Spectral acceleration with 0.3s period	m/s2
QGM	EQ	SA(1.0):m/s2	Spectral acceleration with 1.0s period	m/s2
QGM	EQ	SA(3.0):m/s2	Spectral acceleration with 3.0s period	m/s2
QGM	EQ	Sd(T1):m	Spectral displacement	m
QGM	EQ	Sv(T1):m/s	Spectral velocity	m/s
QGM	EQ	PGDf:m	Permanent ground deformation	m
QGM	EQ	D_a5-95:s	Significant duration a5-95	s
QGM	EQ	D_a5-75 :s	Significant duration a5-75	s
QGM	EQ	IA:m/s	Arias intensity (Iα) or (IA) or (Ia)	m/s
QGM	EQ	Neq:-	Effective number of cycles	-
QGM	EQ	EMS:-	European macroseismic scale	-
QGM	EQ	AvgSa:m/s2	Average spectral acceleration	m/s2
QGM	EQ	I_Np:m/s2	I_Np by Bojórquez and Iervolino	m/s2
QGM	EQ	MMI:-	Modified Mercalli Intensity	-
QGM	EQ	CAV:m/s	Cumulative absolute velocity	m/s
QGM	EQ	D_B:s	Bracketed duration	s
FFF	FL	d_fff:m	Flood water depth	m
FPF	FL	d_fpf:m	Flood water depth	m
FFF	FL	v_fff:m/s	Flood flow velocity	m/s
FPF	FL	v_fpf:m/s	Flood flow velocity	m/s
TCY	WI	v_tcy(3s):km/h	3-sec at 10m sustained wind speed (kph)	km/h
ETC	WI	v_ect(3s):km/h	3-sec at 10m sustained wind speed (kph)	km/h
TCY	WI	v_tcy(1m):km/h	1-min at 10m sustained wind speed (kph)	km/h
ETC	WI	v_ect(1m):km/h	1-min at 10m sustained wind speed (kph)	km/h
TCY	WI	v_tcy(10m):km/h	10-min sustained wind speed (kph)	km/h
ETC	WI	v_etc(10m):km/h	10-min sustained wind speed (kph)	km/h
TCY	WI	PGWS_tcy:km/h	Peak gust wind speed	km/h
ETC	WI	PGWS_ect:km/h	Peak gust wind speed	km/h
LSL	LS	d_lsl:m	Landslide flow depth	m
LSL	LS	I_DF:m3/s2	Debris-flow intensity index	m3/s2
LSL	LS	v_lsl:m/s2	Landslide flow velocity	m/s2
LSL	LS	MFD_lsl:m	Maximum foundation displacement	m
LSL	LS	SD_lsl:m	Landslide displacement	m
TSI	TS	Rh_tsi:m	Tsunami wave runup height	m
TSI	TS	d_tsi:m	Tsunami inundation depth	m
TSI	TS	MMF:m4/s2	Modified momentum flux	m4/s2
TSI	TS	F_drag:kN	Drag force	kN
TSI	TS	Fr:-	Froude number	-
TSI	TS	v_tsi:m/s	Tsunami velocity	m/s
TSI	TS	F_QS:kN	Quasi-steady force	kN
TSI	TS	MF:m3/s2	Momentum flux	m3/s2
TSI	TS	h_tsi:m	Tsunami wave height	m
TSI	TS	Fh_tsi:m	Tsunami Horizontal Force	kN
VAF	VO	h_vaf:m	Ash fall thickness	m
VAF	VO	L_vaf:kg/m2	Ash loading	kg/m2
FSS	CF	v_fss:m/s	Maximum water velocity	m/s
FSS	CF	d_fss:m	Storm surge inundation depth	m
DTA	DR	CMI:-	Crop Moisture Index	-
DTM	DR	PDSI:-	Palmer Drought Severity Index	-
DTM	DR	SPI:-	Standard Precipitation Index	-
\.


--
-- Data for Name: license; Type: TABLE DATA; Schema: cf_common; Owner: -
--

COPY cf_common.license (code, name, notes, url) FROM stdin;
CC0	Creative Commons CCZero (CC0)	Dedicate to the Public Domain (all rights waived)	https://creativecommons.org/publicdomain/zero/1.0/
PDDL	Open Data Commons Public Domain Dedication and Licence (PDDL)	Dedicate to the Public Domain (all rights waived)	https://opendatacommons.org/licenses/pddl/index.html
ODbL	Open Data Commons Open Database License (ODbL)	Attribution-ShareAlike for data(bases)	https://opendatacommons.org/licenses/odbl/summary/
ODC-By	Open Data Commons Attribution License(ODC-BY)	Attribution for data(bases)	https://opendatacommons.org/licenses/by/summary/
CC BY 4.0	Creative Commons Attribution 4.0 (CC-BY-4.0)	\N	https://creativecommons.org/licenses/by/4.0/
CC BY-SA 4.0	Creative Commons Attribution Share-Alike 4.0 (CC-BY-SA-4.0)	\N	http://creativecommons.org/licenses/by-sa/4.0/
\.


--
-- Data for Name: process_type; Type: TABLE DATA; Schema: cf_common; Owner: -
--

COPY cf_common.process_type (code, hazard_code, name) FROM stdin;
QLI	EQ	Liquefaction
QGM	EQ	Ground Motion
Q1R	EQ	Primary Rupture
Q2R	EQ	Secondary Rupture
TSI	TS	Tsunami
VAF	VO	Ashfall
VLH	VO	Lahar
VPF	VO	Pyroclastic Flow
VBL	VO	Ballistics
VLV	VO	Lava
VFH	VO	Proximal hazards
FSS	CF	Storm Surge
FCF	CF	Coastal Flood
FFF	FL	Fluvial Flood
FPF	FL	Pluvial Flood
LAV	LS	Snow Avalanche
LSL	LS	Landslide (general)
TCY	WI	Tropical cyclone
ETC	WI	Extratropical cyclone
EHT	ET	Extreme heat
ECD	ET	Extreme cold
DTS	DR	Socio-economic Drought
DTM	DR	Meteorological Drought
DTH	DR	Hydrological Drought
DTA	DR	Agricultural Drought
WFI	WF	Wildfire
TOR	CS	Tornado
\.


--
-- Name: hazard_type hazard_type_pkey; Type: CONSTRAINT; Schema: cf_common; Owner: -
--

ALTER TABLE ONLY cf_common.hazard_type
    ADD CONSTRAINT hazard_type_pkey PRIMARY KEY (code);


--
-- Name: imt imt_pkey; Type: CONSTRAINT; Schema: cf_common; Owner: -
--

ALTER TABLE ONLY cf_common.imt
    ADD CONSTRAINT imt_pkey PRIMARY KEY (im_code);


--
-- Name: license license_pkey; Type: CONSTRAINT; Schema: cf_common; Owner: -
--

ALTER TABLE ONLY cf_common.license
    ADD CONSTRAINT license_pkey PRIMARY KEY (code);


--
-- Name: process_type process_type_pkey; Type: CONSTRAINT; Schema: cf_common; Owner: -
--

ALTER TABLE ONLY cf_common.process_type
    ADD CONSTRAINT process_type_pkey PRIMARY KEY (code);


--
-- Name: process_type unique_code_hazard_code; Type: CONSTRAINT; Schema: cf_common; Owner: -
--

ALTER TABLE ONLY cf_common.process_type
    ADD CONSTRAINT unique_code_hazard_code UNIQUE (code, hazard_code);


--
-- Name: imt imt_process_code_fkey; Type: FK CONSTRAINT; Schema: cf_common; Owner: -
--

ALTER TABLE ONLY cf_common.imt
    ADD CONSTRAINT imt_process_code_fkey FOREIGN KEY (process_code, hazard_code) REFERENCES cf_common.process_type(code, hazard_code);


--
-- Name: process_type process_type_hazard_code_fkey; Type: FK CONSTRAINT; Schema: cf_common; Owner: -
--

ALTER TABLE ONLY cf_common.process_type
    ADD CONSTRAINT process_type_hazard_code_fkey FOREIGN KEY (hazard_code) REFERENCES cf_common.hazard_type(code);

--
-- PostgreSQL database dump complete
--

