CREATE OR REPLACE FUNCTION flow.project_process_step_insert_function()
    RETURNS TRIGGER AS $$
DECLARE
    v_process_name TEXT;
BEGIN
    v_process_name := 'project_process_step_' || new.id;
    IF NOT EXISTS
        (SELECT 1
         FROM   information_schema.tables
         WHERE  table_name = v_process_name)
    THEN
        --RAISE NOTICE 'A partition has been created %', v_process_name;
        --raise notice 'table %',format(E'CREATE TABLE flow.%I PARTITION OF flow.project_process_step FOR VALUES IN (%s)', v_process_name,new.id);
        EXECUTE format(E'CREATE TABLE flow.%I PARTITION OF flow.project_process_step FOR VALUES IN (%s)', v_process_name,new.id);
        -- EXECUTE format('GRANT SELECT ON TABLE %I TO readonly', partition_name); -- use this if you use role based permission
    END IF;
    RETURN NULL;
END
$$
    LANGUAGE plpgsql;

drop function if exists insert_project_process_step_trg;
CREATE TRIGGER insert_project_process_step_trg
    after INSERT ON flow.process_step
    FOR EACH ROW EXECUTE PROCEDURE flow.project_process_step_insert_function();
