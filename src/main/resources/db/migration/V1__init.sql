--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.5
-- Dumped by pg_dump version 10.0

-- Started on 2018-01-06 18:07:47 MSK

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;


--
-- TOC entry 1 (class 3079 OID 12429)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2342 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 2 (class 3079 OID 37868)
-- Name: citext; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- TOC entry 2343 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


SET search_path = public, pg_catalog;

--
-- TOC entry 246 (class 1255 OID 37952)
-- Name: create_path_post(); Type: FUNCTION; Schema: public; Owner: vlad
--

CREATE FUNCTION create_path_post() RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  newpath BIGINT[];

BEGIN
  IF (NEW.parent::BIGINT = 0) THEN
    NEW.path = newpath || NEW.id::BIGINT;
    RETURN NEW;
  ELSE
    newpath = (SELECT path FROM post WHERE id = NEW.parent::BIGINT AND thread = NEW.thread::BIGINT)::BIGINT[];
    IF (cardinality(newpath) > 0) THEN
      NEW.path = newpath || NEW.id::BIGINT;
      return NEW;
    ELSE
      RAISE  invalid_foreign_key;
    END IF;
  END IF;
END;
$$;


ALTER FUNCTION public.create_path_post() OWNER TO vlad;

--
-- TOC entry 247 (class 1255 OID 37954)
-- Name: process_increment_post_forum(); Type: FUNCTION; Schema: public; Owner: vlad
--

CREATE FUNCTION process_increment_post_forum() RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    UPDATE forum SET posts = posts - 1
    WHERE lower(slug) = lower(OLD.forum);
    RETURN OLD;
  ELSIF (TG_OP = 'INSERT') THEN
    UPDATE forum SET posts = posts + 1
    WHERE lower(slug) = lower(NEW.forum);
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$$;


ALTER FUNCTION public.process_increment_post_forum() OWNER TO vlad;

--
-- TOC entry 248 (class 1255 OID 37955)
-- Name: process_increment_thread_forum(); Type: FUNCTION; Schema: public; Owner: vlad
--

CREATE FUNCTION process_increment_thread_forum() RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    UPDATE forum SET threads = threads - 1
    WHERE lower(slug) = lower(OLD.forum);
    RETURN OLD;
  ELSIF (TG_OP = 'INSERT') THEN
    UPDATE forum SET threads = threads + 1
    WHERE lower(slug) = lower(NEW.forum);
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$$;


ALTER FUNCTION public.process_increment_thread_forum() OWNER TO vlad;

--
-- TOC entry 249 (class 1255 OID 38853)
-- Name: process_vote(); Type: FUNCTION; Schema: public; Owner: vlad
--

CREATE FUNCTION process_vote() RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    UPDATE thread
    SET votes = votes - OLD.voice
    WHERE thread.id = OLD.thread;
    RETURN OLD;
  ELSIF (TG_OP = 'UPDATE') THEN
    UPDATE thread
    SET votes = votes - OLD.voice + NEW.voice
    WHERE thread.id = NEW.thread;
    RETURN NEW;
  ELSIF (TG_OP = 'INSERT') THEN
    UPDATE thread
    SET votes = votes + NEW.voice
    WHERE thread.id = NEW.thread;
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$$;


ALTER FUNCTION public.process_vote() OWNER TO vlad;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 187 (class 1259 OID 37957)
-- Name: forum; Type: TABLE; Schema: public; Owner: vlad
--

CREATE TABLE forum (
  id integer NOT NULL,
  slug citext NOT NULL,
  title character varying(200) NOT NULL,
  user_moderator citext NOT NULL,
  posts integer DEFAULT 0,
  threads integer DEFAULT 0
);


ALTER TABLE forum OWNER TO vlad;

--
-- TOC entry 188 (class 1259 OID 37965)
-- Name: forum_id_seq; Type: SEQUENCE; Schema: public; Owner: vlad
--

CREATE SEQUENCE forum_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE forum_id_seq OWNER TO vlad;

