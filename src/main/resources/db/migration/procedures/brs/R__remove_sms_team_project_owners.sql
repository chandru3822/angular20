DROP FUNCTION IF EXISTS flow.remove_sms_team_project_owners(integer, integer, integer, integer, integer);
CREATE OR REPLACE FUNCTION flow.remove_sms_team_project_owners(p_sms_team_id integer, p_org_id integer, p_position_id integer,
                                                       p_user_id integer, p_current_user_id integer)
  RETURNS void as
$BODY$
declare
v_user_ids integer[];
BEGIN

select array_agg(user_id) as user_id
into v_user_ids
from (
         select user_id
         from flow.sms_team_user stu
         where case
                   when p_user_id is null and p_org_id is null and p_position_id is null then
                           stu.archived is false and
                           sms_team_id = p_sms_team_id and
                           exists(select pmo.user_id
                                  from flow.project_message_owner pmo
                                  where stu.user_id = pmo.user_id
                                    and pmo.archived is false)
                   when p_user_id is not null then
                           stu.archived is false and
                           sms_team_id = p_sms_team_id and stu.user_id = p_user_id and
                           exists(select pmo.user_id
                                  from flow.project_message_owner pmo
                                  where stu.user_id = pmo.user_id
                                    and pmo.archived is false)
                   else false end

         union
         select up.user_id
         from flow.sms_team_position stp
                  inner join flow.user_positions_vw up on up.position_id = stp.position_id
         where case
                   when p_user_id is null and p_org_id is null and p_position_id is null then
                           stp.archived is false and
                           stp.sms_team_id = p_sms_team_id and
                           exists(select pmo.user_id
                                  from flow.project_message_owner pmo
                                  where up.user_id = pmo.user_id
                                    and pmo.archived is false)
                   when p_position_id is not null then
                           stp.archived is false and
                           sms_team_id = p_sms_team_id and stp.position_id = p_position_id and
                           exists(select pmo.user_id
                                  from flow.project_message_owner pmo
                                  where up.user_id = pmo.user_id
                                    and pmo.archived is false
                                    and case when p_user_id is not null then pmo.user_id = p_user_id else true end)
                   else false end
         union
         select up.user_id
         from flow.sms_team_org sto
                  inner join flow.user_positions_vw up on up.org_id = sto.org_id
         where case
                   when p_user_id is null and p_org_id is null and p_position_id is null then
                           sto.archived is false and
                           sto.sms_team_id = p_sms_team_id and
                           exists(select pmo.user_id
                                  from flow.project_message_owner pmo
                                  where up.user_id = pmo.user_id
                                    and pmo.archived is false)
                   when p_org_id is not null then
                           sto.archived is false and
                           sto.sms_team_id = p_sms_team_id and sto.org_id = p_org_id and
                           exists(select pmo.user_id
                                  from flow.project_message_owner pmo
                                  where up.user_id = pmo.user_id
                                    and pmo.archived is false
                                    and case when p_user_id is not null then pmo.user_id = p_user_id else true end)
                   else false end) as foo;


update flow.project_message_owner
set archived       = true,
    date_modified  = now(),
    modified_by_id = p_current_user_id
where sms_team_id = p_sms_team_id
  and archived is false
  and user_id = any (v_user_ids);

if p_user_id is null and p_org_id is null and p_position_id is null then
update flow.project_message_owner_history
set date_removed   = now(),
    date_modified  = now(),
    modified_by_id = p_current_user_id
where sms_team_id = p_sms_team_id and
    date_removed is null;

update flow.project_message_team
set archived       = true,
    date_modified  = now(),
    modified_by_id = p_current_user_id
where sms_team_id = p_sms_team_id
  and archived is false;

update flow.notification
set message_read_tsz   = now(),
    date_modified  = now(),
    modified_by_id = p_current_user_id
where notification_topic_id = 2
  and (metadata->>'smsTeamId')::integer = p_sms_team_id;

else
update flow.project_message_owner_history
set date_removed   = now(),
    date_modified  = now(),
    modified_by_id = p_current_user_id
where sms_team_id = p_sms_team_id
  and user_id = any (v_user_ids) and
    date_removed is null;

update flow.notification
set message_read_tsz   = now(),
    date_modified  = now(),
    modified_by_id = p_current_user_id
where notification_topic_id = 2
  and (metadata->>'smsTeamId')::integer = p_sms_team_id
  and user_id = any (v_user_ids);

end if;
END
$BODY$
LANGUAGE plpgsql VOLATILE
                   COST 100;
