--this is just so the next code bit doesn't fail
alter table flow.project_message_team
drop column if exists user_id;

-- drop all the cached stuff
drop function if exists flow.update_cache_sms_queue() cascade;
drop trigger if exists update_sms_cache_trg on flow.sms_queue;
drop function if exists flow.update_cache_sms_reply() cascade;
drop trigger if exists update_sms_reply_trg on flow.sms_reply;
DROP FUNCTION IF EXISTS flow.remove_sms_team_project_owners(bigint, bigint, bigint, bigint, bigint);
DROP FUNCTION IF EXISTS flow.remove_sms_team_user_owners(bigint, bigint, bigint, bigint, bigint);

alter table flow.recipient_type
    add column if not exists external boolean not null default false;

update flow.recipient_type
    set external = true
where type in ('PROJECT', 'CONTACT');


alter table flow.project_message_team
add column if not exists user_id bigint references flow.user(id);
    --this is in case the user id isn't present from the pump/dump
-- add column if not exists user_id bigint;

CREATE INDEX if not exists sms_owner_user_id_idx ON flow.project_message_team (user_id);

drop index if exists flow.pmt_project_sms_team_id_ix;
-- pretty sure we dont need this cuz of the user id stuff
-- create unique INDEX if not exists pmt_project_sms_team_id_ix on flow.project_message_team (project_id, sms_team_id) where archived is false and user_id is null;

-- drop index if exists flow.pmt_project_sms_user_id_ix;
-- create unique INDEX if not exists pmt_project_sms_user_id_ix on flow.project_message_team (project_id, sms_team_id, user_id) where archived is false;

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

--rename the to and from columns
alter table flow.sms_queue rename column from_phone to internal_phone;
alter table flow.sms_queue rename column to_phone to external_phone;
alter table flow.sms_queue rename column search_to_phone to search_external_phone;


--add the inbound column and set true for all replies
alter table flow.sms_queue
    add column if not exists inbound boolean not null default false;

alter table flow.sms_queue
    add column if not exists temp_sms_reply_id bigint;


--import replies into the queue
alter table flow.sms_queue alter column recipient_type_id drop default;
insert into flow.sms_queue(message, media_urls, message_sid, message_status, external_phone, internal_phone, updated, created, num_media, account_sid, messaging_service_sid, twilio_received, recipient_type_id, inbound, temp_sms_reply_id)
select coalesce(body, ''), media_urls, message_sid, 'received', from_phone, to_phone, date_received, date_received, num_media, account_sid, messaging_service_sid, date_received, case when to_phone = '+18014480029' then 1 else 2 end, true, id
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
    add column if not exists search_internal_phone     varchar generated always as ("right"(
            translate((COALESCE(internal_phone, ''::character varying))::text, '+-() '::text, ''::text), 10)) stored;

--do this as part of the import
-- update flow.sms_queue
--     set inbound = true
-- where twilio_received is not null;

--add the parent stuff
alter table flow.sms_queue
    add column if not exists parent_id bigint;

ALTER TABLE flow.sms_queue ADD COLUMN is_last_inserted BOOLEAN DEFAULT FALSE;

--add a temp column for use by updating parent id since it needs to be to_phone for outgoing and from_phone for incoming
-- ALTER TABLE flow.sms_queue ADD COLUMN temp_thread_phone text;

-- update flow.sms_queue
-- set temp_thread_phone = case when inbound then search_from_phone else search_to_phone end
-- where id > 0;
--^^ this took 10 mins, 4.1 million rows, took 30 mins the 2nd time


--this loop took 25 minutes. trying an index to see if it is faster next time
-- took 50 minutes the 2nd time
-- CREATE INDEX if not exists sq_temp_thread_phone_idx ON flow.sms_queue (temp_thread_phone);

