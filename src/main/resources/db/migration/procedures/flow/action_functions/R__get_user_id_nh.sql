drop function if exists flow.get_user_id_nh(p_value text);
CREATE OR REPLACE FUNCTION flow.get_user_id_nh(p_value text)
  returns bigint AS
$BODY$
declare
  v_user_id bigint;
BEGIN
  v_user_id = null;
  if p_value is not null then
    select id
    into v_user_id
    from flow."user" u
    where u.nh_migration_id = p_value;

    if v_user_id is null then
      v_user_id = 2495780;
    end if;
  end if;
  return v_user_id;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
