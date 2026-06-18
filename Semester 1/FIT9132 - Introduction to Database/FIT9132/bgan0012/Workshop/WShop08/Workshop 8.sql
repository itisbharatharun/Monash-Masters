/*
    FIT9132 Workshop
    Week 8 Basic SQL
    Bharath Arun Gandhimani
    1st May 2025
*/

-- Slide 4
SELECT
    drone_id,
    drone_pur_date,
    drone_flight_time
FROM
    drone.drone
WHERE
    drone_pur_price > 2000;

-->>>>> Slide 6 Quiz Q1



-- Slide 8 Example of IN and LIKE
SELECT
    *
FROM
    drone.drone
WHERE
    dt_code IN ( 'DMA2', 'DSPA' );

SELECT
    *
FROM
    drone.drone_type
WHERE
    dt_model LIKE 'DJI%';

-->>>>> Slide 9 Null Quiz Q2
SELECT
    *
FROM
    DRONE.RENTAL
WHERE
    RENT_IN_DT IS NULL;

-->>>>> Slide 13 Quiz Q3
SELECT
    *
FROM
    DRONE.DRONE_SERVICE
WHERE
        EMP_NO <> 3
    AND EMP_NO <> 8;
-- Slide 15
SELECT
    drone_id,
    drone_cost_hr / 60
FROM
    drone.drone;

-- Slide 16
SELECT stuid,
   enrolmark,
   enrolgrade
FROM uni.enrolment;

SELECT stuid,
   NVL(enrolmark,0),
   NVL(enrolgrade,'WH')
FROM uni.enrolment;

-- Slide 17
SELECT
    rent_no,
    drone_id,
    rent_out_dt,
    nvl(
        rent_in_dt, 'Still out'
    )
FROM
    drone.rental;

-- Slide 18
SELECT
    drone_id,
    drone_cost_hr / 60 AS costpermin
FROM
    drone.drone;

SELECT
    drone_id,
    drone_cost_hr / 60 AS "COST/MIN"
FROM
    drone.drone;

-- Slide 19
SELECT
    drone_id,
    drone_flight_time
FROM
    drone.drone
ORDER BY
    drone_flight_time DESC,
    drone_id;

SELECT
    drone_id,
    drone_flight_time
FROM
    drone.drone
ORDER BY
    drone_flight_time DESC,
    drone_id DESC;

-->>>>> Slide 20 Q4. Write a query to satisfy the following requirements:
SELECT
    RENT_NO,
    RENT_OUT_DT,
    RENT_IN_DT
FROM
    DRONE.RENTAL
ORDER BY
    RENT_IN_DT DESC NULLS LAST;
-- Slide 21
SELECT 
    drone_id
FROM
    drone.rental
ORDER BY
    drone_id;

-->>>>> show once
SELECT DISTINCT
    DRONE_ID
FROM
    DRONE.RENTAL
ORDER BY
    DRONE_ID;

-- Slide 23
SELECT
    *
FROM
   drone.manufacturer;

SELECT
    *
FROM
   drone.drone_type;

SELECT
    *
FROM
    drone.manufacturer
    JOIN drone.drone_type
    ON manufacturer.manuf_id = drone_type.manuf_id
ORDER BY
    dt_code;

SELECT
    *
FROM
    drone.manufacturer
    JOIN drone.drone_type USING(manuf_id)
ORDER BY
    dt_code;

SELECT
    *
FROM
    drone.manufacturer
    NATURAL JOIN drone.drone_type
ORDER BY
    dt_code;

-- Slide 24
SELECT
    *
FROM
    drone.manufacturer
    NATURAL JOIN drone.drone_type
ORDER BY
    dt_code;

-- Slide 25
SELECT
    *
FROM
    drone.rental
    NATURAL JOIN drone.employee;

-- Slide 26
SELECT
    *
FROM
    drone.rental
    NATURAL JOIN drone.employee
ORDER BY
    rent_no;

/*
 Slide 27
 Find the full name and contact number of all customers who have completed a
 training course run by trainer id 1
*/

select * from drone.training;
select * from drone.cust_train;
select * from drone.customer;

-- Join and Limit rows early to keep smaller (table alias)
SELECT DISTINCT
    C.CUST_FNAME
    || ' '
    || C.CUST_LNAME AS CUST_NAME,
    C.CUST_PHONE
FROM
    (
             DRONE.TRAINING T
        JOIN DRONE.CUST_TRAIN CT ON T.TRAIN_CODE = CT.TRAIN_CODE
    )
    JOIN DRONE.CUSTOMER   C ON C.CUST_ID = CT.CUST_ID
WHERE
    T.TRAIN_HRS > 4
ORDER BY
    CUST_NAME;

--  Limit attributes


-- order by


-- Final formatted


-- Slide 33
SELECT
    drone_id,
    to_char(drone_pur_date, 'dd-Mon-yyyy') as purchase_date,
    to_char(drone_pur_price, '$9990.99') as purchase_price,
    to_char(drone_flight_time, '99990') as flight_time
FROM
    drone.drone
WHERE
    drone_pur_date > TO_DATE('01-Mar-2021','dd-Mon-yyyy')
ORDER BY
    drone_id;

-- Slide 34
SELECT
    rent_no,
    drone_id,
    to_char(rent_out_dt, 'dd-Mon-yyyy') AS dateout,
    nvl(to_char(rent_in_dt, 'dd-Mon-yyyy'), 'Still out') as datein
FROM
    drone.rental;

-- Slide 35
SELECT
    to_char(sysdate, 'hh:mi:ss PM') as current_time
FROM
    dual;

SELECT
    to_char(sysdate, 'dd-Mon-yyyy hh:mi:ss AM') AS current_datetime
FROM
    dual;

SELECT
    user
FROM
    dual;