DO
$do$
    declare
        x    record;
        v_id bigint;
        v_rowcount bigint;
    BEGIN
        v_rowcount = 0;
        for x in select id,
                        parent_id,
                        date_created,
                        search_external_phone,
                        CASE
                            WHEN ROW_NUMBER() OVER (PARTITION BY search_external_phone ORDER BY date_created, search_external_phone) = 1
                                THEN true
                            ELSE false END AS is_first_row,
                        CASE
                            WHEN ROW_NUMBER() OVER (PARTITION BY search_external_phone ORDER BY date_created desc, search_external_phone) = 1
                                THEN true
                            ELSE false END AS is_last_row,
                        is_last_inserted
                 from flow.sms_queue
                 where parent_id is null
                 order by search_external_phone, date_created
            loop
                v_rowcount = v_rowcount + 1;
                if x.is_first_row is true then
                    v_id = x.id;
                end if;
                update flow.sms_queue sq
                set parent_id = v_id,
                    is_last_inserted = case when x.is_last_row is true then true else false end
                where id = x.id;
                if v_rowcount = 50000 then
                    commit;
                    raise notice 'HIT ROW COUNT: %', v_rowcount;
                    v_rowcount = 0;
                end if;
            end loop;
        v_rowcount = 0;
    end
$do$;

--rename the queue table
alter table flow.sms_queue
    rename to sms_thread;

drop function if exists flow.update_last_inserted() cascade;
CREATE OR REPLACE FUNCTION flow.update_last_inserted()
    RETURNS TRIGGER AS $$
BEGIN
    UPDATE flow.sms_thread
    SET is_last_inserted = FALSE
    WHERE parent_id = NEW.parent_id AND is_last_inserted = TRUE;

    NEW.is_last_inserted = TRUE;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


drop trigger if exists set_last_inserted on flow.sms_thread;
CREATE TRIGGER set_last_inserted
    BEFORE INSERT ON flow.sms_thread
    FOR EACH ROW
EXECUTE FUNCTION flow.update_last_inserted();


--rename the reply table:
alter table flow.sms_reply
    rename to sms_reply_deprecated;

--owner stuff for projects
ALTER TABLE IF EXISTS flow.project_message_team
    RENAME TO sms_thread_owner;


alter table flow.sms_thread_owner
    drop column if exists sms_thread_id;
alter table flow.sms_thread_owner
    add column if not exists sms_thread_id bigint references flow.sms_thread(id);

--sometimes if a project phone number changed we will lose that history (1.2 mins)
update flow.sms_thread_owner co
set sms_thread_id = (
    select st.id
    from flow.sms_thread st
        inner join flow.project p on st.sent_to_project_id = p.id
        inner join flow.contact c on p.contact_id = c.id
    where st.sent_to_project_id = co.project_id
      and st.id = st.parent_id
    and st.search_external_phone = c.search_phones)
where co.id > 0;

--this deletes from the owner table if there was no matching conversation/project id stuff in the sms queue
--only if archived so we dont have to create ghost threads
delete from flow.sms_thread_owner
    where sms_thread_id is null
and archived is true;

--add "ghost threads" for any threads that have owners but no messages in the thread, 2 = projects
alter table flow.sms_thread
add column if not exists archived boolean not null default false;

insert into flow.sms_thread(message, internal_phone, external_phone, recipient_type_id, message_sent_by_user_id, sent_to_project_id, archived)
select distinct 'THREAD INITIALIZATION', '+18014480212', c.search_phones, 2, 99999999, sto.project_id, true
    from flow.sms_thread_owner sto
        inner join flow.project p on sto.project_id = p.id
        inner join flow.contact c on p.contact_id = c.id
        where sto.sms_thread_id is null;

update flow.sms_thread
    set parent_id = id
where message = 'THREAD INITIALIZATION'
  and recipient_type_id = 2;

--run the update again for those that are null
update flow.sms_thread_owner co
set sms_thread_id = (
    select st.id
    from flow.sms_thread st
             inner join flow.project p on st.sent_to_project_id = p.id
             inner join flow.contact c on p.contact_id = c.id
    where st.sent_to_project_id = co.project_id
      and st.id = st.parent_id
      and st.external_phone = c.search_phones)
where co.sms_thread_id is null;

alter table flow.sms_thread_owner alter column sms_thread_id set not null;

alter table flow.sms_thread_owner
    rename column project_id to project_id_deprecated;


--refactor some user message stuff then insert it into the sms_thread_owner stuff
alter table flow.user_message_team
    add column if not exists owner_user_id bigint references flow.user(id);

drop index if exists sms_owner_user_id_idx;
CREATE INDEX if not exists sms_owner_user_id_idx ON flow.user_message_team (owner_user_id);

insert into flow.user_message_team(owner_user_id, sms_team_id, user_id, archived, date_created, date_modified, created_by_id, modified_by_id)
select owner_user_id, sms_team_id, user_id, archived, date_created, date_modified, created_by_id, modified_by_id
from flow.user_message_owner;

