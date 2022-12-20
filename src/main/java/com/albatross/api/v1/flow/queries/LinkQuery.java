package com.albatross.api.v1.flow.queries;

public class LinkQuery {

  //language=PostgreSQL
  public final static String getLinksForCompany = """
    select *
    from flow.link
    where company_id = :companyId
    and archived is not true
    """;

  //language=PostgreSQL
  public final static String updateOrderInProcessStep = """
    update flow.process_step_link
        set display_order = :displayOrder,
            modified_by_id = :modifiedById,
            date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String getLinksForProcessStep = """
    select *
    from flow.process_step_link psl
        inner join flow.link l on psl.link_id = l.id
    where process_step_id = :processStepId
    and psl.archived is not true
      and l.archived is not true
    order by psl.display_order
    """;

  //language=PostgreSQL
  public final static String getAvailableLinksForProcessStep = """
    select l.*
      from flow.link l
    where l.archived is not true
      and l.company_id = :companyId
      and not exists (
        select process_step_id
        from flow.process_step_link psl
        where psl.link_id = l.id
          and psl.process_step_id = :id
          and archived is not true
      )
     order by l.link
    """;

  //language=PostgreSQL
  public final static String getProcessStepLink = """
    SELECT psl.id,
           psl.link_id as "linkId",
           psl.display_order as "displayOrder",
           psl.created_by_id as "createdById",
           psl.process_step_id as "processStepId",
           psl.modified_by_id as "modifiedById",
           l.link,
           l.url,
           psl.archived
        FROM flow.process_step_link psl
               inner join flow.link l on l.id = psl.link_id
        where psl.id = :id
        """;

  //language=PostgreSQL
  public final static String insertProcessStepLink = """
    insert into flow.process_step_link (link_id, process_step_id, display_order, created_by_id, date_created,  modified_by_id, date_modified)
    values (:linkId, :processStepId,(select coalesce(max(display_order) + 1, 0) from flow.process_step_link where process_step_id = :processStepId and archived is not true), :createdById, now(), :createdById, now())
        """;

  //language=PostgreSQL
  public final static String getLink = """
      select id,
             link,
             company_id,
             archived,
             url
      from flow.link
      where company_id = :companyId
        and id = :linkId
    """;

  //language=PostgreSQL
  public final static String deleteProcessStepLink = """
        update flow.process_step_link
        set archived = true,
          modified_by_id = :modifiedById,
          date_modified = now()
        where id = :id
    """;

  //language=PostgreSQL
  public final static String deleteLink = """
        update flow.link
        set archived = true, date_modified = now()
        where id = :id
    """;

  //language=PostgreSQL
  public final static String updateLink = """
      update flow.link
        set link = :link,
            url = :url,
            date_modified = now()
      where id = :id
    """;

  //language=PostgreSQL
  public final static String insertLink = """
      insert into flow.link(link, company_id, url)
        values (:link, :companyId, :url)
      returning id;
    """;

  //language=PostgreSQL
  public final static String getAvailableLinksForAction = """
    select l.*
    from flow.link l
    where l.archived is not true
      and l.company_id = :companyId
      and not exists (
            select psl.process_step_action_id
            from flow.process_step_action_link psl
            where psl.link_id = l.id
              and psl.process_step_action_id = :id
              and archived is not true
        )
    order by l.link
    """;

  //language=PostgreSQL
  public final static String getAvailableLinksForEventAction = """
    select l.*
    from flow.link l
    where l.archived is not true
      and l.company_id = :companyId
      and not exists (
        select psl.process_step_event_action_id
        from flow.process_step_event_action_link psl
        where psl.link_id = l.id
          and psl.process_step_event_action_id = :id
          and archived is not true
      )
    order by l.link
    """;

}
