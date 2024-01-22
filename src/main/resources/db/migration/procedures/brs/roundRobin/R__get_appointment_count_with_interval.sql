drop function if exists brs.get_appointment_count_with_interval(p_user_id bigint,p_closer_gen_source_ids bigint[], p_interval bigint);
CREATE OR REPLACE FUNCTION brs.get_appointment_count_with_interval(p_user_id bigint,p_closer_gen_source_ids bigint[], p_interval bigint)
  RETURNS table
          (

            user_id        bigint,
            appointment_count_with_interval bigint
          )
AS
$BODY$
declare

BEGIN
  return query
  select pd2.closer_user_id::bigint, count(pd2.id) as appointment_count_with_interval
  from  brs.project_details pd2
  where  pd2.closer_user_id =  p_user_id and
         pd2.first_appointment between now() and now() +  (p_interval ||' days')::interval
    and not pd2.source=  any (p_closer_gen_source_ids)
  group by pd2.closer_user_id;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