--9399 team owners
--7805 user owners

ALTER TABLE IF EXISTS flow.user_message_owner
    RENAME TO old_user_message_owner;

alter table flow.user_message_team
add column if not exists sms_thread_id bigint;

--took 3 mins
update flow.user_message_team umt
set sms_thread_id = (select st.id
                     from flow.sms_thread st
                              inner join flow.user u on u.id = st.sent_to_user_id
                     where st.sent_to_user_id = umt.user_id
                       and st.id = st.parent_id
                       and st.search_external_phone = u.search_phone)
where umt.id > 0;

delete from flow.user_message_team
where sms_thread_id is null
and archived is true;

insert into flow.sms_thread(message, external_phone, internal_phone, recipient_type_id, message_sent_by_user_id, sent_to_user_id, archived)
select distinct 'THREAD INITIALIZATION', '+18014480029', u.search_phone, 1, 99999999, sto.user_id, true
from flow.user_message_team sto
         inner join flow.user u on u.id = sto.user_id
where sto.sms_thread_id is null;

update flow.sms_thread
set parent_id = id
where message = 'THREAD INITIALIZATION'
and recipient_type_id = 1;

update flow.user_message_team umt
set sms_thread_id = (select st.id
                     from flow.sms_thread st
                              inner join flow.user u on u.id = st.sent_to_user_id
                     where st.sent_to_user_id = umt.user_id
                       and st.id = st.parent_id
                       and st.search_external_phone = u.search_phone)
where umt.sms_thread_id is null;

--now that the data is ready, insert into the sms_thread_owner
alter table flow.sms_thread_owner add column if not exists user_id_deprecated bigint;
alter table flow.sms_thread_owner alter column project_id_deprecated drop not null;

-- select count(1)
--     from flow.user_message_team
--         where sms_thread_id is null;

-- delete from flow.user_message_team
-- where sms_thread_id is null;

insert into flow.sms_thread_owner(sms_team_id, archived, date_created, date_modified, created_by_id, modified_by_id, sms_thread_id, user_id, user_id_deprecated)
select sms_team_id, archived, date_created, date_modified, created_by_id, modified_by_id, sms_thread_id, owner_user_id, user_id
from flow.user_message_team;

ALTER TABLE IF EXISTS flow.user_message_team
    RENAME TO old_user_message_team;
ALTER TABLE IF EXISTS flow.user_message_properties
    RENAME TO old_user_message_properties;


--need to populated the closed property
alter table flow.sms_thread
add column if not exists closed boolean not null default false;

--7min
update flow.sms_thread st
set closed = true
from flow.old_project_message_properties op
where op.project_id = st.sent_to_project_id
and op.closed is true;

--5 mins
update flow.sms_thread st
set closed = true
from flow.old_user_message_properties op
where op.user_id = st.sent_to_user_id
  and op.closed is true;

CREATE INDEX if not exists sto_sms_thread_id_idx ON flow.sms_thread_owner (sms_thread_id);
CREATE INDEX if not exists st_parent_id_idx ON flow.sms_thread (parent_id);
CREATE INDEX if not exists st_search_external_phone_idx ON flow.sms_thread (search_external_phone);
CREATE INDEX if not exists st_search_internal_phone_idx ON flow.sms_thread (search_internal_phone);


-- TODO: need to do project_message_owner_history and user_message_owner_history into sms_thread_owner_history

--already done above this was for post updates
-- update flow.sms_thread
-- set from_phone = to_phone,
--     to_phone = from_phone
-- where inbound is true;

-- alter table flow.sms_thread rename column from_phone to internal_phone;
-- alter table flow.sms_thread rename column to_phone to external_phone;
-- alter table flow.sms_thread rename column search_to_phone to search_external_phone;
-- alter table flow.sms_thread rename column search_from_phone to search_internal_phone;

-- DROP INDEX if exists flow.sq_created_idx;
-- CREATE INDEX if not exists sq_created_idx ON flow.sms_thread (date_created);

drop index if exists flow.sq_combo_parent_last_inserted_ix;
create index if not exists sq_combo_parent_last_inserted_ix
    on flow.sms_thread (parent_id, inbound)
    where (archived is false and is_last_inserted is true);

--in flux - this whole thing took 34 mins

--HISTORY STUFF (project)

