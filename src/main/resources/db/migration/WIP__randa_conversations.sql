--this is just so the next code bit doesn't fail
alter table flow.project_message_team
drop column if exists user_id;

-- drop all the cached stuff
drop function if exists flow.update_cache_sms_queue() cascade;
drop trigger if exists update_sms_cache_trg on flow.sms_queue;
drop function if exists flow.update_cache_sms_reply() cascade;
drop trigger if exists update_sms_reply_trg on flow.sms_reply;

alter table flow.project_message_team
add column if not exists user_id bigint references flow.user(id);
    --this is in case the user id isn't present from the pump/dump
-- add column if not exists user_id bigint;

CREATE INDEX if not exists sms_owner_user_id_idx ON flow.project_message_team (user_id);

drop index if exists flow.pmt_project_sms_team_id_ix;
-- pretty sure we dont need this cuz of the user id stuff
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
    RENAME TO sms_thread_owner;

--setting to OLD in case i still need
ALTER TABLE IF EXISTS flow.project_message_properties
    RENAME TO old_project_message_properties;
ALTER TABLE IF EXISTS flow.sms_cache
    RENAME TO old_sms_cache;
ALTER TABLE IF EXISTS flow.sms_reply
    RENAME TO old_sms_reply;

--prep the sms queue stuff
alter table flow.sms_queue
    drop column if exists num_media;
alter table flow.sms_queue
    add column if not exists num_media integer default 0;

--Disable
-- SET session_replication_role = replica;

update flow.sms_queue
    set num_media = array_length(media_urls, 1)
where media_urls is not null;
--re-enable
-- SET session_replication_role = DEFAULT;


--setting/dropping default is WAY faster than updating every row
alter table flow.sms_queue
    drop column if exists account_sid;
alter table flow.sms_queue
    add column if not exists account_sid varchar(35) default 'REPLACE_WITH_PROD_SECRET';
alter table flow.sms_queue alter column account_sid drop default;

alter table flow.sms_queue
    drop column if exists messaging_service_sid;
alter table flow.sms_queue
    add column if not exists messaging_service_sid varchar(35) default 'REPLACE_WITH_PROD_SECRET';
alter table flow.sms_queue alter column messaging_service_sid drop default;

alter table flow.sms_queue
    add column if not exists twilio_received timestamp;


--import replies into the queue
insert into flow.sms_queue(message, media_urls, message_sid, message_status, from_phone, to_phone, updated, created, num_media, account_sid, messaging_service_sid, twilio_received)
select coalesce(body, ''), media_urls, message_sid, 'received', from_phone, to_phone, date_received, date_received, num_media, account_sid, messaging_service_sid, date_received
from flow.sms_reply;
;

--then change some column names
alter table flow.sms_queue
    rename column user_id to sent_to_user_id;
alter table flow.sms_queue
    rename column project_id to sent_to_project_id;
alter table flow.sms_queue
    rename column updated to date_modified;
alter table flow.sms_queue
    rename column created to date_created;
alter table flow.sms_queue
    drop column if exists contact_id;

--add this after import from reply table
alter table flow.sms_queue
    add column if not exists search_from_phone     varchar generated always as ("right"(
            translate((COALESCE(from_phone, ''::character varying))::text, '+-() '::text, ''::text), 10)) stored;

--add the inbound stuff
alter table flow.sms_queue
    add column if not exists inbound boolean not null default false;
update flow.sms_queue
    set inbound = true
where twilio_received is not null;

--add the parent stuff
alter table flow.sms_queue
    add column if not exists parent_id bigint;




--rename the queue table
alter table flow.sms_queue
    rename to sms_thread;

--blah
alter table flow.sms_thread_owner
    add column if not exists sms_thread_id bigint references flow.sms_thread_owner(id);

update flow.sms_thread_owner co
set sms_thread_id = (select id from flow.sms_thread c where c.project_id = co.project_id and c.parent_id is null)
where id > 0;

--this deletes from the owner table if there was no matching conversation/project id stuff in the sms queue
delete from flow.sms_thread_owner
    where sms_thread_id is null;

alter table flow.sms_thread_owner alter column sms_thread_id set not null;

--so far this has been for refactoring the project stuff...need to do the user stuff