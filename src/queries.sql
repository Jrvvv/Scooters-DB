-- 1. Получить список всех пользователей с их активными поездками (если такие имеются), отсортированный по фамилии
SELECT u.name, u.surname, r.ride_id, r.start_time
FROM users u
JOIN rides r ON u.user_id = r.user_id AND r.ride_status = 'now'
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

-- 7. Получить все поездки, после которых самокат мог оказаться на паркеовке с индексом 5
SELECT r.ride_id, r.start_time, r.end_time, u.name, u.surname
FROM rides r
JOIN users u ON r.user_id = u.user_id
JOIN scooters s ON r.scooter_id = s.scooter_id
WHERE s.parking_lot_id = 5 AND r.ride_status = 'ended';

-- 8. Получить список самокатов, которые не были использованы
SELECT s.scooter_id, COUNT(r.ride_id) AS ride_count
FROM scooters s
FULL OUTER JOIN rides r ON s.scooter_id = r.scooter_id
GROUP BY s.scooter_id
HAVING COUNT(r.ride_id) = 0;

-- 11. Поллучить список всех разряженных самокатов (заряд меньше 5%)
SELECT s.scooter_id, sm.name AS model_name, s.charge_level, s.status
FROM scooters s
JOIN scooter_models sm ON s.model_id = sm.model_id
WHERE s.charge_level < 5;

-- 12. Получить список всех самокатов, находящихся на в сервисном режиме
SELECT s.scooter_id, sm.name AS model_name, s.charge_level, s.status
FROM scooters s
JOIN scooter_models sm ON s.model_id = sm.model_id
WHERE s.status = 'service';

-- 13. Получить количество поездок, которые совершил Михаель Шумахер
SELECT COUNT(*) AS total_rides
FROM rides r
JOIN users u ON r.user_id = u.user_id
WHERE u.name = 'Михаель' AND u.surname = 'Шумахер';

-- 14. Получить общую сумму штрафов для каждого из пользователей
SELECT u.user_id, u.name, u.surname, SUM(f.sum) AS total_fines
FROM users u
JOIN fines f ON u.user_id = f.user_id
GROUP BY u.user_id, u.name, u.surname
ORDER BY total_fines DESC;

-- 15. Получить поездку наибольшей стоимости
SELECT r.ride_id, r.scooter_id, r.user_id, r.start_time, r.end_time, r.ride_status, r.ride_price
FROM rides r
JOIN scooters s ON r.scooter_id = s.scooter_id
JOIN scooter_models sm ON s.model_id = sm.model_id
WHERE r.ride_status = 'ended'
ORDER BY r.ride_price DESC
LIMIT 1;

-- 16. Получить поездку наименьшей стоимости
SELECT r.ride_id, r.scooter_id, r.user_id, r.start_time, r.end_time, r.ride_status, r.ride_price
FROM rides r
JOIN scooters s ON r.scooter_id = s.scooter_id
JOIN scooter_models sm ON s.model_id = sm.model_id
WHERE r.ride_status = 'ended'
ORDER BY r.ride_price
LIMIT 1;

-- 17. Получить самую продолжительную поездку
SELECT r.ride_id, r.scooter_id, r.user_id, r.start_time, r.end_time, r.ride_status, 
       EXTRACT(EPOCH FROM (r.end_time - r.start_time)) / 60 AS ride_duration_minutes
FROM rides r
WHERE r.ride_status = 'ended'
ORDER BY ride_duration_minutes DESC
LIMIT 1;

-- 18. Получить самую короткую поездку
SELECT r.ride_id, r.scooter_id, r.user_id, r.start_time, r.end_time, r.ride_status, 
       EXTRACT(EPOCH FROM (r.end_time - r.start_time)) / 60 AS ride_duration_minutes
FROM rides r
WHERE r.ride_status = 'ended'
ORDER BY ride_duration_minutes
LIMIT 1;

-- 19.Получить все активные поездки, которые начались в последние 24 часа.
SELECT r.ride_id, r.start_time, u.name, u.surname
FROM rides r
JOIN users u ON r.user_id = u.user_id
WHERE r.ride_status = 'now' AND r.start_time > CURRENT_TIMESTAMP - INTERVAL '1 day';

-- 20. Получить самый часто используемый самокат
SELECT scooter_id, COUNT(*) AS ride_count
FROM rides
GROUP BY scooter_id
ORDER BY ride_count DESC
LIMIT 1;