alter table flow.project_message_owner_history rename to sms_thread_owner_audit;
alter table flow.sms_thread_owner_audit
add column if not exists sms_thread_owner_id bigint references flow.sms_thread_owner(id);
CREATE INDEX if not exists stoa_sms_thread_owner_id_idx ON flow.sms_thread_owner_audit (sms_thread_owner_id);

update flow.sms_thread_owner_audit stoa
set sms_thread_owner_id = (
    select max(sto.id)
    from flow.sms_thread_owner sto
    where sto.project_id_deprecated = stoa.project_id
    and sto.sms_team_id = stoa.sms_team_id
    and sto.user_id = stoa.user_id
    and archived is false
    )
where id > 0;

create index pmt_temp_randa_project_id_ix
    on flow.sms_thread_owner (project_id_deprecated, sms_team_id, user_id)
    where (archived IS true);


update flow.sms_thread_owner_audit stoa
set sms_thread_owner_id = (
    select max(sto.id)
    from flow.sms_thread_owner sto
    where sto.project_id_deprecated = stoa.project_id
      and sto.sms_team_id = stoa.sms_team_id
      and sto.user_id = stoa.user_id
      and archived is true
)
where sms_thread_owner_id is null;

update flow.sms_thread_owner_audit stoa
set sms_thread_owner_id = (
    select max(sto.id)
    from flow.sms_thread_owner sto
    where sto.project_id_deprecated = stoa.project_id
      and sto.sms_team_id = stoa.sms_team_id
      and sto.user_id is null
      and archived is true
)
where sms_thread_owner_id is null
and user_id is null;

drop index if exists flow.pmt_temp_randa_project_id_ix;

--78k
-- select count(1)
--     from flow.sms_thread_owner_audit
--         where sms_thread_owner_id is null;

delete from flow.sms_thread_owner_audit
where sms_thread_owner_id is null;

alter table flow.sms_thread_owner_audit
rename column project_id to project_id_deprecated;
alter table flow.sms_thread_owner_audit
    add column if not exists user_id_deprecated bigint;

--HISTORY STUFF (user)
alter table flow.user_message_owner_history
add column if not exists sms_thread_owner_id bigint references flow.sms_thread_owner(id);

 create index pmt_temp_randa_user_id_ix
    on flow.sms_thread_owner (user_id_deprecated, sms_team_id, user_id)
    where (archived IS true);

update flow.user_message_owner_history stoa
set sms_thread_owner_id = (
    select max(sto.id)
    from flow.sms_thread_owner sto
    where sto.user_id_deprecated = stoa.owner_user_id
      and sto.sms_team_id = stoa.sms_team_id
      and sto.user_id = stoa.user_id
    and archived is false
)
where id > 0;

update flow.user_message_owner_history stoa
set sms_thread_owner_id = (
    select max(sto.id)
    from flow.sms_thread_owner sto
    where sto.user_id_deprecated = stoa.owner_user_id
      and sto.sms_team_id = stoa.sms_team_id
      and sto.user_id = stoa.user_id
      and archived is true
)
where sms_thread_owner_id is null;

update flow.user_message_owner_history stoa
set sms_thread_owner_id = (
    select max(sto.id)
    from flow.sms_thread_owner sto
    where sto.user_id_deprecated = stoa.owner_user_id
      and sto.sms_team_id = stoa.sms_team_id
      and sto.user_id is null
      and archived is true
)
where sms_thread_owner_id is null
and user_id is null;

drop index if exists flow.pmt_temp_randa_user_id_ix;

--10k
-- select count(1)
-- from flow.user_message_owner_history
-- where sms_thread_owner_id is null;

delete from flow.user_message_owner_history
where sms_thread_owner_id is null;

alter table flow.sms_thread_owner_audit
    add column if not exists user_id_deprecated bigint;
alter table flow.sms_thread_owner_audit alter column project_id_deprecated drop not null;

insert into flow.sms_thread_owner_audit(sms_team_id, user_id, date_created, date_removed, date_modified, created_by_id, modified_by_id, sms_thread_owner_id, user_id_deprecated)
select sms_team_id, user_id, date_created, date_removed, date_modified, created_by_id, modified_by_id, sms_thread_owner_id, owner_user_id
    from flow.user_message_owner_history;

alter table flow.user_message_owner_history rename to user_message_owner_history_deprecated;

alter table flow.sms_thread_owner_audit alter column sms_thread_owner_id set not null;