alter table brs.permit_pack_log
add column if not exists design_nbr integer;

update brs.permit_pack_log
set design_nbr = design_log_id;


update brs.permit_pack_log ppl
set design_log_id = (select dl.id
                     from brs.design_log dl
                     where dl.project_id = ppl.project_id
                     and dl.design_nbr = ppl.design_nbr);

alter table brs.permit_pack_log_history
  add column if not exists design_nbr integer;

update brs.permit_pack_log_history
set design_nbr = design_log_id;

update brs.permit_pack_log_history ppl
set design_log_id = (select dl.id
                     from brs.design_log dl
                     where dl.project_id = ppl.project_id
                       and dl.design_nbr = ppl.design_nbr);
