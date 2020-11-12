alter table flow.note
    add column if not exists migrated_process_step_id integer;
alter table flow.note
    add column if not exists migrated_process_step_work_queue_type_id integer;


WITH note_insert as (
    INSERT INTO flow."note" (
                             migrated_process_step_work_queue_type_id,
                             migrated_process_step_id,
                             note,
                             date_created,
                             date_modified,
                             created_by_id,
                             modified_by_id)
        (SELECT
             pswqt.id,
             pps.id,
             notes,
             created,
             updated,
             cn.created_by_id,
             cn.updated_by_id
         FROM
             blueraven.card c
                 inner join blueraven.card_note cn on cn.card_id = c.id
                 inner join flow.project_process_step pps on pps.project_id = cn.deal_id
                 inner join flow.process_step_work_queue_type pswqt on pswqt.process_step_id = c.migrate_process_step_id
                 and pps.process_step_id = c.migrate_process_step_id
                 and c.migrate_process_step_id is not null and cn.deal_id is not null)
        returning *)
INSERT INTO flow.project_process_step_process_step_work_queue_type_note (project_process_step_id,process_step_work_queue_type_id,note_id)
    (select ni.migrated_process_step_id,
            ni.migrated_process_step_work_queue_type_id,
            ni.id
     from   note_insert ni);


WITH note_insert as (
    INSERT INTO flow."note" (
                             migrated_process_step_work_queue_type_id,
                             migrated_process_step_id,
                             note,
                             date_created,
                             date_modified,
                             created_by_id,
                             modified_by_id)
        (SELECT
             pswqt.id,
             pps.id,
             notes,
             created,
             updated,
             cn.created_by_id,
             cn.updated_by_id
         FROM blueraven.card c
                  inner join blueraven.card_note cn on cn.card_id = c.id
                  inner join flow.project_process_step pps on pps.project_id = cn.deal_id and array[pps.process_step_id] <@ migrate_process_step_ids
                  inner join flow.process_step_work_queue_type pswqt on array[pswqt.process_step_id] <@ c.migrate_process_step_ids
             and c.migrate_process_step_ids is not null and cn.deal_id is not null
             and pswqt.process_step_id is not null)
        returning *)
INSERT INTO flow.project_process_step_process_step_work_queue_type_note (project_process_step_id,process_step_work_queue_type_id,note_id)
    (select
         ni.migrated_process_step_id,
         ni.migrated_process_step_work_queue_type_id,
         ni.id
     from   note_insert ni);

alter table flow.note
    drop column if exists migrated_process_step_id;

alter table flow.note
    drop column if exists migrated_process_step_work_queue_type_id;

alter table flow.note
    add column if not exists migrated_deal_id integer;

WITH note_insert as (
    INSERT INTO flow."note" (
                             migrated_deal_id,
                             note,
                             date_created,
                             date_modified,
                             created_by_id,
                             modified_by_id)
        (SELECT
             deal_id,
             note,
             created_date,
             modified_date,
             coalesce(u.id,2350555),
             coalesce(u.id,2350555)
         FROM blueraven."deal_base_note" dbn
                  inner join flow.project p on p.id = dbn.deal_id
                  left join blueraven.user u on (u.user_base_oid = dbn.created_by or u.user_base_setter_oid = dbn.created_by))
        returning *)
INSERT INTO flow."project_note" (project_id,note_id)
    (select ni.migrated_deal_id,
            ni.id
     from   note_insert ni);

alter table flow.note
    drop column if exists migrated_deal_id;


insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 1
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (33,373,374) and main is true
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 2
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (72,711,712) and main is true
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 3
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (40,1790,1971) and main is true
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 4
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (44,412,413) and main is true
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 5
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (153,2323,23224) and main is true
    --and pps.migrated_work_type_id = 5
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 6
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (54,1257,1258) and main is true
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 7
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (5,256,257) and main is true
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 8
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (16,308,309) and main is true
    and pps.migrated_work_type_id = 8
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 9
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (13,282,283) and main is true
    and pps.migrated_work_type_id = 9
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 11
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (98,2362,2363) and main is true
    and pps.migrated_work_type_id = 11
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 12
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (85,919,920) and main is true
    --and pps.migrated_work_type_id = 11
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 13
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (30,360,361) and main is true
    --and pps.migrated_work_type_id = 11
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 14
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (192,2193,2194) and main is true
    --and pps.migrated_work_type_id = 11
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 15
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (196,2232,2233) and main is true
    --and pps.migrated_work_type_id = 11
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 16
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (13,282,283) and main is true
    and pps.migrated_work_type_id = 16
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 17
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (16,309,308) and main is true
    and pps.migrated_work_type_id = 17
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 18
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (13,282,283) and main is true
    and pps.migrated_work_type_id = 18
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 19
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (13,282,283) and main is true
    and pps.migrated_work_type_id = 19
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 20
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (16,309,308) and main is true
    and pps.migrated_work_type_id = 20
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 21
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (16,309,308) and main is true
    and pps.migrated_work_type_id = 21
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 22
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (170,2375,2376) and main is true
    --and pps.migrated_work_type_id = 21
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 23
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (153,2323,2324) and main is true
    and pps.migrated_work_type_id = 23
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 24
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (165,1972,1973) and main is true
    --and pps.migrated_work_type_id = 23
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 25
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (25,646,647) and main is true
    --and pps.migrated_work_type_id = 23
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 26
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (172,1829,1830) and main is true
    --and pps.migrated_work_type_id = 23
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 27
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (28,867,868) and main is true
    --and pps.migrated_work_type_id = 23
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 28
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (98,2362,2363) and main is true
    and pps.migrated_work_type_id = 28
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 29
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (98,2362,2363) and main is true
    and pps.migrated_work_type_id = 29
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;

