-- Slide 4  >>>>>>>>>>

select drone_id,
       dt_carry_kg,
       drone_cost_hr
  from drone.drone_type
natural join drone.drone
 order by drone_id;

-- Slide 5 Answer, Slide 6
SELECT
    drone_id,
    CASE
        WHEN dt_carry_kg = 0  THEN
            'No load'
        WHEN dt_carry_kg < 4  THEN
            'Light Loads'
        ELSE
            'Heavy Loads'
    END AS carryingcapacity,
    drone_cost_hr
FROM
         drone.drone_type
    NATURAL JOIN drone.drone
ORDER BY
    drone_id;

----------------------------------------------------------------------------------------
-- Slide 9-10
-- For each drone find the customers who rented the drone for the longest duration
-- Drone rent time out
SELECT
    drone_id,
    ( rent_in_dt - rent_out_dt ) as daysout
FROM
    drone.rental
WHERE
    rent_in_dt IS NOT NULL
ORDER BY
    drone_id;

-- Using to char
SELECT
    drone_id,
    to_char(( rent_in_dt - rent_out_dt ),'990.99') as daysout
FROM
    drone.rental
WHERE
    rent_in_dt IS NOT NULL
ORDER BY
    drone_id;

-- Using round
SELECT
    drone_id,
    round(( rent_in_dt - rent_out_dt ),2) as daysout
FROM
    drone.rental
WHERE
    rent_in_dt IS NOT NULL
ORDER BY
    drone_id;

-- Drone max time out
SELECT
    drone_id,
    MAX(rent_in_dt - rent_out_dt) as maxdaysout
FROM
    drone.rental
WHERE
    rent_in_dt IS NOT NULL
GROUP BY
    drone_id
ORDER BY
    drone_id;

-------------------------------------------------------
-- Slide 11: nested
-------------------------------------------------------

SELECT
    drone_id,
    ( rent_in_dt - rent_out_dt ) AS maxdaysout,
    cust_id
FROM
         drone.cust_train
    NATURAL JOIN drone.rental
WHERE
    rent_in_dt IS NOT NULL
    AND ( drone_id, ( rent_in_dt - rent_out_dt ) ) IN (
        SELECT
            drone_id, MAX(rent_in_dt - rent_out_dt)
        FROM
            drone.rental
        WHERE
            rent_in_dt IS NOT NULL
        GROUP BY
            drone_id
    )
ORDER BY
    drone_id,
    cust_id;
-------------------------------------------------------
-- Slide 12: correlated
-------------------------------------------------------

SELECT
    drone_id,
    ( rent_in_dt - rent_out_dt ) AS maxdaysout,
    cust_id
FROM
         drone.cust_train
    NATURAL JOIN drone.rental r1
WHERE
    rent_in_dt IS NOT NULL
    AND ( rent_in_dt - rent_out_dt ) = (
        SELECT
            MAX(rent_in_dt - rent_out_dt)
        FROM
            drone.rental r2
        WHERE
            rent_in_dt IS NOT NULL
            AND r1.drone_id = r2.drone_id
    )
ORDER BY
    drone_id,
    cust_id;

-------------------------------------------------------
-- Slide 13: inline
-------------------------------------------------------

SELECT
    rental.drone_id,
    ( rent_in_dt - rent_out_dt ) AS maxdaysout,
    cust_id
FROM
    (
             (
            SELECT
                drone_id,
                MAX(rent_in_dt - rent_out_dt) AS maxout
            FROM
                drone.rental
            WHERE
                rent_in_dt IS NOT NULL
            GROUP BY
                drone_id
        ) maxtable
        JOIN drone.rental
        ON maxtable.drone_id = rental.drone_id
           AND ( rent_in_dt - rent_out_dt ) = maxtable.maxout
    )
    JOIN drone.cust_train
    USING ( ct_id )
ORDER BY
    drone_id,
    cust_id;

--------------------------------------------------------
-- Slide 14 - 16
--------------------------------------------------------
-- Slide 14
SELECT
    COUNT(*) AS totalrentals
FROM
    drone.rental
WHERE
    rent_in_dt IS NOT NULL;

SELECT
    drone_id,
    COUNT(*) AS times_rented
FROM
    drone.rental
WHERE
    rent_in_dt IS NOT NULL
GROUP BY
    drone_id
ORDER BY
    drone_id;

-------------------------------------------------------
-- Slide 16 subquery inline
-------------------------------------------------------

SELECT
    drone_id,
    COUNT(*) AS times_rented,
    to_char(COUNT(*) * 100 /(
        SELECT
            COUNT(rent_in_dt)
        FROM
            drone.rental
    ), '990.99') AS percent_overall
FROM
    drone.rental
WHERE
    rent_in_dt IS NOT NULL
GROUP BY
    drone_id
ORDER BY
    percent_overall DESC;

-- slide 17
drop table drone_details cascade constraints purge;

CREATE TABLE drone_details (
    dd_id        NUMBER(5) NOT NULL,
    dd_pur_date  DATE NOT NULL,
    dd_model     VARCHAR2(50) NOT NULL,
    CONSTRAINT drone_details_pk PRIMARY KEY ( dd_id )
);

INSERT INTO drone_details
    ( SELECT
        drone_id,
        drone_pur_date,
        dt_model
    FROM
             drone.drone
        NATURAL JOIN drone.drone_type
    );

SELECT
    *
FROM
    drone_details
ORDER BY
    dd_id;

-- Alternative slide 18

drop table drone_details cascade constraints purge;

CREATE TABLE drone_details
    AS
        ( SELECT
            drone_id,
            drone_pur_date,
            dt_model
        FROM
                 drone.drone
            NATURAL JOIN drone.drone_type
        );


