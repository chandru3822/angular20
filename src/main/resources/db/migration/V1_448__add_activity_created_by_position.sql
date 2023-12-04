--PROJECTS
ALTER TABLE if exists flow.project_activity
    add column if not exists created_by_user_position_id integer references flow.user_position(id);

update flow.project_activity a
set created_by_user_position_id =
        (
            select up.id
            from flow.user_position up
                     inner join flow.position pos on pos.id = up.position_id
            where up.user_id = a.created_by_id
              and up.primary_flag is true
              and pos.company_id = c.company_id
--          and a.date_created between up.start_date and coalesce(up.end_date, now())
              and up.archived is false
        )
from flow.project p
         inner join flow.contact c on p.contact_id = c.id
where p.id = a.project_id
  and a.created_by_user_position_id is null;

CREATE INDEX if not exists pa_created_by_user_position_id_idx ON flow.project_activity (created_by_user_position_id);

--CONTACTS
ALTER TABLE if exists flow.contact_activity
    add column if not exists created_by_user_position_id integer references flow.user_position(id);

update flow.contact_activity a
set created_by_user_position_id =
        (
            select up.id
            from flow.user_position up
                     inner join flow.position pos on pos.id = up.position_id
            where up.user_id = a.created_by_id
              and up.primary_flag is true
              and pos.company_id = c.company_id
--          and a.date_created between up.start_date and coalesce(up.end_date, now())
              and up.archived is false
        )
from flow.contact c
where a.contact_id = c.id
  and a.created_by_user_position_id is null;

CREATE INDEX if not exists ca_created_by_user_position_id_idx ON flow.contact_activity (created_by_user_position_id);

--USERS
ALTER TABLE if exists flow.user_activity
    add column if not exists created_by_user_position_id integer references flow.user_position(id);

update flow.user_activity a
set created_by_user_position_id =
        (
            select up.id
            from flow.user_position up
             inner join flow.position pos on up.position_id = pos.id
            where up.user_id = a.created_by_id
              and up.primary_flag is true
--          and a.date_created between up.start_date and coalesce(up.end_date, now())
              and up.archived is false
            and pos.company_id = 3
        )
where a.created_by_user_position_id is null;

CREATE INDEX if not exists ua_created_by_user_position_id_idx ON flow.user_activity (created_by_user_position_id);

--ORGS
ALTER TABLE if exists flow.org_activity
    add column if not exists created_by_user_position_id integer references flow.user_position(id);

update flow.org_activity a
set created_by_user_position_id =
        (
            select up.id
            from flow.user_position up
            inner join flow.position pos on up.position_id = pos.id
            where up.user_id = a.created_by_id
              and up.primary_flag is true
--          and a.date_created between up.start_date and coalesce(up.end_date, now())
              and up.archived is false
            and pos.company_id = o.company_id
        )
from flow.org o
where o.id = a.org_id
and a.created_by_user_position_id is null;

CREATE INDEX if not exists oa_created_by_user_position_id_idx ON flow.org_activity (created_by_user_position_id);