insert into flow.project_process_step_attachment(attachment_id, project_process_step_id,
                                                 date_created,created_by_id)
select a.id,pps.id,now(),a.created_by_id
from blueraven.deal_calendar_event_attachment dcea
         inner join blueraven.deal_calendar_event dce on dce.id = dcea.deal_calendar_event_id and dce.work_type_id = 30
         inner join flow.project_process_step pps on pps.project_id = dce.deal_id and pps.process_step_id in (66,568,569) and main is true
    --and pps.migrated_work_type_id = 29
         inner join flow.attachment a on a.migrated_deal_resource_id = dcea.deal_resource_oid and
                                         a.migrated_deal_id = dce.deal_id;



with update_notes as (
    with bucket as (
        select distinct cf2.company_id,cfga.id as custom_field_group_assignemnt_id,cfg.process_step_id
        from flow.custom_field cf2
                 inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                 inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                 inner join blueraven.work_type wt on wt.migrated_process_step_id = cfg.process_step_id
        where cf2.field_name = 'Notes for Technician'
          and cfga.archived is false and cf2.archived is false and cfg.archived is false)
    select ppscfv.id,foo.note from (
                                       select b.custom_field_group_assignemnt_id, case when wt.id > 99 then
                                                                                               wt.id - 100
                                                                                       else
                                                                                           wt.id end new_work_order_type_id,wt.migrated_process_step_id,dn.*
                                       from blueraven.deal_note dn
                                                inner join blueraven.work_type wt on wt.id = dn.work_type_id
                                                inner join flow.project p on p.id = dn.deal_id
                                                inner join flow.contact c on c.id = p.contact_id
                                                inner join bucket b on b.company_id = c.company_id and b.process_step_id = wt.migrated_process_step_id
                                       where wt.migrated_process_step_id = 13) as foo
                                       inner join flow.project_process_step pps on pps.project_id = foo.deal_id and pps.process_step_id = foo.migrated_process_step_id
                                       inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
        and ppscfv.custom_field_group_assignment_id = foo.custom_field_group_assignemnt_id
        and pps.migrated_work_type_id = foo.new_work_order_type_id)  --- don't need this for all work_type
update flow.project_process_step_custom_field_value ppscfv2
set text_value = un.note
from update_notes un
where un.id = ppscfv2.id;

with update_notes as (
    with bucket as (
        select distinct cf2.company_id,cfga.id as custom_field_group_assignemnt_id,cfg.process_step_id
        from flow.custom_field cf2
                 inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                 inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                 inner join blueraven.work_type wt on wt.migrated_process_step_id = cfg.process_step_id
        where cf2.field_name = 'Notes for Technician'
          and cfga.archived is false and cf2.archived is false and cfg.archived is false)
    select ppscfv.id,foo.note from (
                                       select b.custom_field_group_assignemnt_id, case when wt.id > 99 then
                                                                                               wt.id - 100
                                                                                       else
                                                                                           wt.id end new_work_order_type_id,wt.migrated_process_step_id,dn.*
                                       from blueraven.deal_note dn
                                                inner join blueraven.work_type wt on wt.id = dn.work_type_id
                                                inner join flow.project p on p.id = dn.deal_id
                                                inner join flow.contact c on c.id = p.contact_id
                                                inner join bucket b on b.company_id = c.company_id and b.process_step_id = wt.migrated_process_step_id
                                       where wt.migrated_process_step_id = 16) as foo
                                       inner join flow.project_process_step pps on pps.project_id = foo.deal_id and pps.process_step_id = foo.migrated_process_step_id
                                       inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
        and ppscfv.custom_field_group_assignment_id = foo.custom_field_group_assignemnt_id
        and pps.migrated_work_type_id = foo.new_work_order_type_id)  --- don't need this for all work_type
