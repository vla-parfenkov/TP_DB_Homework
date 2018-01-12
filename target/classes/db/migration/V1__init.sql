--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.5
-- Dumped by pg_dump version 10.0

-- Started on 2018-01-12 13:57:47 MSK

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
-- TOC entry 2415 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 3 (class 3079 OID 61376)
-- Name: citext; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- TOC entry 2416 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- TOC entry 2 (class 3079 OID 61460)
-- Name: intarray; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS intarray WITH SCHEMA public;


--
-- TOC entry 2417 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION intarray; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION intarray IS 'functions, operators, and index support for 1-D arrays of integers';


SET search_path = public, pg_catalog;

--
-- TOC entry 298 (class 1255 OID 61578)
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
-- TOC entry 299 (class 1255 OID 62170)
-- Name: procces_vote(text, integer, integer); Type: FUNCTION; Schema: public; Owner: vlad
--

CREATE FUNCTION procces_vote(voting text, new_voice integer, thread_id integer) RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  old_voice integer;
BEGIN
  old_voice = 0;
  old_voice = (SELECT voice FROM thread_votes WHERE lower(nickname) = lower(voting) AND thread = thread_id) ::integer;
  IF old_voice = new_voice THEN
    RETURN 0;
  ELSE IF old_voice != 0  THEN
    UPDATE thread_votes SET voice = new_voice WHERE lower(nickname) = lower(voting) AND thread = thread_id;
    UPDATE thread SET votes = votes - old_voice + new_voice WHERE id = thread_id;
    RETURN new_voice - old_voice;
  ELSE
    insert into thread_votes(nickname, thread, voice) values(voting,thread_id,new_voice);
    UPDATE thread SET votes = votes + new_voice WHERE id = thread_id;
    RETURN new_voice;
  END IF;
  END IF;
END;
$$;


ALTER FUNCTION public.procces_vote(voting text, new_voice integer, thread_id integer) OWNER TO vlad;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 188 (class 1259 OID 61581)
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
-- TOC entry 189 (class 1259 OID 61589)
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
-- TOC entry 2418 (class 0 OID 0)
-- Dependencies: 189
-- Name: forum_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE forum_id_seq OWNED BY forum.id;


--
-- TOC entry 190 (class 1259 OID 61591)
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
-- TOC entry 191 (class 1259 OID 61593)
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


--
-- TOC entry 192 (class 1259 OID 61603)
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
-- TOC entry 193 (class 1259 OID 61610)
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
-- TOC entry 2419 (class 0 OID 0)
-- Dependencies: 193
-- Name: thread_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE thread_id_seq OWNED BY thread.id;


--
-- TOC entry 194 (class 1259 OID 61612)
-- Name: thread_votes; Type: TABLE; Schema: public; Owner: vlad
--

CREATE TABLE thread_votes (
  thread integer NOT NULL,
  voice smallint NOT NULL,
  nickname citext NOT NULL
);


ALTER TABLE thread_votes OWNER TO vlad;

--
-- TOC entry 195 (class 1259 OID 61615)
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
-- TOC entry 196 (class 1259 OID 61621)
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
-- TOC entry 2420 (class 0 OID 0)
-- Dependencies: 196
-- Name: user_account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE user_account_id_seq OWNED BY user_account.id;


--
-- TOC entry 2236 (class 2604 OID 61623)
-- Name: forum id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum ALTER COLUMN id SET DEFAULT nextval('forum_id_seq'::regclass);


--
-- TOC entry 2242 (class 2604 OID 61624)
-- Name: thread id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread ALTER COLUMN id SET DEFAULT nextval('thread_id_seq'::regclass);


--
-- TOC entry 2243 (class 2604 OID 61625)
-- Name: user_account id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account ALTER COLUMN id SET DEFAULT nextval('user_account_id_seq'::regclass);


--
-- TOC entry 2248 (class 2606 OID 61627)
-- Name: forum forum_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum
  ADD CONSTRAINT forum_pkey PRIMARY KEY (id);


--
-- TOC entry 2251 (class 2606 OID 61629)
-- Name: forum forum_slug_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum
  ADD CONSTRAINT forum_slug_key UNIQUE (slug);


--
-- TOC entry 2254 (class 2606 OID 61631)
-- Name: post post_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post
  ADD CONSTRAINT post_pkey PRIMARY KEY (id);




