--
-- PostgreSQL database dump
--

-- Dumped from database version 16.12 (Debian 16.12-1.pgdg13+1)
-- Dumped by pg_dump version 17.5

-- Started on 2026-02-24 21:08:06

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 858 (class 1247 OID 16390)
-- Name: book_medium_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.book_medium_enum AS ENUM (
    'Paperback',
    'Kindle',
    'Audiobook'
);


ALTER TYPE public.book_medium_enum OWNER TO postgres;

--
-- TOC entry 861 (class 1247 OID 16398)
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
-- TOC entry 3541 (class 0 OID 0)
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
-- TOC entry 3542 (class 0 OID 0)
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
-- TOC entry 221 (class 1259 OID 16426)
-- Name: genre; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.genre (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.genre OWNER TO postgres;

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
-- TOC entry 232 (class 1259 OID 16554)
-- Name: book_display; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.book_display AS
 SELECT books.id AS book_id,
    books.title AS book_title,
    books.cover AS book_cover,
    books.page_count,
    books.series_order,
    author.first_name AS author_first_name,
    author.last_name AS author_last_name,
    series.name AS series_name,
    string_agg(genre.name, ', '::text) AS genres
   FROM ((((public.books
     JOIN public.author ON ((books.author_id = author.id)))
     LEFT JOIN public.series ON ((books.series_id = series.id)))
     LEFT JOIN public.book_genre_map ON ((books.id = book_genre_map.book_id)))
     LEFT JOIN public.genre ON ((book_genre_map.genre_id = genre.id)))
  GROUP BY books.id, books.title, books.cover, books.page_count, books.series_order, author.first_name, author.last_name, series.name;


ALTER VIEW public.book_display OWNER TO postgres;

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
-- TOC entry 3543 (class 0 OID 0)
-- Dependencies: 222
-- Name: genre_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.genre_id_seq OWNED BY public.genre.id;


--
-- TOC entry 231 (class 1259 OID 16550)
-- Name: library_table; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.library_table AS
 SELECT books.id AS book_id,
    books.title AS book_title,
    books.cover AS book_cover,
    author.first_name AS author_first_name,
    author.last_name AS author_last_name
   FROM (public.books
     JOIN public.author ON ((books.author_id = author.id)));


ALTER VIEW public.library_table OWNER TO postgres;

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
-- TOC entry 3544 (class 0 OID 0)
-- Dependencies: 224
-- Name: reading_calendar_session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reading_calendar_session_id_seq OWNED BY public.reading_calendar.session_id;


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
-- TOC entry 3545 (class 0 OID 0)
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
-- TOC entry 233 (class 1259 OID 16559)
-- Name: user_book_library; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.user_book_library AS
 SELECT user_books.user_id,
    library_table.book_id,
    library_table.book_title,
    library_table.book_cover,
    library_table.author_first_name,
    library_table.author_last_name
   FROM (public.user_books
     JOIN public.library_table ON ((user_books.book_id = library_table.book_id)));


ALTER VIEW public.user_book_library OWNER TO postgres;

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
-- TOC entry 3546 (class 0 OID 0)
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
-- TOC entry 3547 (class 0 OID 0)
-- Dependencies: 230
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 3324 (class 2604 OID 16459)
-- Name: author id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.author ALTER COLUMN id SET DEFAULT nextval('public.author_id_seq'::regclass);


--
-- TOC entry 3323 (class 2604 OID 16460)
-- Name: books id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books ALTER COLUMN id SET DEFAULT nextval('public."Master_Books_id_seq"'::regclass);


--
-- TOC entry 3326 (class 2604 OID 16461)
-- Name: genre id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genre ALTER COLUMN id SET DEFAULT nextval('public.genre_id_seq'::regclass);


--
-- TOC entry 3328 (class 2604 OID 16462)
-- Name: reading_calendar session_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reading_calendar ALTER COLUMN session_id SET DEFAULT nextval('public.reading_calendar_session_id_seq'::regclass);


--
-- TOC entry 3329 (class 2604 OID 16463)
-- Name: series id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.series ALTER COLUMN id SET DEFAULT nextval('public.series_id_seq'::regclass);


--
-- TOC entry 3330 (class 2604 OID 16464)
-- Name: user_books session_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_books ALTER COLUMN session_id SET DEFAULT nextval('public.user_books_session_id_seq'::regclass);


--
-- TOC entry 3332 (class 2604 OID 16465)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 3522 (class 0 OID 16411)
-- Dependencies: 217
-- Data for Name: author; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.author VALUES (1, 'Brandon', 'Sanderson');
INSERT INTO public.author VALUES (2, 'Simon', 'Jimenez');
INSERT INTO public.author VALUES (3, 'J.A.J.', 'Minton');
INSERT INTO public.author VALUES (4, 'Christopher', 'Buehlman');
INSERT INTO public.author VALUES (5, 'Joe', 'Abercrombie');
INSERT INTO public.author VALUES (6, 'Terry', 'Pratchett');
INSERT INTO public.author VALUES (11, 'Sarah J.', 'Maas');
INSERT INTO public.author VALUES (12, 'Matt', 'Dinniman');


--
-- TOC entry 3524 (class 0 OID 16417)
-- Dependencies: 219
-- Data for Name: book_genre_map; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.book_genre_map VALUES (1, 5);
INSERT INTO public.book_genre_map VALUES (1, 6);
INSERT INTO public.book_genre_map VALUES (1, 7);
INSERT INTO public.book_genre_map VALUES (2, 5);
INSERT INTO public.book_genre_map VALUES (2, 6);
INSERT INTO public.book_genre_map VALUES (2, 7);
INSERT INTO public.book_genre_map VALUES (10, 5);
INSERT INTO public.book_genre_map VALUES (11, 5);
INSERT INTO public.book_genre_map VALUES (12, 5);
INSERT INTO public.book_genre_map VALUES (13, 5);
INSERT INTO public.book_genre_map VALUES (14, 5);
INSERT INTO public.book_genre_map VALUES (15, 5);
INSERT INTO public.book_genre_map VALUES (16, 5);
INSERT INTO public.book_genre_map VALUES (17, 5);
INSERT INTO public.book_genre_map VALUES (10, 6);
INSERT INTO public.book_genre_map VALUES (11, 6);
INSERT INTO public.book_genre_map VALUES (12, 6);
INSERT INTO public.book_genre_map VALUES (13, 6);
INSERT INTO public.book_genre_map VALUES (14, 6);
INSERT INTO public.book_genre_map VALUES (15, 6);
INSERT INTO public.book_genre_map VALUES (16, 6);
INSERT INTO public.book_genre_map VALUES (17, 6);
INSERT INTO public.book_genre_map VALUES (10, 7);
INSERT INTO public.book_genre_map VALUES (11, 7);
INSERT INTO public.book_genre_map VALUES (12, 7);
INSERT INTO public.book_genre_map VALUES (13, 7);
INSERT INTO public.book_genre_map VALUES (14, 7);
INSERT INTO public.book_genre_map VALUES (15, 7);
INSERT INTO public.book_genre_map VALUES (16, 7);
INSERT INTO public.book_genre_map VALUES (17, 7);
INSERT INTO public.book_genre_map VALUES (6, 7);
INSERT INTO public.book_genre_map VALUES (7, 7);
INSERT INTO public.book_genre_map VALUES (8, 7);
INSERT INTO public.book_genre_map VALUES (6, 6);
INSERT INTO public.book_genre_map VALUES (7, 6);
INSERT INTO public.book_genre_map VALUES (8, 6);
INSERT INTO public.book_genre_map VALUES (6, 5);
INSERT INTO public.book_genre_map VALUES (7, 5);
INSERT INTO public.book_genre_map VALUES (8, 5);
INSERT INTO public.book_genre_map VALUES (6, 8);
INSERT INTO public.book_genre_map VALUES (7, 8);
INSERT INTO public.book_genre_map VALUES (8, 8);
INSERT INTO public.book_genre_map VALUES (7, 10);
INSERT INTO public.book_genre_map VALUES (18, 6);
INSERT INTO public.book_genre_map VALUES (18, 12);
INSERT INTO public.book_genre_map VALUES (18, 5);
INSERT INTO public.book_genre_map VALUES (18, 13);
INSERT INTO public.book_genre_map VALUES (18, 15);
INSERT INTO public.book_genre_map VALUES (18, 14);
INSERT INTO public.book_genre_map VALUES (5, 16);
INSERT INTO public.book_genre_map VALUES (5, 6);
INSERT INTO public.book_genre_map VALUES (5, 17);
INSERT INTO public.book_genre_map VALUES (5, 5);


--
-- TOC entry 3520 (class 0 OID 16405)
-- Dependencies: 215
-- Data for Name: books; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.books VALUES (1, 'The Way of Kings', 'images/books/the_way_of_kings.jpg', 1124, 1, 1, 1);
INSERT INTO public.books VALUES (2, 'Words of Radiance', 'images/books/words_of_radiance.jpg', 1124, 1, 1, 2);
INSERT INTO public.books VALUES (3, 'The Spear Cuts Through Water', 'images/books/the_spear_cuts_through_water.jpg', 518, NULL, 2, NULL);
INSERT INTO public.books VALUES (4, 'Discovery', 'images/books/discovery.jpg', 448, NULL, 3, NULL);
INSERT INTO public.books VALUES (5, 'Between Two Fires', 'images/books/between_two_fires.jpg', 434, NULL, 4, NULL);
INSERT INTO public.books VALUES (10, 'The Assassin’s Blade', 'images/books/the_assassin''s_blade.jpg', 448, 2, 11, 1);
INSERT INTO public.books VALUES (11, 'Throne of Glass', 'images/books/throne_of_glass.jpg', 409, 2, 11, 2);
INSERT INTO public.books VALUES (12, 'Crown of Midnight', 'images/books/crown_of_midnight.jpg', 446, 2, 11, 3);
INSERT INTO public.books VALUES (17, 'Heir of Fire', 'images/books/heir_of_fire.jpg', 576, 2, 11, 4);
INSERT INTO public.books VALUES (13, 'Queen of Shadows', 'images/books/queen_of_shadows.jpg', 693, 2, 11, 5);
INSERT INTO public.books VALUES (14, 'Empire of Storms', 'images/books/empire_of_storms.jpg', 693, 2, 11, 6);
INSERT INTO public.books VALUES (15, 'Tower of Dawn', 'images/books/tower_of_dawn.jpg', 663, 2, 11, 7);
INSERT INTO public.books VALUES (16, 'Kingdom of Ash', 'images/books/kingdom_of_ash.jpg', 984, 2, 11, 8);
INSERT INTO public.books VALUES (6, 'The Blade Itself', 'images/books/the_blade_itself.jpg', 501, 3, 5, 1);
INSERT INTO public.books VALUES (7, 'Before they are Hanged', 'images/books/before_they_are_hanged.jpg', 514, 3, 5, 2);
INSERT INTO public.books VALUES (8, 'Last Argument of Kings', 'images/books/last_argument_of_kings.jpg', 603, 3, 5, 3);
INSERT INTO public.books VALUES (18, 'Dungeon Crawler Carl', 'images/books/dungeon_crawler_carl.jpg', 446, 6, 12, 1);
INSERT INTO public.books VALUES (19, 'Carl''s Doomsday Scenario', 'images/books/carl''s_doomsday_scenario.jpg', 364, 6, 12, 2);
INSERT INTO public.books VALUES (20, 'The Dungeon Anarchist''s Cookbook', 'images/books/the_dungeon_anarchist''s_cookbook.jpg', 534, 6, 12, 3);
INSERT INTO public.books VALUES (21, 'The Gate of the Feral Gods', 'images/books/the_gate_of_the_feral_gods.jpg', 586, 6, 12, 4);
INSERT INTO public.books VALUES (22, 'The Butcher''s Masquerade', 'images/books/the_butcher''s_masquerade.jpg', 732, 6, 12, 5);
INSERT INTO public.books VALUES (23, 'The Eye of the Bedlam Bride', 'images/books/the_eye_of_the_bedlam_bride.jpg', 694, 6, 12, 6);
INSERT INTO public.books VALUES (24, 'This Inevitable Ruin', 'images/books/this_inevitable_ruin.jpg', 724, 6, 12, 7);


--
-- TOC entry 3525 (class 0 OID 16420)
-- Dependencies: 220
-- Data for Name: friendships; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3526 (class 0 OID 16426)
-- Dependencies: 221
-- Data for Name: genre; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.genre VALUES (5, 'Fiction');
INSERT INTO public.genre VALUES (6, 'Fantasy');
INSERT INTO public.genre VALUES (7, 'High Fantasy');
INSERT INTO public.genre VALUES (8, 'Novel');
INSERT INTO public.genre VALUES (9, 'Grim Dark');
INSERT INTO public.genre VALUES (10, 'Adventure');
INSERT INTO public.genre VALUES (11, 'History');
INSERT INTO public.genre VALUES (12, 'Science Fiction');
INSERT INTO public.genre VALUES (13, 'Humor');
INSERT INTO public.genre VALUES (14, 'Dystopia');
INSERT INTO public.genre VALUES (15, 'Comedy');
INSERT INTO public.genre VALUES (16, 'Horror');
INSERT INTO public.genre VALUES (17, 'Historical Fiction');
INSERT INTO public.genre VALUES (18, 'Medieval');


--
-- TOC entry 3528 (class 0 OID 16432)
-- Dependencies: 223
-- Data for Name: reading_calendar; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 3530 (class 0 OID 16439)
-- Dependencies: 225
-- Data for Name: series; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.series VALUES (1, 'The Stormlight Archive', 1);
INSERT INTO public.series VALUES (2, 'Throne of Glass', 11);
INSERT INTO public.series VALUES (3, 'The First Law', 5);
INSERT INTO public.series VALUES (6, 'Dungeon Crawler Carl', 12);


--
-- TOC entry 3532 (class 0 OID 16445)
-- Dependencies: 227
-- Data for Name: user_books; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.user_books VALUES (12, 5, 5, 'To Be Read', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.user_books VALUES (12, 11, 6, 'To Be Read', NULL, NULL, NULL, NULL, NULL, NULL);


--
-- TOC entry 3534 (class 0 OID 16452)
-- Dependencies: 229
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.users VALUES (1, 'useradmin@gmail.com', 'scrypt:32768:8:1$ik9nTzIftzI8wUzw$a65206a33ad629e2f73bb54b5fee502bef8cf8780797e908b0fbbe66afc9fea241c9f92e3989c88eace678fc41271ebbb5776afcdf255532913d54aab8965b76', 'This is the Admin account. The Admin account has the ability to add books to the general library of the app amongst other higher level capabilities', 'images/users/admin_profile_picture.png', '2026-01-21 11:43:12.347303', NULL, NULL, 'Admin');
INSERT INTO public.users VALUES (12, 'bryanmurphy02@gmail.com', 'scrypt:32768:8:1$zHNlrLChhqez50sx$06b2f260d66c5eb3fbcb033e70856d07d8ff6dbfe3cf158666127dc1764e02e898df33cd2d20c4a2b7bc4272478fe64018ebe501ea65629091a60b92989c3244', NULL, NULL, '2026-02-21 00:28:21.184186', NULL, NULL, 'bryanmurphy02');


--
-- TOC entry 3548 (class 0 OID 0)
-- Dependencies: 216
-- Name: Master_Books_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Master_Books_id_seq"', 25, true);


--
-- TOC entry 3549 (class 0 OID 0)
-- Dependencies: 218
-- Name: author_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.author_id_seq', 13, true);


--
-- TOC entry 3550 (class 0 OID 0)
-- Dependencies: 222
-- Name: genre_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.genre_id_seq', 18, true);


--
-- TOC entry 3551 (class 0 OID 0)
-- Dependencies: 224
-- Name: reading_calendar_session_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reading_calendar_session_id_seq', 60, true);


--
-- TOC entry 3552 (class 0 OID 0)
-- Dependencies: 226
-- Name: series_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.series_id_seq', 7, true);


--
-- TOC entry 3553 (class 0 OID 0)
-- Dependencies: 228
-- Name: user_books_session_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_books_session_id_seq', 6, true);


--
-- TOC entry 3554 (class 0 OID 0)
-- Dependencies: 230
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 12, true);


--
-- TOC entry 3339 (class 2606 OID 16467)
-- Name: books Master_Books_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT "Master_Books_pkey" PRIMARY KEY (id);


--
-- TOC entry 3343 (class 2606 OID 16469)
-- Name: author author_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.author
    ADD CONSTRAINT author_pkey PRIMARY KEY (id);


--
-- TOC entry 3345 (class 2606 OID 16471)
-- Name: book_genre_map book_genre_map_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.book_genre_map
    ADD CONSTRAINT book_genre_map_pkey PRIMARY KEY (book_id, genre_id);


--
-- TOC entry 3347 (class 2606 OID 16473)
-- Name: friendships friendships_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friendships
    ADD CONSTRAINT friendships_pkey PRIMARY KEY (user_id, friend_id);


--
-- TOC entry 3349 (class 2606 OID 16475)
-- Name: genre genre_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genre
    ADD CONSTRAINT genre_pkey PRIMARY KEY (id);


--
-- TOC entry 3351 (class 2606 OID 16477)
-- Name: reading_calendar reading_calendar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reading_calendar
    ADD CONSTRAINT reading_calendar_pkey PRIMARY KEY (session_id);


--
-- TOC entry 3353 (class 2606 OID 16479)
-- Name: series series_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.series
    ADD CONSTRAINT series_pkey PRIMARY KEY (id);


--
-- TOC entry 3341 (class 2606 OID 16481)
-- Name: books unique_series_order; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT unique_series_order UNIQUE (series_id, series_order);


--
-- TOC entry 3357 (class 2606 OID 16483)
-- Name: users unique_username; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT unique_username UNIQUE (username);


--
-- TOC entry 3355 (class 2606 OID 16485)
-- Name: user_books user_books_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_books
    ADD CONSTRAINT user_books_pkey PRIMARY KEY (user_id, book_id, session_id);


--
-- TOC entry 3359 (class 2606 OID 16487)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 3361 (class 2606 OID 16489)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 3364 (class 2606 OID 16490)
-- Name: book_genre_map book_genre_map_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.book_genre_map
    ADD CONSTRAINT book_genre_map_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.books(id);


--
-- TOC entry 3365 (class 2606 OID 16495)
-- Name: book_genre_map book_genre_map_genre_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.book_genre_map
    ADD CONSTRAINT book_genre_map_genre_id_fkey FOREIGN KEY (genre_id) REFERENCES public.genre(id);


--
-- TOC entry 3370 (class 2606 OID 16500)
-- Name: series fk_author_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.series
    ADD CONSTRAINT fk_author_id FOREIGN KEY (author_id) REFERENCES public.author(id);


--
-- TOC entry 3362 (class 2606 OID 16505)
-- Name: books fk_author_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT fk_author_id FOREIGN KEY (author_id) REFERENCES public.author(id);


--
-- TOC entry 3363 (class 2606 OID 16510)
-- Name: books fk_books_series; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT fk_books_series FOREIGN KEY (series_id) REFERENCES public.series(id);


--
-- TOC entry 3373 (class 2606 OID 16515)
-- Name: users fk_favorite_book; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_favorite_book FOREIGN KEY (favorite_book) REFERENCES public.books(id);


--
-- TOC entry 3366 (class 2606 OID 16520)
-- Name: friendships friendships_friend_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friendships
    ADD CONSTRAINT friendships_friend_id_fkey FOREIGN KEY (friend_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3367 (class 2606 OID 16525)
-- Name: friendships friendships_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.friendships
    ADD CONSTRAINT friendships_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3368 (class 2606 OID 16530)
-- Name: reading_calendar reading_calendar_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reading_calendar
    ADD CONSTRAINT reading_calendar_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.books(id) ON DELETE CASCADE;


--
-- TOC entry 3369 (class 2606 OID 16535)
-- Name: reading_calendar reading_calendar_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reading_calendar
    ADD CONSTRAINT reading_calendar_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 3371 (class 2606 OID 16540)
-- Name: user_books user_books_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_books
    ADD CONSTRAINT user_books_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.books(id) ON DELETE CASCADE;


--
-- TOC entry 3372 (class 2606 OID 16545)
-- Name: user_books user_books_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_books
    ADD CONSTRAINT user_books_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


-- Completed on 2026-02-24 21:08:06

--
-- PostgreSQL database dump complete
--