update flow.project_process_step_custom_field_value ppscfv2
set text_value = un.note
from update_notes un
where un.id = ppscfv2.id;

with update_notes as (
    with bucket as (
        select distinct cf2.company_id,cfga.id as custom_field_group_assignemnt_id,cfg.process_step_id
        from flow.custom_field cf2
                 inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                 inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                 inner join blueraven.work_type wt on wt.migrated_process_step_id = cfg.process_step_id
        where cf2.field_name = 'Notes for Technician'
          and cfga.archived is false and cf2.archived is false and cfg.archived is false)
    select ppscfv.id,foo.note from (
                                       select b.custom_field_group_assignemnt_id, case when wt.id > 99 then
                                                                                               wt.id - 100
                                                                                       else
                                                                                           wt.id end new_work_order_type_id,wt.migrated_process_step_id,dn.*
                                       from blueraven.deal_note dn
                                                inner join blueraven.work_type wt on wt.id = dn.work_type_id
                                                inner join flow.project p on p.id = dn.deal_id
                                                inner join flow.contact c on c.id = p.contact_id
                                                inner join bucket b on b.company_id = c.company_id and b.process_step_id = wt.migrated_process_step_id
                                       where wt.migrated_process_step_id = 98) as foo
                                       inner join flow.project_process_step pps on pps.project_id = foo.deal_id and pps.process_step_id = foo.migrated_process_step_id
                                       inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
        and ppscfv.custom_field_group_assignment_id = foo.custom_field_group_assignemnt_id
        and pps.migrated_work_type_id = foo.new_work_order_type_id)  --- don't need this for all work_type
update flow.project_process_step_custom_field_value ppscfv2
set text_value = un.note
from update_notes un
where un.id = ppscfv2.id;

with update_notes as (
    with bucket as (
        select distinct cf2.company_id,cfga.id as custom_field_group_assignemnt_id,cfg.process_step_id
        from flow.custom_field cf2
                 inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                 inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                 inner join blueraven.work_type wt on wt.migrated_process_step_id = cfg.process_step_id
        where cf2.field_name = 'Notes for Technician'
          and cfga.archived is false and cf2.archived is false and cfg.archived is false)
    select ppscfv.id,foo.note from (
                                       select b.custom_field_group_assignemnt_id, case when wt.id > 99 then
                                                                                               wt.id - 100
                                                                                       else
                                                                                           wt.id end new_work_order_type_id,wt.migrated_process_step_id,dn.*
                                       from blueraven.deal_note dn
                                                inner join blueraven.work_type wt on wt.id = dn.work_type_id
                                                inner join flow.project p on p.id = dn.deal_id
                                                inner join flow.contact c on c.id = p.contact_id
                                                inner join bucket b on b.company_id = c.company_id and b.process_step_id = wt.migrated_process_step_id
                                       where wt.migrated_process_step_id = 153) as foo
                                       inner join flow.project_process_step pps on pps.project_id = foo.deal_id and pps.process_step_id = foo.migrated_process_step_id
                                       inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
        and ppscfv.custom_field_group_assignment_id = foo.custom_field_group_assignemnt_id
        and pps.migrated_work_type_id = foo.new_work_order_type_id)  --- don't need this for all work_type
update flow.project_process_step_custom_field_value ppscfv2
set text_value = un.note
from update_notes un
where un.id = ppscfv2.id;

with update_notes as (
    with bucket as (
        select distinct cf2.company_id,cfga.id as custom_field_group_assignemnt_id,cfg.process_step_id
        from flow.custom_field cf2
                 inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                 inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                 inner join blueraven.work_type wt on wt.migrated_process_step_id = cfg.process_step_id
        where cf2.field_name = 'Notes for Technician'
          and cfga.archived is false and cf2.archived is false and cfg.archived is false)
    select ppscfv.id,foo.note from (
                                       select b.custom_field_group_assignemnt_id, case when wt.id > 99 then
                                                                                               wt.id - 100
                                                                                       else
                                                                                           wt.id end new_work_order_type_id,wt.migrated_process_step_id,dn.*
                                       from blueraven.deal_note dn
                                                inner join blueraven.work_type wt on wt.id = dn.work_type_id
                                                inner join flow.project p on p.id = dn.deal_id
                                                inner join flow.contact c on c.id = p.contact_id
                                                inner join bucket b on b.company_id = c.company_id and b.process_step_id = wt.migrated_process_step_id
                                       where wt.migrated_process_step_id = 5) as foo
                                       inner join flow.project_process_step pps on pps.project_id = foo.deal_id and pps.process_step_id = foo.migrated_process_step_id
                                       inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
        and ppscfv.custom_field_group_assignment_id = foo.custom_field_group_assignemnt_id)  --- don't need this for all work_type
