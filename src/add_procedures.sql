-- Создание процедуры для старта поездки (пользователь)
CREATE OR REPLACE PROCEDURE start_ride(scooter_id_param INTEGER, user_id_param INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Проверка, что самокат в состоянии "parked"
    IF EXISTS (
        SELECT 1
        FROM scooters
        WHERE scooter_id = scooter_id_param
        AND status = 'parked'
    ) THEN
        -- Удаление номера парковки
        UPDATE scooters
        SET parking_lot_id = NULL
        WHERE scooter_id = scooter_id_param;

        -- Добавление записи о поездке с временем старта
        INSERT INTO rides (scooter_id, user_id, start_time, ride_status)
        VALUES (scooter_id_param, user_id_param, CURRENT_TIMESTAMP, 'now');  -- Используем user_id_param

        -- Изменение статуса самоката на active
        UPDATE scooters
        SET status = 'active'
        WHERE scooter_id = scooter_id_param;
    ELSE
        RAISE EXCEPTION 'Самокат не в состоянии "parked"';
    END IF;
END;
$$;





-- Создание процедуры для окончания поездки (пользователь)
CREATE OR REPLACE PROCEDURE end_ride(scooter_id_param INTEGER, parking_lot_id_param INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    end_time_param TIMESTAMP;
BEGIN
    -- Проверка, что самокат в состоянии "active"
    IF EXISTS (
        SELECT 1
        FROM scooters
        WHERE scooter_id = scooter_id_param
        AND status = 'active'
    ) THEN
        -- Устанавливаем время окончания поездки как текущее время + 1 минута
        end_time_param := CURRENT_TIMESTAMP + INTERVAL '1 minute';

        -- Обновить запись о поездке: установить время окончания и статус 'ended'
        UPDATE rides
        SET end_time = end_time_param,
            ride_status = 'ended'
        WHERE scooter_id = scooter_id_param AND ride_status = 'now';

        -- Добавить номер парковки самокату
        UPDATE scooters
        SET parking_lot_id = parking_lot_id_param,
            status = 'parked'  -- Возвращаем состояние в "parked"
        WHERE scooter_id = scooter_id_param;
    ELSE
        RAISE EXCEPTION 'Самокат не в состоянии "active"';
    END IF;
END;
$$;





-- Перевод самоката в service состояние (администратор, инженер)
-- Перевод самоката в service состояние
CREATE OR REPLACE PROCEDURE set_scooter_to_service(scooter_id_param INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    ride_id INTEGER;
BEGIN
    -- Проверяем, есть ли текущие поездки для этого самоката
    FOR ride_id IN
        SELECT r.ride_id
        FROM rides r
        WHERE r.scooter_id = scooter_id_param AND r.ride_status = 'now'
    LOOP
        -- Завершаем каждую активную поездку через процедуру end_ride
        CALL end_ride(scooter_id_param, NULL);  -- Теперь передаем правильные параметры
    END LOOP;

    -- Теперь меняем статус самоката на "service"
    UPDATE scooters
    SET status = 'service'
    WHERE scooter_id = scooter_id_param;

    -- Проверка успешности обновления
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Самокат с ID % не найден.', scooter_id_param;
    END IF;
END;
$$;




--- Добавление самоката на парковку из сервисного состояния (администратор, инженер)
CREATE OR REPLACE PROCEDURE add_scooter_to_parking_from_service(scooter_id_param INTEGER, parking_lot_id_param INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Проверяем, что самокат находится в состоянии "service"
    IF NOT EXISTS (SELECT 1 FROM scooters WHERE scooter_id = scooter_id_param AND status = 'service') THEN
        RAISE EXCEPTION 'Самокат с ID % не может быть переведен в состояние парковки, так как он не в состоянии "service".', scooter_id_param;
    END IF;

    -- Добавляем самокат на парковку
    UPDATE scooters
    SET parking_lot_id = parking_lot_id_param -- Устанавливаем номер парковки (состояние 'parked' по триггеру)
    WHERE scooter_id = scooter_id_param;

    -- Проверка успешности обновления
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Самокат с ID % не найден.', scooter_id_param;
    END IF;
END;
$$;



-- Создание процедуры для добавления самоката (администратор, инженер)
CREATE OR REPLACE PROCEDURE add_scooter(
    p_charge_level INTEGER,
    p_geo_point POINT,
    p_model_id INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Вставка самоката в таблицу scooters
    INSERT INTO scooters (charge_level, geo_point, model_id, status)
    VALUES (p_charge_level, p_geo_point, p_model_id, 'service');
    
    -- Выводим сообщение об успешном добавлении самоката
    RAISE NOTICE 'Самокат с моделью ID % успешно добавлен в статусе service.', p_model_id;
END;
$$;




-- Создание процедуры для добавления штрафа (администратор)
CREATE OR REPLACE PROCEDURE add_fine(
    p_user_id INTEGER,
    p_reason TEXT,
    p_sum MONEY
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Вставка штрафа в таблицу fines
    INSERT INTO fines (user_id, reason, sum)
    VALUES (p_user_id, p_reason, p_sum);
    
    -- Выводим сообщение об успешном добавлении штрафа
    RAISE NOTICE 'Штраф на сумму % для пользователя с ID % успешно добавлен. Причина: %', p_sum, p_user_id, p_reason;
END;
$$;




