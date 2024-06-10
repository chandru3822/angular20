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
    with projects as (select ip.sp_project_id,
                             pd.project_id,
                             pd.site_survey_start_time,
                             pd.roof_type_name,
                             pd.permit_pack_submittal_start_time,
                             pd.permit_approved_date,
                             pd.installation_start_time,
                             pd.substantial_completion_date,
                             pd.ahj_final_inspection_verified,
                             pd.hoa_approval_needed_name,
                             pd.hoa_management,
                             ip.date_created
                      from flow.import_sp_project ip
                             inner join brs.project_details pd
                                        on pd.project_id = ip.project_id),
      attachments as (select p.project_id,
                             array_remove(array_agg(CASE WHEN a.attachment_type_id = 36 THEN a.filename END),
                                          null) as site_survey_filename,
                             array_remove(array_agg(CASE WHEN a.attachment_type_id = 40 THEN a.filename END),
                                          null) as complete_design_package,
                             array_remove(array_agg(CASE WHEN a.attachment_type_id = 334 THEN a.filename END),
                                          null) as pe_stamp,
                             array_remove(array_agg(CASE WHEN a.attachment_type_id = 950 THEN a.filename END),
                                          null) as final_permit,
                             array_remove(array_agg(CASE WHEN a.attachment_type_id = 364 THEN a.filename END),
                                          null) as preliminary_ic_approval,
                             array_remove(array_agg(CASE WHEN a.attachment_type_id = 330 THEN a.filename END),
                                          null) as pto_letter,
                             array_remove(array_agg(CASE WHEN a.attachment_type_id = 45 THEN a.filename END),
                                          null) as project_bom,
                             array_remove(array_agg(CASE WHEN a.attachment_type_id = 43 THEN a.filename END),
                                          null) as photos
                      from projects p
                             inner join flow.project_attachment pa
                                        on pa.project_id = p.project_id
                             inner join flow.attachment a
                                        on pa.attachment_id = a.id
                                          and a.archived is false
                                          and pa.archived is false
                      where a.attachment_type_id in (36, 40, 334, 950, 364, 330, 45, 43)
                      group by p.project_id),
      results as (select p.sp_project_id,
                         p.project_id,
                         p.site_survey_start_time,
                         p.roof_type_name,
                         p.permit_pack_submittal_start_time,
                         p.permit_approved_date,
                         p.installation_start_time,
                         p.substantial_completion_date,
                         p.ahj_final_inspection_verified,
                         p.hoa_approval_needed_name,
                         p.hoa_management,
                         p.date_created,
                         case
                           when array_length(a.site_survey_filename, 1) > 0
                             then a.site_survey_filename end                                   as site_survey_filename,
                         case
                           when array_length(a.complete_design_package, 1) > 0
                             then a.complete_design_package end                                as complete_design_package,
                         case when array_length(a.pe_stamp, 1) > 0 then a.pe_stamp end         as pe_stamp,
                         case when array_length(a.final_permit, 1) > 0 then a.final_permit end as final_permit,
                         case
                           when array_length(a.preliminary_ic_approval, 1) > 0
                             then a.preliminary_ic_approval end                                as preliminary_ic_approval,
                         case when array_length(a.pto_letter, 1) > 0 then a.pto_letter end     as pto_letter,
                         case when array_length(a.project_bom, 1) > 0 then a.project_bom end   as project_bom,
                         case when array_length(a.photos, 1) > 0 then a.photos end             as photos
                  from projects p
                         left join attachments a on p.project_id = a.project_id),
      snapshot as (select r.project_id, row_to_json(r.*) as snapshot from results r),
      compare as (select s.project_id, s.snapshot as new_snapshot, sp._snapshot as old_snapshot, d as diff
                  from snapshot s
                         inner join flow.import_sp_project sp on sp.project_id = s.project_id
                         left join lateral jsonb_diff(sp._snapshot, s.snapshot::jsonb) d on true
                  where d <> '{}')
      update flow.import_sp_project p
        set _snapshot = c.new_snapshot,
          _snapshot_date_updated = now()
        from compare c
        where p.project_id = c.project_id
        returning p.project_id, p.sp_project_id, c.diff;
end;

$$
;
