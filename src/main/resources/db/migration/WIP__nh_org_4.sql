SET session_replication_role = replica;
DO
$do$
  declare
    x        record;
  BEGIN
    for x in select fdc.*,o2.id as org_id
             from brs.fee_distribution_c fdc
                    inner join flow.org o2 on o2.nh_migration_id = fdc.partner_name_c
             where fdc.record_type_id = '01234000000HrvnAAC'
      loop
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29438,x.Comp_Shingle_Roof_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29439,x.Comp_Inset_on_Tile_Roof_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29440,x.Over_Tile_Roof_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29441,x.Flat_roof_install_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29442,x.Flat_Roof_Tilt_Up_Install_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29443,x.Metal_Standing_Seam_install_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29444,x.Mixed_install_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29445,x.one_roof_install_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29783,x.Other_roof_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29446,x.AC_Rough_Wire_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29447,x.x_3_story_roof_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29448,x.Custom_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29449,x.Steep_Roof_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29450,x.Storage_Install_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29451,x.Permitting_Labor_Only_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29452,x.Pre_COE_Commissioning_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29453,x.Storage_Only_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29454,x.Storage_Base_Fixed_Fee_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29455,x.Storage_Expansion_Fee_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29731,x.Panel_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29732,x.Storage_Base_Fixed_Fee_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29733,x.Storage_Expansion_Fee_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29734,x.Storage_Only_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29735,x.Deal_Type_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29736,x.Storage_Base_Fixed_Fee_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29737,x.Storage_Expansion_Fee_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29738,x.Storage_Installation_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29739,x.Storage_Only_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29740,x.Storage_Rough_Wire_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29741,x.Deal_Type_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29742,x.Storage_Base_Fixed_Fee_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29743,x.Storage_Expansion_Fee_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29744,x.Storage_Installation_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29745,x.Storage_Only_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29746,x.Storage_Rough_Wire_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29747,x.Deal_Type_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29748,x.Storage_Base_Fixed_Fee_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29749,x.Storage_Expansion_Fee_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29750,x.Storage_Installation_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29751,x.Storage_Only_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29752,x.Storage_Rough_Wire_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29753,x.Deal_Type_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29754,x.Storage_Base_Fixed_Fee_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29755,x.Storage_Expansion_Fee_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29756,x.Storage_Installation_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29757,x.Storage_Only_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29758,x.Storage_Rough_Wire_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29759,x.Deal_Type_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29760,x.Storage_Base_Fixed_Fee_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29761,x.Storage_Expansion_Fee_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29762,x.Storage_Installation_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29763,x.Storage_Only_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29764,x.Storage_Rough_Wire_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29765,x.Deal_Type_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29766,x.Storage_Base_Fixed_Fee_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29767,x.Storage_Expansion_Fee_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29768,x.Storage_Installation_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29769,x.Storage_Only_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29770,x.Storage_Rough_Wire_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29771,x.Deal_Type_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29772,x.Storage_Base_Fixed_Fee_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29773,x.Storage_Expansion_Fee_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29774,x.Storage_Installation_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29775,x.Storage_Only_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29776,x.Storage_Rough_Wire_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29777,x.Deal_Type_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29778,x.Storage_Base_Fixed_Fee_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29779,x.Storage_Expansion_Fee_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29780,x.Storage_Installation_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29781,x.Storage_Only_c::text );
        perform flow.set_org_cfv_no_checks(x.org_id, 2384850,29782,x.Storage_Rough_Wire_c::text );

      end loop;
  end
$do$;

insert into brs.new_homes_details( project_id, contact_id, company_id, date_modified, contact_first_name, contact_last_name, contact_email,
                                   contact_mobile_phone, contact_phone, project_name, project_street1, project_city,
                                   project_company_state_id, project_state_abbreviation, project_state_id,
                                   project_postal_code, project_time_zone, project_date_created, project_created_by_id, cancelled_date, archived)
  (select  p.id, c.id, c.company_id, p.date_modified, c.first_name,
           c.last_name, c.email, c.mobile, c.phone, p.project_name,
           p.street1, p.city, p.company_state_id,
           s.abbreviation, s.id, p.postal_code,
           p.time_zone, p.date_created, p.created_by_id, p.cancelled_date, p.archived
   from flow.contact c
          inner join flow.project as p on p.contact_id = c.id
          left join flow.company_state as cs on cs.id = p.company_state_id
          left join flow.state s on s.id = cs.state_id
   where p.nw_migration_id is not null);



insert into flow.work_queue_cycle( project_process_step_id, company_process_step_status_type_id, process_step_work_queue_type_process_step_status_type_id,
                                   date_entered_queue, created_by_id, modified_by_id, date_modified)
with configs as (
  select pswqtpsst.id as process_step_work_queue_type_process_step_status_type_id,
         pswqt.id as process_step_work_queue_type_id,
         pswqt.process_step_id,
         pswqt.work_queue_type_id,
         coalesce(cpsst.id,0) as company_process_status_type_id,
         coalesce(psst.id,0) as process_step_status_type_id,
         coalesce(cpst.id, 0) as company_project_status_type_id,
         coalesce(pst.id,0) as project_status_type_id
  from flow.process_step_work_queue_type_process_step_status_type pswqtpsst
         inner join flow.process_step_work_queue_type pswqt  on pswqtpsst.process_step_work_queue_type_id = pswqt.id and pswqt.archived is false
         inner join flow.work_queue_type wqt on pswqt.work_queue_type_id = wqt.id and wqt.archived is false
         inner join flow.process_step ps on pswqt.process_step_id = ps.id and ps.archived is false and ps.company_id = 3
         left join flow.process_step_work_queue_type_project_status_type pswqtpst on pswqt.id = pswqtpst.process_step_work_queue_type_id and pswqtpst.archived is false
         left join flow.company_process_step_status_type cpsst on pswqtpsst.company_process_step_status_type_id = cpsst.id and cpsst.archived is false
         left join flow.process_step_status_type psst on pswqtpsst.process_step_status_type_id = psst.id and psst.archived is false
         left join flow.company_project_status_type cpst on pswqtpst.company_project_status_type_id = cpst.id and cpst.archived is false
         left join flow.project_status_type pst on pswqtpst.project_status_type_id = pst.id and pst.archived is false
  where  pswqtpsst.archived is false
)
select pps.id,cpsst.id,t.process_step_work_queue_type_process_step_status_type_id,now(),2350555,2350555,now()
from flow.project p
       inner join flow.project_process_step pps on p.id = pps.project_id and pps.archived is false
       inner join flow.process_step ps on pps.process_step_id = ps.id and ps.archived is false and ps.company_id = 3 and ps.id != 1
       inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
       inner join flow.company_project_status_type cpst on p.company_project_status_type_id = cpst.id
       inner join configs t on t.process_step_id = pps.process_step_id
where (t.project_status_type_id = cpst.project_status_type_id or t.company_project_status_type_id = cpst.id) and
  (t.process_step_status_type_id = cpsst.process_step_status_type_id or t.company_process_status_type_id = cpsst.id)
  and p.archived is not true
  and not exists (select wqc.id
                  from flow.work_queue_cycle wqc
                  where wqc.project_process_step_id = pps.id and
                    wqc.process_step_work_queue_type_process_step_status_type_id = t.process_step_work_queue_type_process_step_status_type_id and
                    wqc.date_exited_queue is null);

SET session_replication_role = default;



