drop function if exists flow.refresh_company_user_status_records() cascade;
CREATE OR REPLACE FUNCTION flow.refresh_company_user_status_records()
    RETURNS trigger AS
$BODY$
declare
    v_user_id bigint;
    v_user_ids bigint[];
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


drop function if exists flow.refresh_user_records() cascade;
CREATE OR REPLACE FUNCTION flow.refresh_user_records()
    RETURNS trigger AS
$BODY$
declare
v_user_id bigint;
v_user_ids bigint[];
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

drop function if exists flow.refresh_user_position_records() cascade;
CREATE OR REPLACE FUNCTION flow.refresh_user_position_records()
    RETURNS trigger AS
$BODY$
declare
    v_user_id bigint;
    v_user_ids bigint[];
    v_count bigint;
    v_position_ids bigint[];
BEGIN

--   if (TG_OP = 'INSERT') and new.end_date is null then
--     select array_agg(distinct position_id)
--     from (select distinct position_id
--           from flow.project p
--                  inner join flow.user_position up on up.id = p.user_position_id
--           union
--           select distinct position_id
--           from flow.contact c
--                  inner join flow.user_position u on u.id = c.owner_user_position_id) as foo
--     into v_position_ids;
--
--     if new.position_id = any (v_position_ids) then
--       insert into flow.org_structure_refresh(user_position_id)
--       values(old.id);
--     end if;
--
--
--   end if;

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


drop function if exists flow.refresh_position_records() cascade;
CREATE OR REPLACE FUNCTION flow.refresh_position_records()
    RETURNS trigger AS
$BODY$
BEGIN

    update flow.user_positions_vw
        set position = new.position,
            position_scheduler = new.scheduler,
            position_schedulable = new.schedulable
    where position_id = new.id;
    RETURN NEW;
END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    COST 100;


drop function if exists flow.refresh_org_records() cascade;
CREATE OR REPLACE FUNCTION flow.refresh_org_records()
    RETURNS trigger AS
$BODY$
declare
    v_user_ids bigint[];
BEGIN

    IF (TG_OP = 'UPDATE') and old.parent_org_id is not null and
       ((new.parent_org_id is not null and
       old.parent_org_id != new.parent_org_id) or new.parent_org_id is null) then

      insert into flow.org_structure_refresh(org_id)
      values(new.id);

    end if;

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


drop function if exists flow.refresh_user_status_type_records() cascade;
CREATE OR REPLACE FUNCTION flow.refresh_user_status_type_records()
    RETURNS trigger AS
$BODY$
declare
    v_user_ids bigint[];
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
