
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.5
-- Dumped by pg_dump version 10.0

-- Started on 2018-01-08 16:25:29 MSK


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
-- TOC entry 2508 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 3 (class 3079 OID 41171)
-- Name: citext; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- TOC entry 2509 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- TOC entry 2 (class 3079 OID 41415)
-- Name: ltree; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS ltree WITH SCHEMA public;


--
-- TOC entry 2510 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION ltree; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION ltree IS 'data type for hierarchical tree-like structures';


SET search_path = public, pg_catalog;

--
-- TOC entry 321 (class 1255 OID 42063)
-- Name: add_post_author_to_forum(); Type: FUNCTION; Schema: public; Owner: vlad
--

CREATE FUNCTION add_post_author_to_forum() RETURNS trigger
LANGUAGE plpgsql
AS $$

BEGIN
  INSERT INTO users_forum (forum,user_nickname) values(NEW.forum, NEW.author);
  RETURN NEW;
  EXCEPTION
  WHEN unique_violation THEN
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.add_post_author_to_forum() OWNER TO vlad;

--
-- TOC entry 322 (class 1255 OID 42061)
-- Name: add_thread_author_to_forum(); Type: FUNCTION; Schema: public; Owner: vlad
--

CREATE FUNCTION add_thread_author_to_forum() RETURNS trigger
LANGUAGE plpgsql
AS $$

BEGIN
  INSERT INTO users_forum (forum,user_nickname) values(NEW.forum, NEW.author);
  RETURN NEW;
  EXCEPTION
  WHEN unique_violation THEN
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.add_thread_author_to_forum() OWNER TO vlad;

--
-- TOC entry 320 (class 1255 OID 41255)
-- Name: create_path_post(); Type: FUNCTION; Schema: public; Owner: vlad
--

CREATE FUNCTION create_path_post() RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  newpath ltree;

BEGIN
  IF (NEW.parent::BIGINT = 0) THEN
    NEW.path = NEW.id::text;
    RETURN NEW;
  ELSE
    newpath = (SELECT path FROM post WHERE id = NEW.parent AND thread = NEW.thread)::ltree;
    IF (nlevel(newpath) > 0) THEN
      NEW.path = newpath || NEW.id::text;
      return NEW;
    ELSE
      RAISE  invalid_foreign_key;
    END IF;
  END IF;
END;
$$;


ALTER FUNCTION public.create_path_post() OWNER TO vlad;

--
-- TOC entry 323 (class 1255 OID 43114)
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
-- TOC entry 248 (class 1255 OID 41257)
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
-- TOC entry 249 (class 1255 OID 41258)
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
-- TOC entry 188 (class 1259 OID 41259)
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
-- TOC entry 189 (class 1259 OID 41267)
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
-- TOC entry 2511 (class 0 OID 0)
-- Dependencies: 189
-- Name: forum_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE forum_id_seq OWNED BY forum.id;


--
-- TOC entry 190 (class 1259 OID 41269)
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
  path ltree
);


ALTER TABLE post OWNER TO vlad;

--
-- TOC entry 191 (class 1259 OID 41278)
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
-- TOC entry 2512 (class 0 OID 0)
-- Dependencies: 191
-- Name: post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE post_id_seq OWNED BY post.id;






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
-- TOC entry 193 (class 1259 OID 41287)
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
-- TOC entry 2513 (class 0 OID 0)
-- Dependencies: 193
-- Name: thread_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE thread_id_seq OWNED BY thread.id;


--
-- TOC entry 194 (class 1259 OID 41289)
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
-- TOC entry 195 (class 1259 OID 41295)
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
-- TOC entry 2514 (class 0 OID 0)
-- Dependencies: 195
-- Name: thread_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE thread_votes_id_seq OWNED BY thread_votes.id;


--
-- TOC entry 197 (class 1259 OID 43043)
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
-- TOC entry 198 (class 1259 OID 43049)
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
-- TOC entry 2515 (class 0 OID 0)
-- Dependencies: 198
-- Name: user_account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE user_account_id_seq OWNED BY user_account.id;


