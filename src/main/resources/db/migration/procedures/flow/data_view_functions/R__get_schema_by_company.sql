CREATE OR REPLACE FUNCTION flow.get_schema_by_company(p_company_id integer)
  RETURNS TABLE
          (
            schema_name  varchar,
            view_name varchar,
            id         integer,
            company_process_ids integer[]
          )
AS
$BODY$
BEGIN
  return query
    select c.schema_name, dv.view_name, dv.id,dv.company_process_ids
    from flow.company c
           inner join flow.data_view dv on c.id = dv.company_id
    where c.id = p_company_id;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100
                   ROWS 1000;

