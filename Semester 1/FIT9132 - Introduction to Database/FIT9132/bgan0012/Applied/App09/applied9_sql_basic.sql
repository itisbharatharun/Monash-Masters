/*
Database Teaching Team
applied9_sql_basic.sql

student id: 35501308
student name: Bharath Arun Gandhimani
last modified date: 08/05/2025

*/

/* Part A - Retrieving data from a single table */

-- A1
select *
  from uni.unit
 order by unitcode;

-- A2
select *
  from uni.student
 where upper(stuaddress) like upper('%Caulfield')
 order by stuid; 

-- A3
select stuid,
       stufname as firstname,
       stulname as lastname,
       to_char(
           studob,
           'dd/mm/yyyy'
       ) as studob,
       stuaddress,
       stuphone,
       stuemail
  from uni.student
 where upper(stulname) like upper('M%')
 order by stuid;

-- A4
select stuid,
       stulname,
       stufname,
       stuaddress
  from uni.student
 where upper(stulname) like upper('S%')
   and upper(stufname) like upper('%i%')
 order by stuid;
-- A5
select *
  from uni.unit
 where upper(unitcode) like 'FIT%'
 order by unitcode;

-- A6
select unitcode,
       ofsemester
  from uni.offering
 where to_char(
    ofyear,
    'yyyy'
) = '2021'
 order by unitcode,
          ofsemester;

-- A7
select unitcode,
       to_char(
           ofyear,
           'yyyy'
       )
  from uni.offering
 where ofsemester = '2'
   and ( to_char(
    ofyear,
    'yyyy'
) = '2019'
    or to_char(
    ofyear,
    'yyyy'
) = '2020' )
 order by unitcode;
-- A8
select stuid,
       unitcode,
       enrolmark
  from uni.enrolment
 where enrolmark < 50
   and ofsemester = 2
   and to_char(
    ofyear,
    'yyyy'
) = '2021'
 order by stuid,
          unitcode;
-- A9
select stuid
  from uni.enrolment
 where enrolmark is null
   and enrolgrade is null
   and upper(unitcode) = 'FIT3176'
   and to_char(
    ofyear,
    'yyyy'
) = '2020'
   and ofsemester = 1
 order by stuid;

/* Part B - Retrieving data from multiple tables */

-- B1
select unitcode,
       ofsemester,
       stafffname,
       stafflname
  from uni.offering o
  join uni.staff s
on o.staffid = s.staffid
 where to_char(
    ofyear,
    'yyyy'
) = '2021'
 order by ofsemester;

-- B2


-- B3
select *
  from uni.student s
  join uni.enrolment e
on s.stuid = e.stuid
  join uni.unit u
on u.unitcode = e.unitcode;
-- B4


-- B5


-- B6


-- B7


-- B8


-- B9


-- B10