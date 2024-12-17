# Scooters-DB

## Задача:
Необходимо создать БД самокатов в городе (PostgreSQL)

### Требования:
- Не менее 6 таблиц
- Минимум одна из таблиц содержит триггер на автоматическое вычисление одного из полей
- Каждая из таблиц обязательно должна содержать ограничения

## Таблицы БД:
* **Самокаты (scooters):**
  - scooter_id (SERIAL, **PK**)
  - charge_level (INTEGER, from 0 to 100)
  - geo_point (POINT)
  - modeil_id (INTEGER, **FK**)
  - status (VARCHAR, "active", "parked" and "paused" only)

* **Модели самокатов (scooter_models):**
  - model_id (SERIAL, **PK**)
  - name
  - price_per_min

* **Пользователи (users):**
  - user_id (SERIAL, **PK**)
  - name (VARCHAR)
  - surname (VARCHAR)
  - patronymic (VARCHAR)
  - phone_number (UNIQUE VARCHAR, by regexp '^\+7\(\d{3}\)-\d{3}-\d{4}$', maximum one user per number)

* **Парковки (parking_lots):**
  - lot_id (SERIAL, **PK**)
  - rect_point_1 (POINT, set x1y1 rectangle point)
  - rect_point_2 (POINT, set x2y2 rectangle point)

* **Поездки (rides):**
  - ride_id (SERIAL, **PK**)
  - scooter_id (INTEGER, **FK**)
  - user_id (INTEGER, **FK**)
  - start_time (TIMESTAMP)
  - end_time (TIMESTAMP)
  - ride_status (VARCHAR, "now" and "ended" only) 
  - ride_price (NUMERIC(10, 2), **calculated on *ride_time* and *price_per_min* from model**)

* **Штрафы (fines)**
  - fine_id (SERIAL, **PK**)
  - user_id (INTEGER, **FK**)
  - reason (VARCHAR)
  - sum (NUMERIC(10, 2))

Создай процедуру старта поездки, которая будет
1) Удалять номер парковки
2) Добавлять поездку, выставляя время старта как текущее
3) Выставляет статус now

Создай процедуру окончания поездки, которая будет
1) Добавлять номер парковки
2) Проверять, что точка самоката находится в пределах парковки
3) Добавлять время окончания поездки как текущее + 1 мин
4) Выставляет статус finished
