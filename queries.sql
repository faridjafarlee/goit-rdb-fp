-- ЗАВДАННЯ 1: Створення схеми та імпорт даних

CREATE SCHEMA IF NOT EXISTS pandemic;
USE pandemic;

-- імпорт даних, можна вручну або за допомогою LOAD DATA INFILE
LOAD DATA INFILE '/path/to/infectious_cases.csv'
INTO TABLE infectious_cases
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'

SELECT COUNT(*) FROM infectious_cases;

-- ЗАВДАННЯ 2: Нормалізація до 3НФ

CREATE TABLE IF NOT EXISTS entities (
    id   INT AUTO_INCREMENT PRIMARY KEY,
    entity VARCHAR(255),
    code   VARCHAR(10)
);

INSERT INTO entities (entity, code)
SELECT DISTINCT Entity, Code
FROM infectious_cases;


CREATE TABLE IF NOT EXISTS infectious_cases_norm AS
SELECT
    e.id AS entity_id,
    ic.Year,
    ic.Number_yaws,
    ic.polio_cases,
    ic.cases_guinea_worm,
    ic.Number_rabies,
    ic.Number_malaria,
    ic.Number_hiv,
    ic.Number_tuberculosis,
    ic.Number_smallpox,
    ic.Number_cholera_cases
FROM infectious_cases ic
JOIN entities e
    ON ic.Entity = e.entity
   AND ic.Code   = e.code;

SELECT COUNT(*) FROM infectious_cases;


-- ЗАВДАННЯ 3: Аналіз атрибута Number_rabies

SELECT
    e.entity,
    e.code,
    AVG(CAST(ic.Number_rabies AS DECIMAL(10, 2))) AS avg_rabies,
    MIN(CAST(ic.Number_rabies AS DECIMAL(10, 2))) AS min_rabies,
    MAX(CAST(ic.Number_rabies AS DECIMAL(10, 2))) AS max_rabies,
    SUM(CAST(ic.Number_rabies AS DECIMAL(10, 2))) AS sum_rabies
FROM infectious_cases_norm ic
JOIN entities e ON ic.entity_id = e.id
WHERE ic.Number_rabies IS NOT NULL
  AND ic.Number_rabies != ''
GROUP BY e.entity, e.code
ORDER BY avg_rabies DESC
LIMIT 10;


-- ЗАВДАННЯ 4: Колонка різниці в роках (вбудовані функції)

SELECT
    Year,
    MAKEDATE(Year, 1)                                   AS year_start_date,
    CURDATE()                                           AS today,
    TIMESTAMPDIFF(YEAR, MAKEDATE(Year, 1), CURDATE())   AS year_diff
FROM infectious_cases_norm
LIMIT 10;


-- ЗАВДАННЯ 5: Власна функція

DROP FUNCTION IF EXISTS year_diff_func;

DELIMITER //
CREATE FUNCTION year_diff_func(input_year INT)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, MAKEDATE(input_year, 1), CURDATE());
END //
DELIMITER ;

SELECT
    Year,
    year_diff_func(Year) AS diff_years
FROM infectious_cases_norm
LIMIT 10;