/*
Database Teaching Team
applied10_sql_intermediate.sql

student id: 35501308
student name: Bharath Arun Gandhimani
last modified date: 15/05/2025

*/

--1

SELECT
    MAX(ENROLMARK)
FROM
    UNI.ENROLMENT
WHERE
        UPPER(UNITCODE) = 'FIT9136'
    AND OFSEMESTER = 2
    AND TO_CHAR(OFYEAR, 'yyyy') = '2019';

--2

SELECT
    TO_CHAR(AVG(ENROLMARK), '999.99') AS AVG_MARK
FROM
    UNI.ENROLMENT
WHERE
        UPPER(UNITCODE) = 'FIT2094'
    AND OFSEMESTER = 2
    AND TO_CHAR(OFYEAR, 'yyyy') = '2020';

--3

SELECT
    TO_CHAR(OFYEAR, 'yyyy') AS YEAR,
    OFSEMESTER,
    TO_CHAR(
        AVG(ENROLMARK),
        '999.99'
    )                       AS AVG_MARK
FROM
    UNI.ENROLMENT
WHERE
    UPPER(UNITCODE) = 'FIT9136'
GROUP BY
    TO_CHAR(OFYEAR, 'yyyy'),
    OFSEMESTER
ORDER BY
    YEAR,
    OFSEMESTER;

--4
-- a. 



-- b. Repeat students are only counted once across 2019



--5




--6



--7

SELECT
    UNITCODE,
    COUNT(PREREQUNITCODE) AS NO_OF_PREREQ
FROM
    UNI.PREREQ
GROUP BY
    UNITCODE
ORDER BY
    UNITCODE;

--8

SELECT
    UNITCODE,
    COUNT(ENROLGRADE) AS NO_OF_WITHHELD
FROM
    UNI.ENROLMENT
WHERE
        OFSEMESTER = 2
    AND TO_CHAR(OFYEAR, 'yyyy') = '2020'
    AND ENROLGRADE = 'WH'
GROUP BY
    UNITCODE
ORDER BY
    NO_OF_WITHHELD DESC,
    UNITCODE;

--9



--10




--11

SELECT
    S.STUID,
    STUFNAME
    || ' '
    || STULNAME AS FULLNAME,
    TO_CHAR(STUDOB, 'dd/mm/yyyy') AS DATE_OF_BIRTH
FROM
         UNI.STUDENT S
    JOIN UNI.ENROLMENT E ON S.STUID = E.STUID
WHERE
        UPPER(E.UNITCODE) = 'FIT9132'
    AND STUDOB = (
        SELECT
            MIN(STUDOB)
        FROM
                 UNI.STUDENT S
            JOIN UNI.ENROLMENT E ON S.STUID = E.STUID
        WHERE
            UPPER(E.UNITCODE) = 'FIT9132'
    )
ORDER BY
    S.STUID; 

--12



--13







