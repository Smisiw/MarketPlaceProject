CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Таблицы создаются JPA (ddl-auto: update), но init-скрипт выполняется раньше.

CREATE TABLE IF NOT EXISTS orders
(
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id          UUID           NOT NULL,
    status           VARCHAR(50),
    total_price      NUMERIC(10, 2),
    created_at       TIMESTAMP,
    delivery_address VARCHAR(500),
    payment_method   VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS order_item
(
    id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_variation_id     UUID           NOT NULL,
    quantity                 INTEGER        NOT NULL,
    unit_price               NUMERIC(10, 2) NOT NULL,
    status                   VARCHAR(50)    NOT NULL,
    delivery_tracking_number VARCHAR(255),
    estimated_delivery_date  TIMESTAMP,
    delivery_date            TIMESTAMP,
    cancellation_reason      TEXT,
    order_id                 UUID REFERENCES orders (id)
);

-- Один завершённый заказ для тестового пользователя
INSERT INTO orders (id, user_id, status, total_price, created_at, delivery_address, payment_method) VALUES
    ('f0000000-0000-0000-0000-000000000001',
     '30000000-0000-0000-0000-000000000001',
     'COMPLETED',
     89990.00,
     NOW() - INTERVAL '7 days',
     'г. Москва, ул. Тверская, д. 1',
     'CARD')
ON CONFLICT DO NOTHING;

INSERT INTO order_item (product_variation_id, quantity, unit_price, status, order_id) VALUES
    ('e0000000-0000-0000-0000-000000000001',
     1,
     89990.00,
     'DELIVERED',
     'f0000000-0000-0000-0000-000000000001')
ON CONFLICT DO NOTHING;
