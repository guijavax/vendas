--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

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
-- Name: sales; Type: SCHEMA; Schema: -; Owner: adm
--

CREATE SCHEMA sales;


ALTER SCHEMA sales OWNER TO adm;

--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA sales;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: address_type; Type: TYPE; Schema: sales; Owner: adm
--

CREATE TYPE sales.address_type AS ENUM (
    'BILLING',
    'SHIPPING'
);


ALTER TYPE sales.address_type OWNER TO adm;

--
-- Name: order_status; Type: TYPE; Schema: sales; Owner: adm
--

CREATE TYPE sales.order_status AS ENUM (
    'DRAFT',
    'PENDING_PAYMENT',
    'PAID',
    'FULFILLED',
    'CANCELLED'
);


ALTER TYPE sales.order_status OWNER TO adm;

--
-- Name: payment_method; Type: TYPE; Schema: sales; Owner: adm
--

CREATE TYPE sales.payment_method AS ENUM (
    'CREDIT_CARD',
    'PIX',
    'BOLETO',
    'TRANSFER'
);


ALTER TYPE sales.payment_method OWNER TO adm;

--
-- Name: payment_status; Type: TYPE; Schema: sales; Owner: adm
--

CREATE TYPE sales.payment_status AS ENUM (
    'PENDING',
    'AUTHORIZED',
    'CAPTURED',
    'REFUNDED',
    'FAILED'
);


ALTER TYPE sales.payment_status OWNER TO adm;

--
-- Name: shipment_status; Type: TYPE; Schema: sales; Owner: adm
--

CREATE TYPE sales.shipment_status AS ENUM (
    'PENDING',
    'SHIPPED',
    'DELIVERED',
    'LOST',
    'RETURNED'
);


ALTER TYPE sales.shipment_status OWNER TO adm;

--
-- Name: adjust_stock_on_status_change(); Type: FUNCTION; Schema: sales; Owner: adm
--

CREATE FUNCTION sales.adjust_stock_on_status_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec record;
BEGIN
  -- Baixa ao FULFILLED
  IF (TG_OP = 'UPDATE'
      AND NEW.status = 'FULFILLED'
      AND OLD.status <> 'FULFILLED') THEN

    FOR rec IN
      SELECT oi.product_id, oi.quantity
      FROM order_items oi
      WHERE oi.order_id = NEW.order_id
    LOOP
      IF (SELECT qty_on_hand FROM inventory WHERE product_id = rec.product_id) < rec.quantity THEN
        RAISE EXCEPTION 'Estoque insuficiente para product_id=% (pedido=%)', rec.product_id, NEW.order_id;
      END IF;

      UPDATE inventory
         SET qty_on_hand = qty_on_hand - rec.quantity
       WHERE product_id = rec.product_id;
    END LOOP;
  END IF;

  -- Reposição ao cancelar pedido que já estava FULFILLED
  IF (TG_OP = 'UPDATE'
      AND NEW.status = 'CANCELLED'
      AND OLD.status = 'FULFILLED') THEN
    FOR rec IN
      SELECT oi.product_id, oi.quantity
      FROM order_items oi
      WHERE oi.order_id = NEW.order_id
    LOOP
      UPDATE inventory
         SET qty_on_hand = qty_on_hand + rec.quantity
       WHERE product_id = rec.product_id;
    END LOOP;
  END IF;

  RETURN NEW;
END$$;


ALTER FUNCTION sales.adjust_stock_on_status_change() OWNER TO adm;

--
-- Name: log_order_status_change(); Type: FUNCTION; Schema: sales; Owner: adm
--

CREATE FUNCTION sales.log_order_status_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF TG_OP = 'UPDATE' AND NEW.status IS DISTINCT FROM OLD.status THEN
    INSERT INTO order_status_history(order_id, old_status, new_status, changed_at)
    VALUES (NEW.order_id, OLD.status, NEW.status, now());
  END IF;
  RETURN NEW;
END$$;


