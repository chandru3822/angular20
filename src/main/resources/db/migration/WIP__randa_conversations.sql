alter table flow.project_message_team
drop column if exists user_id;

alter table flow.project_message_team
-- add column if not exists user_id bigint;
add column if not exists user_id bigint references flow.user(id);

CREATE INDEX if not exists sms_owner_user_id_idx ON flow.project_message_team (user_id);

drop index if exists flow.pmt_project_sms_team_id_ix;
-- create unique INDEX if not exists pmt_project_sms_team_id_ix on flow.project_message_team (project_id, sms_team_id) where archived is false and user_id is null;

drop index if exists flow.pmt_project_sms_user_id_ix;
create unique INDEX if not exists pmt_project_sms_user_id_ix on flow.project_message_team (project_id, sms_team_id, user_id) where archived is false;

insert into flow.project_message_team(project_id, sms_team_id, user_id, archived, date_created, date_modified, created_by_id, modified_by_id)
select project_id, sms_team_id, user_id, archived, date_created, date_modified, created_by_id, modified_by_id
    from flow.project_message_owner;

--346430 team owners
--383653 user owners

ALTER TABLE IF EXISTS flow.project_message_owner
RENAME TO old_project_message_owner;

ALTER TABLE IF EXISTS flow.project_message_team
    RENAME TO external_conversation_owner;

ALTER TABLE IF EXISTS flow.project_message_properties
    RENAME TO external_conversation;

alter table flow.external_conversation
add column if not exists phone_number text;

alter table flow.external_conversation
rename column project_id to old_project_id;

alter table flow.external_conversation_owner
    rename column project_id to old_project_id;

update flow.external_conversation c2
set phone_number = c.search_phones
from flow.project p2
    inner join flow.contact c on p2.contact_id = c.id
where p2.id = c2.old_project_id;

update flow.external_conversation
    set phone_number = replace(phone_number, '*', '')
where id > 0;

update flow.external_conversation
set phone_number = replace(phone_number, ' ', '')
where id > 0;

alter table flow.external_conversation_owner
    add column if not exists external_conversation_id bigint references flow.external_conversation(id);

update flow.external_conversation_owner co
set external_conversation_id = (select id from flow.external_conversation c where c.old_project_id = co.old_project_id)
where id > 0;

delete from flow.external_conversation_owner
    where external_conversation_id is null;

alter table flow.external_conversation_owner alter column external_conversation_id set not null;

--just adding this to mark which rows to delete before running this
alter table flow.external_conversation
    add column if not exists archived boolean not null default false;

with more_rows as (select id,
                          old_project_id,
                          phone_number,
                          ROW_NUMBER() OVER (PARTITION BY phone_number ORDER BY date_modified DESC) as row_num
                   from flow.external_conversation
                   order by phone_number, row_num)
update flow.external_conversation c
set archived = true
from more_rows r
where r.id = c.id
  and row_num > 1;

--todo: i dont think i wanted to delete these. i wanted to move the owners from the deleted "conversation" to the non-deleted conversation
-- this deleted 77,489 rows
-- delete from flow.conversation_owner co
--     where co.conversation_id in (select c.id from flow.conversation c where c.archived is true);

CREATE INDEX if not exists pc_phone_number_idx ON flow.external_conversation (phone_number);

update flow.external_conversation_owner co
    set external_conversation_id = (select id from flow.external_conversation c2 where c2.phone_number = c.phone_number and c2.archived is false)
from flow.external_conversation c
where c.id = co.external_conversation_id
and c.archived is true;

delete from flow.external_conversation_owner
where external_conversation_id is null;

--Disable
SET session_replication_role = replica;

delete from flow.external_conversation
    where archived is true;
--35k rows. wtf is taking so long

--re-enable
SET session_replication_role = DEFAULT;

alter table flow.external_conversation
    drop column if exists archived;

create unique index if not exists c_phone_number_uniq_idx
    on flow.external_conversation (phone_number);

alter table flow.external_conversation
add column if not exists last_message_text text;
alter table flow.external_conversation
add column if not exists outbound_message boolean not null default false;

--need to populate the last message stuff here, i think this works
with results as (select c.id                                                                        as contact_id,
                        p.id                                                                        as project_id,
                        c.search_phones,
                        sc.message_text,
                        sc.message_date,
                        sc.outbound_message,
                        ROW_NUMBER() OVER (PARTITION BY c.search_phones ORDER BY message_date DESC) as row_num
                 from flow.sms_cache sc
                          inner join flow.project p on p.id = sc.project_id
                          inner join flow.contact c on p.contact_id = c.id
                 where length(c.search_phones) > 0
                 order by c.search_phones)
update flow.external_conversation pc
set last_message_text = r.message_text,
    last_sent = r.message_date,
    outbound_message = r.outbound_message
from results r
where r.search_phones = pc.phone_number
  and r.row_num = 1
    and pc.id > 0;

drop index  if exists eco_sms_team_id_idx;
drop index  if exists eco_user_id_id_idx;
drop index  if exists ec_last_sent_idx;
drop index  if exists eco_external_conversation_id_idx;
CREATE INDEX if not exists ec_last_sent_idx ON flow.external_conversation (last_sent);
CREATE INDEX if not exists eco_external_conversation_id_idx ON flow.external_conversation_owner (external_conversation_id);
CREATE INDEX if not exists eco_sms_team_id_idx ON flow.external_conversation_owner (sms_team_id);
CREATE INDEX if not exists eco_user_id_id_idx ON flow.external_conversation_owner (user_id);