--
-- TOC entry 196 (class 1259 OID 42041)
-- Name: users_forum; Type: TABLE; Schema: public; Owner: vlad
--

CREATE TABLE users_forum (
  forum citext NOT NULL,
  user_nickname citext NOT NULL
);


ALTER TABLE users_forum OWNER TO vlad;

--
-- TOC entry 2304 (class 2604 OID 41305)
-- Name: forum id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum ALTER COLUMN id SET DEFAULT nextval('forum_id_seq'::regclass);


--
-- TOC entry 2308 (class 2604 OID 41306)
-- Name: post id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post ALTER COLUMN id SET DEFAULT nextval('post_id_seq'::regclass);


--
-- TOC entry 2310 (class 2604 OID 41307)
-- Name: thread id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread ALTER COLUMN id SET DEFAULT nextval('thread_id_seq'::regclass);


--
-- TOC entry 2311 (class 2604 OID 41308)
-- Name: thread_votes id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread_votes ALTER COLUMN id SET DEFAULT nextval('thread_votes_id_seq'::regclass);


--
-- TOC entry 2312 (class 2604 OID 43051)
-- Name: user_account id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account ALTER COLUMN id SET DEFAULT nextval('user_account_id_seq'::regclass);




SELECT pg_catalog.setval('forum_id_seq', 1, true);


--
-- TOC entry 2517 (class 0 OID 0)
-- Dependencies: 191
-- Name: post_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vlad
--

SELECT pg_catalog.setval('post_id_seq', 1, true);


--
-- TOC entry 2518 (class 0 OID 0)
-- Dependencies: 193
-- Name: thread_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vlad
--

SELECT pg_catalog.setval('thread_id_seq', 1, true);


--
-- TOC entry 2519 (class 0 OID 0)
-- Dependencies: 195
-- Name: thread_votes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vlad
--

SELECT pg_catalog.setval('thread_votes_id_seq', 1, true);


--
-- TOC entry 2520 (class 0 OID 0)
-- Dependencies: 198
-- Name: user_account_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vlad
--

SELECT pg_catalog.setval('user_account_id_seq', 1, true);


--
-- TOC entry 2319 (class 2606 OID 41311)
-- Name: forum forum_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum
  ADD CONSTRAINT forum_pkey PRIMARY KEY (id);


--
-- TOC entry 2321 (class 2606 OID 41313)
-- Name: forum forum_slug_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum
  ADD CONSTRAINT forum_slug_key UNIQUE (slug);


--
-- TOC entry 2328 (class 2606 OID 41315)
-- Name: post post_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post
  ADD CONSTRAINT post_pkey PRIMARY KEY (id);


--
-- TOC entry 2337 (class 2606 OID 41317)
-- Name: thread thread_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_pkey PRIMARY KEY (id);


--
-- TOC entry 2339 (class 2606 OID 41319)
-- Name: thread thread_slug_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_slug_key UNIQUE (slug);


--
-- TOC entry 2342 (class 2606 OID 41321)
-- Name: thread_votes thread_votes_nickname_thread_uk; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread_votes
  ADD CONSTRAINT thread_votes_nickname_thread_uk UNIQUE (thread, nickname);


--
-- TOC entry 2344 (class 2606 OID 41323)
-- Name: thread_votes thread_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread_votes
  ADD CONSTRAINT thread_votes_pkey PRIMARY KEY (id);


--
-- TOC entry 2349 (class 2606 OID 43053)
-- Name: user_account user_account_email_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account
  ADD CONSTRAINT user_account_email_key UNIQUE (email);


--
-- TOC entry 2353 (class 2606 OID 43055)
-- Name: user_account user_account_nickname_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account
  ADD CONSTRAINT user_account_nickname_key UNIQUE (nickname);