--
-- TOC entry 2344 (class 0 OID 0)
-- Dependencies: 188
-- Name: forum_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE forum_id_seq OWNED BY forum.id;


--
-- TOC entry 189 (class 1259 OID 37967)
-- Name: post; Type: TABLE; Schema: public; Owner: vlad
--

CREATE TABLE post (
  id integer NOT NULL,
  created timestamp without time zone DEFAULT now(),
  message text,
  isedited boolean DEFAULT false,
  author citext NOT NULL,
  thread integer,
  parent integer DEFAULT 0,
  forum citext,
  path bigint[] NOT NULL
);


ALTER TABLE post OWNER TO vlad;

--
-- TOC entry 190 (class 1259 OID 37976)
-- Name: post_id_seq; Type: SEQUENCE; Schema: public; Owner: vlad
--

CREATE SEQUENCE post_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE post_id_seq OWNER TO vlad;

--
-- TOC entry 2345 (class 0 OID 0)
-- Dependencies: 190
-- Name: post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE post_id_seq OWNED BY post.id;


--
-- TOC entry 186 (class 1259 OID 37858)
-- Name: schema_version; Type: TABLE; Schema: public; Owner: vlad
--


--

CREATE TABLE thread (
  id integer NOT NULL,
  slug citext,
  title character varying(200) NOT NULL,
  created timestamp without time zone DEFAULT now(),
  message text,
  votes integer,
  author citext,
  forum citext NOT NULL
);


ALTER TABLE thread OWNER TO vlad;

--
-- TOC entry 192 (class 1259 OID 37985)
-- Name: thread_id_seq; Type: SEQUENCE; Schema: public; Owner: vlad
--

CREATE SEQUENCE thread_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE thread_id_seq OWNER TO vlad;

--
-- TOC entry 2346 (class 0 OID 0)
-- Dependencies: 192
-- Name: thread_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE thread_id_seq OWNED BY thread.id;


--
-- TOC entry 193 (class 1259 OID 37987)
-- Name: thread_votes; Type: TABLE; Schema: public; Owner: vlad
--

CREATE TABLE thread_votes (
  id integer NOT NULL,
  nickname citext NOT NULL,
  thread integer NOT NULL,
  voice smallint NOT NULL
);


ALTER TABLE thread_votes OWNER TO vlad;

--
-- TOC entry 194 (class 1259 OID 37993)
-- Name: thread_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: vlad
--

CREATE SEQUENCE thread_votes_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE thread_votes_id_seq OWNER TO vlad;

--
-- TOC entry 2347 (class 0 OID 0)
-- Dependencies: 194
-- Name: thread_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE thread_votes_id_seq OWNED BY thread_votes.id;


--
-- TOC entry 195 (class 1259 OID 37995)
-- Name: user_account; Type: TABLE; Schema: public; Owner: vlad
--

CREATE TABLE user_account (
  id integer NOT NULL,
  nickname citext COLLATE pg_catalog.ucs_basic NOT NULL,
  email citext NOT NULL,
  fullname character varying(60) NOT NULL,
  about text
);


ALTER TABLE user_account OWNER TO vlad;

--
-- TOC entry 196 (class 1259 OID 38001)
-- Name: user_account_id_seq; Type: SEQUENCE; Schema: public; Owner: vlad
--

CREATE SEQUENCE user_account_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE user_account_id_seq OWNER TO vlad;

--
-- TOC entry 2348 (class 0 OID 0)
-- Dependencies: 196
-- Name: user_account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE user_account_id_seq OWNED BY user_account.id;


--
-- TOC entry 2159 (class 2604 OID 38003)
-- Name: forum id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum ALTER COLUMN id SET DEFAULT nextval('forum_id_seq'::regclass);


--
-- TOC entry 2163 (class 2604 OID 38004)
-- Name: post id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post ALTER COLUMN id SET DEFAULT nextval('post_id_seq'::regclass);


--
-- TOC entry 2165 (class 2604 OID 38005)
-- Name: thread id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread ALTER COLUMN id SET DEFAULT nextval('thread_id_seq'::regclass);