--
-- TOC entry 2263 (class 2606 OID 61633)
-- Name: thread thread_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_pkey PRIMARY KEY (id);


--
-- TOC entry 2265 (class 2606 OID 61635)
-- Name: thread thread_slug_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_slug_key UNIQUE (slug);


--
-- TOC entry 2268 (class 2606 OID 62209)
-- Name: thread_votes thread_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread_votes
  ADD CONSTRAINT thread_votes_pkey PRIMARY KEY (nickname, thread);


--
-- TOC entry 2270 (class 2606 OID 61639)
-- Name: user_account user_account_email_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account
  ADD CONSTRAINT user_account_email_key UNIQUE (email);


--
-- TOC entry 2274 (class 2606 OID 61641)
-- Name: user_account user_account_nickname_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account
  ADD CONSTRAINT user_account_nickname_key UNIQUE (nickname);


--
-- TOC entry 2276 (class 2606 OID 61643)
-- Name: user_account user_account_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account
  ADD CONSTRAINT user_account_pkey PRIMARY KEY (id);


--
-- TOC entry 2249 (class 1259 OID 61644)
-- Name: forum_slug_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX forum_slug_index ON forum USING btree (lower((slug)::text));


--
-- TOC entry 2252 (class 1259 OID 61645)
-- Name: post_id_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_id_index ON post USING btree (id);


--
-- TOC entry 2255 (class 1259 OID 61646)
-- Name: post_subpath_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_subpath_index ON post USING btree (subarray(path, 0, 1));


--
-- TOC entry 2256 (class 1259 OID 61647)
-- Name: post_thread_created_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_thread_created_index ON post USING btree (thread, created, id);


--
-- TOC entry 2257 (class 1259 OID 61648)
-- Name: post_thread_id_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_thread_id_index ON post USING btree (thread, id);


--
-- TOC entry 2258 (class 1259 OID 61649)
-- Name: post_thread_path_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX post_thread_path_index ON post USING btree (thread, path);



--
-- TOC entry 2259 (class 1259 OID 61650)
-- Name: thread_id_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX thread_id_index ON thread USING btree (id);


--
-- TOC entry 2260 (class 1259 OID 61651)
-- Name: thread_lower_forum_created_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX thread_lower_forum_created_index ON thread USING btree (lower((forum)::text), created);


--
-- TOC entry 2261 (class 1259 OID 61652)
-- Name: thread_lower_slug_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX thread_lower_slug_index ON thread USING btree (lower((slug)::text));


--
-- TOC entry 2266 (class 1259 OID 62210)
-- Name: thread_votes_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX thread_votes_index ON thread_votes USING btree (lower((nickname)::text), thread);


--
-- TOC entry 2271 (class 1259 OID 61654)
-- Name: user_account_lower_email_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX user_account_lower_email_index ON user_account USING btree (lower((email)::text));


--
-- TOC entry 2272 (class 1259 OID 61655)
-- Name: user_account_lower_nickname_index; Type: INDEX; Schema: public; Owner: vlad
--

CREATE INDEX user_account_lower_nickname_index ON user_account USING btree (lower((nickname)::text));


--
-- TOC entry 2277 (class 2606 OID 61658)
-- Name: forum forum_user_moderator_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum
  ADD CONSTRAINT forum_user_moderator_fkey FOREIGN KEY (user_moderator) REFERENCES user_account(nickname);


--
-- TOC entry 2278 (class 2606 OID 61663)
-- Name: post post_author_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post
  ADD CONSTRAINT post_author_fkey FOREIGN KEY (author) REFERENCES user_account(nickname);


--
-- TOC entry 2279 (class 2606 OID 61668)
-- Name: thread thread_author_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_author_fkey FOREIGN KEY (author) REFERENCES user_account(nickname);


--
-- TOC entry 2280 (class 2606 OID 61673)
-- Name: thread thread_forum_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_forum_fkey FOREIGN KEY (forum) REFERENCES forum(slug) MATCH FULL;


--
-- TOC entry 2281 (class 2606 OID 62239)
-- Name: thread_votes thread_votes; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread_votes
  ADD CONSTRAINT thread_votes FOREIGN KEY (nickname) REFERENCES user_account(nickname);


-- Completed on 2018-01-12 13:57:49 MSK

--
-- PostgreSQL database dump complete
--