--
-- TOC entry 2355 (class 2606 OID 43057)
-- Name: user_account user_account_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account
  ADD CONSTRAINT user_account_pkey PRIMARY KEY (id);


--
-- TOC entry 2347 (class 2606 OID 42048)
-- Name: users_forum users_forum_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY users_forum
  ADD CONSTRAINT users_forum_pkey PRIMARY KEY (forum, user_nickname);


--
-- TOC entry 2316 (class 1259 OID 41330)
-- Name: forum_id_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX forum_id_index ON forum USING btree (id);


--
-- TOC entry 2317 (class 1259 OID 41331)
-- Name: forum_lower_slug_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX forum_lower_slug_index ON forum USING btree (lower((slug)::text));


--
-- TOC entry 2322 (class 1259 OID 41332)
-- Name: post_created_id_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_created_id_index ON post USING btree (created, id);


--
-- TOC entry 2323 (class 1259 OID 41333)
-- Name: post_id_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_id_index ON post USING btree (id);


--
-- TOC entry 2324 (class 1259 OID 41334)
-- Name: post_lower_forum_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_lower_forum_index ON post USING btree (lower((forum)::text));


--
-- TOC entry 2325 (class 1259 OID 41590)
-- Name: post_parent_thread_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_parent_thread_index ON post USING btree (parent, thread);


--
-- TOC entry 2326 (class 1259 OID 42251)
-- Name: post_path_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_path_index ON post USING btree (path);


--
-- TOC entry 2329 (class 1259 OID 42252)
-- Name: post_subpath_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_subpath_index ON post USING btree (subpath(path, 0, 1));


--
-- TOC entry 2330 (class 1259 OID 41336)
-- Name: post_thread_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_thread_index ON post USING btree (thread);


--
-- TOC entry 2331 (class 1259 OID 42253)
-- Name: post_thread_path_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_thread_path_index ON post USING btree (thread, path);


--
-- TOC entry 2315 (class 1259 OID 41170)
-- Name: schema_version_s_idx; Type: INDEX; Schema: public; Owner: vlad
--



CREATE INDEX thread_id_index ON thread USING btree (id);


--
-- TOC entry 2333 (class 1259 OID 41338)
-- Name: thread_lower_forum_created_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX thread_lower_forum_created_index ON thread USING btree (lower((forum)::text), created);


--
-- TOC entry 2334 (class 1259 OID 41339)
-- Name: thread_lower_forum_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX thread_lower_forum_index ON thread USING btree (lower((forum)::text));


--
-- TOC entry 2335 (class 1259 OID 41340)
-- Name: thread_lower_slug_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX thread_lower_slug_index ON thread USING btree (lower((slug)::text));


--
-- TOC entry 2340 (class 1259 OID 41341)
-- Name: thread_votes_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX thread_votes_index ON thread_votes USING btree (lower((nickname)::text), thread);


--
-- TOC entry 2350 (class 1259 OID 43058)
-- Name: user_account_lower_email_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX user_account_lower_email_index ON user_account USING btree (lower((email)::text));


--
-- TOC entry 2351 (class 1259 OID 43059)
-- Name: user_account_lower_nickname_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX user_account_lower_nickname_index ON user_account USING btree (lower((nickname)::text));


--
-- TOC entry 2345 (class 1259 OID 42136)
-- Name: users_forum_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX users_forum_index ON users_forum USING btree (lower((user_nickname)::text) COLLATE ucs_basic, lower((forum)::text) COLLATE ucs_basic);


--
-- TOC entry 2367 (class 2620 OID 42064)
-- Name: post trigger_add_post; Type: TRIGGER; Schema: public; Owner: vlad
--

CREATE TRIGGER trigger_add_post AFTER INSERT ON post FOR EACH ROW EXECUTE PROCEDURE add_post_author_to_forum();


--
-- TOC entry 2370 (class 2620 OID 42062)
-- Name: thread trigger_add_thread; Type: TRIGGER; Schema: public; Owner: vlad
--

