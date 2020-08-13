insert into brs.project_details_config(company_id , custom_field_group_assignment_id, field_to_update,data_type_id )
(select 3,732,'deal_id',6
    where not exists (select company_id from brs.project_details_config
        where company_id = 3 and custom_field_group_assignment_id = 732 and field_to_update = 'deal_id' and data_type_id = 6));


alter table brs.project_details add column if not exists deal_id integer;
CREATE INDEX if not exists pd_deal_id_idx ON brs.project_details (deal_id);