update flow.project_process_step_custom_field_value ppscfv2
set text_value = un.note
from update_notes un
where un.id = ppscfv2.id;

with update_notes as (
    with bucket as (
        select distinct cf2.company_id,cfga.id as custom_field_group_assignemnt_id,cfg.process_step_id
        from flow.custom_field cf2
                 inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                 inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                 inner join blueraven.work_type wt on wt.migrated_process_step_id = cfg.process_step_id
        where cf2.field_name = 'Notes for Technician'
          and cfga.archived is false and cf2.archived is false and cfg.archived is false)
    select ppscfv.id,foo.note from (
                                       select b.custom_field_group_assignemnt_id, case when wt.id > 99 then
                                                                                               wt.id - 100
                                                                                       else
                                                                                           wt.id end new_work_order_type_id,wt.migrated_process_step_id,dn.*
                                       from blueraven.deal_note dn
                                                inner join blueraven.work_type wt on wt.id = dn.work_type_id
                                                inner join flow.project p on p.id = dn.deal_id
                                                inner join flow.contact c on c.id = p.contact_id
                                                inner join bucket b on b.company_id = c.company_id and b.process_step_id = wt.migrated_process_step_id
                                       where wt.migrated_process_step_id = 25) as foo
                                       inner join flow.project_process_step pps on pps.project_id = foo.deal_id and pps.process_step_id = foo.migrated_process_step_id
                                       inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
        and ppscfv.custom_field_group_assignment_id = foo.custom_field_group_assignemnt_id)  --- don't need this for all work_type
update flow.project_process_step_custom_field_value ppscfv2
set text_value = un.note
from update_notes un
where un.id = ppscfv2.id;

with update_notes as (
    with bucket as (
        select distinct cf2.company_id,cfga.id as custom_field_group_assignemnt_id,cfg.process_step_id
        from flow.custom_field cf2
                 inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                 inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                 inner join blueraven.work_type wt on wt.migrated_process_step_id = cfg.process_step_id
        where cf2.field_name = 'Notes for Technician'
          and cfga.archived is false and cf2.archived is false and cfg.archived is false)
    select ppscfv.id,foo.note from (
                                       select b.custom_field_group_assignemnt_id, case when wt.id > 99 then
                                                                                               wt.id - 100
                                                                                       else
                                                                                           wt.id end new_work_order_type_id,wt.migrated_process_step_id,dn.*
                                       from blueraven.deal_note dn
                                                inner join blueraven.work_type wt on wt.id = dn.work_type_id
                                                inner join flow.project p on p.id = dn.deal_id
                                                inner join flow.contact c on c.id = p.contact_id
                                                inner join bucket b on b.company_id = c.company_id and b.process_step_id = wt.migrated_process_step_id
                                       where wt.migrated_process_step_id = 28) as foo
                                       inner join flow.project_process_step pps on pps.project_id = foo.deal_id and pps.process_step_id = foo.migrated_process_step_id
                                       inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
        and ppscfv.custom_field_group_assignment_id = foo.custom_field_group_assignemnt_id)  --- don't need this for all work_type
update flow.project_process_step_custom_field_value ppscfv2
set text_value = un.note
from update_notes un
where un.id = ppscfv2.id;

with update_notes as (
    with bucket as (
        select distinct cf2.company_id,cfga.id as custom_field_group_assignemnt_id,cfg.process_step_id
        from flow.custom_field cf2
                 inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                 inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                 inner join blueraven.work_type wt on wt.migrated_process_step_id = cfg.process_step_id
        where cf2.field_name = 'Notes for Technician'
          and cfga.archived is false and cf2.archived is false and cfg.archived is false)
    select ppscfv.id,foo.note from (
                                       select b.custom_field_group_assignemnt_id, case when wt.id > 99 then
                                                                                               wt.id - 100
                                                                                       else
                                                                                           wt.id end new_work_order_type_id,wt.migrated_process_step_id,dn.*
                                       from blueraven.deal_note dn
                                                inner join blueraven.work_type wt on wt.id = dn.work_type_id
                                                inner join flow.project p on p.id = dn.deal_id
                                                inner join flow.contact c on c.id = p.contact_id
                                                inner join bucket b on b.company_id = c.company_id and b.process_step_id = wt.migrated_process_step_id
                                       where wt.migrated_process_step_id = 30) as foo
                                       inner join flow.project_process_step pps on pps.project_id = foo.deal_id and pps.process_step_id = foo.migrated_process_step_id
                                       inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
        and ppscfv.custom_field_group_assignment_id = foo.custom_field_group_assignemnt_id)  --- don't need this for all work_type
