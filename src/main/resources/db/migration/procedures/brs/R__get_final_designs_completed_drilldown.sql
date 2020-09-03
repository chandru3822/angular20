-- DROP FUNCTION brs.get_final_designs_completed_drilldown(integer, integer);

-- SELECT * FROM brs.get_final_designs_completed_drilldown(2353957, 1);
-- SELECT * FROM brs.get_final_designs_completed_drilldown(2397009, 1);

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
                   pd.system_size,
                   pd.final_design_signed_date,
                   pd.financial_agreement_signed_date,
                   pd.utility_bill_verified_date,
                   pd.first_cash_payment_paid_date,
                   lov2.name as financier
            from flow.project p
                inner join flow.contact c on c.id = p.contact_id
                inner join brs.project_details pd on pd.project_id = p.id
                inner join flow.user u on u.id = pd.closer_user_id
                inner join flow.user_position up on up.user_id = u.id
                left join flow.list_of_value lov on lov.id = pd.source
                left join flow.list_of_value lov2 on lov2.id = pd.primary_financier
            where pd.final_design_signed_date is not null
                and pd.financial_agreement_signed_date is not null
                and case when p_quarter in (3,4) then pd.utility_bill_verified_date is not null
                    else 1=1
                    end
                and case when pd.primary_financier = 721 then pd.first_cash_payment_paid_date is not null
                    and case when p_quarter in (1,2)
                        then greatest(pd.first_cash_payment_paid_date::date, pd.final_design_signed_date::date, pd.financial_agreement_signed_date::date)
                            between v_start_date and v_end_date
                        else greatest(pd.first_cash_payment_paid_date::date, pd.final_design_signed_date::date, pd.financial_agreement_signed_date::date, pd.utility_bill_verified_date::date)
                            between v_start_date and v_end_date
                            and not greatest(pd.first_cash_payment_paid_date::date, pd.final_design_signed_date::date, pd.financial_agreement_signed_date::date)
                                between '2020-01-01' and '2020-06-30'
                    end
                else case when p_quarter in (1,2)
                    then greatest(pd.final_design_signed_date::date, pd.financial_agreement_signed_date::date)
                        between v_start_date and v_end_date
                    else greatest(pd.final_design_signed_date::date, pd.financial_agreement_signed_date::date, pd.utility_bill_verified_date::date)
                        between v_start_date and v_end_date
                        and not greatest(pd.final_design_signed_date::date, pd.financial_agreement_signed_date::date)
                            between '2020-01-01' and '2020-06-30'
                    end
                end
                and ((pd.cancelled_date is null) or (pd.cancelled_date is not null and pd.cancelled_date::date > v_end_date))
                and (p.company_project_status_type_id is null or p.company_project_status_type_id != 3)
                and u.id = p_user_id
            group by customer_name, p.id, source_name, owner_name, pd.system_size, pd.final_design_signed_date, pd.financial_agreement_signed_date, pd.utility_bill_verified_date, pd.first_cash_payment_paid_date, financier
            order by customer_name
        ) as sub_rows;

END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100
ROWS 1000;
