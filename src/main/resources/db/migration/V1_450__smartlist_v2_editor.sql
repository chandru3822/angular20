create or replace function flow.exec_custom_field_sql(p_sql text)
	returns table (
		id bigint,
		name text
	)
as
$BODY$
begin
	return query execute p_sql;
end
$BODY$
	language 'plpgsql';

update flow.custom_field cf
set custom_field_sql_smartlist = 'select dlh.id,
             dlh.reference_nbr::text as name
      from brs.design_log_history dlh'
where custom_field_sql_key = 'customFieldSql.brs.designLogNumbers';

update flow.custom_field cf
set custom_field_sql_smartlist = 'select plh.id,
           plh.proposal_nbr::text as name
    from brs.proposal_log_history plh'
where custom_field_sql_key = 'customFieldSql.brs.proposalLogNumbers';

update flow.custom_field cf
set custom_field_sql_smartlist = 'select a.id,
       a.name::text
    from brs.feat_db_ahj a
    where archived is not true'
where custom_field_sql_key = 'customFieldSql.brs.ahjList';

update flow.custom_field cf
set custom_field_sql_smartlist = 'select a.id,
           a.name::text
    from brs.feat_db_utility a
    where archived is not true'
where custom_field_sql_key = 'customFieldSql.brs.utilityCompanyList';


update flow.object_type
set smartlist = true
where object_type = 'Data View';

--add 'Manage' access level to report feature
insert into flow.feature_access_control (feature_id, access_control_id, created_by_id, modified_by_id)
values (19, 8, 2417166, 2417166);