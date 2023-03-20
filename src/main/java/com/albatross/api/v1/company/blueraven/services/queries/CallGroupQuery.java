package com.albatross.api.v1.company.blueraven.services.queries;

public class CallGroupQuery {

  //language=PostgreSQL
  public final static String getGroups = """
    select cg.id,
           cg.company_id,
           cg.call_group_name,
           cg.active,
           cg.archived,
           cg.max_call_count,
           cg.days_per_period,
           (select count(1)
            from brs.call_group_phone_number cgpn2
            where cgpn2.call_group_id = cg.id
              and cgpn2.active = true and cgpn2.archived = false) as activePhoneNumbersCount,
            (select count(1)
            from brs.call_group_postal_code cgpc
            where cgpc.call_group_id = cg.id
              and cgpc.archived = false) as postalCodesCount,
           (case when
              (select count(1)
               from brs.call_group_phone_number cgpn2
               where cgpn2.call_group_id = cg.id
                 and cgpn2.active = true and cgpn2.archived = false) = 0 then 0
               else
               (
               (select count(1)
           from brs.call_group_phone_number cgpn3
           where cgpn3.call_group_id = cg.id
             and cg.max_call_count <= cgpn3.call_count
              and cgpn3.active = true and cgpn3.archived = false)
               /
            (select count(1)
            from brs.call_group_phone_number cgpn2
            where cgpn2.call_group_id = cg.id
              and cgpn2.active = true and cgpn2.archived = false)
                   ) end) = 1 as maxCallCountHit
       from brs.call_group cg
       where cg.company_id = :companyId
       and cg.archived is not true
       and case when :searchQuery::text is not null then
                    lower(translate(cg.call_group_name, '*,.& ', '')) like '%' || lower(trim(translate(:searchQuery::text, '*,.&', ''))) || '%'
               OR cg.id in (select cgpc.call_group_id
                   from brs.call_group_postal_code cgpc
                   where cgpc.archived is not true
                   and cgpc.postal_code like '%' || :searchQuery::text || '%')
           else 1=1 end
       group by cg.id, cg.call_group_name
       order by maxCallCountHit desc, cg.call_group_name
    """;

  //language=PostgreSQL
  public final static String getCodesForGroup = """
    select cgpc.id,
           cgpc.postal_code as "postalCode",
           cgpc.call_group_id as "callGroupId",
           cgpc.archived
    from brs.call_group_postal_code cgpc
    where cgpc.call_group_id = :callGroupId
      and cgpc.archived is not true
    order by cgpc.postal_code
    """;

  //language=PostgreSQL
  public final static String getNumbersForGroup = """
    with totals as (select cgpl.phone_number, count(1) as call_count, cg.max_call_count <= count(1) as max_call_count_hit
                    from brs.call_group_phone_log cgpl
                             inner join brs.call_group cg on cg.id = cgpl.call_group_id
                    where cgpl.call_group_id = :callGroupId
                      and cgpl.date_created >= (now() - ('1 day'::interval * cg.days_per_period))
                    group by cgpl.phone_number, cg.max_call_count)
    select cgpn.id,
           cgpn.phone_number,
           cgpn.date_created,
           cgpn.call_group_id,
           cgpn.active,
           cgpn.archived,
           case when t.call_count is null then 0 else t.call_count end,
           case when t.max_call_count_hit is null then false else t.max_call_count_hit end as max_call_count_hit
    from brs.call_group_phone_number cgpn
             left join totals t on t.phone_number = cgpn.phone_number
    where cgpn.call_group_id = :callGroupId
    order by max_call_count_hit desc;
    """;

  //language=PostgreSQL
  public final static String getGroup = """
    select cg.id,
       cg.company_id,
       cg.call_group_name,
       cg.max_call_count,
       cg.days_per_period,
       cg.active,
       cg.archived
    from brs.call_group cg
    where cg.id = :id
    """;

  //language=PostgreSQL
  public final static String insertGroup = """
    insert into brs.call_group(company_id, call_group_name, max_call_count, days_per_period, date_created, created_by_id, date_modified, modified_by_id)
    values (:companyId, :callGroupName, :maxCallCount, :daysPerPeriod, now(), :createdById, now(), :createdById)
    """;

