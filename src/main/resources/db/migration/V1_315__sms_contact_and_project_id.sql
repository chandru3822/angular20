alter table flow.sms_queue
add column if not exists contact_id integer references flow.contact(id);

CREATE INDEX if not exists fki_sms_queue_contact_id
  on flow.sms_queue (contact_id);

alter table flow.sms_queue
  add column if not exists project_id integer references flow.project(id);

CREATE INDEX if not exists fki_sms_queue_project_id
  on flow.sms_queue (project_id);

update flow.sms_queue
  set contact_id = user_id
where recipient_type_id = 2;


update flow.sms_queue sq
set project_id = ( select case when count(1) = 1 then max(p.id) end
                    from flow.project p
                        inner join flow.company_project_status_type cpst on p.company_project_status_type_id = cpst.id
                    where p.contact_id = sq.contact_id
                        and cpst.project_status_type_id != 2
                    group by p.contact_id

                  )
where sq.contact_id is not null
;

update flow.sms_queue set recipient_type_id = 3 where contact_id is not null and project_id is null;

alter table flow.sms_queue alter column user_id drop not null;

update flow.sms_queue
set user_id = null
where contact_id is not null;

CREATE INDEX if not exists fki_sms_queue_user_id
  on flow.sms_queue (user_id);
