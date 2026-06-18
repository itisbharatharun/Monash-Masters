--****PLEASE ENTER YOUR DETAILS BELOW****
--T4-rm-mods.sql

--Student ID: 35501308
--Student Name: Bharath Arun Gandhimani

/* Comments for your marker:




*/

--(a)
alter table competitor add comp_completed_events number default 0 not null;

-- COMMENT Line --
comment on column competitor.comp_completed_events is
    'Number of events completed by the competitor (with a finish time)';

update competitor c
   set
    c.comp_completed_events = (
        select count(e.entry_no)
          from entry e
         where e.comp_no = c.comp_no
           and e.entry_finishtime is not null
    );

commit;

DESC competitor;

select comp_no,
       comp_fname,
       comp_lname,
       comp_completed_events
  from competitor;


--(b)
drop table comp_carn_charity cascade constraints purge;
create table comp_carn_charity (
    comp_no    number(5) not null,
    carn_date  date not null,
    char_id    number(3) not null,
    percentage number(3,0) not null
);

-- COMMENT Line --
comment on table comp_carn_charity is
    'Stores multiple charity support for a competitor per carnival with percentages.'
    ;
comment on column comp_carn_charity.comp_no is
    'Competitor number (FK to COMPETITOR)';
comment on column comp_carn_charity.carn_date is
    'Carnival date (FK to CARNIVAL)';
comment on column comp_carn_charity.char_id is
    'Charity ID (FK to CHARITY)';
comment on column comp_carn_charity.percentage is
    'Percentage of total funds raised for this charity (0-100)';

-- PRIMARY Key Constraint --
alter table comp_carn_charity
    add constraint pk_comp_carn_charity primary key ( comp_no,
                                                      carn_date,
                                                      char_id );

-- FOREIGN Key Constraints - 
alter table comp_carn_charity
    add constraint fk_ccc_comp foreign key ( comp_no )
        references competitor ( comp_no );

alter table comp_carn_charity
    add constraint fk_ccc_carn foreign key ( carn_date )
        references carnival ( carn_date );

alter table comp_carn_charity
    add constraint fk_ccc_char foreign key ( char_id )
        references charity ( char_id );

-- Add check constraint for percentage
alter table comp_carn_charity
    add constraint ck_ccc_percentage check ( percentage between 0 and 100 );


-- 3. 
insert into comp_carn_charity (
    comp_no,
    carn_date,
    char_id,
    percentage
)
    select distinct en.comp_no,
                    c.carn_date,
                    en.char_id,
                    100
      from entry en
      join event ev
    on en.event_id = ev.event_id
      join carnival c
    on ev.carn_date = c.carn_date
     where en.char_id is not null;

commit;

-- 4. 
update entry
   set
    char_id = null
 where char_id is not null;

commit;

-- 5. 
delete from comp_carn_charity
 where comp_no = (
        select comp_no
          from competitor
         where comp_fname = 'Jackson'
           and comp_lname = 'Bull'
           and comp_phone = '0422412524'
    )
   and carn_date = (
    select carn_date
      from carnival
     where upper(trim(carn_name)) = 'RM WINTER SERIES CAULFIELD 2025'
);

insert into comp_carn_charity (
    comp_no,
    carn_date,
    char_id,
    percentage
) values ( (
    select comp_no
      from competitor
     where comp_fname = 'Jackson'
       and comp_lname = 'Bull'
       and comp_phone = '0422412524'
),
           (
               select carn_date
                 from carnival
                where upper(trim(carn_name)) = 'RM WINTER SERIES CAULFIELD 2025'
           ),
           (
               select char_id
                 from charity
                where upper(trim(char_name)) = 'RSPCA'
           ),
           70 );

insert into comp_carn_charity (
    comp_no,
    carn_date,
    char_id,
    percentage
) values ( (
    select comp_no
      from competitor
     where comp_fname = 'Jackson'
       and comp_lname = 'Bull'
       and comp_phone = '0422412524'
),
           (
               select carn_date
                 from carnival
                where upper(trim(carn_name)) = 'RM WINTER SERIES CAULFIELD 2025'
           ),
           (
               select char_id
                 from charity
                where upper(trim(char_name)) = 'BEYOND BLUE'
           ),
           30 );

commit;


DESC comp_carn_charity;

select ccc.comp_no,
       comp.comp_fname,
       comp.comp_lname,
       ccc.carn_date,
       car.carn_name,
       ch.char_name,
       ccc.percentage
  from comp_carn_charity ccc
  join competitor comp
on ccc.comp_no = comp.comp_no
  join carnival car
on ccc.carn_date = car.carn_date
  join charity ch
on ccc.char_id = ch.char_id;