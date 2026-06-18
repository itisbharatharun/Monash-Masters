/*****PLEASE ENTER YOUR DETAILS BELOW*****/
--T2-rm-insert.sql

--Student ID: 35501308
--Student Name: Bharath Arun Gandhimani

/* Comments for your marker:

Used the assistance of AI to verify the requirements to populate the data into the tables. 
Made our own names of competitor's name.

*/

-- Task 2 Load the COMPETITOR, ENTRY and TEAM tables with your own
-- test data following the data requirements expressed in the brief

-- =======================================
-- COMPETITOR
-- =======================================

insert into competitor (
    comp_no,
    comp_fname,
    comp_lname,
    comp_gender,
    comp_dob,
    comp_email,
    comp_unistatus,
    comp_phone
) values ( 1,
           'Bharath',
           'Arun',
           'M',
           to_date('15/JAN/2000','DD/MON/YYYY'),
           'bharath.arun@monash.com',
           'Y',
           '0466135132' );
insert into competitor (
    comp_no,
    comp_fname,
    comp_lname,
    comp_gender,
    comp_dob,
    comp_email,
    comp_unistatus,
    comp_phone
) values ( 2,
           'Monica',
           'Gellar',
           'F',
           to_date('20/FEB/1999','DD/MON/YYYY'),
           'monica.gellar@monash.com',
           'Y',
           '0465943512' );
insert into competitor (
    comp_no,
    comp_fname,
    comp_lname,
    comp_gender,
    comp_dob,
    comp_email,
    comp_unistatus,
    comp_phone
) values ( 3,
           'Clark',
           'Kent',
           'M',
           to_date('10/MAR/1998','DD/MON/YYYY'),
           'clark.kent@monash.com',
           'Y',
           '0463402264' );
insert into competitor (
    comp_no,
    comp_fname,
    comp_lname,
    comp_gender,
    comp_dob,
    comp_email,
    comp_unistatus,
    comp_phone
) values ( 4,
           'Harini',
           'Kanmani',
           'F',
           to_date('05/APR/2001','DD/MON/YYYY'),
           'harini.kanmani@monash.com',
           'Y',
           '0455227490' );
insert into competitor (
    comp_no,
    comp_fname,
    comp_lname,
    comp_gender,
    comp_dob,
    comp_email,
    comp_unistatus,
    comp_phone
) values ( 5,
           'Gokhul',
           'Raj',
           'M',
           to_date('25/MAY/1997','DD/MON/YYYY'),
           'gokhul.raj@monash.com',
           'Y',
           '0431254693' );
insert into competitor (
    comp_no,
    comp_fname,
    comp_lname,
    comp_gender,
    comp_dob,
    comp_email,
    comp_unistatus,
    comp_phone
) values ( 6,
           'Bhavithra',
           'Ravi',
           'F',
           to_date('01/JUN/1996','DD/MON/YYYY'),
           'bhavithra.ravi@email.com',
           'N',
           '0475452230' );
insert into competitor (
    comp_no,
    comp_fname,
    comp_lname,
    comp_gender,
    comp_dob,
    comp_email,
    comp_unistatus,
    comp_phone
) values ( 7,
           'Abishek',
           'Cadbury',
           'M',
           to_date('10/JUL/1995','DD/MON/YYYY'),
           'abishek.cadbury@email.com',
           'N',
           '0485673341' );
insert into competitor (
    comp_no,
    comp_fname,
    comp_lname,
    comp_gender,
    comp_dob,
    comp_email,
    comp_unistatus,
    comp_phone
) values ( 8,
           'Madhimitha',
           'Palanivel',
           'F',
           to_date('18/AUG/1994','DD/MON/YYYY'),
           'madhumitha.palanivel@email.com',
           'N',
           '0492347143' );
