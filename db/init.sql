--
-- PostgreSQL database dump
--

-- Dumped from database version 16.12 (Debian 16.12-1.pgdg13+1)
-- Dumped by pg_dump version 17.5

-- Started on 2026-02-18 21:31:42

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
-- TOC entry 855 (class 1247 OID 16390)
-- Name: book_medium_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.book_medium_enum AS ENUM (
    'Paperback',
    'Kindle',
    'Audiobook'
);


ALTER TYPE public.book_medium_enum OWNER TO postgres;

--
-- TOC entry 858 (class 1247 OID 16398)
-- Name: reading_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.reading_status_enum AS ENUM (
    'To Be Read',
    'Reading',
    'Completed'
);


ALTER TYPE public.reading_status_enum OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 215 (class 1259 OID 16405)
-- Name: books; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.books (
    id integer NOT NULL,
    title text NOT NULL,
    cover text,
    page_count integer,
    series_id integer,
    author_id integer NOT NULL,
    series_order integer
);


ALTER TABLE public.books OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16410)
-- Name: Master_Books_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Master_Books_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Master_Books_id_seq" OWNER TO postgres;

--
-- TOC entry 3510 (class 0 OID 0)
-- Dependencies: 216
-- Name: Master_Books_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Master_Books_id_seq" OWNED BY public.books.id;


--
-- TOC entry 217 (class 1259 OID 16411)
-- Name: author; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.author (
    id integer NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL
);


ALTER TABLE public.author OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16416)
-- Name: author_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.author_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.author_id_seq OWNER TO postgres;

--
-- TOC entry 3511 (class 0 OID 0)
-- Dependencies: 218
-- Name: author_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.author_id_seq OWNED BY public.author.id;


--
-- TOC entry 219 (class 1259 OID 16417)
-- Name: book_genre_map; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.book_genre_map (
    book_id integer NOT NULL,
    genre_id integer NOT NULL
);


ALTER TABLE public.book_genre_map OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16420)
-- Name: friendships; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.friendships (
    user_id integer NOT NULL,
    friend_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT no_self_friendship CHECK ((user_id <> friend_id)),
    CONSTRAINT user_id_smaller CHECK ((user_id < friend_id))
);


ALTER TABLE public.friendships OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16426)
-- Name: genre; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.genre (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.genre OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16431)
-- Name: genre_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.genre_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.genre_id_seq OWNER TO postgres;

--
-- TOC entry 3512 (class 0 OID 0)
-- Dependencies: 222
-- Name: genre_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.genre_id_seq OWNED BY public.genre.id;


--
-- TOC entry 223 (class 1259 OID 16432)
-- Name: reading_calendar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reading_calendar (
    user_id integer NOT NULL,
    book_id integer NOT NULL,
    read_date date NOT NULL,
    start_page integer NOT NULL,
    end_page integer NOT NULL,
    pages_read integer GENERATED ALWAYS AS ((end_page - start_page)) STORED,
    session_id integer NOT NULL,
    CONSTRAINT reading_calendar_check CHECK (((end_page >= 0) AND (end_page >= start_page))),
    CONSTRAINT reading_calendar_start_page_check CHECK ((start_page >= 0))
);


ALTER TABLE public.reading_calendar OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16438)
-- Name: reading_calendar_session_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reading_calendar_session_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reading_calendar_session_id_seq OWNER TO postgres;

--
-- TOC entry 3513 (class 0 OID 0)
-- Dependencies: 224
-- Name: reading_calendar_session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reading_calendar_session_id_seq OWNED BY public.reading_calendar.session_id;


--
-- TOC entry 225 (class 1259 OID 16439)
-- Name: series; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.series (
    id integer NOT NULL,
    name text NOT NULL,
    author_id integer NOT NULL
);


ALTER TABLE public.series OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16444)
-- Name: series_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.series_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.series_id_seq OWNER TO postgres;

--
-- TOC entry 3514 (class 0 OID 0)
-- Dependencies: 226
-- Name: series_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.series_id_seq OWNED BY public.series.id;


--
-- TOC entry 227 (class 1259 OID 16445)
-- Name: user_books; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_books (
    user_id integer NOT NULL,
    book_id integer NOT NULL,
    session_id integer NOT NULL,
    status public.reading_status_enum DEFAULT 'To Be Read'::public.reading_status_enum NOT NULL,
    start_date date,
    completed_date date,
    rating numeric(2,1),
    book_medium public.book_medium_enum,
    last_page integer,
    notes text
);


ALTER TABLE public.user_books OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16451)
-- Name: user_books_session_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_books_session_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_books_session_id_seq OWNER TO postgres;

--
-- TOC entry 3515 (class 0 OID 0)
-- Dependencies: 228
-- Name: user_books_session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_books_session_id_seq OWNED BY public.user_books.session_id;


--
-- TOC entry 229 (class 1259 OID 16452)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    password_hash text NOT NULL,
    bio text,
    profile_picture text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    last_login timestamp without time zone,
    favorite_book integer,
    username character varying(255) NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

-- Admin account seed
INSERT INTO public.users (id, email, password_hash, bio, profile_picture, created_at, last_login, favorite_book, username) 
VALUES (1, 'useradmin@gmail.com', 'scrypt:32768:8:1$ik9nTzIftzI8wUzw$a65206a33ad629e2f73bb54b5fee502bef8cf8780797e908b0fbbe66afc9fea241c9f92e3989c88eace678fc41271ebbb5776afcdf255532913d54aab8965b76', 'This is the Admin account. The Admin account has the ability to add books to the general library of the app amongst other higher level capabilities', 'images/users/admin_profile_picture.png', '2026-01-21 11:43:12.347303', NULL, NULL, 'Admin');

