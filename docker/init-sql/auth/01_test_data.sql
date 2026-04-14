CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Таблицы (JPA создаёт их при старте, но init-скрипты выполняются до этого)
CREATE TABLE IF NOT EXISTS roles
(
    id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS users
(
    id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email    VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS user_roles
(
    user_id UUID NOT NULL REFERENCES users (id),
    role_id UUID NOT NULL REFERENCES roles (id),
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE IF NOT EXISTS refresh_token
(
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    token       VARCHAR(512),
    user_id     UUID REFERENCES users (id),
    expiry_date TIMESTAMP
);

-- Роли
INSERT INTO roles (id, name) VALUES
    ('a0000000-0000-0000-0000-000000000001', 'ROLE_ADMIN'),
    ('a0000000-0000-0000-0000-000000000002', 'ROLE_SELLER'),
    ('a0000000-0000-0000-0000-000000000003', 'ROLE_USER')
ON CONFLICT DO NOTHING;

-- Пользователи (пароль: "password" — BCrypt hash)
INSERT INTO users (id, email, password) VALUES
    ('10000000-0000-0000-0000-000000000001', 'admin@marketplace.dev',  '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
    ('20000000-0000-0000-0000-000000000001', 'seller@marketplace.dev', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'),
    ('30000000-0000-0000-0000-000000000001', 'user@marketplace.dev',   '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy')
ON CONFLICT DO NOTHING;

-- Назначение ролей
INSERT INTO user_roles (user_id, role_id) VALUES
    ('10000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001'), -- admin -> ROLE_ADMIN
    ('20000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000002'), -- seller -> ROLE_SELLER
    ('30000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000003')  -- user -> ROLE_USER
ON CONFLICT DO NOTHING;
