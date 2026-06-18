-- Topic 9 Workshop

-- slide 4
SELECT
    COUNT(*),
    COUNT(rent_out_dt),
    COUNT(rent_in_dt)
FROM
    drone.rental;

SELECT
    *
FROM
    DRONE.DRONE
ORDER BY
    DT_CODE;

-- Slide 7
SELECT
    AVG(drone_flight_time)
FROM
    drone.drone;

SELECT
    DT_CODE,
    TO_CHAR(
        AVG(DRONE_FLIGHT_TIME),
        '990.99'
    ) AS AVERAGE_FT
FROM
    DRONE.DRONE
GROUP BY
    DT_CODE
ORDER BY
    DT_CODE;

-- Slide 8 Quiz Q1
------------------


-- Slide 9-10
SELECT count(*)
FROM drone.cust_train;

SELECT cust_id, COUNT(*) AS no_courses_taken
FROM drone.cust_train
GROUP BY cust_id
ORDER BY cust_id;

SELECT AVG(COUNT(*))
AS average_no_courses_taken
FROM drone.cust_train
GROUP BY cust_id;

-- Slide 11 Quiz Q2
-------------------
SELECT
    CUST_ID,
    TRAIN_CODE,
    COUNT(*) AS NO_OF_COURSES_TAKEN
FROM
    DRONE.CUST_TRAIN
GROUP BY
    CUST_ID,
    TRAIN_CODE
ORDER BY
    CUST_ID,
    TRAIN_CODE

-- Slide 12/13
SELECT cust_id, train_code, count(train_code)
as no_of_courses_taken
FROM drone.cust_train
GROUP BY cust_id, train_code
ORDER BY cust_id, train_code;

-- Slide 14
SELECT cust_id,
to_char(ct_date_start, 'yyyy') as licence_start_year,
count(train_code) as no_of_courses_taken
FROM drone.cust_train
GROUP BY cust_id, to_char(ct_date_start, 'yyyy')
ORDER BY cust_id, licence_start_year;

-- Quiz Q3 Slide 16
-------------------
SELECT
    CUST_ID,
    TRAIN_CODE,
    COUNT(TRAIN_CODE) AS NO_OF_COURSES_TAKEN
FROM
    DRONE.CUST_TRAIN
GROUP BY
    CUST_ID,
    TRAIN_CODE
HAVING
    COUNT(TRAIN_CODE) > 1
ORDER BY
    CUST_ID,
    TRAIN_CODE

-- Slide 18/19
SELECT cust_id, train_code, count(train_code) as no_of_courses_taken
FROM drone.cust_train
GROUP BY cust_id, train_code
HAVING count(train_code) > 1
ORDER BY cust_id, train_code;

SELECT dt_code, AVG(drone_flight_time) as average_drone_flight
FROM drone.drone
GROUP BY dt_code
HAVING AVG(drone_flight_time)>50
ORDER BY dt_code;

-- Slide 20 Q4 <<<<<<<< student code exercise
SELECT
    DT_CODE,
    AVG(DRONE_FLIGHT_TIME) AS AVERAGE_DRONE_FLIGHT
FROM
    DRONE.DRONE
WHERE
    TO_CHAR(DRONE_PUR_DATE, 'yyyy') = '2021'
GROUP BY
    DT_CODE
HAVING
    AVG(DRONE_FLIGHT_TIME) > 50
ORDER BY
    DT_CODE;

-- Slide 23
SELECT cust_id, train_code, count(*) as no_of_courses_taken
FROM drone.cust_train
GROUP BY cust_id, train_code
ORDER BY cust_id;

select * from drone.cust_train order by cust_id;

-- Slide 24
SELECT *
FROM drone.drone
WHERE drone_flight_time >
    (
        SELECT AVG(drone_flight_time)
        FROM drone.drone
    )
ORDER BY drone_id;

-- Quiz Q5/Slide 27
-------------------
SELECT
    *
FROM
    DRONE.DRONE
WHERE
    DRONE_PUR_PRICE > (
        SELECT
            AVG(DRONE_PUR_PRICE)
        FROM
            DRONE.DRONE
        GROUP BY
            DRONE_PUR_DATE
    )

-- Quiz Q6 - Slide 28
----------------------
select dt_code, max(drone_pur_price) from drone.drone_type NATURAL JOIN drone.drone group by dt_code

----
-- Create view
-- makes subsequent selects easier to code

create view dronetypeprice as
SELECT drone_id, dt_code, dt_model, drone_pur_price
FROM drone.drone_type NATURAL JOIN drone.drone;

SELECT
    *
FROM
    dronetypeprice
order by drone_id;

-- Quit Q7/Slide 30/31
-----------------------
SELECT
    *
FROM
    DRONETYPEPRICE
WHERE
    DRONE_PUR_PRICE IN (
        SELECT
            MAX(DRONE_PUR_PRICE)
        FROM
            DRONETYPEPRICE
        GROUP BY
            DT_CODE
    );

-- Quiz 8/Slide 32/33
---------------------
SELECT
    *
FROM
    DRONETYPEPRICE
WHERE
    DRONE_PUR_PRICE > ANY (
        SELECT
            MIN(DRONE_PUR_PRICE)
        FROM
            DRONETYPEPRICE
        GROUP BY
            DT_CODE
    );

--Slide 32 data top right
SELECT dt_code, MIN(drone_pur_price)
FROM dronetypeprice
GROUP BY dt_code;


-- Quiz Q9/Slide 34/35
----------------------


-- Q10: Slide 36/37 <<<<<<<< student code exercise
-------------------