  //language=PostgreSQL
  public final static String updateGroup = """
    update brs.call_group
    set call_group_name = :callGroupName,
        active = :active,
        modified_by_id = :modifiedById,
        date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String updateGroupConfig = """
    update brs.call_group
    set max_call_count = :maxCallCount,
        days_per_period = :daysPerPeriod,
        modified_by_id = :modifiedById,
        date_modified = now()
    """;

  //language=PostgreSQL
  public final static String deleteGroup = """
    update brs.call_group
    set archived = true,
        modified_by_id = :modifiedById,
        date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String addPostalCode = """
    insert into brs.call_group_postal_code(call_group_id, postal_code, date_created, created_by_id, date_modified, modified_by_id)
    values (:callGroupId, trim(:postalCode), now(), :createdById, now(), :createdById)
    """;

  //language=PostgreSQL
  public final static String addPhoneNumber = """
    insert into brs.call_group_phone_number(call_group_id, phone_number, active, date_created, created_by_id, date_modified, modified_by_id)
    values (:callGroupId, :phoneNumber, :active, now(), :createdById, now(), :createdById)
    """;

  //language=PostgreSQL
  public final static String deletePostalCode = """
    update brs.call_group_postal_code
    set archived = true,
        modified_by_id = :modifiedById,
        date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String updatePhoneNumber = """
    update brs.call_group_phone_number
    set active = :active,
        modified_by_id = :modifiedById,
        date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String getPostalCode = """
    select cgpc.id,
           cgpc.call_group_id,
           cgpc.postal_code,
           cgpc.archived
    from brs.call_group_postal_code cgpc
    where cgpc.id = :id
    """;

  //language=PostgreSQL
  public final static String getPhoneNumber = """
    select cgpn.id,
           cgpn.phone_number,
           0 as "callCount",
           cgpn.date_created,
           cgpn.active,
           cgpn.archived
    from brs.call_group_phone_number cgpn
    where cgpn.id = :id
    """;

  //language=PostgreSQL
  public final static String checkForExisting = """
    select cgpc.id,
           cgpc.call_group_id,
           cgpc.postal_code,
           cgpc.archived
    from brs.call_group_postal_code cgpc
        inner join brs.call_group cg on cgpc.call_group_id = cg.id
    where cgpc.postal_code = :postalCode
      and cg.archived is not true and cgpc.archived is not true
    """;

  //language=PostgreSQL
  public final static String getLowestCallsCallGroupNumber = """
    with activeNumbers as (select phone_number, cg.id from brs.call_group_phone_number cgpn
                                                      inner join brs.call_group_postal_code cgpc on cgpn.call_group_id = cgpc.call_group_id
                                                      inner join brs.call_group cg on cg.id = cgpn.call_group_id
                           where cgpc.postal_code = :postalCode and cg.active is true and cgpn.active is true
                             and cg.archived is not true and cgpc.archived is not true),
    totals as (select cgpl.phone_number, cg.id, count(1) as call_count
                from brs.call_group_phone_log cgpl
                         inner join activeNumbers aN on aN.phone_number = cgpl.phone_number
                         inner join brs.call_group cg on cg.id = cgpl.call_group_id
                where  cgpl.date_created >= (now() - ('1 day'::interval * cg.days_per_period))
                group by cgpl.phone_number, cg.id)
    select aN.phone_number,
           case when t.call_count is null then 0 else t.call_count end,
           aN.id as "callGroupId"
    from activeNumbers aN left join totals t on aN.phone_number = t.phone_number
    order by call_count asc limit 1
    """;

  //language=PostgreSQL
  public final static String deletePhoneNumber = """
    update brs.call_group_phone_number
    set archived = true,
        modified_by_id = :modifiedById,
        date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String checkForExistingPhone = """
    select cgpn.id,
           cgpn.call_group_id,
           cgpn.phone_number,
           cgpn.active
    from brs.call_group_phone_number cgpn
        inner join brs.call_group cg on cgpn.call_group_id = cg.id
    where cgpn.phone_number = :phoneNumber
      and cg.archived is not true
    """;

  //language=PostgreSQL
  public final static String addPhoneLog = """
    insert into brs.call_group_phone_log(call_group_id, phone_number, date_created, created_by_id)
    values (:callGroupId, :phoneNumber, now(), :createdById)
    """;

}
