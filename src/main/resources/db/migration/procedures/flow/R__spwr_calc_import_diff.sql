drop function if exists flow.spwr_get_import_diff();
create or replace function flow.spwr_calc_import_diff()
  returns table
          (
            project_id      bigint,
            spwr_project_id text,
            diff            jsonb
          )
  language plpgsql
as
$$
begin
  return query
    with sunpower_roof_mapping(lov_id, name) as (values (901, 'Comp Shingle'),
                                                        (902, 'Metal - Other'),
                                                        (903, 'Metal - Other'),
                                                        (904, 'Metal - Standing Seam'),
                                                        (905, 'Flat Concrete Tile'),
                                                        (906, 'S Concrete Tile'),
                                                        (907, 'W Concrete Tile'),
                                                        (908, 'Flat - Rolled Comp'),
                                                        (909, 'Flat - Foam')),
      projects as (select ip.sp_project_id,
                          pd.project_id,
                          pd.site_survey_start_time,
                          srm.name                as roof_type_name,
                          pd.permit_pack_submittal_start_time,
                          pd.expected_permit_approval_date,
                          pd.permit_approved_date,
                          pd.installation_start_time,
                          pd.substantial_completion_date,
                          pd.ahj_final_inspection_verified,
                          pd.hoa_approval_needed_name,
                          trim(pd.hoa_management) as hoa_management
                   from flow.import_sp_project ip
                          inner join brs.project_details pd
                                     on pd.project_id = ip.project_id
                          left join sunpower_roof_mapping srm on srm.lov_id = pd.roof_type
                   where pd.archived is false
                        and ip._snapshot_error_message is null),
      attachments as (select p.project_id,
                             (select array_to_json(array [a.s3_key])
                              from flow.project_process_step_attachment ppsa
                                     inner join flow.project_process_step pps on ppsa.project_process_step_id = pps.id
                                     inner join flow.attachment a on ppsa.attachment_id = a.id
                              where pps.project_id = p.project_id
                                and ppsa.archived is false
                                and pps.archived is false
                                and pps.main is true
                                and a.archived is false
                                and a.attachment_type_id = 36
                                and pps.process_step_id = 3696
                                and a.filename like '%SS%'
                              order by ppsa.date_created desc
                              limit 1) as site_survey_links,
                             (select array_to_json(array [a.s3_key])
                              from flow.project_process_step_attachment ppsa
                                     inner join flow.project_process_step pps on ppsa.project_process_step_id = pps.id
                                     inner join flow.attachment a on ppsa.attachment_id = a.id
                              where pps.project_id = p.project_id
                                and ppsa.archived is false
                                and pps.archived is false
                                and pps.main is true
                                and a.archived is false
                                and a.attachment_type_id = 40
                                and pps.process_step_id = 3361
                              order by ppsa.date_created desc
                              limit 1) as complete_design_package_links,
                             (select array_to_json(array [a.s3_key])
                              from flow.project_process_step_attachment ppsa
                                     inner join flow.project_process_step pps on ppsa.project_process_step_id = pps.id
                                     inner join flow.attachment a on ppsa.attachment_id = a.id
                              where pps.project_id = p.project_id
                                and ppsa.archived is false
                                and pps.archived is false
                                and pps.main is true
                                and a.archived is false
                                and a.attachment_type_id = 334
                                and pps.process_step_id = 3361
                                and lower(a.filename) like '%permit pack%'
                              order by ppsa.date_created desc
                              limit 1) as pe_stamp_links,
                             (select array_to_json(array [a.s3_key])
                              from flow.project_process_step_event_attachment ppsea
                                     inner join flow.attachment a on ppsea.attachment_id = a.id
                                     inner join flow.project_process_step_event ppse
                                                on ppsea.project_process_step_event_id = ppse.id
                                     inner join flow.project_process_step pps on ppse.project_process_step_id = pps.id
                              where pps.project_id = p.project_id
                                and ppsea.archived is false
                                and pps.archived is false
                                and pps.main is true
                                and pps.process_step_id = 13
                                and ppse.process_step_event_id = 3
                                and a.archived is false
                                and a.attachment_type_id = 950
                                and lower(a.display_name) like '%approved%'
                              order by ppsea.date_created desc
                              limit 1) as final_permit_links,
                             (select array_to_json(array [a.s3_key])
                              from flow.project_process_step_attachment ppsa
                                     inner join flow.project_process_step pps on ppsa.project_process_step_id = pps.id
                                     inner join flow.attachment a on ppsa.attachment_id = a.id
                                     inner join flow.import_sp_project isp on isp.project_id = pps.project_id
                              where pps.project_id = p.project_id
                                and ppsa.archived is false
                                and pps.archived is false
                                and pps.main is true
                                and a.archived is false
                                and a.attachment_type_id = 364
                                and pps.process_step_id = 20
                              order by ppsa.date_created desc
                              limit 1) as preliminary_ic_approval_links,
                             (select array_to_json(array [a.s3_key])
                              from flow.project_process_step_attachment ppsa
                                     inner join flow.project_process_step pps on ppsa.project_process_step_id = pps.id
                                     inner join flow.attachment a on ppsa.attachment_id = a.id
                              where pps.project_id = p.project_id
                                and ppsa.archived is false
                                and pps.archived is false
                                and pps.main is true
                                and a.archived is false
                                and a.attachment_type_id = 330
                                and pps.process_step_id = 50
                              order by ppsa.date_created desc
                              limit 1) as pto_letter_links,
                             (select array_to_json(array [a.s3_key])
                              from flow.project_process_step_attachment ppsa
                                     inner join flow.project_process_step pps on ppsa.project_process_step_id = pps.id
                                     inner join flow.attachment a on ppsa.attachment_id = a.id
                              where pps.project_id = p.project_id
                                and ppsa.archived is false
                                and pps.archived is false
                                and pps.main is true
                                and a.archived is false
                                and a.attachment_type_id = 45
                                and pps.process_step_id = 3361
                                and lower(a.filename) like '%bom%'
                              order by ppsa.date_created desc
                              limit 1) as project_bom_links,
                             (select array_to_json(array [a.s3_key])
                              from flow.project_process_step_attachment ppsa
                                     inner join flow.project_process_step pps on ppsa.project_process_step_id = pps.id
                                     inner join flow.attachment a on ppsa.attachment_id = a.id
                              where pps.project_id = p.project_id
                                and ppsa.archived is false
                                and pps.archived is false
                                and pps.main is true
                                and a.archived is false
                                and a.attachment_type_id = 43
                                and pps.process_step_id = 3365
                              order by ppsa.date_created desc
                              limit 1) as photo_links
                      from projects p),
      results as (select p.sp_project_id,
                         p.project_id,
                         p.site_survey_start_time,
                         p.roof_type_name,
                         p.permit_pack_submittal_start_time,
                         p.expected_permit_approval_date,
                         p.permit_approved_date,
                         p.installation_start_time,
                         p.substantial_completion_date,
                         p.ahj_final_inspection_verified,
                         p.hoa_approval_needed_name,
                         p.hoa_management,
                         a.site_survey_links,
                         a.complete_design_package_links,
                         a.pe_stamp_links,
                         a.final_permit_links,
                         a.preliminary_ic_approval_links,
                         a.pto_letter_links,
                         a.project_bom_links,
                         a.photo_links
                  from projects p
                         left join attachments a on p.project_id = a.project_id),
      snapshot as (select r.project_id, row_to_json(r.*)::jsonb - '{project_id, sp_project_id}'::text[] as snapshot
                   from results r),
      compare as (select s.project_id,
                         s.snapshot as new_snapshot,
                         d          as diff
                  from snapshot s
                         inner join flow.import_sp_project sp
                                    on sp.project_id = s.project_id
                         left join lateral flow.jsonb_diff(sp._snapshot,
                                                           s.snapshot) d on true
                  where d <> '{}')
      update flow.import_sp_project p
        set _snapshot             = c.new_snapshot,
          _snapshot_date_updated  = now()
        from compare c
        where p.project_id = c.project_id
        returning p.project_id, p.sp_project_id, c.diff;
end;

$$
;
