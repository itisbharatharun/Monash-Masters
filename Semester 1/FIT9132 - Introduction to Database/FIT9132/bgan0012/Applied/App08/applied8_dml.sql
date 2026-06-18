/*
Databases Applied 8
applied8_dml.sql

student id: 35501308
student name:Bharath Arun G
last modified date:

*/

---==INSERT==--
/*1. Write SQL INSERT statements to add the data into the specified tables */


INSERT INTO student VALUES(11111111, 'Bloggs', 'Fred',to_date('01-Jan-2003','dd-Mon-yyyy'));
INSERT INTO student VALUES(11111112, 'Nice',NULL,to_date('10-Oct-2004','dd-Mon-yyyy'));
INSERT INTO student VALUES(11111113, 'Wheat', 'Wendy',to_date('5-May-2005','dd-Mon-yyyy'));
INSERT INTO student VALUES(11111114, 'Sheen', 'Cindy',to_date('25-Dec-2004','dd-Mon-yyyy'));

SELECT * from STUDENT;

INSERT INTO UNIT VALUES('FIT9999', 'FIT Last Unit');
INSERT INTO UNIT VALUES('FIT9132', 'Introduction to Databases');
INSERT INTO UNIT VALUES('FIT9161', 'Project');
INSERT INTO UNIT VALUES('FIT5111', 'Student''s Life');

SELECT * FROM UNIT;

INSERT INTO ENROLMENT (stu_nbr,
                    unit_code,
                    enrol_year,
                    enrol_semester
                    ) 
                    VALUES(11111111,
                        'FIT9132',  
                        TO_DATE('2022', 'yyyy'),    
                        '1');
INSERT INTO ENROLMENT (stu_nbr,
                    unit_code,
                    enrol_year,
                    enrol_semester
                    ) 
                    VALUES(11111111,
                        'FIT9161',  
                        TO_DATE('2022', 'yyyy'),    
                        '1');
INSERT INTO ENROLMENT (stu_nbr,
                    unit_code,
                    enrol_year,
                    enrol_semester
                    ) 
                    VALUES(11111111,
                        'FIT9132',  
                        TO_DATE('2022', 'yyyy'),    
                        '2');
INSERT INTO ENROLMENT (stu_nbr,
                    unit_code,
                    enrol_year,
                    enrol_semester
                    ) 
                    VALUES(11111111,
                        'FIT5111',  
                        TO_DATE('2022', 'yyyy'),    
                        '2');


SELECT * from ENROLMENT;


---==INSERT using SEQUENCEs ==--
/*1. Create a sequence for the STUDENT table called STUDENT_SEQ */
CREATE SEQUENCE STUDENT_SEQ START with 11111115
/*2. Add a new student (MICKEY MOUSE) and an enrolment for this student as listed below, 
treat all the data that you add as a single transaction. */


---==Advanced INSERT==--
/*1. A new student has started a course. Subsequently this new student needs to enrol into 
Introduction to databases. Enter the new student's details, then insert his/her enrollment 
to the database using the sequence in combination with a SELECT statement. You can 
make up details of the new student and when they will attempt Introduction to databases 
and you may assume there is only one student with such a name in the system.

You must not do a manual lookup to find the unit code of the Introduction to Databases 
and the student number.
 */

---=Creating a table and inserting data as a single SQL statement==--
/*1. Create a table called FIT5111_STUDENT. The table should contain all enrolments for the 
unit FIT5111 */

/*2. Check the table exists */


/*3. List the contents of the table */

---==8.2.5 UPDATE==--
/*1. Update the unit name of FIT9999 from 'FIT Last Unit' to 'place holder unit'.*/


/*2. Enter the mark and grade for the student with the student number of 11111113 
for Introduction to Databases that the student enrolled in semester 1 of 2023. 
The mark is 75 and the grade is D.*/
UPDATE enrolment
SET enrol_mark = 63, enrol_grade = 'C'
WHERE stu_nbr = 11111111 AND
    upper(unit_code) = (select UNIT_CODE FROM UNIT where UNIT.UNIT_NAME = 'Introduction to Databases') AND
    enrol_semester = '1' AND
    to_char(enrol_year,'yyyy') = '2023';

COMMIT;

/*3. The university introduced a new grade classification scale. 
The new classification are:
0 - 44 is N
45 - 54 is P1
55 - 64 is P2
65 - 74 is C
75 - 84 is D
85 - 100 is HD
Change the database to reflect the new grade classification scale.
*/


/*4. Due to the new regulation, the Faculty of IT decided to change 'Project' unit code 
from FIT9161 into FIT5161. Change the database to reflect this situation.
Note: you need to disable the FK constraint before you do the modification 
then enable the FK to have it active again.
*/



--==DELETE==--
/*1. A student with student number 11111114 has taken intermission in semester 1 2023, 
hence all the enrolment of this student for semester 1 2023 should be removed. 
Change the database to reflect this situation.*/


/*2. The faculty decided to remove all Student's Life unit's enrolments. 
Change the database to reflect this situation.
Note: unit names are unique in the database.*/


/*3. Assume that Wendy Wheat (student number 11111113) has withdrawn from the university. 
Remove her details from the database.*/