-- Slide 20
CREATE OR REPLACE VIEW maxdaysout_view AS
    SELECT
        drone_id,
        MAX(rent_in_dt - rent_out_dt) AS maxdays
    FROM
        drone.rental
    WHERE
        rent_in_dt IS NOT NULL
    GROUP BY
        drone_id;

select * from maxdaysout_view
order by drone_id;

-- Slide 21

SELECT
    drone_id,
    ( rent_in_dt - rent_out_dt ) AS maxdaysout,
    cust_id
FROM
         drone.cust_train
    NATURAL JOIN drone.rental
WHERE
    rent_in_dt IS NOT NULL
    AND ( drone_id, ( rent_in_dt - rent_out_dt ) ) IN (
        SELECT
            drone_id, ( rent_in_dt - rent_out_dt )
        FROM
            maxdaysout_view
    )
ORDER BY
    drone_id,
    cust_id;

-- Slide 24

SELECT *
  FROM payroll.employee e1
  JOIN payroll.employee e2
ON e1.mgrno = e2.empno;

SELECT e1.empno,
       e1.empname,
       e1.empinit,
       e1.mgrno,
       e2.empname AS manager
  FROM payroll.employee e1
  JOIN payroll.employee e2
ON e1.mgrno = e2.empno
 ORDER BY e1.empname;

-- Slide 32 - 33
SELECT
    drone_id,
    COUNT(rent_out_dt) as timerented
FROM
         drone.drone
    JOIN drone.rental
    USING ( drone_id )
GROUP BY
    drone_id
ORDER BY
    drone_id;

SELECT
    drone_id,
    COUNT(rent_out_dt) as timesrented
FROM
    drone.drone
    LEFT OUTER JOIN drone.rental
    USING ( drone_id )
GROUP BY
    drone_id
ORDER BY
    drone_id;

-- Slide 36
SELECT
    drone_id
FROM
    drone.drone;

SELECT
    drone_id
FROM
    drone.rental;

-- Slide 37
SELECT
    drone_id,
    to_char(drone_pur_date, 'dd-Mon-YYYY') AS purchasedate,
    drone_cost_hr
FROM
    drone.drone
WHERE
    drone_id IN (
        SELECT
            drone_id
        FROM
            drone.drone
        MINUS
        SELECT
            drone_id
        FROM
            drone.rental
    )
ORDER BY
    drone_id;

-- Slide 38 - 39 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>














-- Slide 40-41
SELECT
    cust_lname
FROM
    drone.customer
ORDER BY
    cust_lname;

SELECT
    emp_lname
FROM
    drone.employee
ORDER BY
    emp_lname;

-- Intersect
SELECT
    emp_no,
    emp_fname,
    emp_lname,
    emp_type
FROM
    drone.employee
WHERE
    emp_lname IN (
        SELECT
            emp_lname
        FROM
            drone.employee
        INTERSECT
        SELECT
            cust_lname
        FROM
            drone.customer
    );

-- Slide 43 Extract and Decode
SELECT
    drone_id,
    ds_date_serviced,
    emp_no,
    emp_fname
    || ' '
    || emp_lname                                        AS employee_fullname,
    decode(emp_type, 'F', 'Full time', 'C', 'Contract') AS employee_category
FROM
         drone.employee
    NATURAL JOIN drone.drone_service
WHERE
    EXTRACT(MONTH FROM ds_date_serviced) BETWEEN 1 AND 3
ORDER BY
    drone_id,
    ds_date_serviced;

-- Slide 44 LPAD
-- Run statement, run as script
SELECT
    lpad('Page 1', 15, '*') AS "Lpad example"
FROM
    dual;

-- Slide 45 - 48
SELECT
    drone_id,
    COUNT(*) AS times_rented,
    to_char(COUNT(*) * 100 /(
        SELECT
            COUNT(rent_in_dt)
        FROM
            drone.rental
    ), '990.99') AS percent_overall
FROM
    drone.rental
WHERE
    rent_in_dt IS NOT NULL
GROUP BY
    drone_id
ORDER BY
    percent_overall DESC;

SELECT
    drone_id,
    COUNT(*) AS times_rented,
    lpad(ltrim(to_char(COUNT(*) * 100 /(
        SELECT
            COUNT(rent_in_dt)
        FROM
            drone.rental
    ), '990.99')),15,'*') AS percent_overall
FROM
    drone.rental
WHERE
    rent_in_dt IS NOT NULL
GROUP BY
    drone_id
ORDER BY
    percent_overall DESC;

-- Slide 50

SELECT
    drone_id,
    ( rent_in_dt - rent_out_dt ) AS maxdaysout,
    cust_id
FROM
         drone.cust_train
    NATURAL JOIN drone.rental
WHERE
    rent_in_dt IS NOT NULL
    AND ( drone_id, ( rent_in_dt - rent_out_dt ) ) IN (
        SELECT
            drone_id, MAX(rent_in_dt - rent_out_dt)
        FROM
            drone.rental
        WHERE
            rent_in_dt IS NOT NULL
        GROUP BY
            drone_id
    )
ORDER BY
    drone_id,
    cust_id;

-- Slide 51

SELECT
    drone_id,
    ( rent_in_dt - rent_out_dt ) AS maxdaysout,
    cust_id
FROM
         drone.cust_train
    NATURAL JOIN drone.rental r1
WHERE
    rent_in_dt IS NOT NULL
    AND ( rent_in_dt - rent_out_dt ) = (
        SELECT
            MAX(rent_in_dt - rent_out_dt)
        FROM
            drone.rental r2
        WHERE
            rent_in_dt IS NOT NULL
            AND r1.drone_id = r2.drone_id
    )
ORDER BY
    drone_id,
    cust_id;
