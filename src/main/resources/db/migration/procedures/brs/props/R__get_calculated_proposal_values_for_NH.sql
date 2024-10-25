drop function if exists brs.get_calculated_proposal_values_nh(bigint, boolean);
drop type if exists brs.calculated_proposal_value_nh cascade;

create type brs.calculated_proposal_value_nh as
(
  proposal_id                    bigint,
  project_id                     bigint,
  version_id                     bigint,
  project_process_step_id        bigint,
  first_year_production_estimate bigint,
  contact_first_name             character varying,
  contact_last_name              character varying,
  contact_phone                  character varying,
  contact_email                  character varying,
  project_name                   character varying,
  project_street1                character varying,
  project_street2                character varying,
  city                           character varying,
  postal_code                    character varying,
  project_state                  character varying,
  project_state_abbrev           character varying,
  nh_cash_price                  numeric,
  estimated_down_payment         numeric,
  estimated_itc                  numeric,
  net_system_cost                numeric,
  system_size                    numeric,
  proposal_nbr                   bigint
);

-- drop type brs.excluded_proposal_value_nh;
-- create type brs.excluded_proposal_value_nh as
-- (
-- );

CREATE OR REPLACE FUNCTION brs.get_calculated_proposal_values_nh(
  p_proposal_id bigint,
  p_insert_prop_log_history boolean default false
)

  RETURNS TABLE
          (
            "like" brs.calculated_proposal_value_nh
          )
AS
$BODY$
declare
  v_proposal_id                    bigint;
  v_project_id                     bigint;
  v_version_id                     bigint;
  v_project_process_step_id        bigint;
  v_first_year_production_estimate bigint;
  v_contact_first_name             character varying;
  v_contact_last_name              character varying;
  v_contact_phone                  character varying;
  v_contact_email                  character varying;
  v_project_name                   character varying;
  v_project_street1                character varying;
  v_project_street2                character varying;
  v_city                           character varying;
  v_postal_code                    character varying;
  v_project_state                  character varying;
  v_project_state_abbrev           character varying;
  v_nh_cash_price                  numeric;
  v_estimated_down_payment         numeric;
  v_estimated_itc                  numeric;
  v_net_system_cost                numeric;
  v_system_size                    numeric;
  v_proposal_nbr                   bigint;
BEGIN

  select proposal_id,
         proposal_nbr,
         version_id,
         project_process_step_id,
         project_id,
         first_year_production_estimate,
         contact_first_name,
         contact_last_name,
         project_name,
         project_street1,
         project_street2,
         city,
         postal_code,
         project_state,
         project_state_abbrev,
         contact_phone,
         contact_email,
         nh_cash_price,
         system_size
  into v_proposal_id,
    v_proposal_nbr,
    v_version_id,
    v_project_process_step_id,
    v_project_id,
    v_first_year_production_estimate,
    v_contact_first_name,
    v_contact_last_name,
    v_project_name,
    v_project_street1,
    v_project_street2,
    v_city,
    v_postal_code,
    v_project_state,
    v_project_state_abbrev,
    v_contact_phone,
    v_contact_email,
    v_nh_cash_price,
    v_system_size
  from brs.get_new_homes_details_nh(p_proposal_id);

  v_estimated_down_payment = coalesce(v_nh_cash_price::numeric, 0) * .2::numeric;
  v_estimated_itc = coalesce(v_nh_cash_price::numeric, 0) * .3::numeric;
  v_net_system_cost =
    coalesce(v_nh_cash_price::numeric, 0) - v_estimated_down_payment::numeric - v_estimated_itc::numeric;

  if p_insert_prop_log_history is true then
    insert into brs.proposal_log_history(project_id, fullname, address, city, state, zip, phone,
                                         email,
                                         nh_down_payment,
                                         year_1_kwh_output,
                                         system_size,
                                         proposal_date, proposal_nbr, proposal_log_id,
                                         nh_cash_price,
                                         nh_net_system_cost,
                                         nh_estimated_itc)
    values (v_project_id,
            v_project_name,
            v_project_street1,
            v_city,
            v_project_state_abbrev,
            v_postal_code,
            v_contact_phone,
            v_contact_email,
            coalesce(round(v_estimated_down_payment, 0), 0),
            v_first_year_production_estimate,
            v_system_size,
            now(),
            v_proposal_nbr,
            v_proposal_id,
            coalesce(round(v_nh_cash_price, 0), 0),
            coalesce(round(v_net_system_cost, 0), 0),
            coalesce(round(v_estimated_itc, 0), 0));


  end if;

  return query
    select v_proposal_id,
           v_project_id,
           v_version_id,
           v_project_process_step_id,
           v_first_year_production_estimate,
           v_contact_first_name,
           v_contact_last_name,
           v_contact_phone,
           v_contact_email,
           v_project_name,
           v_project_street1,
           v_project_street2,
           v_city,
           v_postal_code,
           v_project_state,
           v_project_state_abbrev,
           v_nh_cash_price,
           v_estimated_down_payment,
           v_estimated_itc,
           v_net_system_cost,
           v_system_size,
           v_proposal_nbr;




END
$BODY$ LANGUAGE plpgsql VOLATILE
                        COST 100;
