--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.5
-- Dumped by pg_dump version 10.0

-- Started on 2017-11-26 13:45:07 MSK

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
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
-- TOC entry 2316 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 2 (class 3079 OID 35501)
-- Name: citext; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- TOC entry 2317 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


SET search_path = public, pg_catalog;

--
-- TOC entry 249 (class 1255 OID 36860)
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
-- TOC entry 246 (class 1255 OID 35767)
-- Name: process_add_post(); Type: FUNCTION; Schema: public; Owner: vlad
--

CREATE FUNCTION process_add_post() RETURNS trigger
LANGUAGE plpgsql
AS $$

BEGIN

  PERFORM setval('post_id_seq'::regclass, NEW.id);
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.process_add_post() OWNER TO vlad;

--
-- TOC entry 247 (class 1255 OID 36154)
-- Name: process_increment_post_forum(); Type: FUNCTION; Schema: public; Owner: vlad
--

CREATE FUNCTION process_increment_post_forum() RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    UPDATE forum SET posts = ((SELECT posts FROM forum WHERE lower(slug) = lower(OLD.forum)) - 1)
    WHERE lower(slug) = lower(OLD.forum);
    RETURN OLD;
  ELSIF (TG_OP = 'INSERT') THEN
    UPDATE forum SET posts = ((SELECT posts FROM forum WHERE lower(slug) = lower(NEW.forum))::INTEGER + 1)
    WHERE lower(slug) = lower(NEW.forum);
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$$;


ALTER FUNCTION public.process_increment_post_forum() OWNER TO vlad;

--
-- TOC entry 248 (class 1255 OID 36156)
-- Name: process_increment_thread_forum(); Type: FUNCTION; Schema: public; Owner: vlad
--

CREATE FUNCTION process_increment_thread_forum() RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    UPDATE forum SET threads = ((SELECT threads FROM forum WHERE lower(slug) = lower(OLD.forum)) - 1)
    WHERE lower(slug) = lower(OLD.forum);
    RETURN OLD;
  ELSIF (TG_OP = 'INSERT') THEN
    UPDATE forum SET threads = ((SELECT threads FROM forum WHERE lower(slug) = lower(NEW.forum))::INTEGER + 1)
    WHERE lower(slug) = lower(NEW.forum);
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
$$;


ALTER FUNCTION public.process_increment_thread_forum() OWNER TO vlad;

--
-- TOC entry 245 (class 1255 OID 35698)
-- Name: process_vote(); Type: FUNCTION; Schema: public; Owner: vlad
--

CREATE FUNCTION process_vote() RETURNS trigger
LANGUAGE plpgsql
AS $$

BEGIN
  IF (TG_OP = 'DELETE') THEN
    UPDATE thread
    SET votes = (SELECT sum(voice) FROM thread_votes WHERE thread_votes.thread = OLD.thread)::INTEGER
    WHERE thread.id = OLD.thread;
    RETURN OLD;
  ELSIF (TG_OP = 'UPDATE') THEN
    UPDATE thread
    SET votes = (SELECT sum(voice) FROM thread_votes WHERE thread_votes.thread = NEW.thread)::INTEGER
    WHERE thread.id = NEW.thread;
    RETURN NEW;
  ELSIF (TG_OP = 'INSERT') THEN
    UPDATE thread
    SET votes = (SELECT sum(voice) FROM thread_votes WHERE thread_votes.thread = NEW.thread)::INTEGER
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
-- TOC entry 192 (class 1259 OID 36519)
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
-- TOC entry 193 (class 1259 OID 36527)
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
-- TOC entry 2318 (class 0 OID 0)
-- Dependencies: 193
-- Name: forum_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE forum_id_seq OWNED BY forum.id;


--
-- TOC entry 186 (class 1259 OID 35595)
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
-- TOC entry 187 (class 1259 OID 35604)
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
-- TOC entry 2319 (class 0 OID 0)
-- Dependencies: 187
-- Name: post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE post_id_seq OWNED BY post.id;


--
-- TOC entry 194 (class 1259 OID 36529)
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
-- TOC entry 195 (class 1259 OID 36536)
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
-- TOC entry 2320 (class 0 OID 0)
-- Dependencies: 195
-- Name: thread_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE thread_id_seq OWNED BY thread.id;


--
-- TOC entry 191 (class 1259 OID 35677)
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
-- TOC entry 190 (class 1259 OID 35675)
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
-- TOC entry 2321 (class 0 OID 0)
-- Dependencies: 190
-- Name: thread_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE thread_votes_id_seq OWNED BY thread_votes.id;


--
-- TOC entry 188 (class 1259 OID 35615)
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
-- TOC entry 189 (class 1259 OID 35621)
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
-- TOC entry 2322 (class 0 OID 0)
-- Dependencies: 189
-- Name: user_account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE user_account_id_seq OWNED BY user_account.id;


--
-- TOC entry 2160 (class 2604 OID 36538)
-- Name: forum id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum ALTER COLUMN id SET DEFAULT nextval('forum_id_seq'::regclass);


--
-- TOC entry 2155 (class 2604 OID 36539)
-- Name: post id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post ALTER COLUMN id SET DEFAULT nextval('post_id_seq'::regclass);


