drop function if exists flow.get_schema_by_company(p_company_id bigint);
CREATE OR REPLACE FUNCTION flow.get_schema_by_company(p_company_id bigint)
  RETURNS TABLE
          (
            schema_name         varchar,
            view_name           varchar,
            id                  bigint,
            company_process_ids bigint[]
          )
AS
$BODY$
BEGIN
  return query
    select c.schema_name, dv.view_name, dv.id::bigint, dv.company_process_ids::bigint[]
    from flow.company c
           inner join flow.data_view dv on c.id = dv.company_id
    where c.id = p_company_id;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100
                   ROWS 1000;

