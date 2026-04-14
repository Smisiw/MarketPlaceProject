# API Gateway

Единая точка входа в систему Marketplace. Реализован на Spring Cloud Gateway (WebFlux). Выполняет JWT-валидацию, маршрутизацию запросов к downstream-сервисам через Eureka, CORS-конфигурацию и агрегацию Swagger UI.

- **Порт:** 8080
- **Имя в Eureka:** `API-GATEWAY`
- **Java:** 21
- **Spring Boot:** 3.4.4

---

## Содержание

- [Назначение](#назначение)
- [Маршруты Gateway](#маршруты-gateway)
- [Фильтры](#фильтры)
- [Swagger UI](#swagger-ui)
- [Переменные окружения](#переменные-окружения)
- [Docker Compose](#docker-compose)
- [Сборка и запуск](#сборка-и-запуск)

---

## Назначение

- **Маршрутизация** всех входящих HTTP-запросов к нужному микросервису через Eureka (`lb://SERVICE-NAME`).
- **JWT-валидация** на уровне Gateway: фильтр `JwtAuthenticationFilter` проверяет подпись и срок действия токена для всех защищённых маршрутов.
- **Публичный маршрут** `/auth/**` пропускается без проверки токена.
- **Прокси к Dadata API** (`/iplocate/**`): автоматически подставляет IP клиента в запрос и добавляет токен авторизации Dadata.
- **Агрегация Swagger UI**: объединяет документацию всех сервисов на одной странице.

---

## Маршруты Gateway

Определены в `src/main/resources/application.yml`.

| ID маршрута       | Предикат (Path)                                     | Целевой сервис (Eureka)   | JWT-фильтр |
|-------------------|-----------------------------------------------------|---------------------------|------------|
| `auth_service`    | `/auth/**`                                          | `lb://AUTH-SERVICE`       | Нет        |
| `product_service` | `/api/products/**`, `/api/search/**`                | `lb://PRODUCT-SERVICE`    | Да         |
| `cart-service`    | `/api/cart/**`                                      | `lb://CART-SERVICE`       | Да         |
| `order-service`   | `/api/orders/**`                                    | `lb://ORDER-SERVICE`      | Да         |
| `ip-location-api` | `/iplocate/**`                                      | `https://suggestions.dadata.ru` | Нет  |

Для каждого сервиса настроено перенаправление путей `/v3/api-docs` и `/swagger-ui.html` для агрегации документации.

---

## Фильтры

### JwtAuthenticationFilter

Применяется ко всем маршрутам, кроме `/auth/**`. Алгоритм:
1. Извлекает заголовок `Authorization: Bearer <token>`.
2. Если заголовок присутствует — проверяет подпись (HMAC-SHA, ключ `JWT_SECRET`) и срок действия.
3. При невалидном токене возвращает ошибку; при отсутствии — пропускает запрос (защита перекладывается на downstream-сервис).

### AddClientIpParamFilter

Применяется к маршруту `/iplocate/**`. Извлекает IP-адрес клиента из `RemoteAddress` и добавляет его как query-параметр `ip=` в запрос к Dadata.

---

## Swagger UI

Агрегированная документация всех сервисов:

```
http://localhost:8080/swagger-ui.html
```

Настроен в `application.yml` через `springdoc.swagger-ui.urls`:

| Имя             | URL источника                |
|-----------------|------------------------------|
| Auth Service    | `/auth/v3/api-docs`          |
| Product Service | `/api/products/v3/api-docs`  |
| Cart Service    | `/api/cart/v3/api-docs`      |
| Order Service   | `/api/orders/v3/api-docs`    |

Функция `persist-authorization: true` сохраняет введённый токен между переходами между сервисами.

---

## Переменные окружения

| Переменная              | По умолчанию (dev)                               | Описание                                               |
|-------------------------|--------------------------------------------------|--------------------------------------------------------|
| `JWT_SECRET`            | `nTDmGYqtvLfDCptgzwG+xKGtXV/JHL4fHKJrxK9tHdI=` | HMAC-ключ для проверки JWT; должен совпадать со всеми downstream-сервисами |
| `EUREKA_URL`            | `http://localhost:8761/eureka/`                  | Адрес Eureka Discovery                                 |
| `IP_LOCATION_API_TOKEN` | —                                                | Токен Dadata, добавляется как `Authorization: Token <value>` к `/iplocate/**` |

---

## Docker Compose

В директории `MarketPlaceProject/` находятся три Compose-файла:

### docker-compose.dev.yml — разработка (сборка из исходников)

```bash
# Из директории MarketPlaceProject/
docker compose -f docker-compose.dev.yml up --build -d

# Сброс данных
docker compose -f docker-compose.dev.yml down -v
```

Сервисы собираются из исходников (директив `build: context: ../ServiceName`). БД наполняются тестовыми данными из `docker/init-sql/`.

### docker-compose.prod.yml — production (образы из Docker Hub)

Перед запуском создайте файл `.env` в директории `MarketPlaceProject/`:

```
JWT_SECRET=<ваш-секрет>
DB_PASSWORD=<пароль>
IP_LOCATION_API_TOKEN=<токен-dadata>
```

```bash
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d
```

### docker-compose.yml — базовый

```bash
export IP_LOCATION_API_TOKEN=your_token
docker compose up --build -d
```

### Образы Docker Hub

| Сервис          | Docker Hub образ                         |
|-----------------|------------------------------------------|
| Eureka          | `axterium/eureka-discovery-service:latest` |
| AuthService     | `axterium/auth-service:latest`           |
| CartService     | `axterium/cart-service:latest`           |
| OrderService    | `axterium/order-service:latest`          |
| API Gateway     | `axterium/api-gateway-service:latest` (prod) / собирается локально (dev) |
| ProductService  | собирается локально (dev) / `axterium/product-service:latest` (prod) |

---

## Сборка и запуск

### Локально из исходников

Требования: JDK 21, запущенный Eureka, все downstream-сервисы.

```bash
cd MarketPlaceProject
JWT_SECRET=nTDmGYqtvLfDCptgzwG+xKGtXV/JHL4fHKJrxK9tHdI= \
EUREKA_URL=http://localhost:8761/eureka/ \
./gradlew bootRun
```

### Сборка JAR

```bash
cd MarketPlaceProject
./gradlew build
```

### Тесты

```bash
cd MarketPlaceProject
./gradlew test
```

Health-check endpoint: `GET http://localhost:8080/actuator/health`
