-- DROP FUNCTION brs.get_setters_by_setter_mgr_office(bigint);

-- SELECT * FROM brs.get_setters_by_setter_mgr_office(717);
drop function if exists brs.get_setters_by_setter_mgr_office(p_office_id bigint);
  CREATE OR REPLACE FUNCTION brs.get_setters_by_setter_mgr_office(p_office_id bigint)
    RETURNS bigint[] AS
$BODY$
DECLARE
    v_setter_ids bigint[];

BEGIN

    SELECT array_agg(user_id)
    INTO v_setter_ids
    FROM flow.user_position
    WHERE org_id = p_office_id
        AND primary_flag IS TRUE
        AND position_id in (select unnest(string_to_array(value, ',')::bigint[])
                            from flow.company_configuration_value
                            where code = 'SETTER_POSITION_IDS');

    RETURN v_setter_ids;

END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