ALTER FUNCTION sales.log_order_status_change() OWNER TO adm;

--
-- Name: set_updated_at(); Type: FUNCTION; Schema: sales; Owner: adm
--

CREATE FUNCTION sales.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END$$;


ALTER FUNCTION sales.set_updated_at() OWNER TO adm;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: addresses; Type: TABLE; Schema: sales; Owner: adm
--

CREATE TABLE sales.addresses (
    address_id bigint NOT NULL,
    customer_id bigint NOT NULL,
    kind sales.address_type NOT NULL,
    line1 text NOT NULL,
    line2 text,
    city text NOT NULL,
    state text NOT NULL,
    postal_code text NOT NULL,
    country text DEFAULT 'BR'::text NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE sales.addresses OWNER TO adm;

--
-- Name: addresses_address_id_seq; Type: SEQUENCE; Schema: sales; Owner: adm
--

ALTER TABLE sales.addresses ALTER COLUMN address_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME sales.addresses_address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: categories; Type: TABLE; Schema: sales; Owner: adm
--

CREATE TABLE sales.categories (
    category_id bigint NOT NULL,
    name text NOT NULL,
    parent_id bigint
);


ALTER TABLE sales.categories OWNER TO adm;

--
-- Name: categories_category_id_seq; Type: SEQUENCE; Schema: sales; Owner: adm
--

ALTER TABLE sales.categories ALTER COLUMN category_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME sales.categories_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: customers; Type: TABLE; Schema: sales; Owner: adm
--

CREATE TABLE sales.customers (
    customer_id bigint NOT NULL,
    full_name text NOT NULL,
    email sales.citext NOT NULL,
    phone text,
    tax_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE sales.customers OWNER TO adm;

--
-- Name: customers_customer_id_seq; Type: SEQUENCE; Schema: sales; Owner: adm
--

ALTER TABLE sales.customers ALTER COLUMN customer_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME sales.customers_customer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: inventory; Type: TABLE; Schema: sales; Owner: adm
--

CREATE TABLE sales.inventory (
    product_id bigint NOT NULL,
    qty_on_hand integer NOT NULL,
    reorder_level integer DEFAULT 5 NOT NULL,
    warehouse_location text,
    CONSTRAINT inventory_qty_on_hand_check CHECK ((qty_on_hand >= 0)),
    CONSTRAINT inventory_reorder_level_check CHECK ((reorder_level >= 0))
);


ALTER TABLE sales.inventory OWNER TO adm;

--
-- Name: order_items; Type: TABLE; Schema: sales; Owner: adm
--

CREATE TABLE sales.order_items (
    order_id bigint NOT NULL,
    item_no integer NOT NULL,
    product_id bigint NOT NULL,
    quantity integer NOT NULL,
    unit_price numeric(12,2) NOT NULL,
    discount_value numeric(12,2) DEFAULT 0 NOT NULL,
    CONSTRAINT order_items_discount_value_check CHECK ((discount_value >= (0)::numeric)),
    CONSTRAINT order_items_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT order_items_unit_price_check CHECK ((unit_price >= (0)::numeric))
);


ALTER TABLE sales.order_items OWNER TO adm;

--
-- Name: order_status_history; Type: TABLE; Schema: sales; Owner: adm
--

CREATE TABLE sales.order_status_history (
    history_id bigint NOT NULL,
    order_id bigint NOT NULL,
    old_status sales.order_status,
    new_status sales.order_status NOT NULL,
    changed_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE sales.order_status_history OWNER TO adm;

--
-- Name: order_status_history_history_id_seq; Type: SEQUENCE; Schema: sales; Owner: adm
--

ALTER TABLE sales.order_status_history ALTER COLUMN history_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME sales.order_status_history_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: orders; Type: TABLE; Schema: sales; Owner: adm
--

CREATE TABLE sales.orders (
    order_id bigint NOT NULL,
    customer_id bigint NOT NULL,
    billing_address_id bigint,
    shipping_address_id bigint,
    order_date timestamp with time zone DEFAULT now() NOT NULL,
    status sales.order_status DEFAULT 'DRAFT'::sales.order_status NOT NULL,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE sales.orders OWNER TO adm;

--
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: sales; Owner: adm
--

ALTER TABLE sales.orders ALTER COLUMN order_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME sales.orders_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: payments; Type: TABLE; Schema: sales; Owner: adm
--

CREATE TABLE sales.payments (
    payment_id bigint NOT NULL,
    order_id bigint NOT NULL,
    method sales.payment_method NOT NULL,
    status sales.payment_status DEFAULT 'PENDING'::sales.payment_status NOT NULL,
    amount numeric(12,2) NOT NULL,
    paid_at timestamp with time zone,
    transaction_ref text,
    CONSTRAINT payments_amount_check CHECK ((amount >= (0)::numeric))
);


ALTER TABLE sales.payments OWNER TO adm;

--
-- Name: payments_payment_id_seq; Type: SEQUENCE; Schema: sales; Owner: adm
--

ALTER TABLE sales.payments ALTER COLUMN payment_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME sales.payments_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: products; Type: TABLE; Schema: sales; Owner: adm
--

CREATE TABLE sales.products (
    product_id bigint NOT NULL,
    sku character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    category_id bigint,
    supplier_id bigint,
    price numeric(12,2) NOT NULL,
    cost numeric(12,2) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT products_cost_check CHECK ((cost >= (0)::numeric)),
    CONSTRAINT products_price_check CHECK ((price >= (0)::numeric))
);


ALTER TABLE sales.products OWNER TO adm;

--
-- Name: products_product_id_seq; Type: SEQUENCE; Schema: sales; Owner: adm
--

ALTER TABLE sales.products ALTER COLUMN product_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME sales.products_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: shipments; Type: TABLE; Schema: sales; Owner: adm
--

CREATE TABLE sales.shipments (
    shipment_id bigint NOT NULL,
    order_id bigint NOT NULL,
    carrier text,
    tracking_no text,
    shipped_at timestamp with time zone,
    delivered_at timestamp with time zone,
    status sales.shipment_status DEFAULT 'PENDING'::sales.shipment_status NOT NULL
);


ALTER TABLE sales.shipments OWNER TO adm;

--
-- Name: shipments_shipment_id_seq; Type: SEQUENCE; Schema: sales; Owner: adm
--

ALTER TABLE sales.shipments ALTER COLUMN shipment_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME sales.shipments_shipment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: suppliers; Type: TABLE; Schema: sales; Owner: adm
--

CREATE TABLE sales.suppliers (
    supplier_id bigint NOT NULL,
    name text NOT NULL,
    tax_id text,
    email sales.citext,
    phone text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE sales.suppliers OWNER TO adm;

--
-- Name: suppliers_supplier_id_seq; Type: SEQUENCE; Schema: sales; Owner: adm
--

ALTER TABLE sales.suppliers ALTER COLUMN supplier_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME sales.suppliers_supplier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: vw_order_totals; Type: VIEW; Schema: sales; Owner: adm
--

CREATE VIEW sales.vw_order_totals AS
 SELECT o.order_id,
    o.customer_id,
    o.status,
    sum(((oi.quantity)::numeric * oi.unit_price)) AS gross_amount,
    sum(oi.discount_value) AS discount_amount,
    (sum(((oi.quantity)::numeric * oi.unit_price)) - sum(oi.discount_value)) AS net_amount
   FROM (sales.orders o
     JOIN sales.order_items oi USING (order_id))
  GROUP BY o.order_id, o.customer_id, o.status;


ALTER VIEW sales.vw_order_totals OWNER TO adm;

--
-- Name: vw_customer_ltv; Type: VIEW; Schema: sales; Owner: adm
--

CREATE VIEW sales.vw_customer_ltv AS
 SELECT c.customer_id,
    c.full_name,
    COALESCE(sum(v.net_amount), (0)::numeric) AS lifetime_value
   FROM (sales.customers c
     LEFT JOIN sales.vw_order_totals v ON ((v.customer_id = c.customer_id)))
  GROUP BY c.customer_id, c.full_name
  ORDER BY COALESCE(sum(v.net_amount), (0)::numeric) DESC;


ALTER VIEW sales.vw_customer_ltv OWNER TO adm;

--
-- Data for Name: addresses; Type: TABLE DATA; Schema: sales; Owner: adm
--

COPY sales.addresses (address_id, customer_id, kind, line1, line2, city, state, postal_code, country, is_default, created_at) FROM stdin;
1	1	BILLING	Rua A, 100	\N	São Paulo	SP	01000-000	BR	t	2025-09-12 21:30:19.698523-03
2	1	SHIPPING	Rua B, 200	\N	São Paulo	SP	02000-000	BR	t	2025-09-12 21:30:19.698523-03
3	2	BILLING	Av Central, 500	\N	Rio de Janeiro	RJ	20000-000	BR	t	2025-09-12 21:30:19.698523-03
4	2	SHIPPING	Rua das Laranjeiras, 50	\N	Rio de Janeiro	RJ	22240-003	BR	t	2025-09-12 21:30:19.698523-03
5	3	BILLING	Rua Um, 10	\N	Belo Horizonte	MG	30000-000	BR	t	2025-09-12 21:30:19.698523-03
6	3	SHIPPING	Rua Dois, 20	\N	Belo Horizonte	MG	30010-010	BR	t	2025-09-12 21:30:19.698523-03
7	4	BILLING	Rua Três, 30	\N	Curitiba	PR	80000-000	BR	t	2025-09-12 21:30:19.698523-03
8	4	SHIPPING	Rua Quatro, 40	\N	Curitiba	PR	80020-020	BR	t	2025-09-12 21:30:19.698523-03
9	5	BILLING	Rua Cinco, 50	\N	Porto Alegre	RS	90000-000	BR	t	2025-09-12 21:30:19.698523-03
10	5	SHIPPING	Rua Seis, 60	\N	Porto Alegre	RS	90030-030	BR	t	2025-09-12 21:30:19.698523-03
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: sales; Owner: adm
--

COPY sales.categories (category_id, name, parent_id) FROM stdin;
1	Eletrônicos	\N
2	Acessórios	\N
3	Casa & Cozinha	\N
4	Escritório	\N
5	Fitness	\N
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: sales; Owner: adm
--

COPY sales.customers (customer_id, full_name, email, phone, tax_id, created_at, updated_at) FROM stdin;
1	Ana Souza	ana@example.com	(11) 90000-0001	11122233344	2025-09-12 21:30:01.534215-03	2025-09-12 21:30:01.534215-03
2	Bruno Lima	bruno@example.com	(21) 90000-0002	22233344455	2025-09-12 21:30:01.534215-03	2025-09-12 21:30:01.534215-03
3	Carla Mendes	carla@example.com	(31) 90000-0003	33344455566	2025-09-12 21:30:01.534215-03	2025-09-12 21:30:01.534215-03
4	Diego Santos	diego@example.com	(41) 90000-0004	44455566677	2025-09-12 21:30:01.534215-03	2025-09-12 21:30:01.534215-03
5	Eduarda Campos	edu@example.com	(51) 90000-0005	55566677788	2025-09-12 21:30:01.534215-03	2025-09-12 21:30:01.534215-03
\.


--
-- Data for Name: inventory; Type: TABLE DATA; Schema: sales; Owner: adm
--

COPY sales.inventory (product_id, qty_on_hand, reorder_level, warehouse_location) FROM stdin;
1	50	5	A-01
2	40	5	A-01
3	100	5	A-01
4	80	5	A-01
5	25	5	A-01
6	35	5	A-01
7	10	5	A-01
8	90	5	A-01
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: sales; Owner: adm
--

COPY sales.order_items (order_id, item_no, product_id, quantity, unit_price, discount_value) FROM stdin;
8	1	5	1	599.90	0.00
8	2	4	2	129.90	10.00
9	1	1	1	199.90	0.00
9	2	8	1	149.90	0.00
10	1	7	1	1299.90	0.00
\.


--
-- Data for Name: order_status_history; Type: TABLE DATA; Schema: sales; Owner: adm
--

COPY sales.order_status_history (history_id, order_id, old_status, new_status, changed_at) FROM stdin;
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: sales; Owner: adm
--

COPY sales.orders (order_id, customer_id, billing_address_id, shipping_address_id, order_date, status, notes, created_at, updated_at) FROM stdin;
8	1	1	2	2025-09-02 21:44:55.205529-03	PAID	Pedido inicial da Ana	2025-09-12 21:44:55.205529-03	2025-09-12 21:44:55.205529-03
9	2	3	4	2025-09-09 21:45:33.059576-03	PENDING_PAYMENT	Aguardando pagamento	2025-09-12 21:45:33.059576-03	2025-09-12 21:45:33.059576-03
10	3	5	6	2025-09-07 21:46:06.31636-03	PAID	Compra Carla	2025-09-12 21:46:06.31636-03	2025-09-12 21:46:06.31636-03
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: sales; Owner: adm
--

COPY sales.payments (payment_id, order_id, method, status, amount, paid_at, transaction_ref) FROM stdin;
15	8	CREDIT_CARD	CAPTURED	0.00	2025-09-03 21:44:55.205529-03	TRX-ANA-001
17	9	PIX	PENDING	0.00	\N	\N
18	9	PIX	PENDING	0.00	\N	\N
19	10	BOLETO	CAPTURED	0.00	2025-09-08 21:46:06.31636-03	TRX-CARLA-001
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: sales; Owner: adm
--

COPY sales.products (product_id, sku, name, category_id, supplier_id, price, cost, active, created_at) FROM stdin;
1	SKU-001	Fone Bluetooth	1	1	199.90	90.00	t	2025-09-12 21:30:48.0669-03
2	SKU-002	Teclado Mecânico	4	1	349.90	180.00	t	2025-09-12 21:30:48.0669-03
3	SKU-003	Garrafa Térmica 1L	3	2	89.90	35.00	t	2025-09-12 21:30:48.0669-03
4	SKU-004	Mouse Sem Fio	2	1	129.90	55.00	t	2025-09-12 21:30:48.0669-03
5	SKU-005	Smartwatch Fit	5	1	599.90	320.00	t	2025-09-12 21:30:48.0669-03
6	SKU-006	Cafeteira Elétrica	3	2	249.90	120.00	t	2025-09-12 21:30:48.0669-03
7	SKU-007	Cadeira Gamer	4	2	1299.90	700.00	t	2025-09-12 21:30:48.0669-03
8	SKU-008	Carregador USB-C 30W	2	1	149.90	60.00	t	2025-09-12 21:30:48.0669-03
\.


--
-- Data for Name: shipments; Type: TABLE DATA; Schema: sales; Owner: adm
--

COPY sales.shipments (shipment_id, order_id, carrier, tracking_no, shipped_at, delivered_at, status) FROM stdin;
8	8	Correios	BR123456789BR	2025-09-04 21:44:55.205529-03	2025-09-06 21:44:55.205529-03	DELIVERED
9	10	Transportadora X	TX000777	2025-09-08 21:46:06.31636-03	2025-09-10 21:46:06.31636-03	DELIVERED
\.


--
-- Data for Name: suppliers; Type: TABLE DATA; Schema: sales; Owner: adm
--

COPY sales.suppliers (supplier_id, name, tax_id, email, phone, created_at) FROM stdin;
1	Tech Import	12.345.678/0001-00	contato@techimport.com	(11) 4000-1000	2025-09-12 21:30:48.0669-03
2	Brasil Distrib	98.765.432/0001-00	vendas@brasildistrib.com	(21) 4000-2000	2025-09-12 21:30:48.0669-03
\.


--
-- Name: addresses_address_id_seq; Type: SEQUENCE SET; Schema: sales; Owner: adm
--

SELECT pg_catalog.setval('sales.addresses_address_id_seq', 10, true);


--
-- Name: categories_category_id_seq; Type: SEQUENCE SET; Schema: sales; Owner: adm
--

SELECT pg_catalog.setval('sales.categories_category_id_seq', 5, true);


--
-- Name: customers_customer_id_seq; Type: SEQUENCE SET; Schema: sales; Owner: adm
--

SELECT pg_catalog.setval('sales.customers_customer_id_seq', 5, true);


--
-- Name: order_status_history_history_id_seq; Type: SEQUENCE SET; Schema: sales; Owner: adm
--

SELECT pg_catalog.setval('sales.order_status_history_history_id_seq', 1, false);


--
-- Name: orders_order_id_seq; Type: SEQUENCE SET; Schema: sales; Owner: adm
--

SELECT pg_catalog.setval('sales.orders_order_id_seq', 10, true);


--
-- Name: payments_payment_id_seq; Type: SEQUENCE SET; Schema: sales; Owner: adm
--

SELECT pg_catalog.setval('sales.payments_payment_id_seq', 19, true);


--
-- Name: products_product_id_seq; Type: SEQUENCE SET; Schema: sales; Owner: adm
--

SELECT pg_catalog.setval('sales.products_product_id_seq', 8, true);


--
-- Name: shipments_shipment_id_seq; Type: SEQUENCE SET; Schema: sales; Owner: adm
--

SELECT pg_catalog.setval('sales.shipments_shipment_id_seq', 9, true);


--
-- Name: suppliers_supplier_id_seq; Type: SEQUENCE SET; Schema: sales; Owner: adm
--

SELECT pg_catalog.setval('sales.suppliers_supplier_id_seq', 2, true);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (address_id);


--
-- Name: categories categories_name_key; Type: CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.categories
    ADD CONSTRAINT categories_name_key UNIQUE (name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (category_id);


--
-- Name: customers customers_email_key; Type: CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.customers
    ADD CONSTRAINT customers_email_key UNIQUE (email);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- Name: customers customers_tax_id_key; Type: CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.customers
    ADD CONSTRAINT customers_tax_id_key UNIQUE (tax_id);


--
-- Name: inventory inventory_pkey; Type: CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.inventory
    ADD CONSTRAINT inventory_pkey PRIMARY KEY (product_id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (order_id, item_no);


--
-- Name: order_status_history order_status_history_pkey; Type: CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.order_status_history
    ADD CONSTRAINT order_status_history_pkey PRIMARY KEY (history_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (payment_id);


--
-- Name: payments payments_transaction_ref_key; Type: CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.payments
    ADD CONSTRAINT payments_transaction_ref_key UNIQUE (transaction_ref);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: products products_sku_key; Type: CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.products
    ADD CONSTRAINT products_sku_key UNIQUE (sku);


--
-- Name: shipments shipments_pkey; Type: CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.shipments
    ADD CONSTRAINT shipments_pkey PRIMARY KEY (shipment_id);


--
-- Name: shipments shipments_tracking_no_key; Type: CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.shipments
    ADD CONSTRAINT shipments_tracking_no_key UNIQUE (tracking_no);


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (supplier_id);


--
-- Name: suppliers suppliers_tax_id_key; Type: CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.suppliers
    ADD CONSTRAINT suppliers_tax_id_key UNIQUE (tax_id);


--
-- Name: idx_customers_created_at; Type: INDEX; Schema: sales; Owner: adm
--

CREATE INDEX idx_customers_created_at ON sales.customers USING btree (created_at);


--
-- Name: idx_order_items_product; Type: INDEX; Schema: sales; Owner: adm
--

CREATE INDEX idx_order_items_product ON sales.order_items USING btree (product_id);


--
-- Name: idx_orders_customer; Type: INDEX; Schema: sales; Owner: adm
--

CREATE INDEX idx_orders_customer ON sales.orders USING btree (customer_id);


--
-- Name: idx_orders_status; Type: INDEX; Schema: sales; Owner: adm
--

CREATE INDEX idx_orders_status ON sales.orders USING btree (status);


--
-- Name: idx_payments_order; Type: INDEX; Schema: sales; Owner: adm
--

CREATE INDEX idx_payments_order ON sales.payments USING btree (order_id);


--
-- Name: idx_shipments_order; Type: INDEX; Schema: sales; Owner: adm
--

CREATE INDEX idx_shipments_order ON sales.shipments USING btree (order_id);


--
-- Name: orders trg_orders_status_history; Type: TRIGGER; Schema: sales; Owner: adm
--

CREATE TRIGGER trg_orders_status_history AFTER UPDATE ON sales.orders FOR EACH ROW EXECUTE FUNCTION sales.log_order_status_change();


--
-- Name: orders trg_orders_stock; Type: TRIGGER; Schema: sales; Owner: adm
--

CREATE TRIGGER trg_orders_stock AFTER UPDATE ON sales.orders FOR EACH ROW EXECUTE FUNCTION sales.adjust_stock_on_status_change();


--
-- Name: orders trg_orders_updated_at; Type: TRIGGER; Schema: sales; Owner: adm
--

CREATE TRIGGER trg_orders_updated_at BEFORE UPDATE ON sales.orders FOR EACH ROW EXECUTE FUNCTION sales.set_updated_at();


--
-- Name: addresses addresses_customer_id_fkey; Type: FK CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.addresses
    ADD CONSTRAINT addresses_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES sales.customers(customer_id) ON DELETE CASCADE;


--
-- Name: categories categories_parent_id_fkey; Type: FK CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.categories
    ADD CONSTRAINT categories_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES sales.categories(category_id) ON DELETE SET NULL;


--
-- Name: inventory inventory_product_id_fkey; Type: FK CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.inventory
    ADD CONSTRAINT inventory_product_id_fkey FOREIGN KEY (product_id) REFERENCES sales.products(product_id) ON DELETE CASCADE;


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES sales.orders(order_id) ON DELETE CASCADE;


--
-- Name: order_items order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.order_items
    ADD CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES sales.products(product_id);


--
-- Name: order_status_history order_status_history_order_id_fkey; Type: FK CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.order_status_history
    ADD CONSTRAINT order_status_history_order_id_fkey FOREIGN KEY (order_id) REFERENCES sales.orders(order_id) ON DELETE CASCADE;


--
-- Name: orders orders_billing_address_id_fkey; Type: FK CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.orders
    ADD CONSTRAINT orders_billing_address_id_fkey FOREIGN KEY (billing_address_id) REFERENCES sales.addresses(address_id);


--
-- Name: orders orders_customer_id_fkey; Type: FK CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.orders
    ADD CONSTRAINT orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES sales.customers(customer_id);


--
-- Name: orders orders_shipping_address_id_fkey; Type: FK CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.orders
    ADD CONSTRAINT orders_shipping_address_id_fkey FOREIGN KEY (shipping_address_id) REFERENCES sales.addresses(address_id);


--
-- Name: payments payments_order_id_fkey; Type: FK CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.payments
    ADD CONSTRAINT payments_order_id_fkey FOREIGN KEY (order_id) REFERENCES sales.orders(order_id) ON DELETE CASCADE;


--
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.products
    ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES sales.categories(category_id) ON DELETE SET NULL;


--
-- Name: products products_supplier_id_fkey; Type: FK CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.products
    ADD CONSTRAINT products_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES sales.suppliers(supplier_id) ON DELETE SET NULL;


--
-- Name: shipments shipments_order_id_fkey; Type: FK CONSTRAINT; Schema: sales; Owner: adm
--

ALTER TABLE ONLY sales.shipments
    ADD CONSTRAINT shipments_order_id_fkey FOREIGN KEY (order_id) REFERENCES sales.orders(order_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

