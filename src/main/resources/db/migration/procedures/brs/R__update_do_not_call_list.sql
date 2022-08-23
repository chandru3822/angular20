drop function if exists brs.update_do_not_call_list(phonenumbers character varying[]);
create or replace function brs.update_do_not_call_list(phonenumbers character varying[]) returns void
  language plpgsql
as
$$
DECLARE
  num VARCHAR;
BEGIN
  foreach num in array phoneNumbers
    LOOP
      update flow.contact_custom_field_value set int_value = 19595, modified_by_id = 99999999, date_modified = now()
      where contact_id in
            (select c.id from flow.contact c
             where regexp_replace(c.phone, '[^0-9]', '', 'g') ILIKE '%' || num
                or regexp_replace(c.mobile, '[^0-9]', '', 'g') ILIKE '%' || num)
        and custom_field_group_assignment_id = 399;
    END LOOP;
END;
$$;
