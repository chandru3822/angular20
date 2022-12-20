package com.albatross.api.v1.flow.queries;

public class StateQuery {

  //language=PostgreSQL
  public final static String getAllStates = """
    select s.id,
               s.state,
               s.abbreviation,
               s.map_latitude,
               s.map_longitude,
               s.map_zoom
        from flow.state s
        order by s.state
        """;

  //language=PostgreSQL
  public final static String getAvailableStates = """
    select s.id,
           s.state,
           s.abbreviation,
           s.map_latitude,
           s.map_longitude,
           s.map_zoom
    from flow.state s
    where not exists (
        select state_id
        from flow.company_state cs
        where company_id = :companyId
        and s.id = cs.state_id
        and cs.archived is false
    )
    order by s.state
    """;

  //language=PostgreSQL
  public final static String getAllCompanyStates = """
    select cs.id,
          s.state,
          cs.state_id,
          s.abbreviation,
          cs.active,
          cs.archived,
          cs.company_id,
          case when cs.map_latitude is not null then cs.map_latitude else s.map_latitude end as map_latitude,
          case when cs.map_longitude is not null then cs.map_longitude else s.map_longitude end as map_longitude,
          case when cs.map_zoom is not null then cs.map_zoom else s.map_zoom end as map_zoom
       from flow.company_state cs
           inner join flow.state s on s.id = cs.state_id
       where cs.company_id = :companyId
       and cs.archived is false
       order by s.state
       """;

  //language=PostgreSQL
  public final static String getActiveStatesByCompany = """
    select cs.id,
       s.state,
       cs.state_id,
       s.abbreviation,
       cs.active,
       cs.archived,
       cs.company_id,
       case when cs.map_latitude is not null then cs.map_latitude else s.map_latitude end as map_latitude,
       case when cs.map_longitude is not null then cs.map_longitude else s.map_longitude end as map_longitude,
       case when cs.map_zoom is not null then cs.map_zoom else s.map_zoom end as map_zoom
    from flow.company_state cs
        inner join flow.state s on s.id = cs.state_id
    where cs.active is true
      and cs.company_id = :companyId
      and cs.archived is false
    order by s.state
    """;

  //language=PostgreSQL
  public final static String getOneCompanyState = """
    select cs.id,
       s.state,
       cs.state_id,
       s.abbreviation,
       cs.active,
       cs.id as company_state_id,
       cs.archived,
       cs.company_id,
       case when cs.map_latitude is not null then cs.map_latitude else s.map_latitude end as map_latitude,
       case when cs.map_longitude is not null then cs.map_longitude else s.map_longitude end as map_longitude,
       case when cs.map_zoom is not null then cs.map_zoom else s.map_zoom end as map_zoom
    from flow.company_state cs
        inner join flow.state s on s.id = cs.state_id
    where cs.id = :companyStateId
      and cs.archived is false
    """;

  //language=PostgreSQL
  public final static String getActiveStatesByHierarchy = """
    select distinct cs.id,
                s.state,
                cs.state_id,
                s.abbreviation,
                coalesce(cs.map_latitude, s.map_latitude) as map_latitude,
                coalesce(cs.map_longitude, s.map_longitude) as map_longitude,
                coalesce(cs.map_zoom, s.map_zoom) as map_zoom
    from flow.company_state cs
             inner join flow.state s on s.id = cs.state_id
    where cs.active is true
        and cs.archived is not true
        and cs.company_id = :companyId
    ORDER BY state
    """;

  //language=PostgreSQL
  public final static String insertCompanyState = """
    insert into flow.company_state(state_id, company_id, map_latitude, map_longitude, map_zoom, active)
    values (:stateId, :companyId, :mapLatitude, :mapLongitude, :mapZoom, :active)
    """;

  //language=PostgreSQL
  public final static String updateCompanyState = """
    update flow.company_state
        set map_zoom = :mapZoom,
            map_latitude = :mapLatitude,
            map_longitude = :mapLongitude,
            active = :active
    where id = :companyStateId
    """;

  //language=PostgreSQL
  public final static String deleteCompanyState = """
    update flow.company_state
        set archived = true
    where id = :companyStateId
    """;

}
