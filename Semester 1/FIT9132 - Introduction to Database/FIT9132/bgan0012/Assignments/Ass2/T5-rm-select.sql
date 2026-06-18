/*****PLEASE ENTER YOUR DETAILS BELOW*****/
--T5-rm-select.sql

--Student ID: 35501308
--Student Name: Bharath Arun Gandhimani


/* Comments for your marker:




*/


/* (a) */
-- PLEASE PLACE REQUIRED SQL SELECT STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon
-- (;) at the end of this answer
select t.team_name as team_name,
       t.carn_date as carnival_date,
       trim(c.comp_fname
            || ' '
            || c.comp_lname) as teamleader,
       (
           select count(distinct en.comp_no)
             from entry en
            where en.team_id = t.team_id
       ) as team_no_members
  from team t
  join entry leader_entry
on t.entry_no = leader_entry.entry_no
   and t.event_id = leader_entry.event_id
  join competitor c
on leader_entry.comp_no = c.comp_no
 where t.carn_date in (
    select distinct ev.carn_date
      from entry en_completed
      join event ev
    on en_completed.event_id = ev.event_id
     where en_completed.entry_finishtime is not null
)
   and upper(trim(t.team_name)) in (
    select upper(trim(t_inner.team_name))
      from team t_inner
     where t_inner.carn_date in (
        select distinct ev_inner.carn_date
          from entry en_inner
          join event ev_inner
        on en_inner.event_id = ev_inner.event_id
         where en_inner.entry_finishtime is not null
    )
     group by upper(trim(t_inner.team_name))
    having count(upper(trim(t_inner.team_name))) = (
        select max(name_count)
          from (
            select count(upper(trim(t_count.team_name))) as name_count
              from team t_count
             where t_count.carn_date in (
                select distinct ev_count.carn_date
                  from entry en_count
                  join event ev_count
                on en_count.event_id = ev_count.event_id
                 where en_count.entry_finishtime is not null
            )
             group by upper(trim(t_count.team_name))
        )
    )
)
 order by team_name,
          carnival_date;

/* (b) */
-- PLEASE PLACE REQUIRED SQL SELECT STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon
-- (;) at the end of this answer

select et.eventtype_desc as "Event",
       carn.carn_name
       || ', '
       || trim(to_char(
           carn.carn_date,
           'Day'
       ))
       || ' '
       || to_char(
           carn.carn_date,
           'DD/MON/YYYY'
       ) as "Carnival",
       to_char(
           e.entry_elapsedtime,
           'HH24:MI:SS'
       ) as "Current Record",
       to_char(
           c.comp_no,
           '00099'
       )
       || ' '
       || trim(c.comp_fname
               || ' '
               || c.comp_lname) as "Competitor No and Name",
       to_char(
           (carn.carn_date - c.comp_dob) / 365,
           '99'
       ) as "Age at Carnival"
  from entry e
  join event ev
on e.event_id = ev.event_id
  join eventtype et
on ev.eventtype_code = et.eventtype_code
  join carnival carn
on ev.carn_date = carn.carn_date
  join competitor c
on e.comp_no = c.comp_no
  join (
    select et_min.eventtype_code,
           min(e_min.entry_elapsedtime) as min_elapsed_time
      from entry e_min
      join event ev_min
    on e_min.event_id = ev_min.event_id
      join eventtype et_min
    on ev_min.eventtype_code = et_min.eventtype_code
     where e_min.entry_elapsedtime is not null
     group by et_min.eventtype_code
) min_times
on et.eventtype_code = min_times.eventtype_code
   and e.entry_elapsedtime = min_times.min_elapsed_time
 where e.entry_elapsedtime is not null
 order by "Event",
          c.comp_no;




/* (c) */
-- PLEASE PLACE REQUIRED SQL SELECT STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon
-- (;) at the end of this answer
select c.carn_name as "Carnival Name",
       c.carn_date as "Carnival Date",
       et.eventtype_desc as "Event Description",
       case
           when event_entry_counts.entries_count is null then
               'Not offered'
           else
               to_char(event_entry_counts.entries_count)
       end as "Number of Entries",
       to_char(
           case
               when nvl(
                   total_carnival_entries.total_entries,
                   0
               ) = 0 then
                   0
               else nvl(
                   event_entry_counts.entries_count,
                   0
               ) * 100 / total_carnival_entries.total_entries
           end,
           'FM999'
       ) as "% of Carnival Entries"
  from carnival c
 cross join eventtype et
  left join (
    select ev.carn_date,
           ev.eventtype_code,
           count(e.entry_no) as entries_count
      from entry e
      join event ev
    on e.event_id = ev.event_id
     group by ev.carn_date,
              ev.eventtype_code
) event_entry_counts
on c.carn_date = event_entry_counts.carn_date
   and et.eventtype_code = event_entry_counts.eventtype_code
  left join (
    select ev.carn_date,
           count(e.entry_no) as total_entries
      from entry e
      join event ev
    on e.event_id = ev.event_id
     group by ev.carn_date
) total_carnival_entries
on c.carn_date = total_carnival_entries.carn_date
 order by "Carnival Date",
          case
              when event_entry_counts.entries_count is null then
                  0
              else
                  event_entry_counts.entries_count
          end
      desc,
          "Event Description";


