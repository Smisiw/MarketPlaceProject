-- Этот скрипт выполняется при первом старте postgres-контейнера (до Flyway).
-- Flyway (baseline-on-migrate=true) увидит существующие таблицы и пропустит V1.

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS attributes
(
    id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS categories
(
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name           VARCHAR(100) NOT NULL,
    route_location VARCHAR(100) NOT NULL,
    parent_id      UUID,
    CONSTRAINT fk_category_parent FOREIGN KEY (parent_id) REFERENCES categories (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS category_attributes
(
    category_id  UUID NOT NULL REFERENCES categories (id) ON DELETE CASCADE,
    attribute_id UUID NOT NULL REFERENCES attributes (id) ON DELETE CASCADE,
    PRIMARY KEY (category_id, attribute_id)
);

CREATE TABLE IF NOT EXISTS products
(
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id   UUID      NOT NULL,
    category_id UUID      NOT NULL REFERENCES categories (id),
    created_at  TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS product_variations
(
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id  UUID           NOT NULL REFERENCES products (id) ON DELETE CASCADE,
    name        TEXT           NOT NULL,
    description TEXT,
    price       NUMERIC(10, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS attribute_values
(
    variation_id UUID NOT NULL REFERENCES product_variations (id) ON DELETE CASCADE,
    attribute_id UUID NOT NULL REFERENCES attributes (id),
    PRIMARY KEY (variation_id, attribute_id),
    value        TEXT NOT NULL
);

-- Тестовые данные
INSERT INTO attributes (id, name) VALUES
    ('c0000000-0000-0000-0000-000000000001', 'Цвет'),
    ('c0000000-0000-0000-0000-000000000002', 'Объём памяти')
ON CONFLICT DO NOTHING;

INSERT INTO categories (id, name, route_location, parent_id) VALUES
    ('b0000000-0000-0000-0000-000000000001', 'Электроника', 'electronics',             NULL),
    ('b0000000-0000-0000-0000-000000000002', 'Смартфоны',   'electronics/smartphones', 'b0000000-0000-0000-0000-000000000001')
ON CONFLICT DO NOTHING;

INSERT INTO category_attributes (category_id, attribute_id) VALUES
    ('b0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001'),
    ('b0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000002')
ON CONFLICT DO NOTHING;

-- seller_id совпадает с ID продавца из auth-сервиса
INSERT INTO products (id, seller_id, category_id) VALUES
    ('d0000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000002'),
    ('d0000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000002')
ON CONFLICT DO NOTHING;

INSERT INTO product_variations (id, product_id, name, description, price) VALUES
    ('e0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000001', 'iPhone 15 128GB Чёрный',  'Флагман Apple 2023 года',    89990.00),
    ('e0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000001', 'iPhone 15 256GB Белый',   'Флагман Apple 2023 года',    99990.00),
    ('e0000000-0000-0000-0000-000000000003', 'd0000000-0000-0000-0000-000000000002', 'Samsung S24 128GB Синий', 'Флагман Samsung 2024 года',  79990.00)
ON CONFLICT DO NOTHING;

INSERT INTO attribute_values (variation_id, attribute_id, value) VALUES
    ('e0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'Чёрный'),
    ('e0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000002', '128 ГБ'),
    ('e0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', 'Белый'),
    ('e0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000002', '256 ГБ'),
    ('e0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000001', 'Синий'),
    ('e0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000002', '128 ГБ')
ON CONFLICT DO NOTHING;