update flow.project_process_step_custom_field_value ppscfv2
set text_value = un.note
from update_notes un
where un.id = ppscfv2.id;

with update_notes as (
    with bucket as (
        select distinct cf2.company_id,cfga.id as custom_field_group_assignemnt_id,cfg.process_step_id
        from flow.custom_field cf2
                 inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                 inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                 inner join blueraven.work_type wt on wt.migrated_process_step_id = cfg.process_step_id
        where cf2.field_name = 'Notes for Technician'
          and cfga.archived is false and cf2.archived is false and cfg.archived is false)
    select ppscfv.id,foo.note from (
                                       select b.custom_field_group_assignemnt_id, case when wt.id > 99 then
                                                                                               wt.id - 100
                                                                                       else
                                                                                           wt.id end new_work_order_type_id,wt.migrated_process_step_id,dn.*
                                       from blueraven.deal_note dn
                                                inner join blueraven.work_type wt on wt.id = dn.work_type_id
                                                inner join flow.project p on p.id = dn.deal_id
                                                inner join flow.contact c on c.id = p.contact_id
                                                inner join bucket b on b.company_id = c.company_id and b.process_step_id = wt.migrated_process_step_id
                                       where wt.migrated_process_step_id = 33) as foo
                                       inner join flow.project_process_step pps on pps.project_id = foo.deal_id and pps.process_step_id = foo.migrated_process_step_id
                                       inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
        and ppscfv.custom_field_group_assignment_id = foo.custom_field_group_assignemnt_id)  --- don't need this for all work_type
update flow.project_process_step_custom_field_value ppscfv2
set text_value = un.note
from update_notes un
where un.id = ppscfv2.id;

with update_notes as (
    with bucket as (
        select distinct cf2.company_id,cfga.id as custom_field_group_assignemnt_id,cfg.process_step_id
        from flow.custom_field cf2
                 inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                 inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                 inner join blueraven.work_type wt on wt.migrated_process_step_id = cfg.process_step_id
        where cf2.field_name = 'Notes for Technician'
          and cfga.archived is false and cf2.archived is false and cfg.archived is false)
    select ppscfv.id,foo.note from (
                                       select b.custom_field_group_assignemnt_id, case when wt.id > 99 then
                                                                                               wt.id - 100
                                                                                       else
                                                                                           wt.id end new_work_order_type_id,wt.migrated_process_step_id,dn.*
                                       from blueraven.deal_note dn
                                                inner join blueraven.work_type wt on wt.id = dn.work_type_id
                                                inner join flow.project p on p.id = dn.deal_id
                                                inner join flow.contact c on c.id = p.contact_id
                                                inner join bucket b on b.company_id = c.company_id and b.process_step_id = wt.migrated_process_step_id
                                       where wt.migrated_process_step_id = 40) as foo
                                       inner join flow.project_process_step pps on pps.project_id = foo.deal_id and pps.process_step_id = foo.migrated_process_step_id
                                       inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
        and ppscfv.custom_field_group_assignment_id = foo.custom_field_group_assignemnt_id)--- don't need this for all work_type
update flow.project_process_step_custom_field_value ppscfv2
set text_value = un.note
from update_notes un
where un.id = ppscfv2.id;

with update_notes as (
    with bucket as (
        select distinct cf2.company_id,cfga.id as custom_field_group_assignemnt_id,cfg.process_step_id
        from flow.custom_field cf2
                 inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                 inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                 inner join blueraven.work_type wt on wt.migrated_process_step_id = cfg.process_step_id
        where cf2.field_name = 'Notes for Technician'
          and cfga.archived is false and cf2.archived is false and cfg.archived is false)
    select ppscfv.id,foo.note from (
                                       select b.custom_field_group_assignemnt_id, case when wt.id > 99 then
                                                                                               wt.id - 100
                                                                                       else
                                                                                           wt.id end new_work_order_type_id,wt.migrated_process_step_id,dn.*
                                       from blueraven.deal_note dn
                                                inner join blueraven.work_type wt on wt.id = dn.work_type_id
                                                inner join flow.project p on p.id = dn.deal_id
                                                inner join flow.contact c on c.id = p.contact_id
                                                inner join bucket b on b.company_id = c.company_id and b.process_step_id = wt.migrated_process_step_id
                                       where wt.migrated_process_step_id = 44) as foo
                                       inner join flow.project_process_step pps on pps.project_id = foo.deal_id and pps.process_step_id = foo.migrated_process_step_id
                                       inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
        and ppscfv.custom_field_group_assignment_id = foo.custom_field_group_assignemnt_id)  --- don't need this for all work_type
