drop function if exists flow.project_audit();
CREATE OR REPLACE FUNCTION flow.project_audit()
  RETURNS TRIGGER AS
$$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    insert into flow.project_custom_field_value_audit(project_custom_field_value_id, old_value, new_value,
                                                      date_modified, modified_by_id)
    values (new.id, null, case
                            when new.date_value is not null then new.date_value::text
                            when new.timestamp_value is not null then new.timestamp_value::text
                            when new.rich_text_value is not null then new.rich_text_value
                            when new.text_value is not null then new.text_value
                            when new.numeric_value is not null then new.numeric_value::text
                            when new.int_value is not null then new.int_value::text
                            when new.int_array_value is not null then new.int_array_value::text
                            when new.boolean_value is not null then new.boolean_value::text end,
            now(),
            new.modified_by_id);
  elsif (TG_OP = 'UPDATE') THEN
    insert into flow.project_custom_field_value_audit(project_custom_field_value_id, old_value, new_value,
                                                      date_modified, modified_by_id)
    values (old.id, case
                      when old.date_value is not null then old.date_value::text
                      when old.timestamp_value is not null then old.timestamp_value::text
                      when old.rich_text_value is not null then old.rich_text_value
                      when old.text_value is not null then old.text_value
                      when old.numeric_value is not null then old.numeric_value::text
                      when old.int_value is not null then old.int_value::text
                      when old.int_array_value is not null then old.int_array_value::text
                      when old.boolean_value is not null then old.boolean_value::text end,
            case
              when new.date_value is not null then new.date_value::text
              when new.timestamp_value is not null then new.timestamp_value::text
              when new.rich_text_value is not null then new.rich_text_value
              when new.text_value is not null then new.text_value
              when new.numeric_value is not null then new.numeric_value::text
              when new.int_value is not null then new.int_value::text
              when new.int_array_value is not null then new.int_array_value::text
              when new.boolean_value is not null then new.boolean_value::text end,
            now(),
            new.modified_by_id);
  ELSIF (TG_OP = 'DELETE') THEN
    insert into flow.project_custom_field_value_audit(project_custom_field_value_id, old_value, new_value,
                                                      date_modified, modified_by_id)
    values (old.id, case
                      when old.date_value is not null then old.date_value::text
                      when old.timestamp_value is not null then old.timestamp_value::text
                      when old.rich_text_value is not null then old.rich_text_value
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
  after INSERT or update or delete
  ON flow.project_custom_field_value
  FOR EACH ROW
EXECUTE PROCEDURE flow.project_audit();

drop function if exists flow.user_audit();
CREATE OR REPLACE FUNCTION flow.user_audit()
  RETURNS TRIGGER AS
$$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    insert into flow.user_custom_field_value_audit(user_custom_field_value_id, old_value, new_value, date_modified,
                                                   modified_by_id)
    values (new.id, null, case
                            when new.date_value is not null then new.date_value::text
                            when new.timestamp_value is not null then new.timestamp_value::text
                            when new.rich_text_value is not null then new.rich_text_value
                            when new.text_value is not null then new.text_value
                            when new.numeric_value is not null then new.numeric_value::text
                            when new.int_value is not null then new.int_value::text
                            when new.int_array_value is not null then new.int_array_value::text
                            when new.boolean_value is not null then new.boolean_value::text end,
            now(),
            new.modified_by_id);
  elsif (TG_OP = 'UPDATE') THEN
    insert into flow.user_custom_field_value_audit(user_custom_field_value_id, old_value, new_value, date_modified,
                                                   modified_by_id)
    values (old.id, case
                      when old.date_value is not null then old.date_value::text
                      when old.timestamp_value is not null then old.timestamp_value::text
                      when old.rich_text_value is not null then old.rich_text_value
                      when old.text_value is not null then old.text_value
                      when old.numeric_value is not null then old.numeric_value::text
                      when old.int_value is not null then old.int_value::text
                      when old.int_array_value is not null then old.int_array_value::text
                      when old.boolean_value is not null then old.boolean_value::text end,
            case
              when new.date_value is not null then new.date_value::text
              when new.timestamp_value is not null then new.timestamp_value::text
              when new.rich_text_value is not null then new.rich_text_value
              when new.text_value is not null then new.text_value
              when new.numeric_value is not null then new.numeric_value::text
              when new.int_value is not null then new.int_value::text
              when new.int_array_value is not null then new.int_array_value::text
              when new.boolean_value is not null then new.boolean_value::text end,
            now(),
            new.modified_by_id);
  ELSIF (TG_OP = 'DELETE') THEN
    insert into flow.user_custom_field_value_audit(user_custom_field_value_id, old_value, new_value, date_modified,
                                                   modified_by_id)
    values (old.id, case
                      when old.date_value is not null then old.date_value::text
                      when old.timestamp_value is not null then old.timestamp_value::text
                      when old.rich_text_value is not null then old.rich_text_value
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
  after INSERT or update or delete
  ON flow.user_custom_field_value
  FOR EACH ROW
EXECUTE PROCEDURE flow.user_audit();

drop function if exists flow.contact_audit();
CREATE OR REPLACE FUNCTION flow.contact_audit()
  RETURNS TRIGGER AS
$$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    insert into flow.contact_custom_field_value_audit(contact_custom_field_value_id, old_value, new_value,
                                                      date_modified, modified_by_id)
    values (new.id, null, case
                            when new.date_value is not null then new.date_value::text
                            when new.timestamp_value is not null then new.timestamp_value::text
                            when new.rich_text_value is not null then new.rich_text_value
                            when new.text_value is not null then new.text_value
                            when new.numeric_value is not null then new.numeric_value::text
                            when new.int_value is not null then new.int_value::text
                            when new.int_array_value is not null then new.int_array_value::text
                            when new.boolean_value is not null then new.boolean_value::text end,
            now(),
            new.modified_by_id);
  elsif (TG_OP = 'UPDATE') THEN
    insert into flow.contact_custom_field_value_audit(contact_custom_field_value_id, old_value, new_value,
                                                      date_modified, modified_by_id)
    values (old.id, case
                      when old.date_value is not null then old.date_value::text
                      when old.timestamp_value is not null then old.timestamp_value::text
                      when old.rich_text_value is not null then old.rich_text_value
                      when old.text_value is not null then old.text_value
                      when old.numeric_value is not null then old.numeric_value::text
                      when old.int_value is not null then old.int_value::text
                      when old.int_array_value is not null then old.int_array_value::text
                      when old.boolean_value is not null then old.boolean_value::text end,
            case
              when new.date_value is not null then new.date_value::text
              when new.timestamp_value is not null then new.timestamp_value::text
              when new.rich_text_value is not null then new.rich_text_value
              when new.text_value is not null then new.text_value
              when new.numeric_value is not null then new.numeric_value::text
              when new.int_value is not null then new.int_value::text
              when new.int_array_value is not null then new.int_array_value::text
              when new.boolean_value is not null then new.boolean_value::text end,
            now(),
            new.modified_by_id);
  ELSIF (TG_OP = 'DELETE') THEN
    insert into flow.contact_custom_field_value_audit(contact_custom_field_value_id, old_value, new_value,
                                                      date_modified, modified_by_id)
    values (old.id, case
                      when old.date_value is not null then old.date_value::text
                      when old.timestamp_value is not null then old.timestamp_value::text
                      when old.rich_text_value is not null then old.rich_text_value
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
  after INSERT or update or delete
  ON flow.contact_custom_field_value
  FOR EACH ROW
EXECUTE PROCEDURE flow.contact_audit();

drop function if exists flow.organization_audit();
CREATE OR REPLACE FUNCTION flow.organization_audit()
  RETURNS TRIGGER AS
$$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    insert into flow.organization_custom_field_value_audit(organization_custom_field_value_id, old_value, new_value,
                                                           date_modified, modified_by_id)
    values (new.id, null, case
                            when new.date_value is not null then new.date_value::text
                            when new.timestamp_value is not null then new.timestamp_value::text
                            when new.rich_text_value is not null then new.rich_text_value
                            when new.text_value is not null then new.text_value
                            when new.numeric_value is not null then new.numeric_value::text
                            when new.int_value is not null then new.int_value::text
                            when new.int_array_value is not null then new.int_array_value::text
                            when new.boolean_value is not null then new.boolean_value::text end,
            now(),
            new.modified_by_id);
  elsif (TG_OP = 'UPDATE') THEN
    insert into flow.organization_custom_field_value_audit(organization_custom_field_value_id, old_value, new_value,
                                                           date_modified, modified_by_id)
    values (old.id, case
                      when old.date_value is not null then old.date_value::text
                      when old.timestamp_value is not null then old.timestamp_value::text
                      when old.rich_text_value is not null then old.rich_text_value
                      when old.text_value is not null then old.text_value
                      when old.numeric_value is not null then old.numeric_value::text
                      when old.int_value is not null then old.int_value::text
                      when old.int_array_value is not null then old.int_array_value::text
                      when old.boolean_value is not null then old.boolean_value::text end,
            case
              when new.date_value is not null then new.date_value::text
              when new.timestamp_value is not null then new.timestamp_value::text
              when new.rich_text_value is not null then new.rich_text_value
              when new.text_value is not null then new.text_value
              when new.numeric_value is not null then new.numeric_value::text
              when new.int_value is not null then new.int_value::text
              when new.int_array_value is not null then new.int_array_value::text
              when new.boolean_value is not null then new.boolean_value::text end,
            now(),
            new.modified_by_id);
  ELSIF (TG_OP = 'DELETE') THEN
    insert into flow.organization_custom_field_value_audit(organization_custom_field_value_id, old_value, new_value,
                                                           date_modified, modified_by_id)
    values (old.id, case
                      when old.date_value is not null then old.date_value::text
                      when old.timestamp_value is not null then old.timestamp_value::text
                      when old.rich_text_value is not null then old.rich_text_value
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
  after INSERT or update or delete
  ON flow.organization_custom_field_value
  FOR EACH ROW
EXECUTE PROCEDURE flow.organization_audit();


drop function if exists flow.project_process_step_audit();
CREATE OR REPLACE FUNCTION flow.project_process_step_audit()
  RETURNS TRIGGER AS
$$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    insert into flow.project_process_step_custom_field_value_audit(project_process_step_custom_field_value_id,
                                                                   old_value, new_value, date_modified, modified_by_id)
    values (new.id, null, case
                            when new.date_value is not null then new.date_value::text
                            when new.timestamp_value is not null then new.timestamp_value::text
                            when new.rich_text_value is not null then new.rich_text_value
                            when new.text_value is not null then new.text_value
                            when new.numeric_value is not null then new.numeric_value::text
                            when new.int_value is not null then new.int_value::text
                            when new.int_array_value is not null then new.int_array_value::text
                            when new.boolean_value is not null then new.boolean_value::text
                            when new.json_value is not null then new.json_value::text end,
            now(),
            new.modified_by_id);
  elsif (TG_OP = 'UPDATE') THEN
    insert into flow.project_process_step_custom_field_value_audit(project_process_step_custom_field_value_id,
                                                                   old_value, new_value, date_modified, modified_by_id)
    values (old.id, case
                      when old.date_value is not null then old.date_value::text
                      when old.timestamp_value is not null then old.timestamp_value::text
                      when old.rich_text_value is not null then old.rich_text_value
                      when old.text_value is not null then old.text_value
                      when old.numeric_value is not null then old.numeric_value::text
                      when old.int_value is not null then old.int_value::text
                      when old.int_array_value is not null then old.int_array_value::text
                      when old.boolean_value is not null then old.boolean_value::text
                      when old.json_value is not null then old.json_value::text end,
            case
              when new.date_value is not null then new.date_value::text
              when new.timestamp_value is not null then new.timestamp_value::text
              when new.rich_text_value is not null then new.rich_text_value
              when new.text_value is not null then new.text_value
              when new.numeric_value is not null then new.numeric_value::text
              when new.int_value is not null then new.int_value::text
              when new.int_array_value is not null then new.int_array_value::text
              when new.boolean_value is not null then new.boolean_value::text
              when new.json_value is not null then new.json_value::text end,
            now(),
            new.modified_by_id);
  ELSIF (TG_OP = 'DELETE') THEN
    insert into flow.project_process_step_custom_field_value_audit(project_process_step_custom_field_value_id,
                                                                   old_value, new_value, date_modified, modified_by_id)
    values (old.id, case
                      when old.date_value is not null then old.date_value::text
                      when old.timestamp_value is not null then old.timestamp_value::text
                      when old.rich_text_value is not null then old.rich_text_value
                      when old.text_value is not null then old.text_value
                      when old.numeric_value is not null then old.numeric_value::text
                      when old.int_value is not null then old.int_value::text
                      when old.int_array_value is not null then old.int_array_value::text
                      when old.boolean_value is not null then old.boolean_value::text
                      when old.json_value is not null then old.json_value::text end,
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
  after INSERT or update or delete
  ON flow.project_process_step_custom_field_value
  FOR EACH ROW
EXECUTE PROCEDURE flow.project_process_step_audit();

drop function if exists flow.project_process_step_event_custom_field_audit();
CREATE OR REPLACE FUNCTION flow.project_process_step_event_custom_field_audit()
  RETURNS TRIGGER AS
$$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    insert into flow.project_process_step_event_custom_field_value_audit(project_process_step_event_custom_field_value_id,
                                                                         old_value,
                                                                         new_value, date_modified, modified_by_id)
    values (new.id, null, case
                            when new.date_value is not null then new.date_value::text
                            when new.timestamp_value is not null then new.timestamp_value::text
                            when new.rich_text_value is not null then new.rich_text_value
                            when new.text_value is not null then new.text_value
                            when new.numeric_value is not null then new.numeric_value::text
                            when new.int_value is not null then new.int_value::text
                            when new.int_array_value is not null then new.int_array_value::text
                            when new.boolean_value is not null then new.boolean_value::text end,
            now(),
            new.modified_by_id);
  elsif (TG_OP = 'UPDATE') THEN
    insert into flow.project_process_step_event_custom_field_value_audit(project_process_step_event_custom_field_value_id,
                                                                         old_value, new_value, date_modified,
                                                                         modified_by_id)
    values (old.id, case
                      when old.date_value is not null then old.date_value::text
                      when old.timestamp_value is not null then old.timestamp_value::text
                      when old.rich_text_value is not null then old.rich_text_value
                      when old.text_value is not null then old.text_value
                      when old.numeric_value is not null then old.numeric_value::text
                      when old.int_value is not null then old.int_value::text
                      when old.int_array_value is not null then old.int_array_value::text
                      when old.boolean_value is not null then old.boolean_value::text end,
            case
              when new.date_value is not null then new.date_value::text
              when new.timestamp_value is not null then new.timestamp_value::text
              when new.rich_text_value is not null then new.rich_text_value
              when new.text_value is not null then new.text_value
              when new.numeric_value is not null then new.numeric_value::text
              when new.int_value is not null then new.int_value::text
              when new.int_array_value is not null then new.int_array_value::text
              when new.boolean_value is not null then new.boolean_value::text end,
            now(),
            new.modified_by_id);
  ELSIF (TG_OP = 'DELETE') THEN
    insert into flow.project_process_step_event_custom_field_value_audit(project_process_step_event_custom_field_value_id,
                                                                         old_value, new_value, date_modified,
                                                                         modified_by_id)
    values (old.id, case
                      when old.date_value is not null then old.date_value::text
                      when old.timestamp_value is not null then old.timestamp_value::text
                      when old.rich_text_value is not null then old.rich_text_value
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

drop trigger if exists project_process_step_event_custom_field_value_audit_trg ON flow.project_process_step_event_custom_field_value;
CREATE TRIGGER project_process_step_event_custom_field_value_audit_trg
  after INSERT or update or delete
  ON flow.project_process_step_event_custom_field_value
  FOR EACH ROW
EXECUTE PROCEDURE flow.project_process_step_event_custom_field_audit();


drop function if exists flow.concrete_project_audit();
CREATE OR REPLACE FUNCTION flow.concrete_project_audit()
  RETURNS TRIGGER AS
$$
BEGIN

  insert into flow.project_audit(project_id, contact_id, company_process_id, project_name,
                                 date_created, date_modified, created_by_id, modified_by_id,
                                 company_project_status_type_id, user_position_id, street1, street2,
                                 city, postal_code, time_zone, latitude, longitude, company_state_id,
                                 company_country_id, cancelled_date)
  values (new.id, new.contact_id, new.company_process_id, new.project_name,
          new.date_created, new.date_modified, new.created_by_id, new.modified_by_id,
          new.company_project_status_type_id, new.user_position_id, new.street1, new.street2,
          new.city, new.postal_code, new.time_zone, new.latitude, new.longitude, new.company_state_id,
          new.company_country_id, new.cancelled_date);

  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

drop trigger if exists concrete_project_audit_trg ON flow.project;
CREATE TRIGGER concrete_project_audit_trg
  after INSERT or update
  ON flow.project
  FOR EACH ROW
EXECUTE PROCEDURE flow.concrete_project_audit();


drop function if exists flow.concrete_contact_audit();
CREATE OR REPLACE FUNCTION flow.concrete_contact_audit()
  RETURNS TRIGGER AS
$$
BEGIN
  insert into flow.contact_audit(contact_id, contact_type_id, first_name, last_name,
                                 street1, street2, city, postal_code, phone, email,
                                 prospect_status, mobile, mailing_street1, mailing_street2,
                                 mailing_city, mailing_postal_code, date_created, date_modified,
                                 created_by_id, modified_by_id, company_id, archived, title,
                                 owner_user_position_id, migrate_lead_id, company_state_id,
                                 mailing_company_state_id, company_country_id, latitude, longitude)
  values (new.id, new.contact_type_id, new.first_name, new.last_name,
          new.street1, new.street2, new.city, new.postal_code, new.phone, new.email,
          new.prospect_status, new.mobile, new.mailing_street1, new.mailing_street2,
          new.mailing_city, new.mailing_postal_code, new.date_created, new.date_modified,
          new.created_by_id, new.modified_by_id, new.company_id, new.archived, new.title,
          new.owner_user_position_id, new.migrate_lead_id, new.company_state_id,
          new.mailing_company_state_id, new.company_country_id, new.latitude, new.longitude);

  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

drop trigger if exists concrete_contact_audit_trg ON flow.contact;
CREATE TRIGGER concrete_contact_audit_trg
  after INSERT or update
  ON flow.contact
  FOR EACH ROW
EXECUTE PROCEDURE flow.concrete_contact_audit();

drop function if exists flow.concrete_user_audit();
CREATE OR REPLACE FUNCTION flow.concrete_user_audit()
  RETURNS TRIGGER AS
$$
BEGIN
  insert into flow.user_audit(user_id, first_name, last_name, email,
                              password, phone_number, created_by_id, date_created,
                              modified_by_id, date_modified, default_company_id,
                              username, archived, uuid, expiry_date)
  values (new.id, new.first_name, new.last_name, new.email,
          new.password, new.phone_number, new.created_by_id, new.date_created,
          new.modified_by_id, new.date_modified, new.default_company_id,
          new.username, new.archived, new.uuid, new.expiry_date);


  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

drop trigger if exists concrete_user_audit_trg ON flow.user;
CREATE TRIGGER concrete_user_audit_trg
  after INSERT or update
  ON flow.user
  FOR EACH ROW
EXECUTE PROCEDURE flow.concrete_user_audit();


drop function if exists flow.concrete_project_process_step_audit();
CREATE OR REPLACE FUNCTION flow.concrete_project_process_step_audit()
  RETURNS TRIGGER AS
$$
BEGIN
  insert into flow.project_process_step_audit(project_process_step_id, project_id, process_step_id,
                                              user_position_id, company_process_step_status_type_id,
                                              process_step_complete_date, date_created, date_modified,
                                              created_by_id, modified_by_id, archived, main,
                                              cancelled_date)
  values (new.id, new.project_id, new.process_step_id,
          new.user_position_id, new.company_process_step_status_type_id,
          new.process_step_complete_date, new.date_created, new.date_modified,
          new.created_by_id, new.modified_by_id, new.archived, new.main, new.cancelled_date);
  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

drop trigger if exists concrete_project_process_step_audit_trg ON flow.project_process_step;
CREATE TRIGGER concrete_project_process_step_audit_trg
  after INSERT or update
  ON flow.project_process_step
  FOR EACH ROW
EXECUTE PROCEDURE flow.concrete_project_process_step_audit();


drop function if exists flow.concrete_project_process_step_event_audit();
CREATE OR REPLACE FUNCTION flow.concrete_project_process_step_event_audit()
  RETURNS TRIGGER AS
$$
declare
  v_project_id bigint;
  v_project_process_step_id bigint;
  v_user_position_id bigint;
  v_user_id bigint;

BEGIN
  insert into flow.project_process_step_event_audit(project_process_step_event_id, project_process_step_id,
                                                    process_step_event_id, resource_id, company_event_status_type_id,
                                                    start_time, end_time, date_created, date_modified,
                                                    created_by_id, modified_by_id, archived, scheduled_date,
                                                    cancelled_date, completed_date)
  values (new.id, new.project_process_step_id,
          new.process_step_event_id, new.resource_id, new.company_event_status_type_id,
          new.start_time, new.end_time, new.date_created, new.date_modified,
          new.created_by_id, new.modified_by_id, new.archived, new.scheduled_date, new.cancelled_date,
          new.completed_date);

  if old.start_time is null and new.start_time is not null and
     old.end_time is null and new.end_time is not null and
     old.resource_id is null and new.resource_id is not null and
     new.process_step_event_id = 14 then

    select project_id,id
    into v_project_id,v_project_process_step_id
    from flow.project_process_step pps
    where pps.id = new.project_process_step_id;

    select up.id,up.user_id
    into v_user_position_id,v_user_id
    from flow.user_position up
    where up.id = new.resource_id;



      insert into brs.set_closer_appointment_audit(project_id, user_id, project_process_step_id,appointment_start_date,
                                                created_date,created_by_id, override, user_position_id, project_process_step_event_id)
      values(v_project_id,v_user_id,new.project_process_step_id,new.start_time,now(),new.created_by_id,true,v_user_position_id,new.id);
  end if;


     RETURN NULL;
END
$$
  LANGUAGE plpgsql;

drop trigger if exists concrete_project_process_step_event_audit_trg ON flow.project_process_step_event;
CREATE TRIGGER concrete_project_process_step_event_audit_trg
  after INSERT or update
  ON flow.project_process_step_event
  FOR EACH ROW
EXECUTE PROCEDURE flow.concrete_project_process_step_event_audit();


drop function if exists flow.concrete_postal_code_zone_audit();
CREATE OR REPLACE FUNCTION flow.concrete_postal_code_zone_audit()
  RETURNS TRIGGER AS
$$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    insert into flow.postal_code_zone_audit(postal_code_zone_id, company_id, zone_name, archived, date_created,
                                            date_modified, created_by_id, modified_by_id,
                                            distribution_time_frame_days, schedulable_future_days,
                                            date_zone_created)
    values (new.id, new.company_id, new.zone_name, new.archived, new.date_created,
            new.date_modified, new.created_by_id, new.modified_by_id,
            new.distribution_time_frame_days, new.schedulable_future_days,
            now());
  elsif (TG_OP = 'UPDATE') THEN
    update flow.postal_code_zone_audit
    set postal_code_zone_id          = new.id,
        company_id                   = new.company_id,
        zone_name                    = new.zone_name,
        archived                     = new.archived,
        date_created                 = new.date_created,
        date_modified                = new.date_modified,
        created_by_id                = new.created_by_id,
        modified_by_id               = new.modified_by_id,
        distribution_time_frame_days = new.distribution_time_frame_days,
        schedulable_future_days      = new.schedulable_future_days,
        date_zone_archived           = case
                                         when new.archived is true and old.archived is false then
                                           now()
                                         else date_zone_archived end
    where postal_code_zone_id = new.id;

  end if;


  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

drop trigger if exists concrete_postal_code_zone_audit_trg ON flow.postal_code_zone;
CREATE TRIGGER concrete_postal_code_zone_audit_trg
  after INSERT or update
  ON flow.postal_code_zone
  FOR EACH ROW
EXECUTE PROCEDURE flow.concrete_postal_code_zone_audit();


drop function if exists flow.concrete_postal_code_zone_user_audit();
CREATE OR REPLACE FUNCTION flow.concrete_postal_code_zone_user_audit()
  RETURNS TRIGGER AS
$$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    insert into flow.postal_code_zone_user_audit(postal_code_zone_user_id, postal_code_zone_id, archived, date_created,
                                                 date_modified, created_by_id, modified_by_id,
                                                 postal_code_zone_user_type_id, user_id, manual_allocation,
                                                 date_user_created)
    values (new.id, new.postal_code_zone_id, new.archived, new.date_created,
            new.date_modified, new.created_by_id, new.modified_by_id,
            new.postal_code_zone_user_type_id, new.user_id, new.manual_allocation,
            now());
  elsif (TG_OP = 'UPDATE') THEN
    update flow.postal_code_zone_user_audit
    set postal_code_zone_id           = new.postal_code_zone_id,
        archived                      = new.archived,
        date_created                  = new.date_created,
        date_modified                 = new.date_modified,
        created_by_id                 = new.created_by_id,
        modified_by_id                = new.modified_by_id,
        postal_code_zone_user_type_id = new.postal_code_zone_user_type_id,
        user_id                       = new.user_id,
        manual_allocation             = new.manual_allocation,
        date_user_archived            = case
                                          when new.archived is true and old.archived is false then
                                            now()
                                          else date_user_archived end
    where postal_code_zone_user_id = new.id;
  end if;
  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

drop trigger if exists concrete_postal_code_zone_user_audit_trg ON flow.postal_code_zone_user;
CREATE TRIGGER concrete_postal_code_zone_user_audit_trg
  after INSERT or update
  ON flow.postal_code_zone_user
  FOR EACH ROW
EXECUTE PROCEDURE flow.concrete_postal_code_zone_user_audit();
