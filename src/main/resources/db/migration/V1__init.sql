
--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.5
-- Dumped by pg_dump version 10.0

-- Started on 2017-11-21 20:18:42 MSK

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
-- TOC entry 2323 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 2 (class 3079 OID 25487)
-- Name: citext; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- TOC entry 2324 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 187 (class 1259 OID 16499)
-- Name: forum; Type: TABLE; Schema: public; Owner: vlad
--

CREATE TABLE IF NOT EXISTS forum (
  id integer NOT NULL,
  slug citext NOT NULL,
  title character varying(200) NOT NULL,
  user_moderator citext NOT NULL,
  posts integer DEFAULT 0,
  threads integer DEFAULT 0
);


ALTER TABLE forum OWNER TO vlad;

--
-- TOC entry 188 (class 1259 OID 16505)
-- Name: forum_id_seq; Type: SEQUENCE; Schema: public; Owner: vlad
--

CREATE SEQUENCE IF NOT EXISTS forum_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE forum_id_seq OWNER TO vlad;

--
-- TOC entry 2325 (class 0 OID 0)
-- Dependencies: 188
-- Name: forum_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE forum_id_seq OWNED BY forum.id;


--
-- TOC entry 189 (class 1259 OID 16507)
-- Name: post; Type: TABLE; Schema: public; Owner: vlad
--

CREATE TABLE IF NOT EXISTS post (
  id integer NOT NULL,
  created timestamp without time zone DEFAULT now(),
  message text,
  isedited boolean DEFAULT false,
  author citext NOT NULL,
  thread integer NOT NULL,
  parent integer DEFAULT 0,
  forum citext,
  path bigint[] NOT NULL
);


ALTER TABLE post OWNER TO vlad;

--
-- TOC entry 190 (class 1259 OID 16516)
-- Name: post_id_seq; Type: SEQUENCE; Schema: public; Owner: vlad
--

CREATE SEQUENCE IF NOT EXISTS post_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE post_id_seq OWNER TO vlad;

--
-- TOC entry 2326 (class 0 OID 0)
-- Dependencies: 190
-- Name: post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE post_id_seq OWNED BY post.id;


--
-- TOC entry 191 (class 1259 OID 16518)
-- Name: post_thread_seq; Type: SEQUENCE; Schema: public; Owner: vlad
--

CREATE SEQUENCE IF NOT EXISTS post_thread_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE post_thread_seq OWNER TO vlad;

--
-- TOC entry 2327 (class 0 OID 0)
-- Dependencies: 191
-- Name: post_thread_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE post_thread_seq OWNED BY post.thread;


--
-- TOC entry 186 (class 1259 OID 16489)
-- Name: schema_version; Type: TABLE; Schema: public; Owner: vlad
--