update flow.project_process_step_custom_field_value ppscfv2
set text_value = un.note
from update_notes un
where un.id = ppscfv2.id;

with update_notes as (
    with bucket as (
        select distinct cf2.company_id,cfga.id as custom_field_group_assignemnt_id,cfg.process_step_id
        from flow.custom_field cf2
                 inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                 inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                 inner join blueraven.work_type wt on wt.migrated_process_step_id = cfg.process_step_id
        where cf2.field_name = 'Notes for Technician'
          and cfga.archived is false and cf2.archived is false and cfg.archived is false)
    select ppscfv.id,foo.note from (
                                       select b.custom_field_group_assignemnt_id, case when wt.id > 99 then
                                                                                               wt.id - 100
                                                                                       else
                                                                                           wt.id end new_work_order_type_id,wt.migrated_process_step_id,dn.*
                                       from blueraven.deal_note dn
                                                inner join blueraven.work_type wt on wt.id = dn.work_type_id
                                                inner join flow.project p on p.id = dn.deal_id
                                                inner join flow.contact c on c.id = p.contact_id
                                                inner join bucket b on b.company_id = c.company_id and b.process_step_id = wt.migrated_process_step_id
                                       where wt.migrated_process_step_id = 54) as foo
                                       inner join flow.project_process_step pps on pps.project_id = foo.deal_id and pps.process_step_id = foo.migrated_process_step_id
                                       inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
        and ppscfv.custom_field_group_assignment_id = foo.custom_field_group_assignemnt_id)  --- don't need this for all work_type
update flow.project_process_step_custom_field_value ppscfv2
set text_value = un.note
from update_notes un
where un.id = ppscfv2.id;

with update_notes as (
    with bucket as (
        select distinct cf2.company_id,cfga.id as custom_field_group_assignemnt_id,cfg.process_step_id
        from flow.custom_field cf2
                 inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                 inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                 inner join blueraven.work_type wt on wt.migrated_process_step_id = cfg.process_step_id
        where cf2.field_name = 'Notes for Technician'
          and cfga.archived is false and cf2.archived is false and cfg.archived is false)
    select ppscfv.id,foo.note from (
                                       select b.custom_field_group_assignemnt_id, case when wt.id > 99 then
                                                                                               wt.id - 100
                                                                                       else
                                                                                           wt.id end new_work_order_type_id,wt.migrated_process_step_id,dn.*
                                       from blueraven.deal_note dn
                                                inner join blueraven.work_type wt on wt.id = dn.work_type_id
                                                inner join flow.project p on p.id = dn.deal_id
                                                inner join flow.contact c on c.id = p.contact_id
                                                inner join bucket b on b.company_id = c.company_id and b.process_step_id = wt.migrated_process_step_id
                                       where wt.migrated_process_step_id = 66) as foo
                                       inner join flow.project_process_step pps on pps.project_id = foo.deal_id and pps.process_step_id = foo.migrated_process_step_id
                                       inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
        and ppscfv.custom_field_group_assignment_id = foo.custom_field_group_assignemnt_id)  --- don't need this for all work_type
update flow.project_process_step_custom_field_value ppscfv2
set text_value = un.note
from update_notes un
where un.id = ppscfv2.id;

with update_notes as (
    with bucket as (
        select distinct cf2.company_id,cfga.id as custom_field_group_assignemnt_id,cfg.process_step_id
        from flow.custom_field cf2
                 inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                 inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                 inner join blueraven.work_type wt on wt.migrated_process_step_id = cfg.process_step_id
        where cf2.field_name = 'Notes for Technician'
          and cfga.archived is false and cf2.archived is false and cfg.archived is false)
    select ppscfv.id,foo.note from (
                                       select b.custom_field_group_assignemnt_id, case when wt.id > 99 then
                                                                                               wt.id - 100
                                                                                       else
                                                                                           wt.id end new_work_order_type_id,wt.migrated_process_step_id,dn.*
                                       from blueraven.deal_note dn
                                                inner join blueraven.work_type wt on wt.id = dn.work_type_id
                                                inner join flow.project p on p.id = dn.deal_id
                                                inner join flow.contact c on c.id = p.contact_id
                                                inner join bucket b on b.company_id = c.company_id and b.process_step_id = wt.migrated_process_step_id
                                       where wt.migrated_process_step_id = 72) as foo
                                       inner join flow.project_process_step pps on pps.project_id = foo.deal_id and pps.process_step_id = foo.migrated_process_step_id
                                       inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
        and ppscfv.custom_field_group_assignment_id = foo.custom_field_group_assignemnt_id)  --- don't need this for all work_type
