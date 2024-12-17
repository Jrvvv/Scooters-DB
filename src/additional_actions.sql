-- Сбросить активную поездку для Атта, если такая имеется
DO $$
DECLARE
    scooter_id INTEGER;
BEGIN
    -- Находим самокат для активной поездки пользователя Атта
    SELECT r.scooter_id
    INTO scooter_id
    FROM rides r
    JOIN users u ON r.user_id = u.user_id
    WHERE u.surname = 'Атта'  -- Используйте правильное имя столбца для фамилии
      AND u.phone_number = '+7(991)-991-9911'
      AND r.ride_status = 'now'
    LIMIT 1;

    -- Если самокат найден, переводим его в состояние "service"
    IF scooter_id IS NOT NULL THEN
        -- Вызов процедуры для перевода самоката в сервисное состояние
        CALL set_scooter_to_service(scooter_id);
    ELSE
        RAISE EXCEPTION 'Активная поездка для пользователя Атта с номером +7(991)-991-9911 не найдена.';
    END IF;
END;
$$;


-- Ошибочные процедуры
-- Самокат не у парковки
CALL add_scooter_to_parking_from_service(7, 7);
-- Самокат в состоянии сервиса
CALL start_ride(6, 6);
-- Самокат уже активен
CALL start_ride(1, 9);
-- Самокат в состоянии сервиса (в пределах парковки)
CALL end_ride(6, 6);
-- Самокат уже на парковке (после завершения поездки выше)
CALL end_ride(4, 4);