--
-- TOC entry 2166 (class 2604 OID 38006)
-- Name: thread_votes id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread_votes ALTER COLUMN id SET DEFAULT nextval('thread_votes_id_seq'::regclass);


--
-- TOC entry 2167 (class 2604 OID 38007)
-- Name: user_account id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account ALTER COLUMN id SET DEFAULT nextval('user_account_id_seq'::regclass);




SELECT pg_catalog.setval('forum_id_seq', 1, true);


--
-- TOC entry 2350 (class 0 OID 0)
-- Dependencies: 190
-- Name: post_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vlad
--

SELECT pg_catalog.setval('post_id_seq', 1, true);


--
-- TOC entry 2351 (class 0 OID 0)
-- Dependencies: 192
-- Name: thread_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vlad
--

SELECT pg_catalog.setval('thread_id_seq', 1, true);


--
-- TOC entry 2352 (class 0 OID 0)
-- Dependencies: 194
-- Name: thread_votes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vlad
--

SELECT pg_catalog.setval('thread_votes_id_seq', 1, true);


--
-- TOC entry 2353 (class 0 OID 0)
-- Dependencies: 196
-- Name: user_account_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vlad
--

SELECT pg_catalog.setval('user_account_id_seq', 1, true);


--
-- TOC entry 2174 (class 2606 OID 38009)
-- Name: forum forum_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum
  ADD CONSTRAINT forum_pkey PRIMARY KEY (id);


--
-- TOC entry 2176 (class 2606 OID 38011)
-- Name: forum forum_slug_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum
  ADD CONSTRAINT forum_slug_key UNIQUE (slug);


--
-- TOC entry 2179 (class 2606 OID 38013)
-- Name: post post_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post
  ADD CONSTRAINT post_pkey PRIMARY KEY (id);


--
-- TOC entry 2169 (class 2606 OID 37866)
-- Name: schema_version schema_version_pk; Type: CONSTRAINT; Schema: public; Owner: vlad
--



ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_pkey PRIMARY KEY (id);


--
-- TOC entry 2185 (class 2606 OID 38017)
-- Name: thread thread_slug_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_slug_key UNIQUE (slug);


--
-- TOC entry 2188 (class 2606 OID 38019)
-- Name: thread_votes thread_votes_nickname_thread_uk; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread_votes
  ADD CONSTRAINT thread_votes_nickname_thread_uk UNIQUE (thread, nickname);


--
-- TOC entry 2190 (class 2606 OID 38021)
-- Name: thread_votes thread_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread_votes
  ADD CONSTRAINT thread_votes_pkey PRIMARY KEY (id);


--
-- TOC entry 2192 (class 2606 OID 38023)
-- Name: user_account user_account_email_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account
  ADD CONSTRAINT user_account_email_key UNIQUE (email);


--
-- TOC entry 2196 (class 2606 OID 38025)
-- Name: user_account user_account_nickname_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account
  ADD CONSTRAINT user_account_nickname_key UNIQUE (nickname);


--
-- TOC entry 2198 (class 2606 OID 38027)
-- Name: user_account user_account_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account
  ADD CONSTRAINT user_account_pkey PRIMARY KEY (id);


--
-- TOC entry 2171 (class 1259 OID 38973)
-- Name: forum_id_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX forum_id_index ON forum USING btree (id);


--
-- TOC entry 2161 (class 1259 OID 40616)
-- Name: forum_lower_slug_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX forum_lower_slug_index ON forum USING btree (lower((slug)::text));


--
-- TOC entry 2166 (class 1259 OID 40617)
-- Name: post_created_id_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_created_id_index ON post USING btree (created, id);


--
-- TOC entry 2167 (class 1259 OID 40618)
-- Name: post_id_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_id_index ON post USING btree (id);


--
-- TOC entry 2168 (class 1259 OID 40877)
-- Name: post_lower_forum_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_lower_forum_index ON post USING btree (lower((forum)::text));


--
-- TOC entry 2169 (class 1259 OID 40619)
-- Name: post_path_id_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_path_id_index ON post USING btree (path, id);


