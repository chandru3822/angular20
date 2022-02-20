CREATE OR REPLACE function flow.migrate_fields_to_group(p_to_custom_field_group_id integer,
                                                       p_custom_field_group_assignment_id integer,
                                                        p_field_order integer)
  returns void as
$$
BEGIN
    update flow.custom_field_group_assignment
    set custom_field_group_id = p_to_custom_field_group_id,
        field_order = p_field_order
    where id = p_custom_field_group_assignment_id;

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