--
-- TOC entry 2162 (class 2604 OID 36540)
-- Name: thread id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread ALTER COLUMN id SET DEFAULT nextval('thread_id_seq'::regclass);


--
-- TOC entry 2157 (class 2604 OID 35680)
-- Name: thread_votes id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread_votes ALTER COLUMN id SET DEFAULT nextval('thread_votes_id_seq'::regclass);


--
-- TOC entry 2156 (class 2604 OID 36541)
-- Name: user_account id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account ALTER COLUMN id SET DEFAULT nextval('user_account_id_seq'::regclass);


--
-- TOC entry 2176 (class 2606 OID 36543)
-- Name: forum forum_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum
  ADD CONSTRAINT forum_pkey PRIMARY KEY (id);


--
-- TOC entry 2178 (class 2606 OID 36545)
-- Name: forum forum_slug_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum
  ADD CONSTRAINT forum_slug_key UNIQUE (slug);


--
-- TOC entry 2164 (class 2606 OID 35632)
-- Name: post post_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post
  ADD CONSTRAINT post_pkey PRIMARY KEY (id);


--
-- TOC entry 2180 (class 2606 OID 36547)
-- Name: thread thread_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_pkey PRIMARY KEY (id);


--
-- TOC entry 2182 (class 2606 OID 36549)
-- Name: thread thread_slug_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_slug_key UNIQUE (slug);


--
-- TOC entry 2172 (class 2606 OID 35697)
-- Name: thread_votes thread_votes_nickname_thread_uk; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread_votes
  ADD CONSTRAINT thread_votes_nickname_thread_uk UNIQUE (thread, nickname);


--
-- TOC entry 2174 (class 2606 OID 35685)
-- Name: thread_votes thread_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread_votes
  ADD CONSTRAINT thread_votes_pkey PRIMARY KEY (id);


--
-- TOC entry 2166 (class 2606 OID 35640)
-- Name: user_account user_account_email_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account
  ADD CONSTRAINT user_account_email_key UNIQUE (email);


--
-- TOC entry 2168 (class 2606 OID 36358)
-- Name: user_account user_account_nickname_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account
  ADD CONSTRAINT user_account_nickname_key UNIQUE (nickname);


--
-- TOC entry 2170 (class 2606 OID 35644)
-- Name: user_account user_account_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account
  ADD CONSTRAINT user_account_pkey PRIMARY KEY (id);


--
-- TOC entry 2188 (class 2620 OID 35793)
-- Name: post trigger_add_post; Type: TRIGGER; Schema: public; Owner: vlad
--

CREATE TRIGGER trigger_add_post AFTER INSERT ON post FOR EACH ROW EXECUTE PROCEDURE process_add_post();


--
-- TOC entry 2189 (class 2620 OID 36861)
-- Name: post trigger_create_path_post; Type: TRIGGER; Schema: public; Owner: vlad
--

CREATE TRIGGER trigger_create_path_post BEFORE INSERT ON post FOR EACH ROW EXECUTE PROCEDURE create_path_post();


--
-- TOC entry 2190 (class 2620 OID 36155)
-- Name: post trigger_inc_post_forum; Type: TRIGGER; Schema: public; Owner: vlad
--

CREATE TRIGGER trigger_inc_post_forum AFTER INSERT OR DELETE ON post FOR EACH ROW EXECUTE PROCEDURE process_increment_post_forum();


--
-- TOC entry 2192 (class 2620 OID 36569)
-- Name: thread trigger_inc_thread_forum; Type: TRIGGER; Schema: public; Owner: vlad
--

CREATE TRIGGER trigger_inc_thread_forum AFTER INSERT OR DELETE ON thread FOR EACH ROW EXECUTE PROCEDURE process_increment_thread_forum();


--
-- TOC entry 2191 (class 2620 OID 35699)
-- Name: thread_votes trigger_vote; Type: TRIGGER; Schema: public; Owner: vlad
--

CREATE TRIGGER trigger_vote AFTER INSERT OR DELETE OR UPDATE ON thread_votes FOR EACH ROW EXECUTE PROCEDURE process_vote();


--
-- TOC entry 2185 (class 2606 OID 36552)
-- Name: forum forum_user_moderator_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum
  ADD CONSTRAINT forum_user_moderator_fkey FOREIGN KEY (user_moderator) REFERENCES user_account(nickname);


--
-- TOC entry 2183 (class 2606 OID 36364)
-- Name: post post_author_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post
  ADD CONSTRAINT post_author_fkey FOREIGN KEY (author) REFERENCES user_account(nickname);


--
-- TOC entry 2186 (class 2606 OID 36557)
-- Name: thread thread_author_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_author_fkey FOREIGN KEY (author) REFERENCES user_account(nickname);


--
-- TOC entry 2187 (class 2606 OID 36562)
-- Name: thread thread_forum_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_forum_fkey FOREIGN KEY (forum) REFERENCES forum(slug) MATCH FULL;


--
-- TOC entry 2184 (class 2606 OID 36374)
-- Name: thread_votes thread_votes_nickname_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread_votes
  ADD CONSTRAINT thread_votes_nickname_fkey FOREIGN KEY (nickname) REFERENCES user_account(nickname);


-- Completed on 2017-11-26 13:45:09 MSK

--
-- PostgreSQL database dump complete
--