--
-- TOC entry 2172 (class 1259 OID 40620)
-- Name: post_thread_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_thread_index ON post USING btree (thread);


--
-- TOC entry 2173 (class 1259 OID 40621)
-- Name: thread_id_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX thread_id_index ON thread USING btree (id);


--
-- TOC entry 2174 (class 1259 OID 40622)
-- Name: thread_lower_forum_created_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX thread_lower_forum_created_index ON thread USING btree (lower((forum)::text), created);


--
-- TOC entry 2175 (class 1259 OID 40940)
-- Name: thread_lower_forum_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX thread_lower_forum_index ON thread USING btree (lower((forum)::text));


--
-- TOC entry 2176 (class 1259 OID 40623)
-- Name: thread_lower_slug_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX thread_lower_slug_index ON thread USING btree (lower((slug)::text));


--
-- TOC entry 2181 (class 1259 OID 40624)
-- Name: thread_votes_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX thread_votes_index ON thread_votes USING btree (lower((nickname)::text), thread);


--
-- TOC entry 2188 (class 1259 OID 40625)
-- Name: user_account_lower_email_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX user_account_lower_email_index ON user_account USING btree (lower((email)::text));


--
-- TOC entry 2189 (class 1259 OID 40626)
-- Name: user_account_lower_nickname_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX user_account_lower_nickname_index ON user_account USING btree (lower((nickname)::text));


--
-- TOC entry 2199 (class 2620 OID 40627)
-- Name: post trigger_create_path_post; Type: TRIGGER; Schema: public; Owner: vlad
--

CREATE TRIGGER trigger_create_path_post BEFORE INSERT ON post FOR EACH ROW EXECUTE PROCEDURE create_path_post();


--
-- TOC entry 2205 (class 2620 OID 38030)
-- Name: post trigger_inc_post_forum; Type: TRIGGER; Schema: public; Owner: vlad
--

CREATE TRIGGER trigger_inc_post_forum AFTER INSERT OR DELETE ON post FOR EACH ROW EXECUTE PROCEDURE process_increment_post_forum();


--
-- TOC entry 2206 (class 2620 OID 38031)
-- Name: thread trigger_inc_thread_forum; Type: TRIGGER; Schema: public; Owner: vlad
--

CREATE TRIGGER trigger_inc_thread_forum AFTER INSERT OR DELETE ON thread FOR EACH ROW EXECUTE PROCEDURE process_increment_thread_forum();


--
-- TOC entry 2207 (class 2620 OID 38854)
-- Name: thread_votes trigger_vote; Type: TRIGGER; Schema: public; Owner: vlad
--

CREATE TRIGGER trigger_vote AFTER INSERT OR DELETE OR UPDATE ON thread_votes FOR EACH ROW EXECUTE PROCEDURE process_vote();


--
-- TOC entry 2199 (class 2606 OID 38033)
-- Name: forum forum_user_moderator_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum
  ADD CONSTRAINT forum_user_moderator_fkey FOREIGN KEY (user_moderator) REFERENCES user_account(nickname);


--
-- TOC entry 2200 (class 2606 OID 38038)
-- Name: post post_author_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post
  ADD CONSTRAINT post_author_fkey FOREIGN KEY (author) REFERENCES user_account(nickname);


--
-- TOC entry 2201 (class 2606 OID 38043)
-- Name: thread thread_author_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_author_fkey FOREIGN KEY (author) REFERENCES user_account(nickname);


--
-- TOC entry 2202 (class 2606 OID 38048)
-- Name: thread thread_forum_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_forum_fkey FOREIGN KEY (forum) REFERENCES forum(slug) MATCH FULL;


--
-- TOC entry 2203 (class 2606 OID 38053)
-- Name: thread_votes thread_votes_nickname_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread_votes
  ADD CONSTRAINT thread_votes_nickname_fkey FOREIGN KEY (nickname) REFERENCES user_account(nickname);


-- Completed on 2018-01-06 18:07:47 MSK

--
-- PostgreSQL database dump complete
--

