CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Таблицы создаются JPA (ddl-auto: update), но init-скрипт выполняется раньше.
-- Создаём схему вручную, JPA обновит при необходимости.

CREATE TABLE IF NOT EXISTS cart
(
    user_id UUID PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS cart_item
(
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_variation_id UUID    NOT NULL,
    quantity             INTEGER NOT NULL,
    cart_id              UUID REFERENCES cart (user_id),
    UNIQUE (cart_id, product_variation_id)
);

-- Корзина для тестового пользователя с двумя товарами
INSERT INTO cart (user_id) VALUES
    ('30000000-0000-0000-0000-000000000001')
ON CONFLICT DO NOTHING;

INSERT INTO cart_item (product_variation_id, quantity, cart_id) VALUES
    ('e0000000-0000-0000-0000-000000000001', 1, '30000000-0000-0000-0000-000000000001'),
    ('e0000000-0000-0000-0000-000000000003', 2, '30000000-0000-0000-0000-000000000001')
ON CONFLICT DO NOTHING;
