CREATE OR REPLACE FUNCTION flow.refresh_user_records()
    RETURNS trigger AS
$BODY$
declare
v_user_id integer;
v_user_ids integer[];
BEGIN

    IF (TG_OP = 'DELETE') THEN
       v_user_id = old.id;


    ELSIF (TG_OP = 'UPDATE' or TG_OP = 'INSERT') then
        v_user_id = new.id;

    end if;
    select array_agg(v_user_id)
    into v_user_ids;
    perform flow.update_user_org_user_position(v_user_ids);
    RETURN NEW;
END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    COST 100;

CREATE OR REPLACE FUNCTION flow.refresh_user_position_records()
    RETURNS trigger AS
$BODY$
declare
    v_user_id integer;
    v_user_ids integer[];
BEGIN

    IF (TG_OP = 'DELETE') THEN
        v_user_id = old.user_id;


    ELSIF (TG_OP = 'UPDATE' or TG_OP = 'INSERT') then
        v_user_id = new.user_id;

    end if;
    select array_agg(v_user_id)
    into v_user_ids;
    perform flow.update_user_org_user_position(v_user_ids);
    RETURN NEW;
END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    COST 100;

CREATE OR REPLACE FUNCTION flow.refresh_position_records()
    RETURNS trigger AS
$BODY$
declare
    v_user_id integer;
    v_user_ids integer[];
BEGIN

    select array_agg(user_id)
    into v_user_ids
    from flow.user_position
    where position_id = new.id;
    perform flow.update_user_org_user_position(v_user_ids);
    RETURN NEW;
END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    COST 100;



CREATE OR REPLACE FUNCTION flow.refresh_org_records()
    RETURNS trigger AS
$BODY$
declare
    v_user_ids integer[];
BEGIN

    select array_agg(user_id)
    into v_user_ids
    from flow.user_position
        where org_id = new.id;
    perform flow.update_user_org_user_position(v_user_ids);


    RETURN NEW;
END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    COST 100;


drop trigger if exists user_view_trg on flow.user;
CREATE TRIGGER user_view_trg
    AFTER INSERT OR UPDATE OR DELETE
    ON flow.user
    FOR EACH ROW
EXECUTE PROCEDURE flow.refresh_user_records();

drop trigger if exists org_view_trg on flow.org;
CREATE TRIGGER org_view_trg
    AFTER UPDATE
    ON flow.org
    FOR EACH ROW
EXECUTE PROCEDURE flow.refresh_org_records();

drop trigger if exists user_position_trg on flow.user_position;
CREATE TRIGGER user_position_trg
    AFTER INSERT OR UPDATE OR DELETE
    ON flow.user_position
    FOR EACH ROW
EXECUTE PROCEDURE flow.refresh_user_position_records();

drop trigger if exists position_trg on flow.position;
CREATE TRIGGER position_trg
    AFTER INSERT OR UPDATE OR DELETE
    ON flow.position
    FOR EACH ROW
EXECUTE PROCEDURE flow.refresh_position_records();