update flow.project_process_step_custom_field_value ppscfv2
set text_value = un.note
from update_notes un
where un.id = ppscfv2.id;

with update_notes as (
    with bucket as (
        select distinct cf2.company_id,cfga.id as custom_field_group_assignemnt_id,cfg.process_step_id
        from flow.custom_field cf2
                 inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                 inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                 inner join blueraven.work_type wt on wt.migrated_process_step_id = cfg.process_step_id
        where cf2.field_name = 'Notes for Technician'
          and cfga.archived is false and cf2.archived is false and cfg.archived is false)
    select ppscfv.id,foo.note from (
                                       select b.custom_field_group_assignemnt_id, case when wt.id > 99 then
                                                                                               wt.id - 100
                                                                                       else
                                                                                           wt.id end new_work_order_type_id,wt.migrated_process_step_id,dn.*
                                       from blueraven.deal_note dn
                                                inner join blueraven.work_type wt on wt.id = dn.work_type_id
                                                inner join flow.project p on p.id = dn.deal_id
                                                inner join flow.contact c on c.id = p.contact_id
                                                inner join bucket b on b.company_id = c.company_id and b.process_step_id = wt.migrated_process_step_id
                                       where wt.migrated_process_step_id = 85) as foo
                                       inner join flow.project_process_step pps on pps.project_id = foo.deal_id and pps.process_step_id = foo.migrated_process_step_id
                                       inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
        and ppscfv.custom_field_group_assignment_id = foo.custom_field_group_assignemnt_id)  --- don't need this for all work_type
update flow.project_process_step_custom_field_value ppscfv2
set text_value = un.note
from update_notes un
where un.id = ppscfv2.id;

with update_notes as (
    with bucket as (
        select distinct cf2.company_id,cfga.id as custom_field_group_assignemnt_id,cfg.process_step_id
        from flow.custom_field cf2
                 inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                 inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                 inner join blueraven.work_type wt on wt.migrated_process_step_id = cfg.process_step_id
        where cf2.field_name = 'Notes for Technician'
          and cfga.archived is false and cf2.archived is false and cfg.archived is false)
    select ppscfv.id,foo.note from (
                                       select b.custom_field_group_assignemnt_id, case when wt.id > 99 then
                                                                                               wt.id - 100
                                                                                       else
                                                                                           wt.id end new_work_order_type_id,wt.migrated_process_step_id,dn.*
                                       from blueraven.deal_note dn
                                                inner join blueraven.work_type wt on wt.id = dn.work_type_id
                                                inner join flow.project p on p.id = dn.deal_id
                                                inner join flow.contact c on c.id = p.contact_id
                                                inner join bucket b on b.company_id = c.company_id and b.process_step_id = wt.migrated_process_step_id
                                       where wt.migrated_process_step_id = 165) as foo
                                       inner join flow.project_process_step pps on pps.project_id = foo.deal_id and pps.process_step_id = foo.migrated_process_step_id
                                       inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
        and ppscfv.custom_field_group_assignment_id = foo.custom_field_group_assignemnt_id)  --- don't need this for all work_type
update flow.project_process_step_custom_field_value ppscfv2
set text_value = un.note
from update_notes un
where un.id = ppscfv2.id;

with update_notes as (
    with bucket as (
        select distinct cf2.company_id,cfga.id as custom_field_group_assignemnt_id,cfg.process_step_id
        from flow.custom_field cf2
                 inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                 inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                 inner join blueraven.work_type wt on wt.migrated_process_step_id = cfg.process_step_id
        where cf2.field_name = 'Notes for Technician'
          and cfga.archived is false and cf2.archived is false and cfg.archived is false)
    select ppscfv.id,foo.note from (
                                       select b.custom_field_group_assignemnt_id, case when wt.id > 99 then
                                                                                               wt.id - 100
                                                                                       else
                                                                                           wt.id end new_work_order_type_id,wt.migrated_process_step_id,dn.*
                                       from blueraven.deal_note dn
                                                inner join blueraven.work_type wt on wt.id = dn.work_type_id
                                                inner join flow.project p on p.id = dn.deal_id
                                                inner join flow.contact c on c.id = p.contact_id
                                                inner join bucket b on b.company_id = c.company_id and b.process_step_id = wt.migrated_process_step_id
                                       where wt.migrated_process_step_id = 170) as foo
                                       inner join flow.project_process_step pps on pps.project_id = foo.deal_id and pps.process_step_id = foo.migrated_process_step_id
                                       inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
        and ppscfv.custom_field_group_assignment_id = foo.custom_field_group_assignemnt_id)  --- don't need this for all work_type
