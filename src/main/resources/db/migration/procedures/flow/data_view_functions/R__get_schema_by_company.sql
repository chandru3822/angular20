CREATE OR REPLACE FUNCTION flow.get_schema_by_company(p_company_id integer)
  RETURNS TABLE
          (
            schema_name  varchar,
            view_name varchar,
            id         integer,
            reset_data_view boolean
          )
AS
$BODY$
BEGIN
  return query
    select c.schema_name, dv.view_name, dv.id,dv.reset_data_view
    from flow.company c
           inner join flow.data_view dv on c.id = dv.company_id
    where c.id = p_company_id;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100
                   ROWS 1000;

