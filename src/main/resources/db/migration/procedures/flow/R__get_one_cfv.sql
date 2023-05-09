drop function if exists flow.get_one_cfv(bigint,bigint,bigint);
CREATE OR REPLACE FUNCTION flow.get_one_cfv(p_object_type_id bigint,
                                            p_cfga_id bigint,
                                            p_primary_id bigint)
  RETURNS TABLE
          (
            custom_field_group_assignment_id bigint,
            data_type_id                     bigint,
            field_name                       VARCHAR,
            date_value                       VARCHAR,
            timestamp_value                  VARCHAR,
            boolean_value                    boolean,
            text_value                       VARCHAR,
            numeric_value                    numeric,
            int_value                        bigint,
            int_array_value                  bigint[],
            rich_text_value                  VARCHAR,
            int_value_as_text varchar,
            int_array_value_as_text varchar
          )
AS
$BODY$
declare
  v_field_saved             boolean;
  v_existing_id             bigint;
  v_date_value_to_save      text;
  v_project_process_step_id bigint;
  v_data_type_id            bigint;
  v_request_is_valid        boolean;
  v_existing_value          text;
BEGIN

--todo: write for other object types as needed

  -- 6 = events.
  if p_object_type_id = 6 then


  end if;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
