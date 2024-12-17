-- 1. Получить список всех пользователей с их активными поездками (если такие имеются), отсортированный по фамилии
SELECT u.name, u.surname, r.ride_id, r.start_time
FROM users u
LEFT JOIN rides r ON u.user_id = r.user_id AND r.ride_status = 'now'
ORDER BY u.surname;

-- 2. Получить список всех самокатов с их моделями и статусом, сортировка по статусу
SELECT s.scooter_id, sm.name AS model_name, s.status
FROM scooters s
JOIN scooter_models sm ON s.model_id = sm.model_id
ORDER BY s.status;

-- 3. Получить пользователей, которые никогда не совершали поездок
SELECT u.name, u.surname, u.phone_number
FROM users u
LEFT JOIN rides r ON u.user_id = r.user_id
WHERE r.ride_id IS NULL;

-- 4. Получить все штрафы с информацией о пользователях, отсортированным по сумме штрафа
SELECT u.name, u.surname, f.reason, f.sum
FROM fines f
JOIN users u ON f.user_id = u.user_id
ORDER BY f.sum DESC;

-- 5. Получить список всех самокатов с их местоположением и зарядом, которые находятся на парковке
SELECT s.scooter_id, s.geo_point, s.charge_level, pl.rect_point_1, pl.rect_point_2
FROM scooters s
JOIN parking_lots pl ON s.parking_lot_id = pl.lot_id
WHERE s.status = 'parked';

-- 6. Получить всех пользователей, которым были наложены штрафы за превышение скорости
SELECT u.name, u.surname, f.reason, f.sum
FROM users u
JOIN fines f ON u.user_id = f.user_id
WHERE f.reason = 'Превышение скорости';

-- 7. Получить все поездки, которые закончились на парковке с ID = 5
SELECT r.ride_id, r.start_time, r.end_time, u.name, u.surname
FROM rides r
JOIN users u ON r.user_id = u.user_id
JOIN scooters s ON r.scooter_id = s.scooter_id
WHERE s.parking_lot_id = 5 AND r.ride_status = 'ended';

-- 8. Получить список самокатов, которые не были использованы
SELECT s.scooter_id, COUNT(r.ride_id) AS ride_count
FROM scooters s
JOIN rides r ON s.scooter_id = r.scooter_id
GROUP BY s.scooter_id
HAVING COUNT(r.ride_id) = 0;

-- 11. Поллучить список всех разряженных самокатов

-- 12. Получить список всех самокатов, находящихся на в сервисном режиме
SELECT s.scooter_id, sm.name AS model_name, s.charge_level, s.status
FROM scooters s
JOIN scooter_models sm ON s.model_id = sm.model_id
WHERE s.status = 'service';

-- 13. Получить количество поездок, которые завершились на каждой парковке
SELECT pl.lot_id, COUNT(r.ride_id) AS completed_rides
FROM parking_lots pl
JOIN scooters s ON pl.lot_id = s.parking_lot_id
JOIN rides r ON s.scooter_id = r.scooter_id
WHERE r.ride_status = 'ended'
GROUP BY pl.lot_id;

-- 13. Получить количество поездок, которые завершились на каждой парковке
SELECT pl.lot_id, COUNT(r.ride_id) AS completed_rides
FROM parking_lots pl
JOIN scooters s ON pl.lot_id = s.parking_lot_id
JOIN rides r ON s.scooter_id = r.scooter_id
WHERE r.ride_status = 'ended'
GROUP BY pl.lot_id;