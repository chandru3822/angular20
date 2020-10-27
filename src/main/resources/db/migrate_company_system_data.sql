-- insert into flow.company(company_name,aws_bucket, abbreviation,parent_company_id, level)values('Energy Pal','energypal', 'energypal',(select id from flow.company where company_name = 'Blue Raven Corporate'),(select level from flow.company where company_name = 'Blue Raven Corporate') + 1);
-- INSERT INTO flow.process ( parent_company_id, process_name, date_created,
--                            date_modified, created_by_id, modified_by_id, archived)
-- VALUES ( 2, 'Energy Pal - 001', '2020-02-18 17:18:43.532880', null, 2350555, null, false);
-- INSERT INTO flow.company_process (company_id, process_id, status_type_id, archived)
-- VALUES ( 17, 15, 1, false);
-- insert into flow.user_company(company_id,user_id)
--     (select (select id from flow.company where company_name = 'Energy Pal'),2350555);
-- insert into flow.user_company(company_id,user_id)
--     (select (select id from flow.company where company_name = 'Energy Pal'),99999999);
-- insert into flow.user_company(company_id,user_id)
--     (select (select id from flow.company where company_name = 'Energy Pal'),2405363);
-- insert into flow.user_company(company_id,user_id)
--     (select (select id from flow.company where company_name = 'Energy Pal'),2356764);
-- insert into flow.user_company(company_id,user_id)
--     (select (select id from flow.company where company_name = 'Energy Pal'),2410143);
--
-- insert into flow.user_company(company_id,user_id)
--     (select (select id from flow.company where company_name = 'Revolution Solar'),2350555);
-- insert into flow.user_company(company_id,user_id)
--     (select (select id from flow.company where company_name = 'Revolution Solar'),99999999);
-- insert into flow.user_company(company_id,user_id)
--     (select (select id from flow.company where company_name = 'Revolution Solar'),2405363);
-- insert into flow.user_company(company_id,user_id)
--     (select (select id from flow.company where company_name = 'Revolution Solar'),2356764);
-- insert into flow.user_company(company_id,user_id)
--     (select (select id from flow.company where company_name = 'Revolution Solar'),2410143);
--
--
-- insert into flow.company_process_step_status_type(process_step_status_type, process_step_status_type_id,company_id, archived, date_created, created_by_id)
-- values('Active',1,(select id from flow.company where company_name = 'Energy Pal'),false,now(),2350555);
-- insert into flow.company_process_step_status_type(process_step_status_type, process_step_status_type_id,company_id, archived, date_created, created_by_id)
-- values('Complete',2,(select id from flow.company where company_name = 'Energy Pal'),false,now(),2350555);
-- insert into flow.company_process_step_status_type(process_step_status_type, process_step_status_type_id,company_id, archived, date_created, created_by_id)
-- values('Cancelled',3,(select id from flow.company where company_name = 'Energy Pal'),false,now(),2350555);
--
-- insert into flow.company_project_status_type (project_status_type_id, company_id, project_status_type, created_by_id)
-- values ((select id from flow.project_status_type where project_status_type.project_status_type = 'Active'), (select id from flow.company where company_name =    'Energy Pal'), 'Active', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'Cancelled'), (select id from flow.company where company_name = 'Energy Pal'), 'Cancelled', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'On Hold'), (select id from flow.company where company_name =   'Energy Pal'), 'On Hold', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'Complete'), (select id from flow.company where company_name =   'Energy Pal'), 'Complete', 2350555);
--
--
-- insert into flow.company_system_list (system_list_id, company_id, schedulable)
-- select 1, (select id from flow.company where company_name = 'Energy Pal'), true ;
-- insert into flow.company_system_list (system_list_id, company_id, schedulable)
-- select 2, (select id from flow.company where company_name = 'Energy Pal'), true;
-- insert into flow.company_system_list (system_list_id, company_id, schedulable)
-- select 3, (select id from flow.company where company_name = 'Energy Pal'), true;
-- insert into flow.company_system_list (system_list_id, company_id, schedulable)
-- select 4, (select id from flow.company where company_name = 'Energy Pal'), true ;
--
--
-- insert into flow.company_object_type (object_type_id, company_id)
-- select 1, (select id from flow.company where company_name = 'Energy Pal');
--
-- insert into flow.company_object_type (object_type_id, company_id)
-- select 2, (select id from flow.company where company_name = 'Energy Pal') ;
--
-- insert into flow.company_object_type (object_type_id, company_id)
-- select 3, (select id from flow.company where company_name = 'Energy Pal') ;
--
-- insert into flow.company_object_type (object_type_id, company_id)
-- select 4, (select id from flow.company where company_name = 'Energy Pal') ;
--
-- insert into flow.company_object_type (object_type_id, company_id)
-- select 5, (select id from flow.company where company_name = 'Energy Pal') ;
--
--
--
-- insert into flow.company_data_type(company_id, company_data_type, data_type_id)
-- values((select id from flow.company where company_name = 'Energy Pal'),'Text',5);
-- insert into flow.company_data_type(company_id, company_data_type, data_type_id)
-- values((select id from flow.company where company_name = 'Energy Pal'),'Date',1);
-- insert into flow.company_data_type(company_id, company_data_type, data_type_id)
-- values((select id from flow.company where company_name = 'Energy Pal'),'Timestamp',2);
-- insert into flow.company_data_type(company_id, company_data_type, data_type_id)
-- values((select id from flow.company where company_name = 'Energy Pal'),'Boolean',3);
-- insert into flow.company_data_type(company_id, company_data_type, data_type_id)
-- values((select id from flow.company where company_name = 'Energy Pal'),'Integer',6);
-- insert into flow.company_data_type(company_id, company_data_type, data_type_id)
-- values((select id from flow.company where company_name = 'Energy Pal'),'Decimal Number',4);
-- insert into flow.company_data_type(company_id, company_data_type, data_type_id,has_list_values)
-- values((select id from flow.company where company_name = 'Energy Pal'),'Dropdown',6,true);
-- insert into flow.company_data_type(company_id, company_data_type, data_type_id,has_list_values,allow_multiple)
-- values((select id from flow.company where company_name = 'Energy Pal'),'Multi-Select',7,true,true);
-- insert into flow.company_data_type(company_id, company_data_type, data_type_id,has_list_values)
-- values((select id from flow.company where company_name = 'Energy Pal'),'System',8,false);
-- insert into flow.company_data_type(company_id, company_data_type, data_type_id)
-- select (select id from flow.company where company_name = 'Energy Pal'), 'System List', 9 ;
--
--
-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'Energy Pal'), 1, 'Parent');
-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'Energy Pal'), 2, 'Region');
-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'Energy Pal'), 3, 'Office');
--
--
--
-- INSERT INTO flow.org_type (org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Parent', null, (select id from flow.org_level where level_name = 'Parent' and company_id in (select id from flow.company where company_name = 'Energy Pal')),(select id from flow.company where company_name = 'Energy Pal'), false,now(),2350555);
-- INSERT INTO flow.org_type (org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Region', (select id from flow.org_type where org_type.org_type = 'Parent' and company_id in (select id from flow.company where company_name = 'Energy Pal')), (select id from flow.org_level where level_name = 'Region' and company_id in (select id from flow.company where company_name = 'Energy Pal')), (select id from flow.company where company_name = 'Energy Pal'), false, now(),2350555);
-- INSERT INTO flow.org_type ( org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Office', (select id from flow.org_type where org_type.org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Energy Pal')), (select id from flow.org_level where level_name = 'Office' and company_id in (select id from flow.company where company_name = 'Energy Pal')), (select id from flow.company where company_name = 'Energy Pal'), false,now(),2350555);
--
--
-- SELECT setval('flow.position_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.position), 1), false);
--
-- INSERT INTO flow.position (company_id, position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Energy Pal'), 'Closer', (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Energy Pal')), true,now(),2350555);
-- INSERT INTO flow.position ( company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Energy Pal'), 'Closer Office Manager',(select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Energy Pal')), true,now(),2350555);
-- INSERT INTO flow.position (company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Energy Pal'), 'Closer Regional Manager', (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Energy Pal')), true,now(),2350555);
--
-- SELECT setval('flow.position_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.position), 1), false);
--
--




insert into flow.process_step(company_id, process_step_name, date_created, date_modified, created_by_id, modified_by_id, archived, non_admin_add,migrated_original_id)
    (select c.id, process_step_name, ps.date_created, ps.date_modified, ps.created_by_id, ps.modified_by_id, archived, non_admin_add,ps.id
     from flow.process_step ps
              cross join flow.company c
     where ps.archived is false and c.id not in (1,2,3,9)
       and ps.company_id  in (3));


begin;
insert into flow.process_step_process(process_id, process_step_id, date_created,
                                      date_modified, created_by_id, modified_by_id, initial_step,
                                      company_process_step_status_type_id, archived)
    (select (select cp.process_id from flow.company_process cp where cp.company_id = c.id),
            (select id from flow.process_step ps1 where ps1.migrated_original_id = ps.id and ps1.company_id = c.id ), now(),
            now(), 2410143, 2410143, case when ps.process_step_name = 'Schedule Closer Appointment' then
                                              true else false end,
            (select id from flow.company_process_step_status_type cpsst where cpsst.company_id = c.id
                                                                          and process_step_status_type = 'Active'), false
     from flow.process_step_process psp
         inner join flow.process_step ps on ps.id = psp.process_step_id
              cross join  flow.company c
     where ps.archived is false and c.id not in (1,2,3,9));


insert into flow.list_of_value(name, code, parent_id, display_order, date_created, date_modified, created_by_id, modified_by_id, archived,migrated_original_id,migrated_company_id)
    (select name, code, parent_id, display_order, lov.date_created, lov.date_modified, lov.created_by_id, lov.modified_by_id, archived,lov.id,c.id
     from flow.list_of_value lov
              cross join flow.company c
     where lov.parent_id is null and c.id not in (1,2,3,9));


insert into flow.list_of_value(name, code, parent_id, display_order, date_created, date_modified, created_by_id, modified_by_id, archived,migrated_original_id,migrated_company_id)
    (select name, code, (select id from flow.list_of_value lov1 where lov1.migrated_original_id = lov.parent_id and lov1.migrated_company_id = c.id),
            display_order, lov.date_created, lov.date_modified, lov.created_by_id, lov.modified_by_id, archived,lov.id,c.id
     from flow.list_of_value lov
              cross join flow.company c
     where lov.parent_id is not null and c.id not in (1,2,3,9));


insert into flow.custom_field(list_of_value_id, company_id, field_name, company_data_type_id,
                              date_created, date_modified, created_by_id, modified_by_id, archived,
                              company_system_list_id, custom_field_sql_reference_table,
                              custom_field_sql_key, system_list_option_ids,readonly, multi_line,migrated_original_id)
    (select  (select id
                                         from flow.list_of_value lov
                                         where cf.list_of_value_id = lov.migrated_original_id and lov.migrated_company_id = c.id),
                                        c.id, field_name, (select id from flow.company_data_type cdt where cdt.company_data_type = cdt2.company_data_type and cdt.company_id = c.id),
                                        cf.date_created, cf.date_modified, cf.created_by_id, cf.modified_by_id, cf.archived,
                                        (select csl2.id from flow.company_system_list csl2
                                                            inner join flow.system_list sl1 on sl1.id = csl2.system_list_id
                                         where csl2.company_id = c.id and sl1.system_list = sl.system_list), custom_field_sql_reference_table,
                                        custom_field_sql_key,system_list_option_ids, readonly, multi_line,cf.id
     from flow.custom_field cf
              left join flow.company_data_type cdt2  on cdt2.id = cf.company_data_type_id
              left join flow.company_system_list csl on csl.id = cf.company_system_list_id
              left join flow.system_list sl on sl.id = csl.system_list_id
              cross join flow.company c
     where cf.archived is false and cf.company_id = 3 and c.id not in (1,2,3,9));



insert into flow.custom_field_object_type(custom_field_id, company_object_type_id,
                                          archived, show_on_insert, date_created, date_modified,
                                          created_by_id, modified_by_id)

(select (select id from flow.custom_field cf  where cfot.custom_field_id = cf.migrated_original_id
                                and cf.company_id = c.id) as custom
        , (select cot1.id from flow.company_object_type cot1
            inner join flow.object_type ot1 on ot1.id = cot1.object_type_id
            where ot1.object_type = ot.object_type and c.id = cot1.company_id),
        cfot.archived, show_on_insert, cfot.date_created, cfot.date_modified,
        cfot.created_by_id, cfot.modified_by_id
from flow.custom_field_object_type cfot
    inner join flow.custom_field cf2  on cf2.id = cfot.custom_field_id and cf2.archived is false and cf2.company_id = 3
    inner join flow.company_object_type cot on cot.id = cfot.company_object_type_id
    inner join flow.object_type ot on ot.id = cot.object_type_id
         cross join flow.company c
     where c.id not in (1,2,3,9));



insert into flow.custom_field_group( group_name, company_object_type_id, group_order, unique_behavior_type_id,
                                     archived, process_step_id, event_type_id, date_created,
                                     date_modified, created_by_id, modified_by_id,migrated_original_id,migrated_company_id)
    (select group_name,(select cot1.id from flow.company_object_type cot1
                                           inner join flow.object_type ot1 on ot1.id = cot1.object_type_id
                        where ot1.object_type = ob.object_type and cot1.company_id = c.id) , group_order, unique_behavior_type_id,
            cfg.archived, (select id from flow.process_step ps
                           where ps.migrated_original_id = cfg.process_step_id and
                                   ps.company_id = c.id ) ,
            event_type_id , cfg.date_created,
            cfg. date_modified, cfg.created_by_id, cfg.modified_by_id,cfg.id,c.id
     from flow.custom_field_group cfg
              left join flow.company_object_type cot on cot.id = cfg.company_object_type_id
              left join flow.object_type ob on ob.id = cot.object_type_id
              cross join flow.company c
     where c.id not in (1,2,3,9));


insert into flow.custom_field_group_assignment(custom_field_group_id, custom_field_id,
                                                field_order,
                                               archived, date_created, date_modified,
                                               created_by_id, modified_by_id,
                                               schedule_field_type_id, read_only,migrated_original_id,migrated_company_id)
(select (select id from flow.custom_field_group cfg
         where cfg.migrated_original_id = cfga.custom_field_group_id and cfg.migrated_company_id = c.id),
        (select id from flow.custom_field cf
            where cf.migrated_original_id = cfga.custom_field_id and
                  cf.company_id = c.id),
         field_order,
        archived, cfga.date_created, cfga.date_modified,
        cfga.created_by_id, cfga.modified_by_id,
        schedule_field_type_id, read_only,cfga.id,c.id
    from flow.custom_field_group_assignment cfga
    cross join flow.company c
    where cfga.archived is false and c.id not in (1,2,3,9));


with my_list as (
    select cfga.id as original_ancillary_row , --100
           cfga.ancillary_custom_field_group_assignment_id --50
    from flow.custom_field_group_assignment cfga
    where cfga.archived is false and cfga.ancillary_custom_field_group_assignment_id is not null
),
migrated_matching_rows as (
    select cfga.id, --150,250
    ml.original_ancillary_row,--100,100
    cfga.migrated_company_id --11,12
    from flow.custom_field_group_assignment cfga
    inner join my_list ml on ml.ancillary_custom_field_group_assignment_id = cfga.migrated_original_id
)
update flow.custom_field_group_assignment cfga3
set ancillary_custom_field_group_assignment_id = mmr.id
from migrated_matching_rows mmr
where mmr.original_ancillary_row = cfga3.migrated_original_id and
        mmr.migrated_company_id = cfga3.migrated_company_id;

insert into flow.company_function(company_function_name, db_function_id, archived, company_id,migrated_original_id)
(select company_function_name, db_function_id, archived, c.id,cf.id
    from flow.company_function cf
             cross join flow.company c
    where c.id not in (1,2,3,9));

insert into flow.company_function_param(company_function_id,
                                        archived, system_value_id, db_function_param_id, created_by_id,
                                        date_created, modified_by_id, date_modified)
(select (select id from flow.company_function cf where cfp.company_function_id = cf.migrated_original_id
                                        and cf.company_id = c.id),
        archived, system_value_id, db_function_param_id, cfp.created_by_id,
        cfp.date_created, cfp.modified_by_id, cfp.date_modified
 from flow.company_function_param cfp
          cross join flow.company c
 where c.id not in (1,2,3,9));


insert into flow.attachment_type(attachment_type, attachment_code, company_id, archived,
                                 key_pattern_id, is_system, date_created, date_modified, created_by_id, modified_by_id)
(select attachment_type, attachment_code, c.id, archived,
        key_pattern_id, is_system, at1.date_created, at1.date_modified, at1.created_by_id, at1.modified_by_id
from flow.attachment_type at1
         cross join flow.company c
where company_id = 3 and is_system is false and c.id not in (1,2,3,9));

insert into flow.process_step_attachment_type(attachment_type_id, process_step_id, date_created,
                                              date_modified, created_by_id, modified_by_id, archived)
(select  (select id from flow.attachment_type at1 where at1.attachment_type = at3.attachment_type
                    and at1.company_id = c.id),
        (select id from flow.process_step ps where psat.process_step_id = ps.migrated_original_id
            and ps.company_id = c.id), psat.date_created,
        psat.date_modified, psat.created_by_id, psat.modified_by_id, psat.archived
from flow.process_step_attachment_type psat
    inner join flow.process_step ps2 on ps2.id = psat.process_step_id and ps2.archived is false
    inner join flow.attachment_type at3 on at3.id = psat.attachment_type_id
         cross join flow.company c
 where c.id not in (1,2,3,9));


insert into flow.process_step_work_queue_type(process_step_id, work_queue_type_id, archived,
                                              date_created, date_modified, created_by_id,
                                              modified_by_id,migrated_original_id,migrated_company_id)
( select (select id from flow.process_step ps where
            pswqt.process_step_id = ps.migrated_original_id and
            c.id = ps.company_id) , work_queue_type_id, archived,
         pswqt.date_created, pswqt.date_modified, pswqt.created_by_id,
         pswqt.modified_by_id,
         pswqt.id,
         c.id
from flow.process_step_work_queue_type pswqt
         cross join flow.company c
  where c.id not in (1,2,3,9));


insert into flow.process_step_work_queue_type_project_status_type(company_project_status_type_id,
                                                                  process_step_work_queue_type_id,
                                                                  date_created, date_modified,
                                                                  created_by_id, modified_by_id, archived)
(select (select id from flow.company_project_status_type cpsst1
          where cpsst1.project_status_type = cpst.project_status_type and cpsst1.company_id = c.id) ,
        (select id from flow.process_step_work_queue_type pswqt
            where pswqt.migrated_original_id = pswqtpst.process_step_work_queue_type_id
            and pswqt.migrated_company_id = c.id),
        pswqtpst.date_created, pswqtpst.date_modified,
        pswqtpst.created_by_id, pswqtpst.modified_by_id, pswqtpst.archived
from flow.process_step_work_queue_type_project_status_type pswqtpst
    inner join flow.company_project_status_type cpst on cpst.id = pswqtpst.company_project_status_type_id
         cross join flow.company c
 where c.id not in (1,2,3,9));

insert into flow.process_step_requirement(process_step_requirement_type_id, process_step_id, operator_type_id,
                                          requirement_value, data_type_requirement_id, secondary_requirement_value,
                                          custom_field_group_assignment_id, company_function_id,
                                          requirement_nbr, date_created, date_modified, created_by_id,
                                          modified_by_id, archived, list_of_value_id, list_of_value_ids,
                                          immutable, system_list_option_id, custom_sql_option_id,migrated_company_id,migrated_original_id)
(select process_step_requirement_type_id,
        (select id from flow.process_step ps
            where ps.migrated_original_id = psr.process_step_id
            and ps.company_id = c.id), operator_type_id,
        requirement_value, data_type_requirement_id, secondary_requirement_value,
        (select id from flow.custom_field_group_assignment cfga
            where cfga.migrated_original_id = psr.custom_field_group_assignment_id and
                  cfga.migrated_company_id = c.id),
        (select id from flow.company_function cf
            where cf.migrated_original_id = psr.company_function_id and
                  cf.company_id = c.id),
        requirement_nbr, psr.date_created, psr.date_modified, psr.created_by_id,
        psr.modified_by_id, psr.archived,
        (select id from flow.list_of_value lov
            where lov.migrated_original_id = psr.list_of_value_id and
                  lov.migrated_company_id = c.id), '{}',
        immutable, system_list_option_id, custom_sql_option_id,
        c.id,
        psr.id
from flow.process_step_requirement psr
    inner join flow.process_step ps on ps.id = psr.process_step_id and ps.archived is false and ps.company_id != 9
         cross join flow.company c
 where c.id not in (1,2,3,9));

insert into flow.requirement_param_dynamic_value(db_function_param_id, process_step_requirement_id,
                                                 dynamic_value, archived, created_by_id, date_created,
                                                 modified_by_id, date_modified)
(select db_function_param_id,
        (select id from flow.process_step_requirement psr
            where psr.migrated_original_id = rpdv.process_step_requirement_id and
                  psr.migrated_company_id = c.id),
        dynamic_value, archived, rpdv.created_by_id, rpdv.date_created,
        rpdv.modified_by_id, rpdv.date_modified
from flow.requirement_param_dynamic_value rpdv
         cross join flow.company c
 where c.id not in (1,2,3,9));


insert into flow.process_step_action(process_step_id, action_type_id, action_name,
                                     company_process_step_status_type_id, trigger_automatically,
                                     date_created, date_modified, created_by_id, modified_by_id,
                                     archived, always_enabled, display_order,migrated_original_id,migrated_company_id)


(select (select id from flow.process_step ps
        where ps.migrated_original_id = psa.process_step_id and
              ps.company_id = c.id), action_type_id, action_name,
        (select cpsst.id from flow.company_process_step_status_type cpsst
                  left join flow.process_step_status_type psst2 on psst2.id = cpsst.process_step_status_type_id
            where cpsst.company_id= c.id and psst2.process_step_status_type = psst.process_step_status_type),
        trigger_automatically,
        psa.date_created, psa.date_modified, psa.created_by_id, psa.modified_by_id,
        psa.archived, always_enabled, display_order,psa.id,c.id
 from flow.process_step_action psa
 left join flow.company_process_step_status_type cpsst2 on cpsst2.id = psa.company_process_step_status_type_id
     left join flow.process_step_status_type psst on psst.id = cpsst2.process_step_status_type_id
          cross join flow.company c
 where c.id not in (1,2,3,9));


insert into flow.process_step_action_company_function(process_step_action_id, company_function_id, date_created,
                                                      date_modified, created_by_id, modified_by_id, archived,
                                                      display_order,migrated_original_id,migrated_company_id)
(select (select id from flow.process_step_action psa
        where psa.migrated_original_id = psacf.process_step_action_id and
              psa.migrated_company_id = c.id),
        (select id from flow.company_function cf
            where cf.migrated_original_id = psacf.company_function_id and
                  cf.company_id = c.id), psacf.date_created,
        psacf.date_modified, psacf.created_by_id, psacf.modified_by_id, archived,
        display_order,psacf.id,c.id
from flow.process_step_action_company_function psacf
   cross join flow.company c
 where c.id not in (1,2,3,9));

insert into flow.action_param_dynamic_value(db_function_param_id, process_step_action_company_function_id,
                                            dynamic_value, archived, created_by_id, date_created,
                                            modified_by_id, date_modified)
(select db_function_param_id, (select id from flow.process_step_action_company_function psacf
                                where psacf.migrated_original_id = apdv.process_step_action_company_function_id and
                                        psacf.migrated_company_id = c.id),
        dynamic_value, archived, apdv.created_by_id, apdv.date_created,
        apdv.modified_by_id, apdv.date_modified
from flow.action_param_dynamic_value apdv
                  cross join flow.company c
where c.id not in (1,2,3,9));

insert into flow.process_step_action_child_process(process_step_action_id, process_step_id,
                                                   trigger_automatically, display_order, archived,
                                                   date_created, date_modified, created_by_id, modified_by_id)
(select (select id from flow.process_step_action psa
         where psa.migrated_original_id = psacp.process_step_action_id and
                psa.migrated_company_id = c.id),
        (select id from flow.process_step ps
            where ps.migrated_original_id = psacp.process_step_id and
                  ps.company_id = c.id),
        trigger_automatically, display_order, psacp.archived,
        psacp.date_created, psacp.date_modified, psacp.created_by_id, psacp.modified_by_id
from flow.process_step_action_child_process psacp
    inner join flow.process_step ps1 on ps1.id = psacp.process_step_id and ps1.archived is false
                   cross join flow.company c
 where c.id not in (1,2,3,9) );

--TODO need this for future if new companines come in select * from flow.process_step_action_link;--no need

insert into flow.process_step_logic(process_step_requirement_id, operation_type_id, sql_order,
                                    process_step_action_id, date_created, date_modified, created_by_id,
                                    modified_by_id, archived)
 (select (select id from flow.process_step_requirement psr
          where psr.migrated_original_id = psl.process_step_requirement_id and
                psr.migrated_company_id = c.id), operation_type_id, sql_order,
         (select id from flow.process_step_action psa
             where psa.migrated_original_id = psl.process_step_action_id and
                   psa.migrated_company_id = c.id), psl.date_created, psl.date_modified, psl.created_by_id,
         psl.modified_by_id, archived
 from flow.process_step_logic psl
          cross join flow.company c
  where c.id not in (1,2,3,9));


insert into flow.project_attachment_type(attachment_type_id, company_id, date_created,
                                         date_modified, created_by_id, modified_by_id, archived)
 (select attachment_type_id, c.id, at1.date_created,
         at1.date_modified, at1.created_by_id, at1.modified_by_id, archived
 from flow.project_attachment_type at1
  cross join flow.company c
  where c.id not in (1,2,3,9));


insert into flow.company_feature( feature_name, company_id, feature_id, archived)
( select cf.feature_name, c.id, feature_id, cf.archived
from flow.company_feature cf
      inner join flow.feature f on f.id = cf.feature_id
      and cf.archived is false and f.is_system is true and f.archived is false
      cross join flow.company c
  where c.id not in (1,2,3,9));

insert into flow.company_state(state_id, company_id, map_latitude, map_longitude, map_zoom, active, archived)

(select state_id, c.id, map_latitude, map_longitude, map_zoom, active, archived
from flow.company_state cs
                   cross join flow.company c
 where c.id not in (1,2,3,9));

insert into flow.company_country( country_id, company_id, archived)
(select  country_id, c.id, archived
from flow.company_country cc
                   cross join flow.company c
 where cc.company_id = 3 and c.id not in (1,2,3,9));

insert into brs.project_details_config(company_id, custom_field_group_assignment_id, field_to_update, data_type_id)
(select pdc.custom_field_group_assignment_id,c.id, (select id from flow.custom_field_group_assignment cfga
               where cfga.migrated_original_id = pdc.custom_field_group_assignment_id and
                     cfga.migrated_company_id = c.id), field_to_update, data_type_id
 from brs.project_details_config pdc
  cross join flow.company c
 where c.id not in (1,2,3,9));

insert into flow.process_step_process_owning_position( position_id, process_step_process_id,
                                                       archived, date_created, date_modified,
                                                       created_by_id, modified_by_id)
    (select position_id,
            (select psp1.id
             from flow.process_step_process psp1
                      inner join flow.process p1 on p1.id = psp1.process_id
                      inner join flow.company_process cp1 on cp1.process_id = p1.id
                      inner join flow.process_step ps1 on ps1.id = psp1.process_step_id
             where cp1.company_id = c.id and ps1.migrated_original_id = psp.process_step_id),
            pspop.archived, pspop.date_created, pspop.date_modified,
            pspop.created_by_id, pspop.modified_by_id
     from flow.process_step_process_owning_position pspop
              inner join flow.process_step_process psp on psp.id = pspop.process_step_process_id
              inner join flow.process_step ps on ps.id = psp.process_step_id and ps.archived is false
              cross join flow.company c
     where c.id not in (1,2,3,9));


alter table flow.process_step add column migrated_original_id integer;
alter table flow.custom_field add column migrated_original_id integer;
alter table flow.list_of_value add column migrated_original_id integer;
alter table flow.list_of_value add column migrated_company_id integer;
alter table flow.custom_field_group add column migrated_original_id integer;
alter table flow.custom_field_group_assignment add column migrated_original_id integer;
alter table flow.custom_field_group_assignment add column migrated_company_id integer;
alter table flow.custom_field_group add column migrated_company_id integer;
alter table flow.company_function add column migrated_original_id integer;
alter table flow.process_step_work_queue_type add column migrated_original_id integer;
alter table flow.process_step_work_queue_type add column migrated_company_id integer;
alter table flow.process_step_requirement add column migrated_company_id integer;
alter table flow.process_step_requirement add column migrated_original_id integer;
alter table flow.process_step_action add column migrated_company_id integer;
alter table flow.process_step_action add column migrated_original_id integer;
alter table flow.process_step_action_company_function add column migrated_company_id integer;
alter table flow.process_step_action_company_function add column migrated_original_id integer;


alter table flow.process_step drop column if exists  migrated_original_id ;
alter table flow.custom_field drop column if exists  migrated_original_id ;
alter table flow.list_of_value drop column if exists  migrated_original_id ;
alter table flow.list_of_value drop column if exists  migrated_company_id ;
alter table flow.custom_field_group drop column if exists  migrated_original_id ;
alter table flow.custom_field_group_assignment drop column if exists  migrated_original_id ;
alter table flow.custom_field_group_assignment drop column if exists  migrated_company_id ;
alter table flow.custom_field_group drop column if exists  migrated_company_id ;
alter table flow.company_function drop column if exists  migrated_original_id ;
alter table flow.process_step_work_queue_type drop column if exists  migrated_original_id ;
alter table flow.process_step_work_queue_type drop column if exists  migrated_company_id ;
alter table flow.process_step_requirement drop column if exists  migrated_company_id ;
alter table flow.process_step_requirement drop column if exists  migrated_original_id ;
alter table flow.process_step_action drop column if exists  migrated_company_id ;
alter table flow.process_step_action drop column if exists  migrated_original_id ;
alter table flow.process_step_action_company_function drop column if exists  migrated_company_id ;
alter table flow.process_step_action_company_function drop column if exists  migrated_original_id ;




-- TODO
--1 migrate org email and birdeye from orgs  custom_field_group_assignemnet_id 17257
-- 3) zachs function
-- 2) project query down line
-- 3) contact query down line
-- 10) migrating the position for zach
-- 4) test commissions
-- 5) test lead allocation
-- 7) look at deals that are not bringing over closer
-- 8) look at all resource data from deal calendar event
-- 9) test all data
-- 11) make sure the anything in the future has a resource
--12)  migrate schedule notes to process steps
-- [ ] Do migration for:
-- - [ ] deal_note
-- - [ ] event_closeout_queue
-- - [ ] feedback
-- - [ ] Double check installation agreement request tables with John
-- - [ ] Predesign_status_log
-- cached available time on a cron job as well as the user_position_vw



-- DO
-- $do$
--     declare
--         r record;
--         v_company_feature_id integer;
--     BEGIN
--         for r in
--             select ufac.user_id,cf.feature_name,f.id,ufac.access_control_id,cf.company_id,c.id as new_company_id,ufac.enabled
--             from flow.user_feature_access_control ufac
--                      inner join flow.company_feature cf on cf.id = ufac.company_feature_id
--                      inner join flow.feature f on f.id = cf.feature_id
--                      cross join flow.company c
--             where c.id not in (1,2,3,9) and user_id = 2350555
--               and cf.company_id = 3
--             LOOP
--                 select id
--                 into v_company_feature_id
--                 from flow.company_feature where feature_name = r.feature_name
--                                             and company_id = r.new_company_id limit 1;
--                 if v_company_feature_id is not null then
--                     insert into flow.user_feature_access_control(user_id, company_feature_id, access_control_id, enabled)
--                     values(r.user_id,v_company_feature_id,r.access_control_id,r.enabled);
--                 end if;
--
--             END LOOP;
--     END
-- $do$;
