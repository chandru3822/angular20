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