insert into competitor (
    comp_no,
    comp_fname,
    comp_lname,
    comp_gender,
    comp_dob,
    comp_email,
    comp_unistatus,
    comp_phone
) values ( 9,
           'Senthil',
           'Kumar',
           'M',
           to_date('22/SEP/1993','DD/MON/YYYY'),
           'senthil.kumar@email.com',
           'N',
           '0456387766' );
insert into competitor (
    comp_no,
    comp_fname,
    comp_lname,
    comp_gender,
    comp_dob,
    comp_email,
    comp_unistatus,
    comp_phone
) values ( 10,
           'Kaviya',
           'Udhayakumar',
           'F',
           to_date('30/OCT/1992','DD/MON/YYYY'),
           'kaviya.udhayakumar@email.com',
           'N',
           '0413243546' );
insert into competitor (
    comp_no,
    comp_fname,
    comp_lname,
    comp_gender,
    comp_dob,
    comp_email,
    comp_unistatus,
    comp_phone
) values ( 11,
           'Balaji',
           'Selvam',
           'M',
           to_date('01/NOV/2000','DD/MON/YYYY'),
           'balaji.selvam@monash.com',
           'Y',
           '0498676534' );
insert into competitor (
    comp_no,
    comp_fname,
    comp_lname,
    comp_gender,
    comp_dob,
    comp_email,
    comp_unistatus,
    comp_phone
) values ( 12,
           'Pavithra',
           'Kannan',
           'F',
           to_date('10/DEC/1999','DD/MON/YYYY'),
           'pavithra.kannan@example.com',
           'N',
           '0487964933' );
insert into competitor (
    comp_no,
    comp_fname,
    comp_lname,
    comp_gender,
    comp_dob,
    comp_email,
    comp_unistatus,
    comp_phone
) values ( 13,
           'Munil',
           'Kumar',
           'M',
           to_date('12/JAN/1998','DD/MON/YYYY'),
           'munil.kumar@monash.com',
           'Y',
           '0429486511' );
insert into competitor (
    comp_no,
    comp_fname,
    comp_lname,
    comp_gender,
    comp_dob,
    comp_email,
    comp_unistatus,
    comp_phone
) values ( 14,
           'Manjari',
           'Alagar',
           'F',
           to_date('25/FEB/1997','DD/MON/YYYY'),
           'manjari.alagar@example.com',
           'N',
           '0451230958' );
insert into competitor (
    comp_no,
    comp_fname,
    comp_lname,
    comp_gender,
    comp_dob,
    comp_email,
    comp_unistatus,
    comp_phone
) values ( 15,
           'Abdul',
           'Nizar',
           'M',
           to_date('03/MAR/1996','DD/MON/YYYY'),
           'abdul.nizar@monash.com',
           'Y',
           '0453197825' );

-- =======================================
-- ENTRY
-- =======================================

insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 1,
           1,
           to_date('09:30:00','hh24:mi:ss'),
           to_date('09:55:00','hh24:mi:ss'),
           to_date('00:25:00','hh24:mi:ss'),
           1,
           null,
           1 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 3,
           1,
           to_date('09:00:00','hh24:mi:ss'),
           to_date('09:28:00','hh24:mi:ss'),
           to_date('00:28:00','hh24:mi:ss'),
           9,
           null,
           3 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 2,
           3,
           to_date('08:30:00','hh24:mi:ss'),
           to_date('09:15:00','hh24:mi:ss'),
           to_date('00:45:00','hh24:mi:ss'),
           7,
           null,
           2 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 6,
           1,
           to_date('08:30:00','hh24:mi:ss'),
           to_date('08:45:00','hh24:mi:ss'),
           to_date('00:15:00','hh24:mi:ss'),
           7,
           null,
           2 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 10,
           1,
           to_date('08:00:00','hh24:mi:ss'),
           to_date('08:15:00','hh24:mi:ss'),
           to_date('00:15:00','hh24:mi:ss'),
           2,
           null,
           1 ); 

-- =======================================
-- TEAM
-- =======================================

