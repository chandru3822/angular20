INSERT INTO brs.project_details_config (company_id, custom_field_group_assignment_id, field_to_update, data_type_id)
    (select 3, 7, 'closer_user_position_id', 6
     where not exists(select company_id
                      from brs.project_details_config
                      where company_id = 3
                        and custom_field_group_assignment_id = 7
                        and field_to_update = 'closer_user_position_id'
                        and data_type_id = 6));



alter table brs.project_details
    add column if not exists closer_user_position_id integer;
CREATE INDEX if not exists pd_closer_user_position_id_idx ON brs.project_details (closer_user_position_id);


CREATE TABLE if not exists brs.cached_appointment
(
    user_id           integer,
    appointment_count bigint,
    CONSTRAINT user_id_uk unique  (user_id)

);


drop FUNCTION if exists flow.set_closer_appointment( integer,
    integer,
    timestamp,
    timestamp,
    timestamp,
    integer array);

drop FUNCTION if exists flow.get_availability_time_slots( integer,
    timestamp,
    timestamp,
    date,
    boolean  );


