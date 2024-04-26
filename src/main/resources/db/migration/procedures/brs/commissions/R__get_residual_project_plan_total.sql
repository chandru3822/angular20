drop function if exists brs.get_residual_project_plan_total(p_residual_plan_id bigint,
                                                            p_closer_user_id bigint,
                                                            p_system_size numeric,
                                                            p_total_lifetime_fdc bigint,
                                                            p_total_system_size numeric,
                                                            p_current_qualified_fdc bigint);
drop function if exists brs.get_residual_project_plan_total(p_residual_plan_id bigint,
                                                            p_closer_user_id bigint,
                                                            p_system_size numeric,
                                                            p_total_lifetime_fdc bigint,
                                                            p_total_system_size numeric,
                                                            p_current_qualified_fdc bigint,
                                                            p_total_system_size_by_source numeric);
CREATE or replace function brs.get_residual_project_plan_total(p_residual_plan_id bigint,
                                                               p_closer_user_id bigint,
                                                               p_system_size numeric,
                                                               p_total_lifetime_fdc bigint,
                                                               p_total_system_size numeric,
                                                               p_current_qualified_fdc bigint,
                                                               p_total_system_size_by_source numeric)
  RETURNS numeric
AS
$BODY$
declare
  v_total numeric;
begin
  select coalesce(alloc.partial_allocation,1) * case when rp1.is_system_size is true then p_system_size * rp1.total
                                                          else rp1.total end
  into v_total
   from brs.residual_plan rp1
          inner join brs.residual_plan_allocation rpa on rpa.residual_plan_id = rp1.id
          inner join brs.user_residual ur on ur.user_id = p_closer_user_id
          inner join brs.residual_plan rp2 on rp2.id = ur.residual_plan_id
          inner join brs.residual_plan_allocation a on a.residual_plan_id = rp2.id and
                                                       p_total_lifetime_fdc between a.min and coalesce(a.max,10000)
          left join lateral (select partial_allocation
                             from brs.residual_plan_partial_allocation rppa
                                    inner join brs.residual_plan_partial_allocation_type rppat on rppat.id = rppa.residual_plan_partial_allocation_type_id
                             where rppa.residual_plan_allocation_id = a.id
                               and case when rp2.is_based_on_source is true then
                                          p_total_system_size_by_source >= rppa.fdc_count and
                                          p_total_system_size_by_source < a.allocation
                                        when rp2.is_system_size is true then
                                          p_total_system_size >= rppa.fdc_count and
                                          p_total_system_size < a.allocation
                                        else p_current_qualified_fdc >= rppa.fdc_count and
                                             p_current_qualified_fdc < a.allocation end order by fdc_count desc,rppat.rank_order limit 1) as alloc on true
   where rpa.residual_plan_id = p_residual_plan_id and
     p_total_lifetime_fdc between rpa.min and coalesce(rpa.max,10000);
  return round(v_total,2);
END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;
