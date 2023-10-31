package com.albatross.api.v1.flow.queries;

public class PostalCodeQuery {

  //language=PostgreSQL
  public final static String getActivePostalCodes = """
      select pc.id,
             pc.postal_code,
             pc.place_name,
             pc.round_robin_id,
             pc.postal_code_zone_id,
             pc.call_group_id,
             pc.disqualified,
             pc.state_id,
             s.abbreviation as state_abbreviation,
             pc.self_gen,
             pcz.zone_name,
             rr.round_robin_name,
             cg.call_group_name,
             pc.inside_sales,
             pc.sales_partners,
             pc.archived,
             pc.active
      from flow.postal_code pc
          left join flow.round_robin rr on pc.round_robin_id = rr.id
          left join brs.call_group cg on pc.call_group_id = cg.id
          left join flow.postal_code_zone pcz on pc.postal_code_zone_id = pcz.id
          left join flow.state s on s.id = pc.state_id
      where pc.archived is false
        and pc.active is true
      order by pc.postal_code
  """;

  //language=PostgreSQL
  public final static String getPostalCodeById = """
      select pc.id,
             pc.postal_code,
             pc.place_name,
             pc.round_robin_id,
             pc.disqualified,
             pc.state_id,
             s.abbreviation as state_abbreviation,
             pc.self_gen,
             pcz.zone_name,
             pc.notes,
             pc.postal_code_zone_id,
             rr.round_robin_name,
             cg.call_group_name,
             pc.inside_sales,
             pc.sales_partners,
             pc.archived,
             pc.active
      from flow.postal_code pc
          left join flow.round_robin rr on pc.round_robin_id = rr.id
          left join brs.call_group cg on pc.call_group_id = cg.id
          left join flow.postal_code_zone pcz on pc.postal_code_zone_id = pcz.id
          left join flow.state s on s.id = pc.state_id
      where pc.archived is false
        and pc.id = :id
  """;

  //language=PostgreSQL
  public final static String deletePostalCode = """
      update flow.postal_code
        set archived = true,
        date_modified = now(),
        modified_by_id = :userId
      where id = :id
  """;


  //language=PostgreSQL
  public final static String updatePostalCode = """
      update flow.postal_code
        set round_robin_id = :roundRobinId,
            call_group_id = :callGroupId,
            state_id = :stateId,
            postal_code_zone_id = :postalCodeZoneId,
            place_name =  :placeName,
            notes = :notes,
            disqualified = :disqualified,
            self_gen = :selfGen,
            inside_sales = :insideSales,
            sales_partners = :salesPartners,
            date_modified = now(),
            modified_by_id = :userId
      where id = :id
  """;

  //language=PostgreSQL
  public final static String insertPostalCode = """
      insert into flow.postal_code(country_code, postal_code, place_name, active, state_id)
      values ('US', :postalCode, :placeName, true, :stateId)
      on conflict (postal_code)  do update
      set active = true,
          archived = false,
          place_name = :placeName,
          state_id = :stateId
      returning id
  """;

  //language=PostgreSQL
  public final static String getPostalCodeZones = """
      select pcz.id,
             pcz.zone_name,
             pcz.metro_area_id,
             lov.name as metro_area,
             pcz.archived
      from flow.postal_code_zone pcz
      left join flow.list_of_value lov on pcz.metro_area_id = lov.id
      where pcz.archived is false
      order by pcz.zone_name
  """;

  //language=PostgreSQL
  public final static String getPostalCodeZoneById = """
      select id,
             zone_name,
             metro_area_id,
             adder_amount,
             archived,
             COALESCE((SELECT array_to_json(array_agg(rows))
                from (SELECT pc.id,
                             pc.postal_code as "postalCode",
                             pc.active,
                             pc.archived
                      FROM flow.postal_code pc
                      WHERE pc.archived is false
                        and pc.postal_code_zone_id = pcz.id
                      ORDER BY pc.postal_code) rows), '[]') as postalCodes
      from flow.postal_code_zone pcz
      where pcz.id = :id
  """;

  //language=PostgreSQL
  public final static String updatePostalCodeZone = """
      update flow.postal_code_zone
        set zone_name = :zoneName,
            metro_area_id = :metroAreaId,
            adder_amount = :adderAmount,
            date_modified = now(),
            modified_by_id = :userId
      where id = :id
  """;

  //language=PostgreSQL
  public final static String deletePostalCodeZone = """
      update flow.postal_code_zone
        set archived = true,
        date_modified = now(),
        modified_by_id = :userId
      where id = :id
  """;

  //language=PostgreSQL
  public final static String insertPostalCodeZone = """
      insert into flow.postal_code_zone(company_id, zone_name, created_by_id, modified_by_id, metro_area_id, adder_amount)
      values (:companyId, :zoneName, :userId, :userId, :metroAreaId, :adderAmount)
  """;

  //language=PostgreSQL
  public final static String addPostalCodeToZone = """
      update flow.postal_code
      set postal_code_zone_id = :zoneId,
        modified_by_id = :userId,
        date_modified = now()
    where id = :postalCodeId
  """;

  //language=PostgreSQL
  public final static String deletePostalCodeFromZone = """
    update flow.postal_code
    set postal_code_zone_id = null,
        modified_by_id = :userId,
        date_modified = now()
    where id = :id
  """;

  //language=PostgreSQL
  public final static String getOnePostalCodeToZone = """
      select id,
             postal_code_zone_id,
             postal_code,
             date_modified,
             modified_by_id,
             archived
      from flow.postal_code
      where id = :id
  """;

  //language=PostgreSQL
  public final static String getAvailablePostalCodesForZone = """
    select  id,
            postal_code,
            place_name
    from flow.postal_code pc
    where pc.active is true
    and pc.archived is false
    and pc.postal_code_zone_id is null
    order by postal_code
  """;
}
