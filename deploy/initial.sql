-- Deploy community-schema:initial to pg

BEGIN;

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.5
-- Dumped by pg_dump version 9.5.1

-- Started on 2016-04-01 15:36:26 PDT

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 9 (class 2615 OID 16395)
-- Name: internal; Type: SCHEMA; Schema: -; Owner: nomad
--

CREATE SCHEMA internal;


ALTER SCHEMA internal OWNER TO nomad;

--
-- TOC entry 10 (class 2615 OID 16409)
-- Name: v1; Type: SCHEMA; Schema: -; Owner: nomad
--

CREATE SCHEMA v1;


ALTER SCHEMA v1 OWNER TO nomad;

--
-- TOC entry 1 (class 3079 OID 12723)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 4153 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 2 (class 3079 OID 16429)
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- TOC entry 4154 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


SET search_path = internal, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 176 (class 1259 OID 16401)
-- Name: ip2location_db5; Type: TABLE; Schema: internal; Owner: nomad
--

CREATE TABLE ip2location_db5 (
    ip_from bigint NOT NULL,
    ip_to bigint NOT NULL,
    country_code character(2) NOT NULL,
    country_name character varying(64) NOT NULL,
    region_name character varying(128) NOT NULL,
    city_name character varying(128) NOT NULL,
    latitude real NOT NULL,
    longitude real NOT NULL
);


ALTER TABLE ip2location_db5 OWNER TO nomad;

SET search_path = v1, pg_catalog;

--
-- TOC entry 209 (class 1255 OID 16410)
-- Name: where_is(inet); Type: FUNCTION; Schema: v1; Owner: nomad
--

CREATE FUNCTION where_is(ip inet) RETURNS SETOF internal.ip2location_db5
    LANGUAGE plpgsql
    AS $_$
DECLARE
  addr bigint;
BEGIN
  addr := $1 - '0.0.0.0'::inet;
  RETURN QUERY SELECT * FROM internal.ip2location_db5 WHERE int8range(ip_from, ip_to) @> addr::bigint;
END
$_$;


ALTER FUNCTION v1.where_is(ip inet) OWNER TO nomad;

--
-- TOC entry 195 (class 1259 OID 17772)
-- Name: checkins; Type: TABLE; Schema: v1; Owner: nomad
--

CREATE TABLE checkins (
    id bigint NOT NULL,
    nomad_id bigint,
    "when" timestamp with time zone DEFAULT now() NOT NULL,
    lat numeric NOT NULL,
    lon numeric NOT NULL,
    CONSTRAINT lat_lon_valid CHECK (((((lat >= ((-90))::numeric) AND (lat <= (90)::numeric)) AND (lon >= ((-180))::numeric)) AND (lon <= (180)::numeric)))
);


ALTER TABLE checkins OWNER TO nomad;

--
-- TOC entry 194 (class 1259 OID 17770)
-- Name: checkins_id_seq; Type: SEQUENCE; Schema: v1; Owner: nomad
--

CREATE SEQUENCE checkins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE checkins_id_seq OWNER TO nomad;

--
-- TOC entry 4155 (class 0 OID 0)
-- Dependencies: 194
-- Name: checkins_id_seq; Type: SEQUENCE OWNED BY; Schema: v1; Owner: nomad
--

ALTER SEQUENCE checkins_id_seq OWNED BY checkins.id;


--
-- TOC entry 196 (class 1259 OID 17785)
-- Name: latest_checkins; Type: VIEW; Schema: v1; Owner: nomad
--

CREATE VIEW latest_checkins AS
 SELECT x.r,
    x.id,
    x.nomad_id,
    x."when",
    x.lat,
    x.lon
   FROM ( SELECT row_number() OVER (PARTITION BY t.nomad_id ORDER BY t."when" DESC) AS r,
            t.id,
            t.nomad_id,
            t."when",
            t.lat,
            t.lon
           FROM checkins t) x
  WHERE (x.r < 2);


ALTER TABLE latest_checkins OWNER TO nomad;

--
-- TOC entry 191 (class 1259 OID 17727)
-- Name: nomads; Type: TABLE; Schema: v1; Owner: nomad
--

CREATE TABLE nomads (
    id bigint NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    origin_country text,
    passcode text
);


ALTER TABLE nomads OWNER TO nomad;

--
-- TOC entry 4156 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN nomads.passcode; Type: COMMENT; Schema: v1; Owner: nomad
--

COMMENT ON COLUMN nomads.passcode IS 'This is their "Nomad Pass" which is issued to them on signup.';


--
-- TOC entry 190 (class 1259 OID 17725)
-- Name: nomads_id_seq; Type: SEQUENCE; Schema: v1; Owner: nomad
--

CREATE SEQUENCE nomads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE nomads_id_seq OWNER TO nomad;

--
-- TOC entry 4157 (class 0 OID 0)
-- Dependencies: 190
-- Name: nomads_id_seq; Type: SEQUENCE OWNED BY; Schema: v1; Owner: nomad
--

