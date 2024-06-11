drop function if exists flow.check_project_tag(p_project_id bigint, p_tag_id bigint);

create or replace function flow.check_project_tag(p_project_id bigint, p_tag_id bigint)
    returns boolean as
$BODY$

    --written by carlin, pseudo-not-checked by randa

BEGIN
    return exists (
            select *
            from flow.project_tag
            where project_id = p_project_id
              and tag_id = p_tag_id
              and archived is not true
            );
END
$BODY$
    language plpgsql VOLATILE COST 100;