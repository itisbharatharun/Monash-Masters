--****PLEASE ENTER YOUR DETAILS BELOW****
--T3-rm-dm.sql


--Student ID: 35501308
--Student Name: Bharath Arun Gandhimani


/* Comments for your marker:


Used internet to understand how the insertion of Keith and Jackson work.


*/


--(a)
-- Create SEQUENCE statements for COMPETITOR and TEAM tables
drop sequence competitor_seq;
drop sequence team_seq;


create sequence competitor_seq start with 100 increment by 5;


create sequence team_seq start with 100 increment by 5;




--(b)
-- Record two competitors (Keith Rose, Jackson Bull), form a team (Super Runners), and create their entries.
-- Insert Keith Rose
insert into competitor (
    comp_no,
    comp_fname,
    comp_lname,
    comp_gender,
    comp_dob,
    comp_email,
    comp_unistatus,
    comp_phone
) values ( competitor_seq.nextval,
           'Keith',
           'Rose',
           'M',
           to_date('15/MAR/2002','DD/MON/YYYY'),
           'keith.rose@monash.edu',
           'Y',
           '0422141112' );

-- Insert Jackson Bull
insert into competitor (
    comp_no,
    comp_fname,
    comp_lname,
    comp_gender,
    comp_dob,
    comp_email,
    comp_unistatus,
    comp_phone
) values ( competitor_seq.nextval,
           'Jackson',
           'Bull',
           'M',
           to_date('20/APR/2001','DD/MON/YYYY'),
           'jackson.bull@monash.edu',
           'Y',
           '0422412524' );


-- Insert Keith Rose's entry first to get its entry_no for linking to the TEAM table
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    comp_no,
    team_id,
    char_id
) values ( (
    select e.event_id
      from event e
      join eventtype et
    on e.eventtype_code = et.eventtype_code
     where upper(trim(et.eventtype_desc)) = upper('10 km run')
       and e.carn_date = (
        select carn_date
          from carnival
         where upper(trim(carn_name)) = 'RM WINTER SERIES CAULFIELD 2025'
    )
),
           nvl(
               (
                   select max(entry_no)
                     from entry
                    where event_id =(
                       select e.event_id
                         from event e
                         join eventtype et
                       on e.eventtype_code = et.eventtype_code
                        where upper(trim(et.eventtype_desc)) = upper('10 km run')
                          and e.carn_date =(
                           select carn_date
                             from carnival
                            where upper(trim(carn_name)) = 'RM WINTER SERIES CAULFIELD 2025'
                       )
                   )
               ),
               0
           ) + 1,
           (
               select event_starttime
                 from event
                where event_id = (
                   select e.event_id
                     from event e
                     join eventtype et
                   on e.eventtype_code = et.eventtype_code
                    where upper(trim(et.eventtype_desc)) = upper('10 km run')
                      and e.carn_date = (
                       select carn_date
                         from carnival
                        where upper(trim(carn_name)) = 'RM WINTER SERIES CAULFIELD 2025'
                   )
               )
           ),
           (
               select comp_no
                 from competitor
                where comp_fname = 'Keith'
                  and comp_lname = 'Rose'
                  and comp_phone = '0422141112'
           ),
           null, -- Temporarily NULL, will be updated after team insertion
           (
               select char_id
                 from charity
                where charity.char_name = 'Salvation Army'
           ) );


-- Insert the Super Runners team, referencing Keith's entry for its entry_no and event_id
insert into team (
    team_id,
    team_name,
    carn_date,
    event_id,
    entry_no
)
    select team_seq.nextval,
           'Super Runners',
           c.carn_date,
           e.event_id,
           (
               select entry_no
                 from entry
                where comp_no = (
                       select comp_no
                         from competitor
                        where comp_fname = 'Keith'
                          and comp_lname = 'Rose'
                          and comp_phone = '0422141112'
                   )
                  and event_id = e.event_id
           )
      from carnival c
      join event e
    on e.carn_date = c.carn_date
      join eventtype et
    on e.eventtype_code = et.eventtype_code
     where upper(trim(c.carn_name)) = 'RM WINTER SERIES CAULFIELD 2025'
       and upper(trim(et.eventtype_desc)) = upper('10 km run')
       and not exists (
        select 1
          from team existing_team
         where upper(trim(existing_team.team_name)) = upper('Super Runners')
           and existing_team.carn_date = c.carn_date
    );


-- Update Keith's entry with the new team_id
update entry
   set
    team_id = (
        select team_id
          from team
         where upper(trim(team_name)) = upper('Super Runners')
           and carn_date = (
            select carn_date
              from carnival
             where upper(trim(carn_name)) = 'RM WINTER SERIES CAULFIELD 2025'
        )
    )
 where comp_no = (
        select comp_no
          from competitor
         where comp_fname = 'Keith'
           and comp_lname = 'Rose'
           and comp_phone = '0422141112'
    )
   and event_id = (
    select e.event_id
      from event e
      join eventtype et
    on e.eventtype_code = et.eventtype_code
     where upper(trim(et.eventtype_desc)) = upper('10 km run')
       and e.carn_date = (
        select carn_date
          from carnival
         where upper(trim(carn_name)) = 'RM WINTER SERIES CAULFIELD 2025'
    )
);

