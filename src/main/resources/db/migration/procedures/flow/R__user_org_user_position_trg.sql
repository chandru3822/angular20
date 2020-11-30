CREATE OR REPLACE FUNCTION flow.refresh_company_user_status_records()
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
    v_count bigint;
BEGIN

    IF (TG_OP = 'DELETE') THEN
        v_user_id = old.user_id;

        select count(1)
        into v_count
        from flow.user_position up
        where up.id != old.id;

    ELSIF (TG_OP = 'UPDATE' or TG_OP = 'INSERT') then
        v_user_id = new.user_id;
        v_count = 1;
    end if;
    if v_count > 0 then
        select array_agg(v_user_id)
        into v_user_ids;
        perform flow.update_user_org_user_position(v_user_ids);
    else
        delete from flow.user_positions_vw where user_id = old.user_id;
        delete from flow.user_position_hierarchy_vw where user_id = old.user_id;
    end if;
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

CREATE OR REPLACE FUNCTION flow.refresh_user_status_type_records()
    RETURNS trigger AS
$BODY$
declare
    v_user_ids integer[];
BEGIN

    select array_agg(user_id)
    into v_user_ids
    from flow.company_user_status
    where user_status_type_id = new.id;
    perform flow.update_user_org_user_position(v_user_ids);


    RETURN NEW;
END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    COST 100;


drop trigger if exists user_view_trg on flow.user;
CREATE TRIGGER user_view_trg
    AFTER UPDATE OR DELETE
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

drop trigger if exists company_user_status_trg on flow.company_user_status;
CREATE TRIGGER company_user_status_trg
    AFTER INSERT OR UPDATE OR DELETE
    ON flow.company_user_status
    FOR EACH ROW
EXECUTE PROCEDURE flow.refresh_company_user_status_records();


drop trigger if exists user_status_type_trg on flow.user_status_type;
CREATE TRIGGER user_status_type_trg
    AFTER  UPDATE
    ON flow.user_status_type
    FOR EACH ROW
EXECUTE PROCEDURE flow.refresh_user_status_type_records();