--
-- TOC entry 230 (class 1259 OID 16458)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 3516 (class 0 OID 0)
-- Dependencies: 230
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 3312 (class 2604 OID 16459)
-- Name: author id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.author ALTER COLUMN id SET DEFAULT nextval('public.author_id_seq'::regclass);


--
-- TOC entry 3311 (class 2604 OID 16460)
-- Name: books id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books ALTER COLUMN id SET DEFAULT nextval('public."Master_Books_id_seq"'::regclass);


--
-- TOC entry 3314 (class 2604 OID 16461)
-- Name: genre id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genre ALTER COLUMN id SET DEFAULT nextval('public.genre_id_seq'::regclass);


--
-- TOC entry 3316 (class 2604 OID 16462)
-- Name: reading_calendar session_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reading_calendar ALTER COLUMN session_id SET DEFAULT nextval('public.reading_calendar_session_id_seq'::regclass);


--
-- TOC entry 3317 (class 2604 OID 16463)
-- Name: series id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.series ALTER COLUMN id SET DEFAULT nextval('public.series_id_seq'::regclass);


--
-- TOC entry 3318 (class 2604 OID 16464)
-- Name: user_books session_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_books ALTER COLUMN session_id SET DEFAULT nextval('public.user_books_session_id_seq'::regclass);


--
-- TOC entry 3320 (class 2604 OID 16465)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 3327 (class 2606 OID 16467)
-- Name: books Master_Books_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT "Master_Books_pkey" PRIMARY KEY (id);


--
-- TOC entry 3331 (class 2606 OID 16469)
-- Name: author author_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.author
    ADD CONSTRAINT author_pkey PRIMARY KEY (id);


--
-- TOC entry 3333 (class 2606 OID 16471)
-- Name: book_genre_map book_genre_map_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.book_genre_map
    ADD CONSTRAINT book_genre_map_pkey PRIMARY KEY (book_id, genre_id);


--
-- TOC entry 3335 (class 2606 OID 16473)
-- Name: friendships friendships_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friendships
    ADD CONSTRAINT friendships_pkey PRIMARY KEY (user_id, friend_id);


--
-- TOC entry 3337 (class 2606 OID 16475)
-- Name: genre genre_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genre
    ADD CONSTRAINT genre_pkey PRIMARY KEY (id);


--
-- TOC entry 3339 (class 2606 OID 16477)
-- Name: reading_calendar reading_calendar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reading_calendar
    ADD CONSTRAINT reading_calendar_pkey PRIMARY KEY (session_id);


--
-- TOC entry 3341 (class 2606 OID 16479)
-- Name: series series_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.series
    ADD CONSTRAINT series_pkey PRIMARY KEY (id);


--
-- TOC entry 3329 (class 2606 OID 16481)
-- Name: books unique_series_order; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT unique_series_order UNIQUE (series_id, series_order);


--
-- TOC entry 3345 (class 2606 OID 16483)
-- Name: users unique_username; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT unique_username UNIQUE (username);


--
-- TOC entry 3343 (class 2606 OID 16485)
-- Name: user_books user_books_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_books
    ADD CONSTRAINT user_books_pkey PRIMARY KEY (user_id, book_id, session_id);


--
-- TOC entry 3347 (class 2606 OID 16487)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 3349 (class 2606 OID 16489)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 3352 (class 2606 OID 16490)
-- Name: book_genre_map book_genre_map_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.book_genre_map
    ADD CONSTRAINT book_genre_map_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.books(id);


--
-- TOC entry 3353 (class 2606 OID 16495)
-- Name: book_genre_map book_genre_map_genre_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.book_genre_map
    ADD CONSTRAINT book_genre_map_genre_id_fkey FOREIGN KEY (genre_id) REFERENCES public.genre(id);


--
-- TOC entry 3358 (class 2606 OID 16500)
-- Name: series fk_author_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.series
    ADD CONSTRAINT fk_author_id FOREIGN KEY (author_id) REFERENCES public.author(id);


--
-- TOC entry 3350 (class 2606 OID 16505)
-- Name: books fk_author_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT fk_author_id FOREIGN KEY (author_id) REFERENCES public.author(id);


--
-- TOC entry 3351 (class 2606 OID 16510)
-- Name: books fk_books_series; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT fk_books_series FOREIGN KEY (series_id) REFERENCES public.series(id);


--
-- TOC entry 3361 (class 2606 OID 16515)
-- Name: users fk_favorite_book; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_favorite_book FOREIGN KEY (favorite_book) REFERENCES public.books(id);


--
-- TOC entry 3354 (class 2606 OID 16520)
-- Name: friendships friendships_friend_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friendships
    ADD CONSTRAINT friendships_friend_id_fkey FOREIGN KEY (friend_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3355 (class 2606 OID 16525)
-- Name: friendships friendships_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friendships
    ADD CONSTRAINT friendships_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3356 (class 2606 OID 16530)
-- Name: reading_calendar reading_calendar_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reading_calendar
    ADD CONSTRAINT reading_calendar_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.books(id) ON DELETE CASCADE;


--
-- TOC entry 3357 (class 2606 OID 16535)
-- Name: reading_calendar reading_calendar_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reading_calendar
    ADD CONSTRAINT reading_calendar_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3359 (class 2606 OID 16540)
-- Name: user_books user_books_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_books
    ADD CONSTRAINT user_books_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.books(id) ON DELETE CASCADE;


--
-- TOC entry 3360 (class 2606 OID 16545)
-- Name: user_books user_books_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_books
    ADD CONSTRAINT user_books_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


-- Completed on 2026-02-18 21:31:42

--
-- PostgreSQL database dump complete
--