-- Insert Jackson Bull's entry
insert into entry (
    event_id,
    entry_no,
    entry_starttime,
    comp_no,
    team_id,
    char_id
) values ( (
    select e.event_id
      from event e
      join eventtype et
    on e.eventtype_code = et.eventtype_code
     where upper(trim(et.eventtype_desc)) = upper('10 km run')
       and e.carn_date = (
        select carn_date
          from carnival
         where upper(trim(carn_name)) = 'RM WINTER SERIES CAULFIELD 2025'
    )
),
           nvl(
               (
                   select max(entry_no)
                     from entry
                    where event_id =(
                       select e.event_id
                         from event e
                         join eventtype et
                       on e.eventtype_code = et.eventtype_code
                        where upper(trim(et.eventtype_desc)) = upper('10 km run')
                          and e.carn_date =(
                           select carn_date
                             from carnival
                            where upper(trim(carn_name)) = 'RM WINTER SERIES CAULFIELD 2025'
                       )
                   )
               ),
               0
           ) + 1,
   -- Replaced hardcoded time with subquery to retrieve event_starttime
           (
               select event_starttime
                 from event
                where event_id = (
                   select e.event_id
                     from event e
                     join eventtype et
                   on e.eventtype_code = et.eventtype_code
                    where upper(trim(et.eventtype_desc)) = upper('10 km run')
                      and e.carn_date = (
                       select carn_date
                         from carnival
                        where upper(trim(carn_name)) = 'RM WINTER SERIES CAULFIELD 2025'
                   )
               )
           ),
           (
               select comp_no
                 from competitor
                where comp_fname = 'Jackson'
                  and comp_lname = 'Bull'
                  and comp_phone = '0422412524'
           ),
           (
               select team_id
                 from team
                where upper(trim(team_name)) = upper('Super Runners')
                  and carn_date = (
                   select carn_date
                     from carnival
                    where upper(trim(carn_name)) = 'RM WINTER SERIES CAULFIELD 2025'
               )
           ),
           (
               select char_id
                 from charity
                where charity.char_name = 'RSPCA'
           ) );


commit;




--(c)
-- Jackson Bull downgrades event and changes charity
update entry
   set event_id = (
    select e.event_id
      from event e
      join eventtype et
    on e.eventtype_code = et.eventtype_code
     where upper(trim(et.eventtype_desc)) = upper('5 km run')
       and e.carn_date = (
        select carn_date
          from carnival
         where upper(trim(carn_name)) = 'RM WINTER SERIES CAULFIELD 2025'
    )
),
       char_id = (
           select char_id
             from charity
            where upper(trim(char_name)) = upper('Beyond Blue')
       )
 where comp_no = (
        select comp_no
          from competitor
         where comp_fname = 'Jackson'
           and comp_lname = 'Bull'
           and comp_phone = '0422412524'
    )
   and event_id = (
    select e.event_id
      from event e
      join eventtype et
    on e.eventtype_code = et.eventtype_code
     where upper(trim(et.eventtype_desc)) = upper('10 km run')
       and e.carn_date = (
        select carn_date
          from carnival
         where upper(trim(carn_name)) = 'RM WINTER SERIES CAULFIELD 2025'
    )
); -- This is the *old* event_id to identify the record

commit;

--(d)
-- Keith Rose withdraws, Super Runners disbanded, Jackson Bull becomes individual runner.
-- 1. Unlink ALL entries from 'Super Runners' team first.
update entry
   set
    team_id = null
 where team_id = (
    select team_id
      from team
     where upper(trim(team_name)) = upper('Super Runners')
       and carn_date = (
        select carn_date
          from carnival
         where upper(trim(carn_name)) = 'RM WINTER SERIES CAULFIELD 2025'
    )
);


-- 2. Disband and remove Super Runners team.
delete from team
 where upper(trim(team_name)) = upper('Super Runners')
   and carn_date = (
    select carn_date
      from carnival
     where upper(trim(carn_name)) = 'RM WINTER SERIES CAULFIELD 2025'
);


-- 3. Delete Keith Rose's entry from the specific carnival.
delete from entry
 where comp_no = (
        select comp_no
          from competitor
         where comp_fname = 'Keith'
           and comp_lname = 'Rose'
           and comp_phone = '0422141112'
    )
   and event_id in (
    select e.event_id
      from event e
     where e.carn_date = (
        select carn_date
          from carnival
         where upper(trim(carn_name)) = 'RM WINTER SERIES CAULFIELD 2025'
    )
);

commit;