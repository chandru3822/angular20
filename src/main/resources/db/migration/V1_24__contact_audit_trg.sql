drop trigger if exists customer_audit_trg on flow.contact_custom_field_value;
drop function if exists flow.customer_audit();

create or replace function flow.contact_audit_trg() returns trigger
    language plpgsql
as $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        insert into flow.contact_custom_field_value_audit(contact_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(new.id,null,case when new.date_value is not null then new.date_value::text
                                when new.timestamp_value is not null then new.timestamp_value::text
                                when new.boolean_value is not null then new.boolean_value::text
                                when new.text_value is not null then new.text_value
                                when new.numeric_value is not null then new.numeric_value::text
                                when new.int_value is not null then new.int_value::text
                                when new.int_array_value is not null then new.int_array_value::text end,
               now(),
               new.modified_by_id);
    elsif (TG_OP = 'UPDATE') THEN
        insert into flow.contact_custom_field_value_audit(contact_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(old.id,case when old.date_value is not null then old.date_value::text
                           when old.timestamp_value is not null then old.timestamp_value::text
                           when old.boolean_value is not null then old.boolean_value::text
                           when old.text_value is not null then old.text_value
                           when old.numeric_value is not null then old.numeric_value::text
                           when old.int_value is not null then old.int_value::text
                           when old.int_array_value is not null then old.int_array_value::text end,
               case when new.date_value is not null then new.date_value::text
                    when new.timestamp_value is not null then new.timestamp_value::text
                    when new.boolean_value is not null then new.boolean_value::text
                    when new.text_value is not null then new.text_value
                    when new.numeric_value is not null then new.numeric_value::text
                    when new.int_value is not null then new.int_value::text
                    when new.int_array_value is not null then new.int_array_value::text end,
               now(),
               new.modified_by_id);
    ELSIF (TG_OP = 'DELETE') THEN
        insert into flow.contact_custom_field_value_audit(contact_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(old.id,case when old.date_value is not null then old.date_value::text
                           when old.timestamp_value is not null then old.timestamp_value::text
                           when old.boolean_value is not null then old.boolean_value::text
                           when old.text_value is not null then old.text_value
                           when old.numeric_value is not null then old.numeric_value::text
                           when old.int_value is not null then old.int_value::text
                           when old.int_array_value is not null then old.int_array_value::text end,
               null,
               now(),
               new.modified_by_id);
    end if;

    RETURN NULL;
END
$$;

drop trigger if exists contact_audit_trg on flow.user_asset;

create trigger contact_audit_trg
after insert or update or delete on flow.contact_custom_field_value
for each row execute procedure flow.contact_audit_trg();