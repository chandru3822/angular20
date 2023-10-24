drop FUNCTION if exists brs.populate_permit_pack_system_fields(p_project_id bigint,p_process_step_id bigint,p_project_process_step_id bigint);
CREATE OR REPLACE FUNCTION brs.populate_permit_pack_system_fields(p_project_id bigint,p_process_step_id bigint,p_project_process_step_id bigint)
    RETURNS void
    LANGUAGE plpgsql
AS
$function$
declare
    v_permit_pack_log_history_id bigint;
    _key   text;
    _value text;
    v_company_id bigint;
    v_panel_brand text;
    v_panel_watts bigint;
    v_number_of_arrays bigint;
    v_number_of_pitch bigint;
BEGIN

    select ppscfv.int_value
    into v_permit_pack_log_history_id
    from flow.project_process_step pps
             inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
             inner join flow.custom_field_group_assignment cfga2 on cfga2.id = ppscfv.custom_field_group_assignment_id
    where pps.id = p_project_process_step_id
      and cfga2.custom_field_id = 12687; -- I did this a little different than the other two function. CHECK

    select cp.company_id
    into v_company_id
    from flow.project p
             inner join flow.company_process cp on cp.process_id = p.company_process_id
    where p.id = p_project_id
    limit 1;

    select substring(module,1,position(' ' in module)-1)
    into v_panel_brand
    from brs.permit_pack_log_history
    where id = v_permit_pack_log_history_id;

    SELECT substring(module FROM '(\d+)')::bigint
    into v_panel_watts
    from brs.permit_pack_log_history
    where id = v_permit_pack_log_history_id;

    select greatest(pitch_mp1::numeric,pitch_mp2::numeric,pitch_mp3::numeric,pitch_mp4::numeric,pitch_mp5::numeric,pitch_mp6::numeric,pitch_mp7::numeric,pitch_mp8::numeric)::bigint,
           case
               WHEN number_of_modules_mp8::bigint > 0 THEN 8::bigint
               WHEN number_of_modules_mp7::bigint > 0 THEN 7::bigint
               WHEN number_of_modules_mp6::bigint > 0 THEN 6::bigint
               WHEN number_of_modules_mp5::bigint > 0 THEN 5::bigint
               WHEN number_of_modules_mp4::bigint > 0 THEN 4::bigint
               WHEN number_of_modules_mp3::bigint > 0 THEN 3::bigint
               WHEN number_of_modules_mp2::bigint > 0 THEN 2::bigint
               ELSE 1::bigint
               END
    into v_number_of_pitch,v_number_of_arrays
    from brs.permit_pack_log_history
    where id = v_permit_pack_log_history_id;

    FOR _key, _value IN
        select f.key,f.value
        from (

                 select jsonb_build_object(
                            -- Placard Required,604, DROPDOWN
                                (select cfga.id  -- DROPDOWN
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 604
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                                  from flow.list_of_value lov
                                                                                           inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                           inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                      and cf.company_id = v_company_id
                                                                                      and cf.id = 604 and cf.archived is false
                                                                                  where lov2.name::text = pplh.placard_required),
                            -- Racking Type,273, DROPDOWN
                                (select cfga.id -- DROPDOWN
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 273
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                                  from flow.list_of_value lov
                                                                                           inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                           inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                      and cf.company_id = v_company_id
                                                                                      and cf.id = 273 and cf.archived is false
                                                                                  where lov2.name::text =pplh.primary_mounting_hardware),
                            -- Attachment Type,12290, DROPDOWN
                                (select cfga.id -- DROPDOWN
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 12290
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                                  from flow.list_of_value lov
                                                                                           inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                           inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                      and cf.company_id = v_company_id
                                                                                      and cf.id = 12290 and cf.archived is false
                                                                                  where lov2.name::text =pplh.primary_attachment),

                            -- Design Log BOM JSON -- Don't know how to do this one with a JSON field... FIX THIS

                            -- System Size (kW),333,Decimal Number
                                (select cfga.id -- NUMERIC
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 333
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id),pplh.dc_system_size_kw::numeric,
                            -- Panel Quantity,205,Integer
                                (select cfga.id -- INT
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 205
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), pplh.module_count::bigint,
                            -- Panel Brand,204,Dropdown -- NEED TO FIX THIS ONE
                                (select cfga.id -- DROPDOWN
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 204
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                                  from flow.list_of_value lov
                                                                                           inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                           inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                      and cf.company_id = v_company_id
                                                                                      and cf.id = 204 and cf.archived is false
                                                                                  where lov2.name::text ilike concat(v_panel_brand,'%') limit 1), -- THIS MIGHT NOT WORK, GOT TO DUOBLE CHECK WHEN COMPILING
                     -- Panel Watts,206,Integer
                                (select cfga.id -- INT
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 206
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), v_panel_watts::bigint,
                            -- Panel Name,11986,Text
                                (select cfga.id -- STRING
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 11986
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), pplh.module_part_number::text,
                            -- Inverter Brand,162,Dropdown
                                (select cfga.id -- DROPDOWN
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 162
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                                  from flow.list_of_value lov
                                                                                           inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                           inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                      and cf.company_id = v_company_id
                                                                                      and cf.id = 162 and cf.archived is false
                                                                                  where lov2.name::text =pplh.inverter),
                            -- Home is 3+ stories,11719,Boolean
                                (select cfga.id -- BOOLEAN
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 11719
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), pplh.home_is_3_stories::boolean,
                            -- Roof Material,10665,Text
                                (select cfga.id -- STRING
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 10665
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), pplh.roof_material,
                            -- Blocking Upgrade Required,654,Dropdown
                                (select cfga.id -- DROPDOWN
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 654
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                                  from flow.list_of_value lov
                                                                                           inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                           inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                      and cf.company_id = v_company_id
                                                                                      and cf.id = 654 and cf.archived is false
                                                                                  where lov2.name::text =pplh.blocking_required),
                            -- Conduit Type,11608,Dropdown
                                (select cfga.id -- DROPDOWN
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 11608
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                                  from flow.list_of_value lov
                                                                                           inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                           inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                      and cf.company_id = v_company_id
                                                                                      and cf.id = 11608 and cf.archived is false
                                                                                  where lov2.name::text =pplh.conduit_type),
                            -- Trenching Required,657,Dropdown
                                (select cfga.id -- DROPDOWN
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 657
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                                  from flow.list_of_value lov
                                                                                           inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                           inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                      and cf.company_id = v_company_id
                                                                                      and cf.id = 657 and cf.archived is false
                                                                                  where lov2.name::text =pplh.trenching_required),
                            -- Overhead Span Required,12585,Dropdown
                                (select cfga.id -- DROPDOWN
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 12585
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                                  from flow.list_of_value lov
                                                                                           inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                           inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                      and cf.company_id = v_company_id
                                                                                      and cf.id = 12585 and cf.archived is false
                                                                                  where lov2.name::text =pplh.overhead_span),
                            -- AC Disconnect Required,12587,Dropdown
                                (select cfga.id -- DROPDOWN
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 12587
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                                  from flow.list_of_value lov
                                                                                           inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                           inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                      and cf.company_id = v_company_id
                                                                                      and cf.id = 12587 and cf.archived is false
                                                                                  where lov2.name::text =pplh.ac_disconnect_required),
                            -- Utility PV Meter Required,12586,Dropdown
                                (select cfga.id -- DROPDOWN
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 12586
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                                  from flow.list_of_value lov
                                                                                           inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                           inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                      and cf.company_id = v_company_id
                                                                                      and cf.id = 12586 and cf.archived is false
                                                                                  where lov2.name::text =pplh.utility_pv_meter_required),
                            -- Sheathing Type,12591,Dropdown
                                (select cfga.id -- DROPDOWN
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 12591
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                                  from flow.list_of_value lov
                                                                                           inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                           inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                      and cf.company_id = v_company_id
                                                                                      and cf.id = 12591 and cf.archived is false
                                                                                  where lov2.name::text =pplh.sheathing_type),
                            -- Framing Type,12592,Dropdown
                                (select cfga.id -- DROPDOWN
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 12592
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                                  from flow.list_of_value lov
                                                                                           inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                           inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                      and cf.company_id = v_company_id
                                                                                      and cf.id = 12592 and cf.archived is false
                                                                                  where lov2.name::text =pplh.framing_type),
                            -- Interconnection Interior/Exterior,11490,Dropdown
                                (select cfga.id -- DROPDOWN
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 11490
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                                  from flow.list_of_value lov
                                                                                           inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                           inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                      and cf.company_id = v_company_id
                                                                                      and cf.id = 11490 and cf.archived is false
                                                                                  where lov2.name::text =pplh.interconnection_interior_exterior),
                            -- Interconnection Supply Side/Load Side,12589,Dropdown
                                (select cfga.id -- DROPDOWN
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 12589
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                                  from flow.list_of_value lov
                                                                                           inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                           inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                      and cf.company_id = v_company_id
                                                                                      and cf.id = 12589 and cf.archived is false
                                                                                  where lov2.name::text =pplh.interconnection_supply_side_load_side),
                            -- Point of Interconnection,12588,Dropdown
                                (select cfga.id -- DROPDOWN
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 12588
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                                  from flow.list_of_value lov
                                                                                           inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                           inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                      and cf.company_id = v_company_id
                                                                                      and cf.id = 12588 and cf.archived is false
                                                                                  where lov2.name::text =pplh.point_of_interconnection),
                            -- Interconnection Method,11319,Dropdown
                                (select cfga.id -- DROPDOWN
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 11319
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                                  from flow.list_of_value lov
                                                                                           inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                           inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                      and cf.company_id = v_company_id
                                                                                      and cf.id = 11319 and cf.archived is false
                                                                                  where lov2.name::text =pplh.interconnection_method),
                            -- Non-standard Interconnection Items,12590,Dropdown
                                (select cfga.id -- DROPDOWN
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 12590
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                                  from flow.list_of_value lov
                                                                                           inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                           inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                      and cf.company_id = v_company_id
                                                                                      and cf.id = 12590 and cf.archived is false
                                                                                  where lov2.name::text =pplh.non_standard_interconnection_items),
                            -- Mixed Mounting Hardware,12593,Boolean
                                (select cfga.id -- BOOLEAN
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 12593
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), pplh.mixed_mounting_hardware::boolean,
                            -- AC Disconnect Rating,12594,Integer
                                (select cfga.id -- INT
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 12594
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), pplh.ac_disconnect_rating::bigint,
                            -- AC Disconnect Type,12595,Dropdown
                                (select cfga.id -- DROPDOWN
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 12595
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), (select lov2.id
                                                                                  from flow.list_of_value lov
                                                                                           inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                           inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
                                                                                      and cf.company_id = v_company_id
                                                                                      and cf.id = 12595 and cf.archived is false
                                                                                  where lov2.name::text = pplh.ac_disconnect_type),
                            -- Arrays on Primary Structure,12596,Integer
                                (select cfga.id -- INT
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 12596
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), pplh.arrays_on_primary_structure::bigint,
                            -- Arrays on Detached Structure,12597,Integer
                                (select cfga.id -- INT
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 12597
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), pplh.arrays_on_detached_structure::bigint,
                            -- Max Pitch,749,Integer
                                (select cfga.id
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 749
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), v_number_of_pitch,
                            -- Number of Arrays,197,Integer
                                (select cfga.id
                                 from flow.custom_field cf
                                          inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf.id
                                          inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                                 where cf.id = 197
                                   and cfga.archived is false and cf.archived is false and cfg.archived is false
                                   and cf.company_id = v_company_id
                                   and cfg.process_step_id = p_process_step_id), v_number_of_arrays

                            ) as me
                 from brs.permit_pack_log_history pplh
                          inner join brs.project_details pd on pd.project_id = pplh.project_id
                 where pplh.id = v_permit_pack_log_history_id) as t
                 left join lateral jsonb_each_text(t.me) f on true
        LOOP
            IF(_value IS NOT NULL) -- this is supposed to keep it from breaking if value is null. Check when compiling and testing
            THEN
                perform flow.set_pps_cfv(p_project_id,99999999, _key::bigint, _value, true);
            END IF;
        END LOOP;


    insert into flow.company_function_log(function_name, db_function_id, parameters)
    values ('Populate Permit Pack System Fields', 9999, 'p_project_id: ' || p_project_id || --SET 9999 TO THE CORRECT db_fucntion_id -- FIX THIS
                                                        ' p_process_step_id: '|| p_process_step_id ||
                                                        ' p_project_process_step_id: ' || p_project_process_step_id);

END
$function$