insert into team (
    team_id,
    team_name,
    carn_date,
    event_id,
    entry_no
) values ( 1,
           'Runners High',
           to_date('22/SEP/2024','DD/MON/YYYY'),
           1,
           1 );
insert into team (
    team_id,
    team_name,
    carn_date,
    event_id,
    entry_no
) values ( 2,
           'Fast Trackers',
           to_date('05/OCT/2024','DD/MON/YYYY'),
           3,
           1 );
insert into team (
    team_id,
    team_name,
    carn_date,
    event_id,
    entry_no
) values ( 3,
           'Speedsters',
           to_date('22/SEP/2024','DD/MON/YYYY'),
           2,
           3 );
insert into team (
    team_id,
    team_name,
    carn_date,
    event_id,
    entry_no
) values ( 4,
           'Speedsters',
           to_date('02/FEB/2025','DD/MON/YYYY'),
           6,
           1 );
insert into team (
    team_id,
    team_name,
    carn_date,
    event_id,
    entry_no
) values ( 5,
           'Sprint Crew',
           to_date('15/MAR/2025','DD/MON/YYYY'),
           10,
           1 );


-- =======================================
-- UPDATE ENTRY
-- =======================================

update entry
   set
    team_id = 1
 where event_id = 1
   and entry_no = 1;
update entry
   set
    team_id = 2
 where event_id = 3
   and entry_no = 1;
update entry
   set
    team_id = 3
 where event_id = 2
   and entry_no = 3;
update entry
   set
    team_id = 4
 where event_id = 6
   and entry_no = 1;
update entry
   set
    team_id = 5
 where event_id = 10
   and entry_no = 1;

-- =======================================
-- ENTRY
-- =======================================

insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 1,
           2,
           to_date('09:30:00','hh24:mi:ss'),
           to_date('10:00:00','hh24:mi:ss'),
           to_date('00:30:00','hh24:mi:ss'),
           2,
           1,
           2 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 1,
           3,
           to_date('09:30:00','hh24:mi:ss'),
           to_date('09:58:00','hh24:mi:ss'),
           to_date('00:28:00','hh24:mi:ss'),
           3,
           null,
           1 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 1,
           4,
           to_date('09:30:00','hh24:mi:ss'),
           null,
           null,
           4,
           null,
           null );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 1,
           5,
           to_date('09:30:00','hh24:mi:ss'),
           to_date('10:05:00','hh24:mi:ss'),
           to_date('00:35:00','hh24:mi:ss'),
           11,
           1,
           4 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 1,
           6,
           to_date('09:30:00','hh24:mi:ss'),
           to_date('10:02:00','hh24:mi:ss'),
           to_date('00:32:00','hh24:mi:ss'),
           12,
           null,
           null );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 2,
           1,
           to_date('08:30:00','hh24:mi:ss'),
           to_date('09:20:00','hh24:mi:ss'),
           to_date('00:50:00','hh24:mi:ss'),
           5,
           null,
           3 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 2,
           2,
           to_date('08:30:00','hh24:mi:ss'),
           to_date('09:25:00','hh24:mi:ss'),
           to_date('00:55:00','hh24:mi:ss'),
           6,
           null,
           1 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 2,
           4,
           to_date('08:30:00','hh24:mi:ss'),
           to_date('09:18:00','hh24:mi:ss'),
           to_date('00:48:00','hh24:mi:ss'),
           8,
           3,
           null );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 2,
           5,
           to_date('08:30:00','hh24:mi:ss'),
           to_date('09:30:00','hh24:mi:ss'),
           to_date('01:00:00','hh24:mi:ss'),
           13,
           null,
           1 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 2,
           6,
           to_date('08:30:00','hh24:mi:ss'),
           to_date('09:35:00','hh24:mi:ss'),
           to_date('01:05:00','hh24:mi:ss'),
           14,
           null,
           2 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 3,
           2,
           to_date('09:00:00','hh24:mi:ss'),
           to_date('09:32:00','hh24:mi:ss'),
           to_date('00:32:00','hh24:mi:ss'),
           10,
           2,
           null );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 3,
           3,
           to_date('09:00:00','hh24:mi:ss'),
           to_date('09:25:00','hh24:mi:ss'),
           to_date('00:25:00','hh24:mi:ss'),
           1,
           null,
           1 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 3,
           4,
           to_date('09:00:00','hh24:mi:ss'),
           to_date('09:30:00','hh24:mi:ss'),
           to_date('00:30:00','hh24:mi:ss'),
           11,
           null,
           2 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 3,
           5,
           to_date('09:00:00','hh24:mi:ss'),
           to_date('09:35:00','hh24:mi:ss'),
           to_date('00:35:00','hh24:mi:ss'),
           5,
           2,
           4 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 3,
           6,
           to_date('09:00:00','hh24:mi:ss'),
           to_date('09:38:00','hh24:mi:ss'),
           to_date('00:38:00','hh24:mi:ss'),
           6,
           null,
           null );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 4,
           1,
           to_date('08:30:00','hh24:mi:ss'),
           to_date('09:20:00','hh24:mi:ss'),
           to_date('00:50:00','hh24:mi:ss'),
           2,
           null,
           2 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 4,
           2,
           to_date('08:30:00','hh24:mi:ss'),
           to_date('09:18:00','hh24:mi:ss'),
           to_date('00:48:00','hh24:mi:ss'),
           3,
           null,
           1 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 4,
           3,
           to_date('08:30:00','hh24:mi:ss'),
           to_date('09:25:00','hh24:mi:ss'),
           to_date('00:55:00','hh24:mi:ss'),
           12,
           null,
           4 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 4,
           4,
           to_date('08:30:00','hh24:mi:ss'),
           to_date('09:22:00','hh24:mi:ss'),
           to_date('00:52:00','hh24:mi:ss'),
           15,
           null,
           3 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 4,
           5,
           to_date('08:30:00','hh24:mi:ss'),
           to_date('09:28:00','hh24:mi:ss'),
           to_date('00:58:00','hh24:mi:ss'),
           10,
           null,
           4 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 5,
           1,
           to_date('08:00:00','hh24:mi:ss'),
           to_date('10:00:00','hh24:mi:ss'),
           to_date('02:00:00','hh24:mi:ss'),
           5,
           null,
           3 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 5,
           2,
           to_date('08:00:00','hh24:mi:ss'),
           to_date('10:10:00','hh24:mi:ss'),
           to_date('02:10:00','hh24:mi:ss'),
           6,
           null,
           1 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 5,
           3,
           to_date('08:00:00','hh24:mi:ss'),
           to_date('10:15:00','hh24:mi:ss'),
           to_date('02:15:00','hh24:mi:ss'),
           11,
           null,
           1 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 5,
           4,
           to_date('08:00:00','hh24:mi:ss'),
           to_date('10:20:00','hh24:mi:ss'),
           to_date('02:20:00','hh24:mi:ss'),
           12,
           null,
           2 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 6,
           2,
           to_date('08:30:00','hh24:mi:ss'),
           to_date('08:48:00','hh24:mi:ss'),
           to_date('00:18:00','hh24:mi:ss'),
           8,
           4,
           null );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 6,
           3,
           to_date('08:30:00','hh24:mi:ss'),
           to_date('08:50:00','hh24:mi:ss'),
           to_date('00:20:00','hh24:mi:ss'),
           9,
           null,
           3 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 6,
           4,
           to_date('08:30:00','hh24:mi:ss'),
           to_date('08:52:00','hh24:mi:ss'),
           to_date('00:22:00','hh24:mi:ss'),
           10,
           null,
           null );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 7,
           1,
           to_date('08:30:00','hh24:mi:ss'),
           to_date('09:00:00','hh24:mi:ss'),
           to_date('00:30:00','hh24:mi:ss'),
           13,
           null,
           1 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 7,
           2,
           to_date('08:30:00','hh24:mi:ss'),
           to_date('09:05:00','hh24:mi:ss'),
           to_date('00:35:00','hh24:mi:ss'),
           14,
           null,
           2 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 7,
           3,
           to_date('08:30:00','hh24:mi:ss'),
           to_date('09:10:00','hh24:mi:ss'),
           to_date('00:40:00','hh24:mi:ss'),
           15,
           null,
           4 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 8,
           1,
           to_date('08:00:00','hh24:mi:ss'),
           to_date('08:55:00','hh24:mi:ss'),
           to_date('00:55:00','hh24:mi:ss'),
           15,
           null,
           3 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 8,
           2,
           to_date('08:00:00','hh24:mi:ss'),
           null,
           null,
           1,
           null,
           null );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 8,
           3,
           to_date('08:00:00','hh24:mi:ss'),
           to_date('09:00:00','hh24:mi:ss'),
           to_date('01:00:00','hh24:mi:ss'),
           5,
           null,
           1 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 8,
           4,
           to_date('08:00:00','hh24:mi:ss'),
           to_date('09:05:00','hh24:mi:ss'),
           to_date('01:05:00','hh24:mi:ss'),
           6,
           null,
           2 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 9,
           1,
           to_date('08:00:00','hh24:mi:ss'),
           to_date('10:30:00','hh24:mi:ss'),
           to_date('02:30:00','hh24:mi:ss'),
           7,
           null,
           3 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 9,
           2,
           to_date('08:00:00','hh24:mi:ss'),
           to_date('10:40:00','hh24:mi:ss'),
           to_date('02:40:00','hh24:mi:ss'),
           8,
           null,
           null );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 10,
           2,
           to_date('08:00:00','hh24:mi:ss'),
           to_date('08:20:00','hh24:mi:ss'),
           to_date('00:20:00','hh24:mi:ss'),
           3,
           5,
           2 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 10,
           3,
           to_date('08:00:00','hh24:mi:ss'),
           to_date('08:22:00','hh24:mi:ss'),
           to_date('00:22:00','hh24:mi:ss'),
           4,
           null,
           null );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 10,
           4,
           to_date('08:00:00','hh24:mi:ss'),
           to_date('08:25:00','hh24:mi:ss'),
           to_date('00:25:00','hh24:mi:ss'),
           9,
           null,
           3 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 11,
           1,
           to_date('07:45:00','hh24:mi:ss'),
           to_date('12:00:00','hh24:mi:ss'),
           to_date('04:15:00','hh24:mi:ss'),
           1,
           null,
           3 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 11,
           2,
           to_date('07:45:00','hh24:mi:ss'),
           to_date('12:10:00','hh24:mi:ss'),
           to_date('04:25:00','hh24:mi:ss'),
           2,
           null,
           2 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 12,
           1,
           to_date('08:45:00','hh24:mi:ss'),
           to_date('09:10:00','hh24:mi:ss'),
           to_date('00:25:00','hh24:mi:ss'),
           13,
           null,
           1 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 12,
           2,
           to_date('08:45:00','hh24:mi:ss'),
           to_date('09:12:00','hh24:mi:ss'),
           to_date('00:27:00','hh24:mi:ss'),
           14,
           null,
           2 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 13,
           1,
           to_date('08:30:00','hh24:mi:ss'),
           to_date('09:20:00','hh24:mi:ss'),
           to_date('00:50:00','hh24:mi:ss'),
           15,
           null,
           3 );
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    entry_finishtime,
    entry_elapsedtime,
    comp_no,
    team_id,
    char_id
) values ( 14,
           1,
           to_date('08:00:00','hh24:mi:ss'),
           to_date('10:25:00','hh24:mi:ss'),
           to_date('02:25:00','hh24:mi:ss'),
           1,
           null,
           4 );

commit;