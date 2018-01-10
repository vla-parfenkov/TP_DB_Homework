
--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.5
-- Dumped by pg_dump version 10.0

-- Started on 2018-01-10 21:32:41 MSK

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
-- TOC entry 2428 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 3 (class 3079 OID 53536)
-- Name: citext; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- TOC entry 2429 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- TOC entry 2 (class 3079 OID 54459)
-- Name: intarray; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS intarray WITH SCHEMA public;


--
-- TOC entry 2430 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION intarray; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION intarray IS 'functions, operators, and index support for 1-D arrays of integers';


SET search_path = public, pg_catalog;

--
-- TOC entry 301 (class 1255 OID 53622)
-- Name: create_path_post(); Type: FUNCTION; Schema: public; Owner: vlad
--

CREATE FUNCTION create_path_post() RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  newpath INT[];

BEGIN
  IF (NEW.parent = 0) THEN
    NEW.path = newpath || NEW.id::INT;
    RETURN NEW;
  ELSE
    newpath = (SELECT path FROM post WHERE id = NEW.parent AND thread = NEW.thread)::INT[];
    IF (array_length(newpath,1) > 0) THEN
      NEW.path = newpath || NEW.id::INT;
      return NEW;
    ELSE
      RAISE  invalid_foreign_key;
    END IF;
  END IF;
END;
$$;


ALTER FUNCTION public.create_path_post() OWNER TO vlad;

--
-- TOC entry 247 (class 1255 OID 53623)
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
-- TOC entry 248 (class 1255 OID 53624)
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
-- TOC entry 188 (class 1259 OID 53625)
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
-- TOC entry 189 (class 1259 OID 53633)
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
-- TOC entry 2431 (class 0 OID 0)
-- Dependencies: 189
-- Name: forum_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE forum_id_seq OWNED BY forum.id;


--
-- TOC entry 197 (class 1259 OID 54454)
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
-- TOC entry 190 (class 1259 OID 53635)
-- Name: post; Type: TABLE; Schema: public; Owner: vlad
--

CREATE TABLE post (
  created timestamp without time zone DEFAULT now(),
  message text,
  isedited boolean DEFAULT false,
  author citext NOT NULL,
  thread integer,
  parent integer DEFAULT 0,
  forum citext,
  id integer DEFAULT nextval('post_id_seq'::regclass) NOT NULL,
  path integer[]
);


ALTER TABLE post OWNER TO vlad;



ALTER TABLE schema_version OWNER TO vlad;

--
-- TOC entry 191 (class 1259 OID 53644)
-- Name: thread; Type: TABLE; Schema: public; Owner: vlad
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
-- TOC entry 192 (class 1259 OID 53651)
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
-- TOC entry 2432 (class 0 OID 0)
-- Dependencies: 192
-- Name: thread_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE thread_id_seq OWNED BY thread.id;


--
-- TOC entry 193 (class 1259 OID 53653)
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
-- TOC entry 194 (class 1259 OID 53659)
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
-- TOC entry 2433 (class 0 OID 0)
-- Dependencies: 194
-- Name: thread_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE thread_votes_id_seq OWNED BY thread_votes.id;


--
-- TOC entry 195 (class 1259 OID 53661)
-- Name: user_account; Type: TABLE; Schema: public; Owner: vlad
--

CREATE TABLE user_account (
  id integer NOT NULL,
  nickname citext COLLATE pg_catalog.ucs_basic NOT NULL,
  email citext NOT NULL,
  fullname character varying(60) NOT NULL,
  about text,
  forums integer[]
);


ALTER TABLE user_account OWNER TO vlad;

--
-- TOC entry 196 (class 1259 OID 53667)
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
-- TOC entry 2434 (class 0 OID 0)
-- Dependencies: 196
-- Name: user_account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE user_account_id_seq OWNED BY user_account.id;


--
-- TOC entry 2239 (class 2604 OID 53675)
-- Name: forum id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum ALTER COLUMN id SET DEFAULT nextval('forum_id_seq'::regclass);


