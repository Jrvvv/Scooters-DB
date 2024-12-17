-- Функция для проверки, что новый самокат создается только со статусом 'service'
CREATE OR REPLACE FUNCTION check_initial_scooter_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status <> 'service' THEN
        RAISE EXCEPTION 'New scooters can only be added with status ''service''';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер для проверки статуса при добавлении нового самоката
CREATE TRIGGER trigger_check_initial_scooter_status
BEFORE INSERT ON scooters
FOR EACH ROW
EXECUTE FUNCTION check_initial_scooter_status();




-- Функция для проверки корректности времени начала и окончания поездки
CREATE OR REPLACE FUNCTION check_ride_times()
RETURNS TRIGGER AS $$
BEGIN
    -- Проверка, что end_time не меньше start_time
    IF NEW.end_time IS NOT NULL AND NEW.end_time < NEW.start_time THEN
        RAISE EXCEPTION 'End time cannot be earlier than start time';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер для проверки времени поездки перед вставкой и обновлением записи в rides
CREATE TRIGGER trigger_check_ride_times
BEFORE INSERT OR UPDATE ON rides
FOR EACH ROW
EXECUTE FUNCTION check_ride_times();




-- Функция для расчёта стоимости поездки
CREATE OR REPLACE FUNCTION calculate_ride_price()
RETURNS TRIGGER AS $$
DECLARE
    price_per_min NUMERIC(10, 2);
    ride_time INTEGER;
BEGIN
    -- Если end_time не установлено, то не рассчитываем стоимость
    IF NEW.end_time IS NOT NULL THEN
        -- Получаем цену за минуту из таблицы scooter_models
        SELECT sm.price_per_min
        INTO price_per_min
        FROM scooters s
        JOIN scooter_models sm ON s.model_id = sm.model_id
        WHERE s.scooter_id = NEW.scooter_id;

        -- Рассчитываем время поездки в минутах
        ride_time := EXTRACT(EPOCH FROM (NEW.end_time - NEW.start_time)) / 60;
        ride_time := ride_time::INTEGER;

        -- Рассчитываем стоимость поездки
        NEW.ride_price := price_per_min * ride_time;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер для расчёта стоимости поездки при обновлении записи в rides
CREATE TRIGGER trigger_calculate_ride_price
BEFORE UPDATE ON rides
FOR EACH ROW
EXECUTE FUNCTION calculate_ride_price();




-- Функция для изменения статуса самоката на 'parked' при обновлении его парковки
CREATE OR REPLACE FUNCTION set_scooter_status_parked()
RETURNS TRIGGER AS $$
BEGIN
    -- Если у самоката установлен parking_lot_id, меняем статус на 'parked'
    IF NEW.parking_lot_id IS NOT NULL THEN
        NEW.status := 'parked';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер для изменения статуса на 'parked' при обновлении parking_lot_id
CREATE TRIGGER trigger_set_scooter_status_parked
BEFORE UPDATE OF parking_lot_id ON scooters
FOR EACH ROW
EXECUTE FUNCTION set_scooter_status_parked();





-- Функция для проверки нахождения самоката на парковке по координатам
CREATE OR REPLACE FUNCTION check_scooter_within_parking()
RETURNS TRIGGER AS $$
DECLARE
    rect_p1 POINT;
    rect_p2 POINT;
BEGIN
    -- Если парковка не изменяется (или устанавливается NULL), пропускаем проверку
    IF NEW.parking_lot_id IS NULL OR NEW.parking_lot_id = OLD.parking_lot_id THEN
        RETURN NEW;  -- Не делаем никаких изменений, просто возвращаем NEW
    END IF;

    -- Получаем границы парковки
    SELECT rect_point_1, rect_point_2 INTO rect_p1, rect_p2
    FROM parking_lots
    WHERE lot_id = NEW.parking_lot_id;

    -- Проверяем, находится ли самокат внутри прямоугольника парковки
    IF NOT (
        NEW.geo_point[0] BETWEEN LEAST(rect_p1[0], rect_p2[0]) AND GREATEST(rect_p1[0], rect_p2[0]) AND
        NEW.geo_point[1] BETWEEN LEAST(rect_p1[1], rect_p2[1]) AND GREATEST(rect_p1[1], rect_p2[1])
    ) THEN
        RAISE EXCEPTION 'Самокат находится вне зоны парковки.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер для проверки нахождения самоката на парковке при добавлении места парковки
CREATE TRIGGER trigger_check_scooter_parking
BEFORE UPDATE OF parking_lot_id ON scooters
FOR EACH ROW
EXECUTE FUNCTION check_scooter_within_parking();




-- Функция для проверки, что статус самоката добавляемого в поездки не active
CREATE OR REPLACE FUNCTION check_scooter_status_before_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Проверяем состояние самоката
    IF (SELECT status FROM scooters WHERE scooter_id = NEW.scooter_id) = 'active' THEN
        RAISE EXCEPTION 'Невозможно начать поездку: самокат уже в состоянии "active".';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_scooter_status_before_insert_trigger
BEFORE INSERT ON rides
FOR EACH ROW
EXECUTE FUNCTION check_scooter_status_before_insert();