CREATE TRIGGER trigger_add_thread AFTER INSERT ON thread FOR EACH ROW EXECUTE PROCEDURE add_thread_author_to_forum();


--
-- TOC entry 2366 (class 2620 OID 41344)
-- Name: post trigger_create_path_post; Type: TRIGGER; Schema: public; Owner: vlad
--

CREATE TRIGGER trigger_create_path_post BEFORE INSERT ON post FOR EACH ROW EXECUTE PROCEDURE create_path_post();


--
-- TOC entry 2368 (class 2620 OID 43115)
-- Name: post trigger_inc_post_forum; Type: TRIGGER; Schema: public; Owner: vlad
--

CREATE TRIGGER trigger_inc_post_forum AFTER INSERT OR DELETE ON post FOR EACH ROW EXECUTE PROCEDURE process_increment_post_forum();


--
-- TOC entry 2369 (class 2620 OID 41346)
-- Name: thread trigger_inc_thread_forum; Type: TRIGGER; Schema: public; Owner: vlad
--

CREATE TRIGGER trigger_inc_thread_forum AFTER INSERT OR DELETE ON thread FOR EACH ROW EXECUTE PROCEDURE process_increment_thread_forum();


--
-- TOC entry 2371 (class 2620 OID 41347)
-- Name: thread_votes trigger_vote; Type: TRIGGER; Schema: public; Owner: vlad
--

CREATE TRIGGER trigger_vote AFTER INSERT OR DELETE OR UPDATE ON thread_votes FOR EACH ROW EXECUTE PROCEDURE process_vote();


--
-- TOC entry 2356 (class 2606 OID 43060)
-- Name: forum forum_user_moderator_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum
  ADD CONSTRAINT forum_user_moderator_fkey FOREIGN KEY (user_moderator) REFERENCES user_account(nickname);


--
-- TOC entry 2357 (class 2606 OID 43065)
-- Name: post post_author_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post
  ADD CONSTRAINT post_author_fkey FOREIGN KEY (author) REFERENCES user_account(nickname);


--
-- TOC entry 2358 (class 2606 OID 43090)
-- Name: post post_forum_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post
  ADD CONSTRAINT post_forum_fkey FOREIGN KEY (forum) REFERENCES forum(slug) MATCH FULL;


--
-- TOC entry 2359 (class 2606 OID 43095)
-- Name: post post_thread_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post
  ADD CONSTRAINT post_thread_fkey FOREIGN KEY (thread) REFERENCES thread(id) MATCH FULL;


--
-- TOC entry 2361 (class 2606 OID 43070)
-- Name: thread thread_author_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_author_fkey FOREIGN KEY (author) REFERENCES user_account(nickname);


--
-- TOC entry 2360 (class 2606 OID 41363)
-- Name: thread thread_forum_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_forum_fkey FOREIGN KEY (forum) REFERENCES forum(slug) MATCH FULL;


--
-- TOC entry 2362 (class 2606 OID 43075)
-- Name: thread_votes thread_votes_nickname_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread_votes
  ADD CONSTRAINT thread_votes_nickname_fkey FOREIGN KEY (nickname) REFERENCES user_account(nickname);


--
-- TOC entry 2363 (class 2606 OID 43085)
-- Name: thread_votes thread_votes_thread_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread_votes
  ADD CONSTRAINT thread_votes_thread_fkey FOREIGN KEY (thread) REFERENCES thread(id);


--
-- TOC entry 2364 (class 2606 OID 42049)
-- Name: users_forum users_forum_forum_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY users_forum
  ADD CONSTRAINT users_forum_forum_fkey FOREIGN KEY (forum) REFERENCES forum(slug);


--
-- TOC entry 2365 (class 2606 OID 43080)
-- Name: users_forum users_forum_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY users_forum
  ADD CONSTRAINT users_forum_user_fkey FOREIGN KEY (user_nickname) REFERENCES user_account(nickname);


--
-- TOC entry 2507 (class 0 OID 0)
-- Dependencies: 8
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--