--
-- TOC entry 2245 (class 2604 OID 53676)
-- Name: thread id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread ALTER COLUMN id SET DEFAULT nextval('thread_id_seq'::regclass);


--
-- TOC entry 2246 (class 2604 OID 53677)
-- Name: thread_votes id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread_votes ALTER COLUMN id SET DEFAULT nextval('thread_votes_id_seq'::regclass);


--
-- TOC entry 2247 (class 2604 OID 53678)
-- Name: user_account id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account ALTER COLUMN id SET DEFAULT nextval('user_account_id_seq'::regclass);




SELECT pg_catalog.setval('forum_id_seq', 1, true);


--
-- TOC entry 2436 (class 0 OID 0)
-- Dependencies: 197
-- Name: post_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vlad
--

SELECT pg_catalog.setval('post_id_seq', 1, true);


--
-- TOC entry 2437 (class 0 OID 0)
-- Dependencies: 192
-- Name: thread_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vlad
--

SELECT pg_catalog.setval('thread_id_seq', 1, true);


--
-- TOC entry 2438 (class 0 OID 0)
-- Dependencies: 194
-- Name: thread_votes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vlad
--

SELECT pg_catalog.setval('thread_votes_id_seq', 1, true);


--
-- TOC entry 2439 (class 0 OID 0)
-- Dependencies: 196
-- Name: user_account_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vlad
--

SELECT pg_catalog.setval('user_account_id_seq', 1, true);


--
-- TOC entry 2252 (class 2606 OID 53680)
-- Name: forum forum_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum
  ADD CONSTRAINT forum_pkey PRIMARY KEY (id);


--
-- TOC entry 2254 (class 2606 OID 53682)
-- Name: forum forum_slug_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum
  ADD CONSTRAINT forum_slug_key UNIQUE (slug);


--
-- TOC entry 2259 (class 2606 OID 54438)
-- Name: post post_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post
  ADD CONSTRAINT post_pkey PRIMARY KEY (id);




--
-- TOC entry 2268 (class 2606 OID 53686)
-- Name: thread thread_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_pkey PRIMARY KEY (id);


--
-- TOC entry 2270 (class 2606 OID 53688)
-- Name: thread thread_slug_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_slug_key UNIQUE (slug);


--
-- TOC entry 2272 (class 2606 OID 53690)
-- Name: thread_votes thread_votes_nickname_thread_uk; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread_votes
  ADD CONSTRAINT thread_votes_nickname_thread_uk UNIQUE (thread, nickname);


--
-- TOC entry 2274 (class 2606 OID 53692)
-- Name: thread_votes thread_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread_votes
  ADD CONSTRAINT thread_votes_pkey PRIMARY KEY (id);


--
-- TOC entry 2276 (class 2606 OID 53694)
-- Name: user_account user_account_email_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account
  ADD CONSTRAINT user_account_email_key UNIQUE (email);


--
-- TOC entry 2280 (class 2606 OID 53696)
-- Name: user_account user_account_nickname_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account
  ADD CONSTRAINT user_account_nickname_key UNIQUE (nickname);


--
-- TOC entry 2282 (class 2606 OID 53698)
-- Name: user_account user_account_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account
  ADD CONSTRAINT user_account_pkey PRIMARY KEY (id);


--
-- TOC entry 2255 (class 1259 OID 54439)
-- Name: post_id_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_id_index ON post USING btree (id);


--
-- TOC entry 2256 (class 1259 OID 53703)
-- Name: post_lower_forum_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_lower_forum_index ON post USING btree (lower((forum)::text));


--
-- TOC entry 2257 (class 1259 OID 54458)
-- Name: post_path_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_path_index ON post USING btree (path);


--
-- TOC entry 2260 (class 1259 OID 54577)
-- Name: post_subpath_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_subpath_index ON post USING btree (subarray(path, 0, 1));


--
-- TOC entry 2261 (class 1259 OID 54457)
-- Name: post_thread_created_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_thread_created_index ON post USING btree (thread, created);


--
-- TOC entry 2262 (class 1259 OID 53707)
-- Name: post_thread_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_thread_index ON post USING btree (thread);



