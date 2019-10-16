CREATE OR REPLACE FUNCTION flow.user_asset_trg()
    RETURNS trigger AS
$BODY$
DECLARE
    v_first_name character varying(50);
    v_last_name  character varying(50);
BEGIN


    IF (TG_OP = 'DELETE') THEN
        select first_name,
               last_name
               into v_first_name,v_last_name
        from flow.user
        where id = old.user_id;

        insert into flow.user_asset_history(first_name, last_name, user_id, asset_id, update_date, action_type)
        values (v_first_name, v_last_name, old.user_id, old.asset_id, now(), TG_OP);


    ELSIF (TG_OP = 'UPDATE' or TG_OP = 'INSERT') then
        select first_name,
               last_name
               into v_first_name,v_last_name
        from flow.user
        where id = new.user_id;

        insert into flow.user_asset_history(first_name, last_name, user_id, asset_id, update_date, action_type)
        values (v_first_name, v_last_name, new.user_id, new.asset_id, now(), TG_OP);

    end if;


    RETURN NEW;
END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    COST 100;


drop trigger if exists user_asset_trg on flow.user_asset;
CREATE TRIGGER user_asset_trg
    AFTER INSERT OR UPDATE OR DELETE
    ON flow.user_asset
    FOR EACH ROW
EXECUTE PROCEDURE flow.user_asset_trg();