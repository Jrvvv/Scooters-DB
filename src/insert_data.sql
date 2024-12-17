-- Вставка данных о пользователях
INSERT INTO users (name, surname, patronymic, phone_number)
VALUES
('Макс', 'Ферстаппен', NULL, '+7(999)-999-9999'),
('Михаель', 'Шумахер', NULL, '+7(998)-998-9988'),
('Райан', 'Гослинг', 'Драйвович', '+7(997)-997-9977'),
('Иван', 'Школьников', 'Михайлович', '+7(996)-996-9966'),
('Марвин', 'Химейер', NULL, '+7(995)-995-9955'),
('Димид', 'Близнец-Сиамсов', 'Димидович', '+7(994)-994-9944'),
('Димид', 'Близнец-Сиамсов', 'Димидович', '+7(993)-993-9933'),
('Пол', 'Уокер', NULL, '+7(992)-992-9922'),
('Мухаммед', 'Атта', NULL, '+7(991)-991-9911'),
('Андрей', 'Адекватов', 'Петрович', '+7(990)-990-9900');




-- Вставка данных о моделях самокатов
INSERT INTO scooter_models (name, price_per_min)
VALUES
('Lada Kalyina', 10.99),
('Volkpol Poro', 12.99),
('Tayota Cambry', 27.99),
('BMW 3 Seris', 37.99),
('Mersedes Bens C',44.99),
('Kia Ryo', 11.99),
('Hyunday Elentra', 14.99),
('Ford Musstank', 25.99),
('Audio AAAA', 11.99),
('Ford Fucus', 17.99);




-- Вставка данных о парковках
INSERT INTO parking_lots (rect_point_1, rect_point_2)
VALUES
    (POINT(37.6160, 55.7550), POINT(37.6185, 55.7570)),
    (POINT(30.3140, 59.9330), POINT(30.3175, 59.9355)),
    (POINT(37.6165, 55.7545), POINT(37.6190, 55.7565)),
    (POINT(40.7298, -73.9360), POINT(40.7312, -73.9340)),
    (POINT(13.4030, 52.5195), POINT(13.4065, 52.5210)),
    (POINT(47.6160, 65.7550), POINT(47.6185, 65.7570)),
    (POINT(28.9770, 41.0075), POINT(28.9800, 41.0090)),
    (POINT(55.7525, 37.6165), POINT(55.7545, 37.6185)),
    (POINT(48.8555, 2.3510), POINT(48.8575, 2.3530)),
    (POINT(40.7480, -73.9860), POINT(40.7495, -73.9845));




-- Добавление самокатов через процедуру (первые пять внутри парковок)
CALL add_scooter(80, POINT(37.6170, 55.7560), 1);     -- В пределах парковки 1
CALL add_scooter(90, POINT(30.3160, 59.9340), 2);     -- В пределах парковки 2
CALL add_scooter(75, POINT(37.6178, 55.7555), 3);     -- В пределах парковки 3
CALL add_scooter(60, POINT(40.7305, -73.9355), 4);    -- В пределах парковки 4
CALL add_scooter(50, POINT(13.4045, 52.5205), 5);     -- В пределах парковки 5
CALL add_scooter(85, POINT(47.6170, 65.7560), 6);     -- В пределах парковки 6
CALL add_scooter(95, POINT(28.9850, 41.0150), 7);     -- Вне парковки 7
CALL add_scooter(70, POINT(55.7600, 37.6200), 8);     -- Вне парковки 8
CALL add_scooter(65, POINT(48.8600, 2.3600), 9);      -- Вне парковки 9
CALL add_scooter(80, POINT(40.7520, -73.9800), 10);   -- Вне парковки 10





-- Добавление штрафа через процедуру
-- Для пользователей 1, 2, 3, 8 - штраф "Превышение скорости"
CALL add_fine(1, 'Превышение скорости', '1500');
CALL add_fine(2, 'Превышение скорости', '1500');
CALL add_fine(3, 'Превышение скорости', '1500');
CALL add_fine(8, 'Превышение скорости', '1500');
-- Для пользователей 4, 6 и 7 - штраф "Перемещение на самокате несовершеннолетнего"
CALL add_fine(4, 'Перемещение на самокате несовершеннолетнего', '2000');
CALL add_fine(6, 'Перемещение на самокате несовершеннолетнего', '2000');
CALL add_fine(7, 'Перемещение на самокате несовершеннолетнего', '2000');
-- Для пользователей 6 и 7 - штраф "Езда на самокате вдвоем"
CALL add_fine(6, 'Езда на самокате вдвоем', '1000');
CALL add_fine(7, 'Езда на самокате вдвоем', '1000');
-- Для пользователя 5 - штраф "Вывоз самоката за пределы зоны пользования"
CALL add_fine(5, 'Вывоз самоката за пределы зоны пользования', '3000');
-- Для пользователя 9 - штраф "Наезд на пешехода"
CALL add_fine(9, 'Наезд на пешехода', '5000');




-- Симуляция использования самокатов
-- Переводим самокаты 1-5 из состояния service на парковку (с парковками 1-5)
CALL add_scooter_to_parking_from_service(1, 1);
CALL add_scooter_to_parking_from_service(2, 2);
CALL add_scooter_to_parking_from_service(3, 3);
CALL add_scooter_to_parking_from_service(4, 4);
CALL add_scooter_to_parking_from_service(5, 5);

-- Начинаем поездки для самокатов 1-5
CALL start_ride(1, 1); -- Самокат 1, пользователь 1
CALL start_ride(2, 2); -- Самокат 2, пользователь 2
CALL start_ride(3, 3); -- Самокат 3, пользователь 3
CALL start_ride(4, 4); -- Самокат 4, пользователь 4
CALL start_ride(5, 5); -- Самокат 5, пользователь 5

-- Завершаем поездки для самокатов 1-5
CALL end_ride(1, 1); -- Самокат 1, парковка 1
CALL end_ride(2, 2); -- Самокат 2, парковка 2
CALL end_ride(3, 3); -- Самокат 3, парковка 3
CALL end_ride(4, 4); -- Самокат 4, парковка 4
CALL end_ride(5, 5); -- Самокат 5, парковка 5

-- Снова начинаем поездки для самокатов 1-5
CALL start_ride(1, 6); -- Самокат 1, пользователь 6
CALL start_ride(2, 7); -- Самокат 2, пользователь 7
CALL start_ride(3, 8); -- Самокат 3, пользователь 8
CALL start_ride(4, 9); -- Самокат 4, пользователь 9
CALL start_ride(5, 10); -- Самокат 5, пользователь 10