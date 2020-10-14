CREATE OR REPLACE FUNCTION flow.project_audit()
    RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        insert into flow.project_custom_field_value_audit(project_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(new.id,null,case when new.date_value is not null then new.date_value::text
                                when new.timestamp_value is not null then new.timestamp_value::text
                                when new.text_value is not null then new.text_value
                                when new.numeric_value is not null then new.numeric_value::text
                                when new.int_value is not null then new.int_value::text
                                when new.int_array_value is not null then new.int_array_value::text
                                when new.boolean_value is not null then new.boolean_value::text end,
               now(),
               new.modified_by_id);
    elsif (TG_OP = 'UPDATE') THEN
        insert into flow.project_custom_field_value_audit(project_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(old.id,case when old.date_value is not null then old.date_value::text
                           when old.timestamp_value is not null then old.timestamp_value::text
                           when old.text_value is not null then old.text_value
                           when old.numeric_value is not null then old.numeric_value::text
                           when old.int_value is not null then old.int_value::text
                           when old.int_array_value is not null then old.int_array_value::text
                           when old.boolean_value is not null then old.boolean_value::text end,
               case when new.date_value is not null then new.date_value::text
                    when new.timestamp_value is not null then new.timestamp_value::text
                    when new.text_value is not null then new.text_value
                    when new.numeric_value is not null then new.numeric_value::text
                    when new.int_value is not null then new.int_value::text
                    when new.int_array_value is not null then new.int_array_value::text
                    when new.boolean_value is not null then new.boolean_value::text end,
               now(),
               new.modified_by_id);
    ELSIF (TG_OP = 'DELETE') THEN
        insert into flow.project_custom_field_value_audit(project_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(old.id,case when old.date_value is not null then old.date_value::text
                           when old.timestamp_value is not null then old.timestamp_value::text
                           when old.text_value is not null then old.text_value
                           when old.numeric_value is not null then old.numeric_value::text
                           when old.int_value is not null then old.int_value::text
                           when old.int_array_value is not null then old.int_array_value::text
                           when old.boolean_value is not null then old.boolean_value::text end,
               null,
               now(),
               new.modified_by_id);
    end if;

    RETURN NULL;
END
$$
    LANGUAGE plpgsql;


drop trigger if exists project_audit_trg ON flow.project_custom_field_value;
CREATE TRIGGER project_audit_trg
    after INSERT or update or delete ON flow.project_custom_field_value
    FOR EACH ROW EXECUTE PROCEDURE flow.project_audit();


CREATE OR REPLACE FUNCTION flow.user_audit()
    RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        insert into flow.user_custom_field_value_audit(user_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(new.id,null,case when new.date_value is not null then new.date_value::text
                                when new.timestamp_value is not null then new.timestamp_value::text
                                when new.text_value is not null then new.text_value
                                when new.numeric_value is not null then new.numeric_value::text
                                when new.int_value is not null then new.int_value::text
                                when new.int_array_value is not null then new.int_array_value::text
                                when new.boolean_value is not null then new.boolean_value::text end,
               now(),
               new.modified_by_id);
    elsif (TG_OP = 'UPDATE') THEN
        insert into flow.user_custom_field_value_audit(user_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(old.id,case when old.date_value is not null then old.date_value::text
                           when old.timestamp_value is not null then old.timestamp_value::text
                           when old.text_value is not null then old.text_value
                           when old.numeric_value is not null then old.numeric_value::text
                           when old.int_value is not null then old.int_value::text
                           when old.int_array_value is not null then old.int_array_value::text
                           when old.boolean_value is not null then old.boolean_value::text end,
               case when new.date_value is not null then new.date_value::text
                    when new.timestamp_value is not null then new.timestamp_value::text
                    when new.text_value is not null then new.text_value
                    when new.numeric_value is not null then new.numeric_value::text
                    when new.int_value is not null then new.int_value::text
                    when new.int_array_value is not null then new.int_array_value::text
                    when new.boolean_value is not null then new.boolean_value::text end,
               now(),
               new.modified_by_id);
    ELSIF (TG_OP = 'DELETE') THEN
        insert into flow.user_custom_field_value_audit(user_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(old.id,case when old.date_value is not null then old.date_value::text
                           when old.timestamp_value is not null then old.timestamp_value::text
                           when old.text_value is not null then old.text_value
                           when old.numeric_value is not null then old.numeric_value::text
                           when old.int_value is not null then old.int_value::text
                           when old.int_array_value is not null then old.int_array_value::text
                           when old.boolean_value is not null then old.boolean_value::text end,
               null,
               now(),
               new.modified_by_id);
    end if;

    RETURN NULL;
END
$$
    LANGUAGE plpgsql;

drop trigger if exists user_audit_trg ON flow.user_custom_field_value;
CREATE TRIGGER user_audit_trg
    after INSERT or update or delete ON flow.user_custom_field_value
    FOR EACH ROW EXECUTE PROCEDURE flow.user_audit();


CREATE OR REPLACE FUNCTION flow.contact_audit()
    RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        insert into flow.contact_custom_field_value_audit(contact_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(new.id,null,case when new.date_value is not null then new.date_value::text
                                when new.timestamp_value is not null then new.timestamp_value::text
                                when new.text_value is not null then new.text_value
                                when new.numeric_value is not null then new.numeric_value::text
                                when new.int_value is not null then new.int_value::text
                                when new.int_array_value is not null then new.int_array_value::text
                                when new.boolean_value is not null then new.boolean_value::text end,
               now(),
               new.modified_by_id);
    elsif (TG_OP = 'UPDATE') THEN
        insert into flow.contact_custom_field_value_audit(contact_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(old.id,case when old.date_value is not null then old.date_value::text
                           when old.timestamp_value is not null then old.timestamp_value::text
                           when old.text_value is not null then old.text_value
                           when old.numeric_value is not null then old.numeric_value::text
                           when old.int_value is not null then old.int_value::text
                           when old.int_array_value is not null then old.int_array_value::text
                           when old.boolean_value is not null then old.boolean_value::text end,
               case when new.date_value is not null then new.date_value::text
                    when new.timestamp_value is not null then new.timestamp_value::text
                    when new.text_value is not null then new.text_value
                    when new.numeric_value is not null then new.numeric_value::text
                    when new.int_value is not null then new.int_value::text
                    when new.int_array_value is not null then new.int_array_value::text
                    when new.boolean_value is not null then new.boolean_value::text end,
               now(),
               new.modified_by_id);
    ELSIF (TG_OP = 'DELETE') THEN
        insert into flow.contact_custom_field_value_audit(contact_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(old.id,case when old.date_value is not null then old.date_value::text
                           when old.timestamp_value is not null then old.timestamp_value::text
                           when old.text_value is not null then old.text_value
                           when old.numeric_value is not null then old.numeric_value::text
                           when old.int_value is not null then old.int_value::text
                           when old.int_array_value is not null then old.int_array_value::text
                           when old.boolean_value is not null then old.boolean_value::text end,
               null,
               now(),
               new.modified_by_id);
    end if;

    RETURN NULL;
END
$$
    LANGUAGE plpgsql;

drop trigger if exists contact_audit_trg ON flow.contact_custom_field_value;
CREATE TRIGGER contact_audit_trg
    after INSERT or update or delete ON flow.contact_custom_field_value
    FOR EACH ROW EXECUTE PROCEDURE flow.contact_audit();


CREATE OR REPLACE FUNCTION flow.organization_audit()
    RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        insert into flow.organization_custom_field_value_audit(organization_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(new.id,null,case when new.date_value is not null then new.date_value::text
                                when new.timestamp_value is not null then new.timestamp_value::text
                                when new.text_value is not null then new.text_value
                                when new.numeric_value is not null then new.numeric_value::text
                                when new.int_value is not null then new.int_value::text
                                when new.int_array_value is not null then new.int_array_value::text
                                when new.boolean_value is not null then new.boolean_value::text end,
               now(),
               new.modified_by_id);
    elsif (TG_OP = 'UPDATE') THEN
        insert into flow.organization_custom_field_value_audit(organization_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(old.id,case when old.date_value is not null then old.date_value::text
                           when old.timestamp_value is not null then old.timestamp_value::text
                           when old.text_value is not null then old.text_value
                           when old.numeric_value is not null then old.numeric_value::text
                           when old.int_value is not null then old.int_value::text
                           when old.int_array_value is not null then old.int_array_value::text
                           when old.boolean_value is not null then old.boolean_value::text end,
               case when new.date_value is not null then new.date_value::text
                    when new.timestamp_value is not null then new.timestamp_value::text
                    when new.text_value is not null then new.text_value
                    when new.numeric_value is not null then new.numeric_value::text
                    when new.int_value is not null then new.int_value::text
                    when new.int_array_value is not null then new.int_array_value::text
                    when new.boolean_value is not null then new.boolean_value::text end,
               now(),
               new.modified_by_id);
    ELSIF (TG_OP = 'DELETE') THEN
        insert into flow.organization_custom_field_value_audit(organization_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(old.id,case when old.date_value is not null then old.date_value::text
                           when old.timestamp_value is not null then old.timestamp_value::text
                           when old.text_value is not null then old.text_value
                           when old.numeric_value is not null then old.numeric_value::text
                           when old.int_value is not null then old.int_value::text
                           when old.int_array_value is not null then old.int_array_value::text
                           when old.boolean_value is not null then old.boolean_value::text end,
               null,
               now(),
               new.modified_by_id);
    end if;

    RETURN NULL;
END
$$
    LANGUAGE plpgsql;

drop trigger if exists organization_audit_trg ON flow.organization_custom_field_value;
CREATE TRIGGER organization_audit_trg
    after INSERT or update or delete ON flow.organization_custom_field_value
    FOR EACH ROW EXECUTE PROCEDURE flow.organization_audit();



CREATE OR REPLACE FUNCTION flow.project_process_step_audit()
    RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        insert into flow.project_process_step_custom_field_value_audit(project_process_step_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(new.id,null,case when new.date_value is not null then new.date_value::text
                                when new.timestamp_value is not null then new.timestamp_value::text
                                when new.text_value is not null then new.text_value
                                when new.numeric_value is not null then new.numeric_value::text
                                when new.int_value is not null then new.int_value::text
                                when new.int_array_value is not null then new.int_array_value::text
                                when new.boolean_value is not null then new.boolean_value::text end,
               now(),
               new.modified_by_id);
    elsif (TG_OP = 'UPDATE') THEN
        insert into flow.project_process_step_custom_field_value_audit(project_process_step_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(old.id,case when old.date_value is not null then old.date_value::text
                           when old.timestamp_value is not null then old.timestamp_value::text
                           when old.text_value is not null then old.text_value
                           when old.numeric_value is not null then old.numeric_value::text
                           when old.int_value is not null then old.int_value::text
                           when old.int_array_value is not null then old.int_array_value::text
                           when old.boolean_value is not null then old.boolean_value::text end,
               case when new.date_value is not null then new.date_value::text
                    when new.timestamp_value is not null then new.timestamp_value::text
                    when new.text_value is not null then new.text_value
                    when new.numeric_value is not null then new.numeric_value::text
                    when new.int_value is not null then new.int_value::text
                    when new.int_array_value is not null then new.int_array_value::text
                    when new.boolean_value is not null then new.boolean_value::text end,
               now(),
               new.modified_by_id);
    ELSIF (TG_OP = 'DELETE') THEN
        insert into flow.project_process_step_custom_field_value_audit(project_process_step_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(old.id,case when old.date_value is not null then old.date_value::text
                           when old.timestamp_value is not null then old.timestamp_value::text
                           when old.text_value is not null then old.text_value
                           when old.numeric_value is not null then old.numeric_value::text
                           when old.int_value is not null then old.int_value::text
                           when old.int_array_value is not null then old.int_array_value::text
                           when old.boolean_value is not null then old.boolean_value::text end,
               null,
               now(),
               new.modified_by_id);
    end if;

    RETURN NULL;
END
$$
    LANGUAGE plpgsql;

drop trigger if exists project_process_step_audit_trg ON flow.project_process_step_custom_field_value;
CREATE TRIGGER project_process_step_audit_trg
    after INSERT or update or delete ON flow.project_process_step_custom_field_value
    FOR EACH ROW EXECUTE PROCEDURE flow.project_process_step_audit();

