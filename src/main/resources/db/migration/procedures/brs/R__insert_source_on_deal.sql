CREATE OR REPLACE FUNCTION brs.insert_source_on_deal(p_project_id integer, p_current_user_id integer)
    RETURNS void
    LANGUAGE plpgsql
AS
$function$
declare
    v_company_id                       integer;
    v_source                           character varying;
    v_contact_id                       integer;
    v_custom_field_group_assignment_id integer;
    v_int_value_id                     integer;
    v_company_feature_id               integer;
    v_project_custom_field_value_id    integer;
BEGIN

    select c.id, c.company_id
    into v_contact_id,v_company_id
    from flow.project p
             inner join flow.contact c on c.id = p.contact_id
    where p.id = p_project_id;

    select lov1.name
    into v_source
    from flow.contact c
             inner join flow.contact_custom_field_value ccfv on ccfv.contact_id = c.id
             inner join flow.custom_field_group_assignment cfga on cfga.id = ccfv.custom_field_group_assignment_id
             inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
             inner join flow.company_object_type cot on cot.id = cfg.company_object_type_id
             inner join flow.object_type ot on ot.id = cot.object_type_id and object_type_id = 2
             inner join flow.custom_field cf on cf.id = cfga.custom_field_id
             inner join flow.list_of_value lov on lov.id = cf.list_of_value_id
             inner join flow.list_of_value lov1 on lov1.parent_id = lov.id
    where c.id = v_contact_id
      and cf.company_id = v_company_id
      and field_name = 'Lead Source'
      and ccfv.int_value = lov1.id;

    if v_source is not null then

        select cfga.id, lov1.id
        into v_custom_field_group_assignment_id,v_int_value_id
        from flow.custom_field_group_assignment cfga
                 inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                 inner join flow.company_object_type cot on cot.id = cfg.company_object_type_id
                 inner join flow.object_type ot on ot.id = cot.object_type_id and ot.id = 1
                 inner join flow.custom_field cf on cf.id = cfga.custom_field_id and field_name = 'Lead Source' and
                                                    cf.company_id = v_company_id
                 inner join flow.list_of_value lov on lov.id = cf.list_of_value_id and lov.name = 'Lead Source'
                 inner join flow.list_of_value lov1 on lov1.parent_id = lov.id
        where lov1.name = v_source
          and cfga.archived is false
          and cfg.archived is false
          and cf.archived is false;

        if v_custom_field_group_assignment_id is not null and v_int_value_id is not null then

            select pcfv.id
            into v_project_custom_field_value_id
            from flow.project_custom_field_value pcfv
            where pcfv.custom_field_group_assignment_id = v_custom_field_group_assignment_id
              and pcfv.project_id = p_project_id;

            if v_project_custom_field_value_id is not null then
                update flow.project_custom_field_value
                set int_value = v_int_value_id
                where id = v_project_custom_field_value_id;
            else
                insert into flow.project_custom_field_value(project_id, custom_field_group_assignment_id,
                                                            int_value,
                                                            date_created,
                                                            created_by_id)
                values (p_project_id, v_custom_field_group_assignment_id, v_int_value_id, now(), p_current_user_id);
            end if;
        else
            select cf.id
            into v_company_feature_id
            from flow.company_feature cf
                     inner join flow.feature f on f.id = cf.feature_id
            where f.feature_code = 'PROJECTS'
              and cf.company_id = v_company_id;
            insert into flow.company_error_log(company_feature_id, error_message, error_log_status_id,
                                               date_created, created_by_id)
            values (v_company_feature_id, 'Unable to assign Lead Source to Project ' || p_project_id || '.', 1, now(),
                    p_current_user_id);
        end if;
    else
        select cf.id
        into v_company_feature_id
        from flow.company_feature cf
                 inner join flow.feature f on f.id = cf.feature_id
        where f.feature_code = 'PROJECTS'
          and cf.company_id = v_company_id;
        insert into flow.company_error_log(company_feature_id, error_message, error_log_status_id,
                                           date_created, created_by_id)
        values (v_company_feature_id, 'Unable to assign Lead Source to Project ' || p_project_id || '.', 1, now(),
                p_current_user_id);

    end if;


END;
$function$
