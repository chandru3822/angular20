-- DROP FUNCTION brs.get_final_designs_completed_drilldown(integer, integer);

-- SELECT * FROM brs.get_final_designs_completed_drilldown(2353957, 1);
-- SELECT * FROM brs.get_final_designs_completed_drilldown(2397009, 1);

-- Custom fields needed for R__get_final_designs_completed_drilldown query --
    -- 'Source' p_object_type_id = 1, p_custom_field_id = 5
    -- 'System Size' p_object_type_id = 4, p_custom_field_id = 333, p_process_step_id = 4
    -- 'Final Design Signed' p_object_type_id = 4, p_custom_field_id = 104, p_process_step_id = 9
    -- 'Financial Agreement Signed' p_object_type_id = 4, p_custom_field_id = 108, p_process_step_id = 4
    -- 'Financier' p_object_type_id = 4, p_custom_field_id = 109, p_process_step_id = 4
    -- 'First Cash Payment Paid' p_object_type_id = ?, p_custom_field_id = 112, p_process_step_id = ?
    -- 'Cancelled' p_object_type_id = 1, p_custom_field_id = 52
    -- 'On Hold' p_object_type_id = 1, p_custom_field_id = 200

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
            select c.first_name || ' ' || c.last_name as customer_name,
                   p.id,
                   lov.name as source_name,
                   u.first_name || ' ' || u.last_name as owner_name,
                   system_size,
                   final_design_signed_date,
                   agreement_signed_date,
                   lov2.name as financier
            from flow.project p
                inner join flow.contact c on c.id = p.contact_id
                inner join flow.user_project up on up.project_id = p.id
                inner join flow.user_position up2 on up2.id = up.user_position_id and up2.position_id = 1
                inner join flow.user u on u.id = up2.user_id
                left join lateral (select * from flow.get_value_for_custom_field(1, 5, p.id) as source) source on true
                left join flow.list_of_value lov on lov.parent_id = 5 and lov.name = source
                inner join lateral (select * from flow.get_value_for_custom_field(4, 333, p.id, 4) as system_size) system_size on true
                left join lateral (select * from flow.get_value_for_custom_field(4, 104, p.id, 9) as final_design_signed_date) final_design_signed_date on true
                left join lateral (select * from flow.get_value_for_custom_field(4, 108, p.id, 4) as agreement_signed_date) agreement_signed_date on true
                left join lateral (select * from flow.get_value_for_custom_field(4, 109, p.id, 4) as financier) financier on true
                left join flow.list_of_value lov2 on lov2.parent_id = 115 and lov2.name = financier

                -- TODO: Replace ?'s below w/ correct ID's once 'First Cash Payment Paid Date' custom field gets added to a custom field group
--                 left join lateral (select * from flow.get_value_for_custom_field(?, 112, p.id, ?) as first_cash_payment_paid_date) first_cash_payment_paid_date on true
                left join lateral (select null as first_cash_payment_paid_date) first_cash_payment_paid_date on true

                left join lateral (select * from flow.get_value_for_custom_field(1, 52, p.id) as cancelled_date) cancelled_date on true
                left join lateral (select * from flow.get_value_for_custom_field(1, 200, p.id) as on_hold) on_hold on true
            where final_design_signed_date IS NOT NULL AND agreement_signed_date IS NOT NULL
                and case when financier = 'Cash'
                    then first_cash_payment_paid_date IS NOT NULL
                        and greatest(first_cash_payment_paid_date::date, final_design_signed_date::date, agreement_signed_date::date)
                        between v_start_date AND v_end_date
                    else greatest(final_design_signed_date::date, agreement_signed_date::date)
                        between v_start_date AND v_end_date
                end
                and ((cancelled_date is null) OR (cancelled_date is not null and cancelled_date::date > v_end_date))
                and (on_hold is null or on_hold::boolean is false)
                and u.id = p_user_id
            order by c.first_name
        ) as sub_rows;

END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100
ROWS 1000;
