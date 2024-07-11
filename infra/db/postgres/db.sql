--
-- PostgreSQL database dump
--

-- Dumped from database version 15.7 (Debian 15.7-1.pgdg120+1)
-- Dumped by pg_dump version 15.3

-- Started on 2024-06-24 18:51:31

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
-- TOC entry 3484 (class 1262 OID 16384)
-- Name: Projeto; Type: DATABASE; Schema: -; Owner: -
--

DROP DATABASE IF EXISTS Projeto;

CREATE DATABASE "Projeto" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


\connect "Projeto"

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
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- CREATE SCHEMA public;


--
-- TOC entry 3485 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 230 (class 1259 OID 16497)
-- Name: alerta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alerta (
    id integer NOT NULL,
    veiculo_id integer,
    localizacao_id integer,
    configuracaoalerta_id integer,
    data_hora timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- TOC entry 229 (class 1259 OID 16496)
-- Name: alerta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alerta_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3486 (class 0 OID 0)
-- Dependencies: 229
-- Name: alerta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alerta_id_seq OWNED BY public.alerta.id;


--
-- TOC entry 228 (class 1259 OID 16481)
-- Name: configuracaoalerta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.configuracaoalerta (
    id integer NOT NULL,
    veiculo_id integer,
    tipo_alerta character varying(50) NOT NULL,
    valor numeric(10,2),
    mensagem text,
    ativo boolean DEFAULT true,
    data_criacao timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- TOC entry 227 (class 1259 OID 16480)
-- Name: configuracaoalerta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.configuracaoalerta_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3487 (class 0 OID 0)
-- Dependencies: 227
-- Name: configuracaoalerta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.configuracaoalerta_id_seq OWNED BY public.configuracaoalerta.id;


--
-- TOC entry 224 (class 1259 OID 16455)
-- Name: localizacao; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.localizacao (
    id integer NOT NULL,
    rastreador_id integer,
    latitude numeric(10,7) NOT NULL,
    longitude numeric(10,7) NOT NULL,
    velocidade numeric(5,2),
    horario_rastreador timestamp without time zone NOT NULL,
    bateria numeric(5,2),
    bateria_veiculo numeric(5,2),
    ignicao boolean,
    altitude numeric(7,2),
    direcao numeric(5,2),
    odometro numeric(10,2),
    criado_em timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- TOC entry 222 (class 1259 OID 16440)
-- Name: rastreador; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rastreador (
    id integer NOT NULL,
    veiculo_id integer,
    identificador character varying(100) NOT NULL,
    data_instalacao timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- TOC entry 226 (class 1259 OID 16469)
-- Name: trajeto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trajeto (
    id integer NOT NULL,
    veiculo_id integer,
    data_inicio timestamp without time zone,
    data_fim timestamp without time zone
);


--
-- TOC entry 217 (class 1259 OID 16397)
-- Name: veiculo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.veiculo (
    id integer NOT NULL,
    usuario_id integer,
    placa character varying(20) NOT NULL,
    modelo character varying(100),
    ano integer,
    cor character varying(50),
    data_criacao timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- TOC entry 231 (class 1259 OID 16519)
-- Name: descricaotrajeto; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.descricaotrajeto AS
 SELECT t.id AS trajeto_id,
    v.id AS veiculo_id,
    v.placa,
    l.latitude,
    l.longitude,
    l.horario_rastreador
   FROM (((public.trajeto t
     JOIN public.veiculo v ON ((t.veiculo_id = v.id)))
     JOIN public.rastreador r ON ((v.id = r.veiculo_id)))
     JOIN public.localizacao l ON ((r.id = l.rastreador_id)))
  WHERE ((l.horario_rastreador >= t.data_inicio) AND (l.horario_rastreador <= t.data_fim))
  ORDER BY t.id, l.horario_rastreador;


--
-- TOC entry 219 (class 1259 OID 16412)
-- Name: frota; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.frota (
    id integer NOT NULL,
    usuario_id integer,
    nome character varying(100) NOT NULL,
    data_criacao timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- TOC entry 218 (class 1259 OID 16411)
-- Name: frota_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.frota_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3488 (class 0 OID 0)
-- Dependencies: 218
-- Name: frota_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.frota_id_seq OWNED BY public.frota.id;


--
-- TOC entry 220 (class 1259 OID 16424)
-- Name: frotaveiculo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.frotaveiculo (
    frota_id integer NOT NULL,
    veiculo_id integer NOT NULL
);


--
-- TOC entry 236 (class 1259 OID 16541)
-- Name: frotasequantidadeveiculos; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.frotasequantidadeveiculos AS
 SELECT f.id AS frota_id,
    f.nome AS frota_nome,
    count(fv.veiculo_id) AS quantidade_veiculos
   FROM (public.frota f
     LEFT JOIN public.frotaveiculo fv ON ((f.id = fv.frota_id)))
  GROUP BY f.id, f.nome;


--
-- TOC entry 223 (class 1259 OID 16454)
-- Name: localizacao_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.localizacao_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3489 (class 0 OID 0)
-- Dependencies: 223
-- Name: localizacao_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.localizacao_id_seq OWNED BY public.localizacao.id;


--
-- TOC entry 221 (class 1259 OID 16439)
-- Name: rastreador_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rastreador_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3490 (class 0 OID 0)
-- Dependencies: 221
-- Name: rastreador_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rastreador_id_seq OWNED BY public.rastreador.id;


--
-- TOC entry 233 (class 1259 OID 16529)
-- Name: totalrastreadores; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.totalrastreadores AS
 SELECT ( SELECT count(*) AS count
           FROM public.rastreador) AS total_rastreadores,
    ( SELECT count(*) AS count
           FROM public.rastreador
          WHERE (rastreador.veiculo_id IS NOT NULL)) AS total_rastreadores_vinculados,
    ( SELECT count(*) AS count
           FROM public.rastreador
          WHERE (rastreador.veiculo_id IS NULL)) AS total_rastreadores_sem_vinculo;


--
-- TOC entry 225 (class 1259 OID 16468)
-- Name: trajeto_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trajeto_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3491 (class 0 OID 0)
-- Dependencies: 225
-- Name: trajeto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trajeto_id_seq OWNED BY public.trajeto.id;


--
-- TOC entry 215 (class 1259 OID 16387)
-- Name: usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario (
    id integer NOT NULL,
    nome character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    senha character varying(255) NOT NULL,
    telefone character varying(20),
    data_criacao timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- TOC entry 214 (class 1259 OID 16386)
-- Name: usuario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.usuario_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3492 (class 0 OID 0)
-- Dependencies: 214
-- Name: usuario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.usuario_id_seq OWNED BY public.usuario.id;


--
-- TOC entry 232 (class 1259 OID 16524)
-- Name: usuarioscommaisdedezveiculos; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.usuarioscommaisdedezveiculos AS
 SELECT u.id AS usuario_id,
    u.nome,
    u.email,
    count(v.id) AS quantidade_veiculos
   FROM (public.usuario u
     JOIN public.veiculo v ON ((u.id = v.usuario_id)))
  GROUP BY u.id, u.nome, u.email
 HAVING (count(v.id) > 10);


--
-- TOC entry 216 (class 1259 OID 16396)
-- Name: veiculo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.veiculo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3493 (class 0 OID 0)
-- Dependencies: 216
-- Name: veiculo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.veiculo_id_seq OWNED BY public.veiculo.id;


--
-- TOC entry 235 (class 1259 OID 16537)
-- Name: veiculospordatacriacao; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.veiculospordatacriacao AS
 SELECT v.id AS veiculo_id,
    v.placa,
    v.modelo,
    v.ano,
    v.cor,
    v.data_criacao,
    u.id AS usuario_id,
    u.nome
   FROM (public.veiculo v
     JOIN public.usuario u ON ((v.usuario_id = u.id)))
  WHERE (v.data_criacao >= '2024-06-14 00:00:00'::timestamp without time zone);


--
-- TOC entry 234 (class 1259 OID 16533)
-- Name: veiculosporusuario; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.veiculosporusuario AS
 SELECT u.id AS usuario_id,
    u.nome,
    count(v.id) AS quantidade_total_veiculos
   FROM (public.usuario u
     LEFT JOIN public.veiculo v ON ((u.id = v.usuario_id)))
  GROUP BY u.id, u.nome;


--
-- TOC entry 3276 (class 2604 OID 16500)
-- Name: alerta id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerta ALTER COLUMN id SET DEFAULT nextval('public.alerta_id_seq'::regclass);


--
-- TOC entry 3273 (class 2604 OID 16484)
-- Name: configuracaoalerta id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracaoalerta ALTER COLUMN id SET DEFAULT nextval('public.configuracaoalerta_id_seq'::regclass);


--
-- TOC entry 3266 (class 2604 OID 16415)
-- Name: frota id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.frota ALTER COLUMN id SET DEFAULT nextval('public.frota_id_seq'::regclass);


--
-- TOC entry 3270 (class 2604 OID 16458)
-- Name: localizacao id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.localizacao ALTER COLUMN id SET DEFAULT nextval('public.localizacao_id_seq'::regclass);


--
-- TOC entry 3268 (class 2604 OID 16443)
-- Name: rastreador id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rastreador ALTER COLUMN id SET DEFAULT nextval('public.rastreador_id_seq'::regclass);


--
-- TOC entry 3272 (class 2604 OID 16472)
-- Name: trajeto id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trajeto ALTER COLUMN id SET DEFAULT nextval('public.trajeto_id_seq'::regclass);


--
-- TOC entry 3262 (class 2604 OID 16390)
-- Name: usuario id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario ALTER COLUMN id SET DEFAULT nextval('public.usuario_id_seq'::regclass);


--
-- TOC entry 3264 (class 2604 OID 16400)
-- Name: veiculo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.veiculo ALTER COLUMN id SET DEFAULT nextval('public.veiculo_id_seq'::regclass);


--
-- TOC entry 3478 (class 0 OID 16497)
-- Dependencies: 230
-- Data for Name: alerta; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.alerta VALUES (1, 1, 1, 1, '2024-06-24 21:50:34.947418');
INSERT INTO public.alerta VALUES (2, 2, 3, 2, '2024-06-24 21:50:34.947418');


--
-- TOC entry 3476 (class 0 OID 16481)
-- Dependencies: 228
-- Data for Name: configuracaoalerta; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.configuracaoalerta VALUES (1, 1, 'Velocidade', 80.00, 'Velocidade acima do permitido', true, '2024-06-24 21:50:34.94448');
INSERT INTO public.configuracaoalerta VALUES (2, 2, 'Bateria', 20.00, 'Bateria do veículo baixa', true, '2024-06-24 21:50:34.94448');


--
-- TOC entry 3467 (class 0 OID 16412)
-- Dependencies: 219
-- Data for Name: frota; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.frota VALUES (1, 1, 'Frota 01', '2024-06-24 21:50:34.928919');


--
-- TOC entry 3468 (class 0 OID 16424)
-- Dependencies: 220
-- Data for Name: frotaveiculo; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.frotaveiculo VALUES (1, 1);
INSERT INTO public.frotaveiculo VALUES (1, 2);
INSERT INTO public.frotaveiculo VALUES (1, 3);
INSERT INTO public.frotaveiculo VALUES (1, 4);
INSERT INTO public.frotaveiculo VALUES (1, 5);
INSERT INTO public.frotaveiculo VALUES (1, 6);
INSERT INTO public.frotaveiculo VALUES (1, 7);
INSERT INTO public.frotaveiculo VALUES (1, 8);
INSERT INTO public.frotaveiculo VALUES (1, 9);
INSERT INTO public.frotaveiculo VALUES (1, 10);
INSERT INTO public.frotaveiculo VALUES (1, 11);


--
-- TOC entry 3472 (class 0 OID 16455)
-- Dependencies: 224
-- Data for Name: localizacao; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.localizacao VALUES (1, 1, -23.5505000, -46.6333000, 60.50, '2024-06-14 10:00:00', 85.50, 95.50, true, 760.00, 180.00, 12345.67, '2024-06-24 21:50:34.93764');
INSERT INTO public.localizacao VALUES (2, 1, -23.5506000, -46.6334000, 62.00, '2024-06-14 10:05:00', 84.50, 94.50, true, 762.00, 182.00, 12350.67, '2024-06-24 21:50:34.93764');
INSERT INTO public.localizacao VALUES (3, 2, -23.5510000, -46.6340000, 50.00, '2024-06-15 09:00:00', 90.00, 98.00, true, 700.00, 170.00, 12360.67, '2024-06-24 21:50:34.93764');
INSERT INTO public.localizacao VALUES (4, 3, -23.5520000, -46.6350000, 70.00, '2024-06-16 11:00:00', 75.00, 85.00, false, 780.00, 190.00, 12400.67, '2024-06-24 21:50:34.93764');
INSERT INTO public.localizacao VALUES (5, 4, -23.5530000, -46.6360000, 55.00, '2024-06-17 08:00:00', 80.00, 90.00, true, 720.00, 175.00, 12450.67, '2024-06-24 21:50:34.93764');


--
-- TOC entry 3470 (class 0 OID 16440)
-- Dependencies: 222
-- Data for Name: rastreador; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.rastreador VALUES (1, 1, 'R12345', '2024-06-24 21:50:34.93473');
INSERT INTO public.rastreador VALUES (2, 2, 'R23456', '2024-06-24 21:50:34.93473');
INSERT INTO public.rastreador VALUES (3, 3, 'R34567', '2024-06-24 21:50:34.93473');
INSERT INTO public.rastreador VALUES (4, 4, 'R45678', '2024-06-24 21:50:34.93473');
INSERT INTO public.rastreador VALUES (5, 5, 'R56789', '2024-06-24 21:50:34.93473');
INSERT INTO public.rastreador VALUES (6, 6, 'R67890', '2024-06-24 21:50:34.93473');
INSERT INTO public.rastreador VALUES (7, 7, 'R78901', '2024-06-24 21:50:34.93473');
INSERT INTO public.rastreador VALUES (8, 8, 'R89012', '2024-06-24 21:50:34.93473');
INSERT INTO public.rastreador VALUES (9, 9, 'R90123', '2024-06-24 21:50:34.93473');
INSERT INTO public.rastreador VALUES (10, 10, 'R01234', '2024-06-24 21:50:34.93473');
INSERT INTO public.rastreador VALUES (11, 11, 'R12346', '2024-06-24 21:50:34.93473');
INSERT INTO public.rastreador VALUES (12, NULL, 'R23457', '2024-06-24 21:50:34.93473');


--
-- TOC entry 3474 (class 0 OID 16469)
-- Dependencies: 226
-- Data for Name: trajeto; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.trajeto VALUES (1, 1, '2024-06-14 09:00:00', '2024-06-14 11:00:00');
INSERT INTO public.trajeto VALUES (2, 2, '2024-06-15 08:00:00', '2024-06-15 10:00:00');


--
-- TOC entry 3463 (class 0 OID 16387)
-- Dependencies: 215
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.usuario VALUES (1, 'João Silva', 'joao.silva@example.com', 'senha123', '11987654321', '2024-06-24 21:50:34.920512');
INSERT INTO public.usuario VALUES (2, 'Maria Oliveira', 'maria.oliveira@example.com', 'senha123', '11987654322', '2024-06-24 21:50:34.920512');
INSERT INTO public.usuario VALUES (3, 'Carlos Pereira', 'carlos.pereira@example.com', 'senha123', '11987654323', '2024-06-24 21:50:34.920512');
INSERT INTO public.usuario VALUES (4, 'Ana Souza', 'ana.souza@example.com', 'senha123', '11987654324', '2024-06-24 21:50:34.920512');
INSERT INTO public.usuario VALUES (5, 'Pedro Santos', 'pedro.santos@example.com', 'senha123', '11987654325', '2024-06-24 21:50:34.920512');


--
-- TOC entry 3465 (class 0 OID 16397)
-- Dependencies: 217
-- Data for Name: veiculo; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.veiculo VALUES (1, 1, 'ABC1D23', 'Fiat Uno', 2010, 'Branco', '2024-06-24 21:50:34.92346');
INSERT INTO public.veiculo VALUES (2, 1, 'ABC2D34', 'VW Gol', 2015, 'Preto', '2024-06-24 21:50:34.92346');
INSERT INTO public.veiculo VALUES (3, 1, 'ABC3D45', 'Chevrolet Onix', 2018, 'Vermelho', '2024-06-24 21:50:34.92346');
INSERT INTO public.veiculo VALUES (4, 1, 'ABC4D56', 'Honda Civic', 2020, 'Cinza', '2024-06-24 21:50:34.92346');
INSERT INTO public.veiculo VALUES (5, 1, 'ABC5D67', 'Toyota Corolla', 2021, 'Azul', '2024-06-24 21:50:34.92346');
INSERT INTO public.veiculo VALUES (6, 1, 'ABC6D78', 'Ford Ka', 2019, 'Verde', '2024-06-24 21:50:34.92346');
INSERT INTO public.veiculo VALUES (7, 1, 'ABC7D89', 'Renault Kwid', 2022, 'Amarelo', '2024-06-24 21:50:34.92346');
INSERT INTO public.veiculo VALUES (8, 1, 'ABC8D90', 'Hyundai HB20', 2023, 'Roxo', '2024-06-24 21:50:34.92346');
INSERT INTO public.veiculo VALUES (9, 1, 'ABC9E01', 'Jeep Renegade', 2021, 'Laranja', '2024-06-24 21:50:34.92346');
INSERT INTO public.veiculo VALUES (10, 1, 'ABCD123', 'Kia Sportage', 2019, 'Prata', '2024-06-24 21:50:34.92346');
INSERT INTO public.veiculo VALUES (11, 1, 'ABCDE45', 'Peugeot 208', 2022, 'Marrom', '2024-06-24 21:50:34.92346');


--
-- TOC entry 3494 (class 0 OID 0)
-- Dependencies: 229
-- Name: alerta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.alerta_id_seq', 2, true);


--
-- TOC entry 3495 (class 0 OID 0)
-- Dependencies: 227
-- Name: configuracaoalerta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.configuracaoalerta_id_seq', 2, true);


--
-- TOC entry 3496 (class 0 OID 0)
-- Dependencies: 218
-- Name: frota_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.frota_id_seq', 1, true);


--
-- TOC entry 3497 (class 0 OID 0)
-- Dependencies: 223
-- Name: localizacao_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.localizacao_id_seq', 5, true);


--
-- TOC entry 3498 (class 0 OID 0)
-- Dependencies: 221
-- Name: rastreador_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rastreador_id_seq', 12, true);


--
-- TOC entry 3499 (class 0 OID 0)
-- Dependencies: 225
-- Name: trajeto_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.trajeto_id_seq', 2, true);


--
-- TOC entry 3500 (class 0 OID 0)
-- Dependencies: 214
-- Name: usuario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.usuario_id_seq', 5, true);


--
-- TOC entry 3501 (class 0 OID 0)
-- Dependencies: 216
-- Name: veiculo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.veiculo_id_seq', 11, true);


--
-- TOC entry 3302 (class 2606 OID 16503)
-- Name: alerta alerta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerta
    ADD CONSTRAINT alerta_pkey PRIMARY KEY (id);


--
-- TOC entry 3300 (class 2606 OID 16490)
-- Name: configuracaoalerta configuracaoalerta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracaoalerta
    ADD CONSTRAINT configuracaoalerta_pkey PRIMARY KEY (id);


--
-- TOC entry 3287 (class 2606 OID 16418)
-- Name: frota frota_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.frota
    ADD CONSTRAINT frota_pkey PRIMARY KEY (id);


--
-- TOC entry 3289 (class 2606 OID 16428)
-- Name: frotaveiculo frotaveiculo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.frotaveiculo
    ADD CONSTRAINT frotaveiculo_pkey PRIMARY KEY (frota_id, veiculo_id);


--
-- TOC entry 3296 (class 2606 OID 16461)
-- Name: localizacao localizacao_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.localizacao
    ADD CONSTRAINT localizacao_pkey PRIMARY KEY (id);


--
-- TOC entry 3291 (class 2606 OID 16448)
-- Name: rastreador rastreador_identificador_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rastreador
    ADD CONSTRAINT rastreador_identificador_key UNIQUE (identificador);


--
-- TOC entry 3293 (class 2606 OID 16446)
-- Name: rastreador rastreador_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rastreador
    ADD CONSTRAINT rastreador_pkey PRIMARY KEY (id);


--
-- TOC entry 3298 (class 2606 OID 16474)
-- Name: trajeto trajeto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trajeto
    ADD CONSTRAINT trajeto_pkey PRIMARY KEY (id);


--
-- TOC entry 3279 (class 2606 OID 16395)
-- Name: usuario usuario_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_email_key UNIQUE (email);


--
-- TOC entry 3281 (class 2606 OID 16393)
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id);


--
-- TOC entry 3283 (class 2606 OID 16403)
-- Name: veiculo veiculo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.veiculo
    ADD CONSTRAINT veiculo_pkey PRIMARY KEY (id);


--
-- TOC entry 3285 (class 2606 OID 16405)
-- Name: veiculo veiculo_placa_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.veiculo
    ADD CONSTRAINT veiculo_placa_key UNIQUE (placa);


--
-- TOC entry 3294 (class 1259 OID 16467)
-- Name: idx_localizacao_horario_rastreador; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_localizacao_horario_rastreador ON public.localizacao USING btree (horario_rastreador);


--
-- TOC entry 3311 (class 2606 OID 16514)
-- Name: alerta alerta_configuracaoalerta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerta
    ADD CONSTRAINT alerta_configuracaoalerta_id_fkey FOREIGN KEY (configuracaoalerta_id) REFERENCES public.configuracaoalerta(id) ON DELETE CASCADE;


--
-- TOC entry 3312 (class 2606 OID 16509)
-- Name: alerta alerta_localizacao_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerta
    ADD CONSTRAINT alerta_localizacao_id_fkey FOREIGN KEY (localizacao_id) REFERENCES public.localizacao(id) ON DELETE CASCADE;


--
-- TOC entry 3313 (class 2606 OID 16504)
-- Name: alerta alerta_veiculo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerta
    ADD CONSTRAINT alerta_veiculo_id_fkey FOREIGN KEY (veiculo_id) REFERENCES public.veiculo(id) ON DELETE CASCADE;


--
-- TOC entry 3310 (class 2606 OID 16491)
-- Name: configuracaoalerta configuracaoalerta_veiculo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracaoalerta
    ADD CONSTRAINT configuracaoalerta_veiculo_id_fkey FOREIGN KEY (veiculo_id) REFERENCES public.veiculo(id) ON DELETE CASCADE;


--
-- TOC entry 3304 (class 2606 OID 16419)
-- Name: frota frota_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.frota
    ADD CONSTRAINT frota_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id) ON DELETE CASCADE;


--
-- TOC entry 3305 (class 2606 OID 16429)
-- Name: frotaveiculo frotaveiculo_frota_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.frotaveiculo
    ADD CONSTRAINT frotaveiculo_frota_id_fkey FOREIGN KEY (frota_id) REFERENCES public.frota(id) ON DELETE CASCADE;


--
-- TOC entry 3306 (class 2606 OID 16434)
-- Name: frotaveiculo frotaveiculo_veiculo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.frotaveiculo
    ADD CONSTRAINT frotaveiculo_veiculo_id_fkey FOREIGN KEY (veiculo_id) REFERENCES public.veiculo(id) ON DELETE CASCADE;


--
-- TOC entry 3308 (class 2606 OID 16462)
-- Name: localizacao localizacao_rastreador_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.localizacao
    ADD CONSTRAINT localizacao_rastreador_id_fkey FOREIGN KEY (rastreador_id) REFERENCES public.rastreador(id) ON DELETE CASCADE;


--
-- TOC entry 3307 (class 2606 OID 16449)
-- Name: rastreador rastreador_veiculo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rastreador
    ADD CONSTRAINT rastreador_veiculo_id_fkey FOREIGN KEY (veiculo_id) REFERENCES public.veiculo(id) ON DELETE CASCADE;


--
-- TOC entry 3309 (class 2606 OID 16475)
-- Name: trajeto trajeto_veiculo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trajeto
    ADD CONSTRAINT trajeto_veiculo_id_fkey FOREIGN KEY (veiculo_id) REFERENCES public.veiculo(id) ON DELETE CASCADE;


--
-- TOC entry 3303 (class 2606 OID 16406)
-- Name: veiculo veiculo_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.veiculo
    ADD CONSTRAINT veiculo_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id) ON DELETE CASCADE;


-- Completed on 2024-06-24 18:51:32

--
-- PostgreSQL database dump complete
--

