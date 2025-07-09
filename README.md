# 🛒 E-Commerce Microservices Platform

Проект представляет собой модульную микросервисную архитектуру интернет-магазина, разработанную на Java с использованием Spring Boot, Kafka и других современных технологий.

## 🧩 Архитектура микросервисов

Каждый микросервис располагается в отдельном репозитории:

| Микросервис | Назначение | Репозиторий |
|-------------|------------|-------------|
| `api-gateway` | Единая точка входа, маршрутизация запросов | https://github.com/Smisiw/MarketPlaceProject |
| `auth-service` | Аутентификация, авторизация пользователей, JWT | https://github.com/Smisiw/AuthService |
| `product-service` | Управление товарами, вариациями, категориями и атрибутами | https://github.com/Smisiw/ProductService |
| `cart-service` | Управление корзиной пользователей, слияние сессий | https://github.com/Smisiw/CartService |
| `order-service` | Управление заказами и их статусами *(в процессе разработки)* | https://github.com/Smisiw/OrderService |
| `payment-service` | Обработка и отслеживание оплат *(в процессе)* | |
| `delivery-service` | Обработка информации о доставке *(в процессе)* | |
| `favorites-service` | Избранные товары *(в процессе)* | |
| `notification-service` | Отправка уведомлений (по email, Kafka events и пр.) *(опционально)* | |
| `eureka-server` | Сервис-дискавери | |
| `config-server` | Централизованная конфигурация *(опционально)* | |

## 🔐 Роли пользователей

- `ROLE_ADMIN`: Полный доступ
- `ROLE_SELLER`: Управление только своими товарами
- `ROLE_USER`: Просмотр товаров, управление своей корзиной и заказами

## 📦 Текущие возможности

- ✅ JWT авторизация с ролями
- ✅ Управление товарами и категориями
- ✅ Поддержка вариаций товаров и атрибутов
- ✅ Хранение корзины в БД
- ✅ Слияние корзин при логине
- ⏳ Заказы, оплата и доставка — в процессе реализации

## 📚 Технологии

- Java 17
- Spring Boot
- Spring Cloud
- Spring Security
- Kafka
- PostgreSQL
- Redis
- Docker
- Feign Client
- MapStruct
- CI/CD: GitHub Actions


## 🏁 Запуск

```bash
# Запуск всех сервисов (локально)
docker compose pull
docker compose up --build -d
```