update flow.project_process_step_custom_field_value ppscfv2
set text_value = un.note
from update_notes un
where un.id = ppscfv2.id;

with update_notes as (
    with bucket as (
        select distinct cf2.company_id,cfga.id as custom_field_group_assignemnt_id,cfg.process_step_id
        from flow.custom_field cf2
                 inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                 inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                 inner join blueraven.work_type wt on wt.migrated_process_step_id = cfg.process_step_id
        where cf2.field_name = 'Notes for Technician'
          and cfga.archived is false and cf2.archived is false and cfg.archived is false)
    select ppscfv.id,foo.note from (
                                       select b.custom_field_group_assignemnt_id, case when wt.id > 99 then
                                                                                               wt.id - 100
                                                                                       else
                                                                                           wt.id end new_work_order_type_id,wt.migrated_process_step_id,dn.*
                                       from blueraven.deal_note dn
                                                inner join blueraven.work_type wt on wt.id = dn.work_type_id
                                                inner join flow.project p on p.id = dn.deal_id
                                                inner join flow.contact c on c.id = p.contact_id
                                                inner join bucket b on b.company_id = c.company_id and b.process_step_id = wt.migrated_process_step_id
                                       where wt.migrated_process_step_id = 172) as foo
                                       inner join flow.project_process_step pps on pps.project_id = foo.deal_id and pps.process_step_id = foo.migrated_process_step_id
                                       inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
        and ppscfv.custom_field_group_assignment_id = foo.custom_field_group_assignemnt_id)  --- don't need this for all work_type
update flow.project_process_step_custom_field_value ppscfv2
set text_value = un.note
from update_notes un
where un.id = ppscfv2.id;

with update_notes as (
    with bucket as (
        select distinct cf2.company_id,cfga.id as custom_field_group_assignemnt_id,cfg.process_step_id
        from flow.custom_field cf2
                 inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                 inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                 inner join blueraven.work_type wt on wt.migrated_process_step_id = cfg.process_step_id
        where cf2.field_name = 'Notes for Technician'
          and cfga.archived is false and cf2.archived is false and cfg.archived is false)
    select ppscfv.id,foo.note from (
                                       select b.custom_field_group_assignemnt_id, case when wt.id > 99 then
                                                                                               wt.id - 100
                                                                                       else
                                                                                           wt.id end new_work_order_type_id,wt.migrated_process_step_id,dn.*
                                       from blueraven.deal_note dn
                                                inner join blueraven.work_type wt on wt.id = dn.work_type_id
                                                inner join flow.project p on p.id = dn.deal_id
                                                inner join flow.contact c on c.id = p.contact_id
                                                inner join bucket b on b.company_id = c.company_id and b.process_step_id = wt.migrated_process_step_id
                                       where wt.migrated_process_step_id = 192) as foo
                                       inner join flow.project_process_step pps on pps.project_id = foo.deal_id and pps.process_step_id = foo.migrated_process_step_id
                                       inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
        and ppscfv.custom_field_group_assignment_id = foo.custom_field_group_assignemnt_id)  --- don't need this for all work_type
update flow.project_process_step_custom_field_value ppscfv2
set text_value = un.note
from update_notes un
where un.id = ppscfv2.id;


with update_notes as (
    with bucket as (
        select distinct cf2.company_id,cfga.id as custom_field_group_assignemnt_id,cfg.process_step_id
        from flow.custom_field cf2
                 inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                 inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                 inner join blueraven.work_type wt on wt.migrated_process_step_id = cfg.process_step_id
        where cf2.field_name = 'Notes for Technician'
          and cfga.archived is false and cf2.archived is false and cfg.archived is false)
    select ppscfv.id,foo.note from (
                                       select b.custom_field_group_assignemnt_id, case when wt.id > 99 then
                                                                                               wt.id - 100
                                                                                       else
                                                                                           wt.id end new_work_order_type_id,wt.migrated_process_step_id,dn.*
                                       from blueraven.deal_note dn
                                                inner join blueraven.work_type wt on wt.id = dn.work_type_id
                                                inner join flow.project p on p.id = dn.deal_id
                                                inner join flow.contact c on c.id = p.contact_id
                                                inner join bucket b on b.company_id = c.company_id and b.process_step_id = wt.migrated_process_step_id
                                       where wt.migrated_process_step_id = 196) as foo
                                       inner join flow.project_process_step pps on pps.project_id = foo.deal_id and pps.process_step_id = foo.migrated_process_step_id
                                       inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
        and ppscfv.custom_field_group_assignment_id = foo.custom_field_group_assignemnt_id)  --- don't need this for all work_type
update flow.project_process_step_custom_field_value ppscfv2
set text_value = un.note
from update_notes un
where un.id = ppscfv2.id;
