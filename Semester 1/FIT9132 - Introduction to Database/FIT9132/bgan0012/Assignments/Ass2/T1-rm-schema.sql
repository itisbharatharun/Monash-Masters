/*****PLEASE ENTER YOUR DETAILS BELOW*****/
--T1-rm-schema.sql

--Student ID: 35501308
--Student Name: Bharath Arun Gandhimani

/* Comments for your marker:




*/

/* drop table statements - do not remove*/

DROP TABLE competitor CASCADE CONSTRAINTS PURGE;

DROP TABLE entry CASCADE CONSTRAINTS PURGE;

DROP TABLE team CASCADE CONSTRAINTS PURGE;

/* end of drop table statements*/

-- Task 1 Add Create table statements for the Missing TABLES below.
-- Ensure all column comments, and constraints (other than FK's)are included.
-- FK constraints are to be added at the end of this script

-- COMPETITOR
CREATE TABLE COMPETITOR (
    comp_no NUMBER(5) NOT NULL,
    comp_fname VARCHAR2(30),
    comp_lname VARCHAR2(30),
    comp_gender CHAR(1) NOT NULL,
    comp_dob DATE NOT NULL,
    comp_email VARCHAR2(50) NOT NULL,
    comp_unistatus CHAR(1) NOT NULL,
    comp_phone CHAR(10) NOT NULL
);

-- COMMENT Lines ---
COMMENT ON COLUMN COMPETITOR.comp_no IS 'Unique identifier for a competitor';
COMMENT ON COLUMN COMPETITOR.comp_fname IS 'Competitor''s first name';
COMMENT ON COLUMN COMPETITOR.comp_lname IS 'Competitor''s last name';
COMMENT ON COLUMN COMPETITOR.comp_gender IS 'Competitor''s gender (M/F/U)';
COMMENT ON COLUMN COMPETITOR.comp_dob IS 'Competitor''s date of birth';
COMMENT ON COLUMN COMPETITOR.comp_email IS 'Competitor''s email - unique';
COMMENT ON COLUMN COMPETITOR.comp_unistatus IS 'Y if Monash student/staff, else N';
COMMENT ON COLUMN COMPETITOR.comp_phone IS 'Competitor''s phone - unique';

-- ALTER Lines --
ALTER TABLE COMPETITOR
    ADD CONSTRAINT pk_competitor PRIMARY KEY (comp_no);

ALTER TABLE COMPETITOR
    ADD CONSTRAINT uq_comp_email UNIQUE (comp_email);

ALTER TABLE COMPETITOR
    ADD CONSTRAINT uq_comp_phone UNIQUE (comp_phone);

ALTER TABLE COMPETITOR
    ADD CONSTRAINT chk_comp_gender CHECK (comp_gender IN ('M', 'F', 'U'));

ALTER TABLE COMPETITOR
    ADD CONSTRAINT chk_comp_unistatus CHECK (comp_unistatus IN ('Y', 'N'));


--ENTRY
CREATE TABLE ENTRY (
   event_id NUMBER(6) NOT NULL,
   entry_no NUMBER(5) NOT NULL,
   entry_starttime DATE,
   entry_finishtime DATE,
   entry_elapsedtime DATE,
   comp_no NUMBER(5) NOT NULL,
   team_id NUMBER(3),
   char_id NUMBER(3)
);

-- COMMENT Lines --
COMMENT ON COLUMN ENTRY.event_id IS 'Foreign key to EVENT table';
COMMENT ON COLUMN ENTRY.entry_no IS 'Entry number within event';
COMMENT ON COLUMN ENTRY.entry_starttime IS 'Start time in hh24:mi:ss';
COMMENT ON COLUMN ENTRY.entry_finishtime IS 'Finish time in hh24:mi:ss';
COMMENT ON COLUMN ENTRY.entry_elapsedtime IS 'Elapsed time in hh24:mi:ss';

COMMENT ON COLUMN ENTRY.comp_no IS 'Foreign key to COMPETITOR table';
COMMENT ON COLUMN ENTRY.team_id IS 'Foreign key to TEAM table';
COMMENT ON COLUMN ENTRY.char_id IS 'Foreign key to CHARITY table';

--ALTER Lines --
ALTER TABLE ENTRY
   ADD CONSTRAINT pk_entry PRIMARY KEY (event_id, entry_no);


--TEAM
CREATE TABLE TEAM (
   team_id NUMBER(3) NOT NULL,
   team_name VARCHAR2(30) NOT NULL,
   carn_date DATE NOT NULL,
   event_id NUMBER(6) NOT NULL,
   entry_no NUMBER(5) NOT NULL
);


-- COMMENT Lines --
COMMENT ON COLUMN TEAM.team_id IS 'Unique team identifier';
COMMENT ON COLUMN TEAM.team_name IS 'Name of the team';
COMMENT ON COLUMN TEAM.carn_date IS 'Carnival date in which the team participates';
COMMENT ON COLUMN TEAM.event_id IS 'ID of the event the Team participates';
COMMENT ON COLUMN TEAM.entry_no IS 'Entry Number of the Team';


-- ALTER Lines --
ALTER TABLE TEAM
   ADD CONSTRAINT pk_team PRIMARY KEY (team_id);
ALTER TABLE TEAM
   ADD CONSTRAINT uq_team UNIQUE (team_name, carn_date);

-- Add all missing FK Constraints below here

-- ENTRY foreign keys
ALTER TABLE ENTRY
   ADD CONSTRAINT fk_entry_comp FOREIGN KEY (comp_no)
       REFERENCES COMPETITOR (comp_no);


ALTER TABLE ENTRY
   ADD CONSTRAINT fk_entry_team FOREIGN KEY (team_id)
       REFERENCES TEAM (team_id);

ALTER TABLE ENTRY
   ADD CONSTRAINT fk_entry_charity FOREIGN KEY (char_id)
       REFERENCES CHARITY (char_id);


ALTER TABLE ENTRY
   ADD CONSTRAINT fk_entry_event FOREIGN KEY (event_id)
       REFERENCES EVENT (event_id);


-- TEAM foreign keys
ALTER TABLE TEAM
   ADD CONSTRAINT fk_team_entry FOREIGN KEY (entry_no, event_id)
       REFERENCES ENTRY (entry_no, event_id);


ALTER TABLE TEAM
   ADD CONSTRAINT fk_carnival_team FOREIGN KEY (carn_date)
       REFERENCES CARNIVAL (carn_date);


        