CREATE TABLE IF NOT EXISTS thread (
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
-- TOC entry 193 (class 1259 OID 16527)
-- Name: thread_forum_seq; Type: SEQUENCE; Schema: public; Owner: vlad
--

CREATE SEQUENCE IF NOT EXISTS thread_forum_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE thread_forum_seq OWNER TO vlad;

--
-- TOC entry 2328 (class 0 OID 0)
-- Dependencies: 193
-- Name: thread_forum_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE thread_forum_seq OWNED BY thread.forum;


--
-- TOC entry 194 (class 1259 OID 16529)
-- Name: thread_id_seq; Type: SEQUENCE; Schema: public; Owner: vlad
--

CREATE SEQUENCE IF NOT EXISTS thread_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE thread_id_seq OWNER TO vlad;

--
-- TOC entry 2329 (class 0 OID 0)
-- Dependencies: 194
-- Name: thread_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE thread_id_seq OWNED BY thread.id;


--
-- TOC entry 195 (class 1259 OID 16531)
-- Name: user_account; Type: TABLE; Schema: public; Owner: vlad
--

CREATE TABLE IF NOT EXISTS user_account (
  id integer NOT NULL,
  nickname citext NOT NULL,
  email citext NOT NULL,
  fullname character varying(60) NOT NULL,
  about text
);


ALTER TABLE user_account OWNER TO vlad;

--
-- TOC entry 196 (class 1259 OID 16537)
-- Name: user_account_id_seq; Type: SEQUENCE; Schema: public; Owner: vlad
--

CREATE SEQUENCE IF NOT EXISTS user_account_id_seq
START WITH 1
INCREMENT BY 1
NO MINVALUE
NO MAXVALUE
CACHE 1;


ALTER TABLE user_account_id_seq OWNER TO vlad;

--
-- TOC entry 2330 (class 0 OID 0)
-- Dependencies: 196
-- Name: user_account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vlad
--

ALTER SEQUENCE user_account_id_seq OWNED BY user_account.id;


--
-- TOC entry 2150 (class 2604 OID 16539)
-- Name: forum id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum ALTER COLUMN id SET DEFAULT nextval('forum_id_seq'::regclass);


--
-- TOC entry 2156 (class 2604 OID 16540)
-- Name: post id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post ALTER COLUMN id SET DEFAULT nextval('post_id_seq'::regclass);


--
-- TOC entry 2157 (class 2604 OID 16541)
-- Name: post thread; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post ALTER COLUMN thread SET DEFAULT nextval('post_thread_seq'::regclass);


--
-- TOC entry 2159 (class 2604 OID 16542)
-- Name: thread id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread ALTER COLUMN id SET DEFAULT nextval('thread_id_seq'::regclass);


--
-- TOC entry 2160 (class 2604 OID 25673)
-- Name: thread forum; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread ALTER COLUMN forum SET DEFAULT nextval('thread_forum_seq'::regclass);


--
-- TOC entry 2161 (class 2604 OID 16544)
-- Name: user_account id; Type: DEFAULT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account ALTER COLUMN id SET DEFAULT nextval('user_account_id_seq'::regclass);




--
-- TOC entry 2331 (class 0 OID 0)
-- Dependencies: 188
-- Name: forum_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vlad
--

SELECT pg_catalog.setval('forum_id_seq', 802, true);


--
-- TOC entry 2332 (class 0 OID 0)
-- Dependencies: 190
-- Name: post_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vlad
--

SELECT pg_catalog.setval('post_id_seq', 5, true);


--
-- TOC entry 2333 (class 0 OID 0)
-- Dependencies: 191
-- Name: post_thread_seq; Type: SEQUENCE SET; Schema: public; Owner: vlad
--

SELECT pg_catalog.setval('post_thread_seq', 1, false);


--
-- TOC entry 2334 (class 0 OID 0)
-- Dependencies: 193
-- Name: thread_forum_seq; Type: SEQUENCE SET; Schema: public; Owner: vlad
--

SELECT pg_catalog.setval('thread_forum_seq', 1, false);


--
-- TOC entry 2335 (class 0 OID 0)
-- Dependencies: 194
-- Name: thread_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vlad
--

SELECT pg_catalog.setval('thread_id_seq', 829, true);


--
-- TOC entry 2336 (class 0 OID 0)
-- Dependencies: 196
-- Name: user_account_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vlad
--

SELECT pg_catalog.setval('user_account_id_seq', 6293, true);


--
-- TOC entry 2166 (class 2606 OID 16546)
-- Name: forum forum_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum
  ADD CONSTRAINT forum_pkey PRIMARY KEY (id);


--
-- TOC entry 2168 (class 2606 OID 25606)
-- Name: forum forum_slug_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum
  ADD CONSTRAINT forum_slug_key UNIQUE (slug);


--
-- TOC entry 2170 (class 2606 OID 16550)
-- Name: post post_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post
  ADD CONSTRAINT post_pkey PRIMARY KEY (id);


--
-- TOC entry 2163 (class 2606 OID 16497)
-- Name: schema_version schema_version_pk; Type: CONSTRAINT; Schema: public; Owner: vlad
--



ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_pkey PRIMARY KEY (id);


--
-- TOC entry 2174 (class 2606 OID 25697)
-- Name: thread thread_slug_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_slug_key UNIQUE (slug);


--
-- TOC entry 2176 (class 2606 OID 16695)
-- Name: thread thread_title_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_title_key UNIQUE (title);


--
-- TOC entry 2178 (class 2606 OID 25604)
-- Name: user_account user_account_email_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account
  ADD CONSTRAINT user_account_email_key UNIQUE (email);


--
-- TOC entry 2180 (class 2606 OID 25587)
-- Name: user_account user_account_nickname_key; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account
  ADD CONSTRAINT user_account_nickname_key UNIQUE (nickname);


--
-- TOC entry 2182 (class 2606 OID 16560)
-- Name: user_account user_account_pkey; Type: CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY user_account
  ADD CONSTRAINT user_account_pkey PRIMARY KEY (id);


--


--
-- TOC entry 2183 (class 2606 OID 25588)
-- Name: forum forum_user_moderator_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY forum
  ADD CONSTRAINT forum_user_moderator_fkey FOREIGN KEY (user_moderator) REFERENCES user_account(nickname);


--
-- TOC entry 2185 (class 2606 OID 25593)
-- Name: post post_author_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post
  ADD CONSTRAINT post_author_fkey FOREIGN KEY (author) REFERENCES user_account(nickname);


--
-- TOC entry 2186 (class 2606 OID 33871)
-- Name: post post_forum_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post
  ADD CONSTRAINT post_forum_fkey FOREIGN KEY (forum) REFERENCES forum(slug);


--
-- TOC entry 2184 (class 2606 OID 16576)
-- Name: post post_thread_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY post
  ADD CONSTRAINT post_thread_fkey FOREIGN KEY (thread) REFERENCES thread(id);


--
-- TOC entry 2187 (class 2606 OID 25598)
-- Name: thread thread_author_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_author_fkey FOREIGN KEY (author) REFERENCES user_account(nickname);


--
-- TOC entry 2188 (class 2606 OID 25683)
-- Name: thread thread_forum_fkey; Type: FK CONSTRAINT; Schema: public; Owner: vlad
--

ALTER TABLE ONLY thread
  ADD CONSTRAINT thread_forum_fkey FOREIGN KEY (forum) REFERENCES forum(slug) MATCH FULL;


-- Completed on 2017-11-21 20:18:44 MSK

--
-- PostgreSQL database dump complete
--
