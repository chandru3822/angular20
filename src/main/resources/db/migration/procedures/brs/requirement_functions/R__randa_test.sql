drop function if exists brs.randa_test();
CREATE OR REPLACE FUNCTION brs.randa_test()
    returns int[] AS
$BODY$
declare
    v_data_view_value text;
BEGIN

  return array[ 6756 ]::int[];

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