--
-- TOC entry 2263 (class 1259 OID 53709)
-- Name: thread_id_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX thread_id_index ON thread USING btree (id);


--
-- TOC entry 2264 (class 1259 OID 53710)
-- Name: thread_lower_forum_created_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX thread_lower_forum_created_index ON thread USING btree (lower((forum)::text), created);


--
-- TOC entry 2265 (class 1259 OID 53711)
-- Name: thread_lower_forum_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX thread_lower_forum_index ON thread USING btree (lower((forum)::text));


--
-- TOC entry 2266 (class 1259 OID 53712)
-- Name: thread_lower_slug_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX thread_lower_slug_index ON thread USING btree (lower((slug)::text));


--
-- TOC entry 2277 (class 1259 OID 53713)
-- Name: user_account_lower_email_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX user_account_lower_email_index ON user_account USING btree (lower((email)::text));


--
-- TOC entry 2278 (class 1259 OID 53714)
-- Name: user_account_lower_nickname_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX user_account_lower_nickname_index ON user_account USING btree (lower((nickname)::text));


--
-- TOC entry 2291 (class 2620 OID 53718)
-- Name: post trigger_create_path_post; Type: TRIGGER; Schema: public; Owner: vlad
--

CREATE TRIGGER trigger_create_path_post BEFORE INSERT ON post FOR EACH ROW EXECUTE PROCEDURE create_path_post();


--
-- TOC entry 2292 (class 2620 OID 53719)
-- Name: thread trigger_inc_thread_forum; Type: TRIGGER; Schema: public; Owner: vlad
--

CREATE TRIGGER trigger_inc_thread_forum AFTER INSERT OR DELETE ON thread FOR EACH ROW EXECUTE PROCEDURE process_increment_thread_forum();


--
-- TOC entry 2293 (class 2620 OID 53720)
-- Name: thread_votes trigger_vote; Type: TRIGGER; Schema: public; Owner: vlad
--

CREATE TRIGGER trigger_vote AFTER INSERT OR DELETE OR UPDATE ON thread_votes FOR EACH ROW EXECUTE PROCEDURE process_vote();


--
-- TOC entry 2283 (class 2606 OID 53721)
-- Name: forum forum_user_moderator_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum
  ADD CONSTRAINT forum_user_moderator_fkey FOREIGN KEY (user_moderator) REFERENCES user_account(nickname);


--
-- TOC entry 2284 (class 2606 OID 53726)
-- Name: post post_author_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post
  ADD CONSTRAINT post_author_fkey FOREIGN KEY (author) REFERENCES user_account(nickname);


--
-- TOC entry 2285 (class 2606 OID 53731)
-- Name: post post_forum_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post
  ADD CONSTRAINT post_forum_fkey FOREIGN KEY (forum) REFERENCES forum(slug) MATCH FULL;


--
-- TOC entry 2286 (class 2606 OID 53736)
-- Name: post post_thread_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post
  ADD CONSTRAINT post_thread_fkey FOREIGN KEY (thread) REFERENCES thread(id) MATCH FULL;


--
-- TOC entry 2287 (class 2606 OID 53741)
-- Name: thread thread_author_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_author_fkey FOREIGN KEY (author) REFERENCES user_account(nickname);


--
-- TOC entry 2288 (class 2606 OID 53746)
-- Name: thread thread_forum_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_forum_fkey FOREIGN KEY (forum) REFERENCES forum(slug) MATCH FULL;


--
-- TOC entry 2289 (class 2606 OID 53751)
-- Name: thread_votes thread_votes_nickname_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread_votes
  ADD CONSTRAINT thread_votes_nickname_fkey FOREIGN KEY (nickname) REFERENCES user_account(nickname);


--
-- TOC entry 2290 (class 2606 OID 53756)
-- Name: thread_votes thread_votes_thread_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread_votes
  ADD CONSTRAINT thread_votes_thread_fkey FOREIGN KEY (thread) REFERENCES thread(id);


-- Completed on 2018-01-10 21:32:45 MSK

--
-- PostgreSQL database dump complete
--

