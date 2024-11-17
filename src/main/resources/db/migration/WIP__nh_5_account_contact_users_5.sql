SET session_replication_role = replica;

DO
$do$
  declare
    x        record;
    y        record;
    v_new_user_id        int;
  BEGIN
    for x in select o.nh_migration_id, o.id as org_id
             from flow.org o
             where nh_migration_id is not null
      loop
            for y in select sc.*
                     from brs.account_contact_relation acr
                              inner join brs.sp_contact sc on sc.id = acr.contact_id
                     where acr.account_id = x.nh_migration_id
                loop
                    v_new_user_id = null;
                    insert into flow."user"(first_name, last_name,email, nh_migration_id,  password, phone_number, created_by_id, modified_by_id, username, uuid, expiry_date, phone_extension)
                    values(y.first_name, y.last_name, y.email, array[y.id], (with password as (select public.crypt('solar321', public.gen_salt('bf', 10)) as value)
                                                                select *
                                                                from password), y.phone, 2417170, 2417170, y.email, null, null, null)
                    returning id into v_new_user_id;

                    insert into flow.user_company(company_id, user_id, modified_by_id, is_default)
                    values(3, v_new_user_id, 2417170, true);

                    insert into flow.company_user_status(user_id, user_status_type_id, created_by_id, modified_by_id)
                    values(v_new_user_id, 9, 2417170, 2417170);

                    insert into flow.user_position(user_id, position_id, start_date, end_date, org_id, primary_flag, created_by_id, modified_by_id)
                    values(v_new_user_id, 809, current_date::date, null, x.org_id, true, 2417170, 2417170);
                end loop;

      end loop;
  end
$do$;


SET session_replication_role = default;



