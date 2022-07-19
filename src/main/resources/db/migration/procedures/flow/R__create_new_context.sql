CREATE OR REPLACE FUNCTION flow.create_new_context(p_company_name varchar,p_aws_bucket varchar,
                                                   p_parent_company_id integer, p_user_id integer)
  RETURNS void AS
$BODY$
declare
v_company_id integer;
BEGIN
    insert into flow.company(company_name,aws_bucket, abbreviation,parent_company_id, level)
    values(p_company_name,p_aws_bucket,p_aws_bucket,1,2)
    returning  id into v_company_id;


--     INSERT INTO flow.process ( parent_company_id, process_name, date_created,
--                                 created_by_id,archived)
--     VALUES (p_parent_company_id, p_process_name, now(), p_user_id, false)
--     returning  id into v_process_id;
--
--     INSERT INTO flow.company_process (company_id, process_id, status_type_id, archived)
--     VALUES ( v_company_id,v_process_id, 1, false);


    insert into flow.user_status_type(user_status_type, company_id, archived,
                                      has_access, date_created, created_by_id)
        (select user_status_type, v_company_id, archived,
                has_access, date_created, created_by_id
         from flow.user_status_type
         where company_id = p_parent_company_id);

    insert into flow.company_user_status(user_id, user_status_type_id, archived, date_created,
                                         created_by_id)
        (select p_user_id,(select ust.id
                            from flow.user_status_type ust
                            inner join flow.company c on c.id = ust.company_id
                            where c.id = v_company_id
                           and ust.user_status_type = 'Active'),false,now(),p_user_id
            from flow.company_user_status cus
            inner join flow.user_status_type ust2 on cus.user_status_type_id = ust2.id and ust2.company_id = p_parent_company_id
            where cus.user_id = p_user_id);

    insert into flow.user_company(company_id,user_id)
        values(v_company_id,p_user_id);

    insert into flow.company_process_step_status_type(process_step_status_type, process_step_status_type_id,company_id, archived, date_created, created_by_id)
    (select process_step_status_type,process_step_status_type_id,v_company_id,false,now(),p_user_id
    from flow.company_process_step_status_type
    where process_step_status_type in ('Active','Complete','Cancelled') and company_id = p_parent_company_id);


    insert into flow.company_project_status_type (project_status_type_id, company_id, project_status_type, created_by_id)
    (select cpst.project_status_type_id,v_company_id,cpst.project_status_type,p_user_id
     from flow.company_project_status_type cpst
     where cpst.project_status_type in ('Active','Cancelled','On Hold','Complete')
        and cpst.company_id = p_parent_company_id);

    insert into flow.company_system_list (system_list_id, company_id, schedulable)
    (select csl.system_list_id,v_company_id,csl.schedulable
     from flow.company_system_list csl
     where csl.company_id = p_parent_company_id
    );

    insert into flow.company_object_type (object_type_id, company_id)
    (select cot.object_type_id,v_company_id
    from flow.company_object_type cot
    where cot.company_id = p_parent_company_id);

    insert into flow.company_data_type(company_id, company_data_type, data_type_id)
    (select v_company_id,cdt.company_data_type,cdt.data_type_id
        from flow.company_data_type cdt
        where cdt.company_id = p_parent_company_id);

    insert into flow.company_feature( feature_name, company_id, feature_id, archived, home_page)
    (select cf.feature_name,v_company_id,cf.feature_id,false,cf.home_page
        from flow.company_feature cf
        inner join flow.feature f on cf.feature_id = f.id
        where is_system is true and f.id != 26 and cf.company_id = p_parent_company_id);

    insert into flow.company_state(state_id, company_id, map_latitude, map_longitude, map_zoom, active, archived)
    (select cs.state_id,v_company_id,cs.map_latitude,cs.map_longitude,cs.map_zoom,cs.active,cs.archived
     from flow.company_state cs
     where cs.company_id = p_parent_company_id);

     insert into flow.company_country(country_id, company_id, archived)
         (select cc.country_id,v_company_id,cc.archived
          from flow.company_country cc
          where cc.company_id = p_parent_company_id);

     insert into flow.company_timezone(company_id, timezone_id, date_created, created_by_id, archived)
     (select v_company_id,ct.timezone_id,now(),p_user_id,false
      from flow.company_timezone ct
         where ct.company_id = p_parent_company_id);

    insert into flow.company_week_start(company_id, day_of_week_id)
        (select v_company_id,cws.day_of_week_id
         from flow.company_week_start cws
         where cws.company_id = p_parent_company_id);


    insert into flow.user_feature_access_control(user_id, company_feature_id, access_control_id, enabled)
    (select p_user_id,cf2.id,ac2.id,ufac.enabled
     from flow.user_feature_access_control ufac
              inner join flow.company_feature cf on ufac.company_feature_id = cf.id and cf.company_id = p_parent_company_id
              inner join flow.company_feature cf2 on cf2.feature_id = cf.feature_id and cf2.company_id = v_company_id
              inner join flow.access_control ac2  on ufac.access_control_id = ac2.id
        where ufac.user_id = p_user_id);

    insert into flow.org_level( company_id, level, level_name)
    values(v_company_id,1,'Parent');



END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;


--p_company_name  Blue Raven IT
--p_aws_bucket   blueravenIT
--p_parent_company_id  3
--p_level 1