ALTER SEQUENCE nomads_id_seq OWNED BY nomads.id;


--
-- TOC entry 193 (class 1259 OID 17744)
-- Name: nomads_tags; Type: TABLE; Schema: v1; Owner: nomad
--

CREATE TABLE nomads_tags (
    nomad_id bigint NOT NULL,
    tag text NOT NULL
);


ALTER TABLE nomads_tags OWNER TO nomad;

--
-- TOC entry 192 (class 1259 OID 17736)
-- Name: tags; Type: TABLE; Schema: v1; Owner: nomad
--

CREATE TABLE tags (
    tag text NOT NULL
);


ALTER TABLE tags OWNER TO nomad;

--
-- TOC entry 4010 (class 2604 OID 17775)
-- Name: id; Type: DEFAULT; Schema: v1; Owner: nomad
--

ALTER TABLE ONLY checkins ALTER COLUMN id SET DEFAULT nextval('checkins_id_seq'::regclass);


--
-- TOC entry 4009 (class 2604 OID 17730)
-- Name: id; Type: DEFAULT; Schema: v1; Owner: nomad
--

ALTER TABLE ONLY nomads ALTER COLUMN id SET DEFAULT nextval('nomads_id_seq'::regclass);


SET search_path = internal, pg_catalog;

--
-- TOC entry 4014 (class 2606 OID 16405)
-- Name: ip2location_db5_pkey; Type: CONSTRAINT; Schema: internal; Owner: nomad
--

ALTER TABLE ONLY ip2location_db5
    ADD CONSTRAINT ip2location_db5_pkey PRIMARY KEY (ip_from, ip_to);


SET search_path = v1, pg_catalog;

--
-- TOC entry 4024 (class 2606 OID 17782)
-- Name: checkins_pkey; Type: CONSTRAINT; Schema: v1; Owner: nomad
--

ALTER TABLE ONLY checkins
    ADD CONSTRAINT checkins_pkey PRIMARY KEY (id);


--
-- TOC entry 4017 (class 2606 OID 17735)
-- Name: nomads_pkey; Type: CONSTRAINT; Schema: v1; Owner: nomad
--

ALTER TABLE ONLY nomads
    ADD CONSTRAINT nomads_pkey PRIMARY KEY (id);


--
-- TOC entry 4021 (class 2606 OID 17751)
-- Name: nomads_tags_pkey; Type: CONSTRAINT; Schema: v1; Owner: nomad
--

ALTER TABLE ONLY nomads_tags
    ADD CONSTRAINT nomads_tags_pkey PRIMARY KEY (nomad_id, tag);


--
-- TOC entry 4019 (class 2606 OID 17743)
-- Name: tags_pkey; Type: CONSTRAINT; Schema: v1; Owner: nomad
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (tag);


SET search_path = internal, pg_catalog;

--
-- TOC entry 4015 (class 1259 OID 16428)
-- Name: ip2location_ip_range_idx; Type: INDEX; Schema: internal; Owner: nomad
--

CREATE INDEX ip2location_ip_range_idx ON ip2location_db5 USING gist (int8range(ip_from, ip_to));


SET search_path = v1, pg_catalog;

--
-- TOC entry 4022 (class 1259 OID 17784)
-- Name: checkins_nomad_idx; Type: INDEX; Schema: v1; Owner: nomad
--

CREATE INDEX checkins_nomad_idx ON checkins USING btree (nomad_id);


--
-- TOC entry 4025 (class 1259 OID 17783)
-- Name: checkins_when_idx; Type: INDEX; Schema: v1; Owner: nomad
--

CREATE INDEX checkins_when_idx ON checkins USING btree ("when");


--
-- TOC entry 4028 (class 2606 OID 17789)
-- Name: nomad_checkins_fk; Type: FK CONSTRAINT; Schema: v1; Owner: nomad
--

ALTER TABLE ONLY checkins
    ADD CONSTRAINT nomad_checkins_fk FOREIGN KEY (nomad_id) REFERENCES nomads(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4026 (class 2606 OID 17752)
-- Name: nomads_tags_nomad_id_fkey; Type: FK CONSTRAINT; Schema: v1; Owner: nomad
--

ALTER TABLE ONLY nomads_tags
    ADD CONSTRAINT nomads_tags_nomad_id_fkey FOREIGN KEY (nomad_id) REFERENCES nomads(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4027 (class 2606 OID 17757)
-- Name: nomads_tags_tag_fkey; Type: FK CONSTRAINT; Schema: v1; Owner: nomad
--

ALTER TABLE ONLY nomads_tags
    ADD CONSTRAINT nomads_tags_tag_fkey FOREIGN KEY (tag) REFERENCES tags(tag) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4152 (class 0 OID 0)
-- Dependencies: 8
-- Name: public; Type: ACL; Schema: -; Owner: nomad
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM nomad;
GRANT ALL ON SCHEMA public TO nomad;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2016-04-01 15:36:50 PDT

--
-- PostgreSQL database dump complete
--

COMMIT;
