--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.5
-- Dumped by pg_dump version 10.0

-- Started on 2018-01-11 22:52:58 MSK

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
-- TOC entry 2418 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 3 (class 3079 OID 58184)
-- Name: citext; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- TOC entry 2419 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- TOC entry 2 (class 3079 OID 58268)
-- Name: intarray; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS intarray WITH SCHEMA public;


--
-- TOC entry 2420 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION intarray; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION intarray IS 'functions, operators, and index support for 1-D arrays of integers';


SET search_path = public, pg_catalog;

--
-- TOC entry 300 (class 1255 OID 58642)
-- Name: create_path(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: vlad
--

CREATE FUNCTION create_path(parent_id integer, thread_id integer, post_id integer) RETURNS integer[]
LANGUAGE plpgsql
AS $$
DECLARE
  newpath INT[];
BEGIN
  IF (parent_id = 0) THEN
    RETURN ARRAY[post_id];
  ELSE
    newpath := (SELECT path FROM post WHERE id = parent_id AND thread = thread_id)::INT[];
    IF (array_length(newpath,1) > 0) THEN
      return newpath || post_id;
    ELSE
      RAISE  invalid_foreign_key;
    END IF;
  END IF;
END;
$$;


ALTER FUNCTION public.create_path(parent_id integer, thread_id integer, post_id integer) OWNER TO vlad;

--
-- TOC entry 298 (class 1255 OID 58387)
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
-- TOC entry 299 (class 1255 OID 58388)
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
-- TOC entry 188 (class 1259 OID 58389)
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
-- TOC entry 189 (class 1259 OID 58397)
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
-- TOC entry 2421 (class 0 OID 0)
-- Dependencies: 189
-- Name: forum_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE forum_id_seq OWNED BY forum.id;


--
-- TOC entry 190 (class 1259 OID 58399)
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
-- TOC entry 191 (class 1259 OID 58401)
-- Name: post; Type: TABLE; Schema: public; Owner: vlad
--

CREATE TABLE post (
  created timestamp without time zone DEFAULT now(),
  message text,
  isedited boolean DEFAULT false,
  author citext NOT NULL,
  thread integer,
  parent integer DEFAULT 0,
  id integer DEFAULT nextval('post_id_seq'::regclass) NOT NULL,
  path integer[],
  forum citext
);


ALTER TABLE post OWNER TO vlad;



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
-- TOC entry 193 (class 1259 OID 58418)
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
-- TOC entry 2422 (class 0 OID 0)
-- Dependencies: 193
-- Name: thread_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE thread_id_seq OWNED BY thread.id;


--
-- TOC entry 194 (class 1259 OID 58420)
-- Name: thread_votes; Type: TABLE; Schema: public; Owner: vlad
--

CREATE TABLE thread_votes (
  thread integer NOT NULL,
  voice smallint NOT NULL,
  user_id integer NOT NULL
);


ALTER TABLE thread_votes OWNER TO vlad;

--
-- TOC entry 195 (class 1259 OID 58423)
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
-- TOC entry 196 (class 1259 OID 58429)
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
-- TOC entry 2423 (class 0 OID 0)
-- Dependencies: 196
-- Name: user_account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE user_account_id_seq OWNED BY user_account.id;


--
-- TOC entry 2236 (class 2604 OID 58431)
-- Name: forum id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum ALTER COLUMN id SET DEFAULT nextval('forum_id_seq'::regclass);


--
-- TOC entry 2242 (class 2604 OID 58432)
-- Name: thread id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread ALTER COLUMN id SET DEFAULT nextval('thread_id_seq'::regclass);


--
-- TOC entry 2243 (class 2604 OID 58433)
-- Name: user_account id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account ALTER COLUMN id SET DEFAULT nextval('user_account_id_seq'::regclass);


--
-- TOC entry 2248 (class 2606 OID 58435)
-- Name: forum forum_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum
  ADD CONSTRAINT forum_pkey PRIMARY KEY (id);


--
-- TOC entry 2250 (class 2606 OID 58437)
-- Name: forum forum_slug_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum
  ADD CONSTRAINT forum_slug_key UNIQUE (slug);


--
-- TOC entry 2254 (class 2606 OID 58439)
-- Name: post post_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post
  ADD CONSTRAINT post_pkey PRIMARY KEY (id);




--
-- TOC entry 2264 (class 2606 OID 58441)
-- Name: thread thread_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_pkey PRIMARY KEY (id);


--
-- TOC entry 2266 (class 2606 OID 58443)
-- Name: thread thread_slug_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_slug_key UNIQUE (slug);


--
-- TOC entry 2269 (class 2606 OID 58445)
-- Name: thread_votes thread_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread_votes
  ADD CONSTRAINT thread_votes_pkey PRIMARY KEY (thread, user_id);


--
-- TOC entry 2271 (class 2606 OID 58447)
-- Name: user_account user_account_email_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account
  ADD CONSTRAINT user_account_email_key UNIQUE (email);


--
-- TOC entry 2276 (class 2606 OID 58449)
-- Name: user_account user_account_nickname_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account
  ADD CONSTRAINT user_account_nickname_key UNIQUE (nickname);


--
-- TOC entry 2278 (class 2606 OID 58451)
-- Name: user_account user_account_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account
  ADD CONSTRAINT user_account_pkey PRIMARY KEY (id);


--
-- TOC entry 2251 (class 1259 OID 58452)
-- Name: post_id_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_id_index ON post USING btree (id);


--
-- TOC entry 2252 (class 1259 OID 58453)
-- Name: post_path_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_path_index ON post USING btree (path);


--
-- TOC entry 2255 (class 1259 OID 58454)
-- Name: post_subpath_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_subpath_index ON post USING btree (subarray(path, 0, 1));


--
-- TOC entry 2256 (class 1259 OID 58455)
-- Name: post_thread_created_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_thread_created_index ON post USING btree (thread, created);


--
-- TOC entry 2257 (class 1259 OID 58616)
-- Name: post_thread_id_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_thread_id_index ON post USING btree (thread, id);


--
-- TOC entry 2258 (class 1259 OID 58456)
-- Name: post_thread_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_thread_index ON post USING btree (thread);


--
-- TOC entry 2259 (class 1259 OID 58457)
-- Name: thread_id_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX thread_id_index ON thread USING btree (id);


--
-- TOC entry 2260 (class 1259 OID 58458)
-- Name: thread_lower_forum_created_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX thread_lower_forum_created_index ON thread USING btree (lower((forum)::text), created);


--
-- TOC entry 2261 (class 1259 OID 58459)
-- Name: thread_lower_forum_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX thread_lower_forum_index ON thread USING btree (lower((forum)::text));


--
-- TOC entry 2262 (class 1259 OID 58460)
-- Name: thread_lower_slug_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX thread_lower_slug_index ON thread USING btree (lower((slug)::text));


--
-- TOC entry 2267 (class 1259 OID 58461)
-- Name: thread_votes_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX thread_votes_index ON thread_votes USING btree (thread, user_id);


--
-- TOC entry 2272 (class 1259 OID 58877)
-- Name: user_account_forum_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX user_account_forum_index ON user_account USING gin (forums);


--
-- TOC entry 2273 (class 1259 OID 58462)
-- Name: user_account_lower_email_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX user_account_lower_email_index ON user_account USING btree (lower((email)::text));


--
-- TOC entry 2274 (class 1259 OID 58463)
-- Name: user_account_lower_nickname_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX user_account_lower_nickname_index ON user_account USING btree (lower((nickname)::text));


--
-- TOC entry 2283 (class 2620 OID 58465)
-- Name: thread trigger_inc_thread_forum; Type: TRIGGER; Schema: public; Owner: vlad
--

CREATE TRIGGER trigger_inc_thread_forum AFTER INSERT OR DELETE ON thread FOR EACH ROW EXECUTE PROCEDURE process_increment_thread_forum();


--
-- TOC entry 2284 (class 2620 OID 58466)
-- Name: thread_votes trigger_vote; Type: TRIGGER; Schema: public; Owner: vlad
--

CREATE TRIGGER trigger_vote AFTER INSERT OR DELETE OR UPDATE ON thread_votes FOR EACH ROW EXECUTE PROCEDURE process_vote();


--
-- TOC entry 2279 (class 2606 OID 58467)
-- Name: forum forum_user_moderator_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum
  ADD CONSTRAINT forum_user_moderator_fkey FOREIGN KEY (user_moderator) REFERENCES user_account(nickname);


--
-- TOC entry 2280 (class 2606 OID 58472)
-- Name: post post_author_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post
  ADD CONSTRAINT post_author_fkey FOREIGN KEY (author) REFERENCES user_account(nickname);


--
-- TOC entry 2281 (class 2606 OID 58477)
-- Name: thread thread_author_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_author_fkey FOREIGN KEY (author) REFERENCES user_account(nickname);


--
-- TOC entry 2282 (class 2606 OID 58482)
-- Name: thread thread_forum_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_forum_fkey FOREIGN KEY (forum) REFERENCES forum(slug) MATCH FULL;


-- Completed on 2018-01-11 22:52:58 MSK

--
-- PostgreSQL database dump complete
--

