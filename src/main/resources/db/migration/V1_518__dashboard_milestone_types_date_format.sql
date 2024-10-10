alter table brs.dashboard_milestone_column add column if not exists date_format varchar(20);

update brs.dashboard_milestone_column dmc
set date_format = 'MM/DD/YYYY'
from brs.dashboard_milestone dm
where dm.id = dmc.dashboard_milestone_id
  and dm.dashboard_milestone_type_id = 2
  and data_type_id = 2;
