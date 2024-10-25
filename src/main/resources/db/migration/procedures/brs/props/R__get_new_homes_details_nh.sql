DROP FUNCTION IF EXISTS brs.get_new_homes_details_nh(p_proposal_id bigint);
CREATE OR REPLACE FUNCTION brs.get_new_homes_details_nh(p_proposal_id bigint)
  returns table
          (
            proposal_id                    bigint,
            version_id                     bigint,
            project_process_step_id        bigint,
            project_id                     bigint,
            contact_first_name             varchar,
            contact_last_name              varchar,
            project_name                   varchar,
            project_street1                varchar,
            project_street2                varchar,
            city                           varchar,
            postal_code                    varchar,
            project_state                  varchar,
            project_state_abbrev           varchar,
            contact_phone                  varchar,
            contact_email                  varchar,
            proposal_nbr                   bigint,
            first_year_production_estimate bigint,
            system_size                    numeric,
            state_id                       bigint,
            aurora_design_summary          jsonb,
            aurora_design_id               text,
            company_process_id             bigint,
            nh_cash_price                  bigint
          )

AS
$BODY$
declare

BEGIN
  return query
    select prop.id        as proposal_id,
           proposal_version_id,
           prop.project_process_step_id,
           p.id           as project_id,
           c.first_name,
           c.last_name,
           p.project_name,
           p.street1,
           p.street2,
           p.city,
           p.postal_code,
           s.state,
           s.abbreviation as state_abbreviation,
           c.mobile,
           c.email,
           prop.proposal_nbr::bigint,
           ppscfv31.int_value,
           ppscfv32.numeric_value,
           cs.state_id,
           ppscfv36.json_value,
           ppscfv41.text_value,
           p.company_process_id,
           pcfv60.int_value
    from brs.proposal prop
           inner join flow.project_process_step pps on prop.project_process_step_id = pps.id
           inner join flow.project p on pps.project_id = p.id
           inner join brs.new_homes_details nhd  on nhd.project_id = p.id
           inner join flow.contact c on p.contact_id = c.id
           inner join flow.company_state cs on p.company_state_id = cs.id
           inner join flow.state s on cs.state_id = s.id
           left join brs.proposal_custom_field_value pcfv60 on prop.id = pcfv60.proposal_id and
                        pcfv60.custom_field_group_assignment_id = 1305
           left join flow.project_process_step_custom_field_value ppscfv31
                     on ppscfv31.project_process_step_id = pps.id and
                        ppscfv31.custom_field_group_assignment_id = 22563
           left join flow.project_process_step_custom_field_value ppscfv32
                     on ppscfv32.project_process_step_id = pps.id and
                        ppscfv32.custom_field_group_assignment_id = 22561
           left join flow.project_process_step_custom_field_value ppscfv36
                     on ppscfv36.project_process_step_id = pps.id and
                        ppscfv36.custom_field_group_assignment_id = 22682
           left join flow.project_process_step_custom_field_value ppscfv41
                     on ppscfv41.project_process_step_id = pps.id and
                        ppscfv41.custom_field_group_assignment_id = 22560
    where prop.id = p_proposal_id;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
