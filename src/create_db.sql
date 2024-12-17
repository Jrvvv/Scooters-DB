-- Создание таблицы моделей самокатов
CREATE TABLE scooter_models (
    model_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price_per_min NUMERIC(10, 2) NOT NULL CHECK (price_per_min > 0) -- Цена за минуту обязательна и должна быть положительной
);

-- Создание таблицы парковок
CREATE TABLE parking_lots (
    lot_id SERIAL PRIMARY KEY,
    rect_point_1 POINT NOT NULL, -- Устанавливает точку x1y1 прямоугольной области
    rect_point_2 POINT NOT NULL -- Устанавливает точку x2y2 прямоугольной области
);

-- Создание таблицы самокатов с полем для идентификатора парковки
CREATE TABLE scooters (
    scooter_id SERIAL PRIMARY KEY,
    charge_level INTEGER CHECK (charge_level >= 0 AND charge_level <= 100), -- Уровень заряда от 0 до 100
    geo_point POINT NOT NULL, -- Координаты местоположения самоката
    model_id INTEGER NOT NULL REFERENCES scooter_models(model_id) ON DELETE CASCADE,
    parking_lot_id INTEGER REFERENCES parking_lots(lot_id) ON DELETE SET NULL, -- Идентификатор парковки
    status VARCHAR(10) NOT NULL CHECK (status IN ('active', 'parked', 'service')) -- Ограничение на статус
);

-- Создание таблицы пользователей с ограничением на формат номера телефона
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    surname VARCHAR(50) NOT NULL,
    patronymic VARCHAR(50),
    phone_number VARCHAR(16) UNIQUE NOT NULL CHECK (phone_number ~ '^\+7\(\d{3}\)-\d{3}-\d{4}$')
);

-- Создание таблицы поездок с добавлением статуса 'now' и 'ended'
CREATE TABLE rides (
    ride_id SERIAL PRIMARY KEY,
    scooter_id INTEGER REFERENCES scooters(scooter_id) ON DELETE SET NULL,
    user_id INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP, -- end_time может быть NULL, если статус 'now'
    ride_status VARCHAR(10) NOT NULL CHECK (ride_status IN ('now', 'ended')), -- Статус поездки
    ride_price NUMERIC(10, 2) -- Стоимость поездки будет вычисляться автоматически
);

-- Создание таблицы штрафов
CREATE TABLE fines (
    fine_id SERIAL PRIMARY KEY,          -- Уникальный идентификатор штрафа
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,  -- Ссылка на пользователя, которому наложен штраф
    reason VARCHAR(255) NOT NULL,        -- Причина штрафа
    sum NUMERIC(10, 2) NOT NULL CHECK (sum >= 0) -- Сумма штрафа не может быть отрицательной
);