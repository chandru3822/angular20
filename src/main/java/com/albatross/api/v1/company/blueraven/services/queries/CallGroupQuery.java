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
    select cgpn.id,
           cgpn.phone_number as "phoneNumber",
           cgpn.date_created as "dateCreated",
           cgpn.call_count as "callCount",
           cgpn.call_group_id as "callGroupId",
           cgpn.active,
           cgpn.archived,
           (cg.max_call_count <= cgpn.call_count) as maxCallCountHit
    from brs.call_group_phone_number cgpn
        inner join brs.call_group cg on cgpn.call_group_id = cg.id
    where cgpn.call_group_id = :callGroupId
    order by maxCallCountHit desc
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
           cgpn.call_count,
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
  public final static String getCallerGroupNumbers = """
    select cgpn.id,
           cgpn.phone_number as "phoneNumber",
           cgpn.date_created as "dateCreated",
           cgpn.call_count as "callCount",
           cgpn.call_group_id as "callGroupId",
           cgpn.active,
           cgpn.archived
    from brs.call_group cg
        inner join brs.call_group_postal_code cgpc on cg.id = cgpc.call_group_id
        inner join brs.call_group_phone_number cgpn on cg.id = cgpn.call_group_id
    where cgpc.postal_code = :postalCode and cg.active is true and cgpn.active is true
        and cg.archived is not true and cgpc.archived is not true and cgpn.archived is not true
    order by cgpn.call_count asc, cgpn.id asc
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
  public final static String updatePhoneNumberCallCount = """
    update brs.call_group_phone_number
    set call_count = call_count+1, date_modified = now()
    where id = :currentlyUsedId
    """;

  //language=PostgreSQL
  public final static String addPhoneLog = """
    insert into brs.call_group_phone_log(call_group_id, phone_number, date_created, created_by_id)
    values (:callGroupId, :phoneNumber, now(), :createdById)
    """;

  //language=PostgreSQL
  public final static String updatePhoneCallCount = """
    update brs.call_group_phone_number cgpn set date_modified = now(), call_count  =
      (select count(*) from brs.call_group_phone_log cgpl
      inner join brs.call_group cg on cgpl.call_group_id = cg.id
      where cg.id = :callGroupId and phone_number = :phoneNumber
            and cgpl.date_created between now() -(cg.days_per_period || 'days')::interval and now())
      where cgpn.call_group_id = :callGroupId and cgpn.phone_number = :phoneNumber
    """;
}
