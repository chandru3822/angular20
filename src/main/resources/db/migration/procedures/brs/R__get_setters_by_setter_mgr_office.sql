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
    FROM flow.user_positions_vw
    WHERE org_id = p_office_id
        AND position_id = 4;

    RETURN v_setter_ids;

END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
