package com.albatross.api.disclosureForm;

public class DisclosureFormQuery {
    //language=PostgreSQL
    public final static String getSrec = """
        select
          plh.id,
          plh.proposal_nbr as proposal_number,
          plh.project_id,
          plh.il_srec_disclosure_form_id,
          pd.contact_name,
          pd.contact_email,
          c.search_phones as contact_phone,
          pd.project_name,
          pd.project_state_abbreviation,
          pd.utility_company_name,
          plh.loan_type,
          pd.project_street1,
          pd.project_city,
          pd.project_postal_code,
          plh.system_size,
          plh.system_size_ac,
          plh.year_1_kwh_output as year_one_kwh_output,
          plh.loan_amount,
          plh.optional_down_payment,
          plh.required_down_payment,
          plh.all_rebates->>'Illinois SREC' as srec_value,
          COALESCE(plh.loan_amount::numeric + plh.optional_down_payment::numeric + plh.required_down_payment, '0') as total_cost,
          CAST(COALESCE(plh.number_of_batteries, '0') AS integer) > 0 as has_battery,
          plh.storage_size_kwh_per_battery,
          round(plh.total_yearly_usage_pre_solar::numeric / 1000, 2) as expected_annual_electricity_usage
        from brs.proposal_log_history plh
        inner join brs.project_details pd on pd.project_id = plh.project_id
        inner join flow.project p on pd.project_id = p.id
        inner join flow.contact c on p.contact_id = c.id
        where
            plh.project_id = :projectId and
            plh.proposal_nbr = :proposalNumber
    """;

    //language=PostgreSQL
    public final static String setDisclosureID = """
        update brs.proposal_log_history plh
        set il_srec_disclosure_form_id = :formID
        where
            plh.project_id = :projectID and
            plh.proposal_nbr = :propNbr
    """;

    // the prop nbr custom field is a system list w/custom sql where the prop log history ID is saved as the int_value
    //language=PostgreSQL
    public final static String getProposalNumber = """
        with prop as (
          select int_value as id
          from flow.project_process_step_custom_field_value
          where
            custom_field_group_assignment_id = :cfgaID and
            project_process_step_id = :ppsID
        )
        select plh.proposal_nbr
        from brs.proposal_log_history plh
        inner join prop on prop.id = plh.id
    """;
}

