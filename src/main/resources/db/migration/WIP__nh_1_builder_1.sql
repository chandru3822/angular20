SET session_replication_role = replica;
DO
$do$
  declare
    x                        record;
    v_contact_id             bigint;
    v_object_category_id     bigint;
    v_lov_available_lender_c bigint[];
    v_total bigint;
    v_builder_contacts text;
  BEGIN
    raise notice 'Start NH Builder = %',clock_timestamp();
    select oc.id
    into v_object_category_id
    from flow.object_category oc
    where object_category_code = 'BUILDER_NEW_HOMES_BUILDER'
      and object_type_id = 2;
    v_total = 0;
    for x in select lov1.id as status_c1,
                    cs.id   as company_state_id,
                    a.cash_partner_c,
                    a.contact_name_c,
                    a.credit_check_c,
                    a.credit_limit_c,
                    a.credit_limit_date_c,
                    a.default_dealer_warehouse_shipping_site_c,
                    a.description,
                    a.i_supplier_c,
                    a.legal_business_name_c,
                    a.rlcpa_notes_c,
                    a.shipping_city,
                    a.shipping_postal_code,
                    a.shipping_state,
                    a.shipping_street,
                    a.spwr_cash_partner_c,
                    a.website,
                    a.id,
                    a.name,
                    a.last_name,
                    a.billing_street,
                    a.billing_city,
                    a.billing_postal_code,
                    a.phone,
                    a.email_c,
                    a.account_number,
                    a.available_lender_c,
                    a.owner_id,

                    case when a.account_owner_id is null and a.owner_id is not null then
                           2495780::bigint
                         else
                           a.account_owner_id end as account_owner_id,
                    concat(su.first_name,' ',su.email) as owner_id_name
             from brs.account a

                    left join brs.sp_user su on su.id = a.owner_id
                    left join flow.state s on s.abbreviation = a.billing_state
                    left join flow.company_state cs on cs.state_id = s.id and cs.company_id = 3
                    left join flow.list_of_value lov1 on lov1.name = a.status_c and lov1.parent_id = 25722
             where type = 'Builder' and a.is_deleted = false

      loop
        v_contact_id = null;
        v_total = v_total + 1;
        insert into flow.contact(contact_type_id, first_name, last_name, street1, street2, city, postal_code, phone,
                                 email, mobile, date_created, date_modified, created_by_id, modified_by_id,
                                 company_id,
                                 archived,
                                 company_state_id, company_country_id, nw_migration_id, object_category_id)
        values (1, x.name, x.LAST_NAME, x.billing_street, null, x.billing_city, x.billing_postal_code, x.phone,
                x.email_c,
                x.phone, now(), now(), 2384850, 2384850, 3, false,
                x.company_state_id, 1, x.id, v_object_category_id)
        returning id into v_contact_id;

        if v_contact_id is not null then
          v_builder_contacts = null;
          select array_to_string(
                   ARRAY_AGG(CONCAT(spc.name, ' - ', coalesce(spc.phone,spc.MOBILE_PHONE), ' - ', spc.email, ' - ', spc.title)),
                   E'\n')
            into v_builder_contacts
              from  brs.sp_contact spc
            where spc.account_id = x.id;


          perform flow.set_contact_cfv(v_contact_id, 2384850, 28812, x.account_number::text, true);
          v_lov_available_lender_c = null;
          if x.available_lender_c is not null then
            select array_agg(lov.id)
            into v_lov_available_lender_c
            from (SELECT unnest(string_to_array(aggregated_column, ';')) available_lender_c
                  FROM (SELECT STRING_AGG(available_lender_c, ';') AS aggregated_column
                        from brs.ACCOUNT A2
                        where id = x.id) AS subquery) as foo
                   inner join flow.list_of_value lov
                              on lov.name = foo.available_lender_c and lov.parent_id = 25717;
            perform flow.set_contact_cfv(v_contact_id, 2384850, 28813, v_lov_available_lender_c::text, true);
          end if;
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28814, x.cash_partner_c::text, true);
          if v_builder_contacts is not null then
            perform flow.set_contact_cfv(v_contact_id, 2384850, 30022, v_builder_contacts::text, true);
          end if;
          perform flow.set_contact_cfv(v_contact_id, 2384850, 29911, x.owner_id_name::text, true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28815, x.contact_name_c::text, true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28816, x.credit_check_c::text, true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28817, x.credit_limit_c::text, true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28818, x.credit_limit_date_c::text, true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28819,
                                       x.default_dealer_warehouse_shipping_site_c::text, true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28820, x.description::text, true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28821, x.i_supplier_c::text, true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28822, x.legal_business_name_c::text, true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28823, x.account_owner_id::text,true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28826, x.rlcpa_notes_c::text, true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28831, x.shipping_city::text, true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28832, x.shipping_postal_code::text, true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28833, x.shipping_state::text, true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28830, x.shipping_street::text, true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28827, x.spwr_cash_partner_c::text, true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28828, x.status_c1::text, true);
          perform flow.set_contact_cfv(v_contact_id, 2384850, 28829, x.website::text, true);
        end if;
      end loop;
    raise notice 'NH Builder END = %',clock_timestamp();
    raise notice 'NH Builder Total = %',v_total;
  end
$do$;
