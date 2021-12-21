-- DROP FUNCTION brs.get_setters_by_setter_mgr_office(integer);

-- SELECT * FROM brs.get_setters_by_setter_mgr_office(717);

CREATE OR REPLACE FUNCTION brs.get_setters_by_setter_mgr_office(p_office_id integer)
    RETURNS integer[] AS
$BODY$
DECLARE
    v_setter_ids integer[];

BEGIN

    SELECT array_agg(user_id)
    INTO v_setter_ids
    FROM flow.user_position
    WHERE org_id = p_office_id
        AND primary_flag IS TRUE
        AND position_id in (select unnest(string_to_array(value, ',')::int[])
                            from flow.company_configuration_value
                            where code = 'SETTER_POSITION_IDS');

    RETURN v_setter_ids;

END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
