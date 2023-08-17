drop function if exists flow.build_link_url(character varying,  bigint,  bigint,  bigint,  bigint);
CREATE OR REPLACE FUNCTION flow.build_link_url(p_current_url character varying, p_contact_id bigint,
                                               p_project_id bigint, p_pps_id bigint, p_ppse_id bigint)
    RETURNS text AS

$BODY$
DECLARE
    v_value    text;
    v_error    boolean default false;
    v_cfga_ids int[];
    r          bigint;
BEGIN

    v_error = false;

    with t as (select unnest(regexp_matches(p_current_url,
                                            'CFGA_ID_(\d+)', 'g')) s)
    select array_agg(s)
    from t
    into v_cfga_ids;

    if (p_project_id is not null) then
        foreach r in array v_cfga_ids
            LOOP

                --this function does the heavy lifting of finding the value
                select *
                into v_value
                from flow.get_cfv_value_as_text(p_project_id, p_ppse_id, r::bigint);

                if(v_value is not null) then
                    p_current_url = REPLACE(p_current_url, concat('CFGA_ID_', r::text), v_value);
                else
                    v_error = true;
                end if;

            END LOOP;
    end if;

    raise notice 'current url ******** %', p_current_url;
    if v_error is true then
        return 'ERROR';
    else
        return p_current_url;
    end if;
END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
