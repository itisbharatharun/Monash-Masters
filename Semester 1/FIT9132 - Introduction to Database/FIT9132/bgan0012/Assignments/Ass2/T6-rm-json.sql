/*****PLEASE ENTER YOUR DETAILS BELOW*****/
--T6-rm-json.sql

--Student ID: 35501308
--Student Name: Bharath Arun Gandhimani


/* Comments for your marker:




*/


-- PLEASE PLACE REQUIRED SQL SELECT STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon
-- (;) at the end of this answer

SELECT
    JSON_ARRAYAGG(
        JSON_OBJECT(
            KEY '_id' VALUE t.team_id,
            KEY 'carn_name' VALUE c.carn_name,
            KEY 'carn_date' VALUE TO_CHAR(c.carn_date, 'DD-Mon-YYYY'),
            KEY 'team_name' VALUE t.team_name,
            KEY 'team_leader' VALUE JSON_OBJECT(
                KEY 'name' VALUE TRIM(NVL(cl.comp_fname, '') || ' ' || NVL(cl.comp_lname, '')),
                KEY 'phone' VALUE NVL(cl.comp_phone, ''),
                KEY 'email' VALUE NVL(cl.comp_email, '')
            ),
            KEY 'team_no_of_members' VALUE NVL(team_member_counts.num_members, 0), 
            KEY 'team_members' VALUE (
                SELECT
                    JSON_ARRAYAGG(
                        JSON_OBJECT(
                            KEY 'competitor_name' VALUE TRIM(NVL(cm.comp_fname, '') || ' ' || NVL(cm.comp_lname, '')),
                            KEY 'competitor_phone' VALUE NVL(cm.comp_phone, ''),
                            KEY 'event_type' VALUE etm.eventtype_desc,
                            KEY 'entry_no' VALUE em.entry_no,
                            KEY 'starttime' VALUE NVL(TO_CHAR(em.entry_starttime, 'HH24:MI:SS'), ''),
                            KEY 'finishtime' VALUE NVL(TO_CHAR(em.entry_finishtime, 'HH24:MI:SS'), ''),
                            KEY 'elapsedtime' VALUE NVL(TO_CHAR(em.entry_elapsedtime, 'HH24:MI:SS'), '')
                        ) ORDER BY em.entry_no 
                    )
                FROM
                    entry em
                JOIN
                    competitor cm ON em.comp_no = cm.comp_no
                JOIN
                    event evm ON em.event_id = evm.event_id
                JOIN
                    eventtype etm ON evm.eventtype_code = etm.eventtype_code
                WHERE
                    em.team_id = t.team_id
            )
        ) ORDER BY t.team_id 
    ) AS team_collection_json
FROM
    team t
JOIN
    carnival c ON t.carn_date = c.carn_date
JOIN
    entry el ON t.event_id = el.event_id AND t.entry_no = el.entry_no 
JOIN
    competitor cl ON el.comp_no = cl.comp_no 
LEFT JOIN
    ( 
        SELECT
            team_id,
            COUNT(entry_no) AS num_members
        FROM
            entry
        WHERE
            team_id IS NOT NULL 
        GROUP BY
            team_id
    ) team_member_counts ON t.team_id = team_member_counts.team_id;