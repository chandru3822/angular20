CREATE OR REPLACE FUNCTION brs.get_final_designs_completed_drilldown(p_user_id integer, p_quarter integer)
	RETURNS SETOF json AS
$BODY$
declare
	v_start_date date;
	v_end_date date;
	v_year integer;
BEGIN
	select extract('year' from now())::integer
	into v_year;

	case when p_quarter = 1 then
		v_start_date := (v_year || '-01-01')::date;
		v_end_date := (v_year || '-03-31')::date;
	when p_quarter = 2 then
		v_start_date := (v_year || '-04-01')::date;
		v_end_date := (v_year || '-06-30')::date;
  when p_quarter = 3 then
    v_start_date := (v_year || '-07-01')::date;
		v_end_date := (v_year || '-09-30')::date;
  else
    v_start_date := (v_year || '-10-01')::date;
		v_end_date := (v_year || '-12-31')::date;
	end case;

  RETURN QUERY select array_to_json(array_agg(row_to_json(sub_rows)))
    from (
      select concat(c.first_name, ' ', c.last_name) as customer_name,
             p.id,
             pd.source_name,
             concat(u.first_name, ' ', u.last_name) as owner_name,
             pd.system_size,
             pd.final_design_complete_date
      from flow.project p
        inner join flow.contact c on c.id = p.contact_id
        inner join brs.project_details pd on pd.project_id = p.id
        inner join flow.user u on u.id = pd.closer_user_id
        inner join flow.user_position up on up.user_id = u.id
      where pd.final_design_complete_date is not null
        and pd.final_design_complete_date::date between v_start_date and v_end_date
        and ((pd.cancelled_date is null) or (pd.cancelled_date is not null and pd.cancelled_date::date > v_end_date))
        and (p.company_project_status_type_id is null or p.company_project_status_type_id != 3)
        and u.id = p_user_id
        and pd.company_id = 3
      group by customer_name, p.id, pd.source_name, owner_name, pd.system_size, pd.final_design_complete_date
      order by customer_name
    ) as sub_rows;

END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100
ROWS 1000;
