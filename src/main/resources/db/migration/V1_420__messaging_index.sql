
UPDATE flow.project_message_owner AS pmo
SET archived = true
WHERE (project_id, sms_team_id, user_id) IN (
    -- identify duplicate rows
    SELECT project_id, sms_team_id, user_id
    FROM flow.project_message_owner
    WHERE archived is false
    GROUP BY project_id, sms_team_id, user_id
    HAVING count(*) > 1
)
  AND archived = false
  AND id NOT IN (
    -- identify the row with the lowest id within each set of duplicates, keep that unarchived
    SELECT MIN(id)
    FROM flow.project_message_owner
    WHERE archived is false
    GROUP BY project_id, sms_team_id, user_id
    HAVING count(*) > 1
);

UPDATE flow.project_message_team AS pmt
SET archived = true
WHERE (project_id, sms_team_id) IN (
    -- identify duplicate rows
    SELECT project_id, sms_team_id
    FROM flow.project_message_team
    WHERE archived is false
    GROUP BY project_id, sms_team_id
    HAVING count(*) > 1
)
  AND archived = false
  AND id NOT IN (
    -- identify the row with the lowest id within each set of duplicates, keep that unarchived
    SELECT MIN(id)
    FROM flow.project_message_team
    WHERE archived is false
    GROUP BY project_id, sms_team_id
    HAVING count(*) > 1
);

create unique INDEX if not exists pmo_project_sms_user_id_ix on flow.project_message_owner (project_id, sms_team_id, user_id) where archived is false;
create unique INDEX if not exists pmt_project_sms_team_id_ix on flow.project_message_team (project_id, sms_team_id) where archived is false;
