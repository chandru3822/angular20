package com.albatross.api.v1.flow.queries;

public class PostalCodeQuery {

  //language=PostgreSQL
  public final static String getActivePostalCodes = """
      select id,
             postal_code,
             place_name,
             round_robin_id,
             metro_area_id,
             archived,
             active
      from flow.postal_code pc
      where pc.active is true
      and pc.archived is false
      order by pc.postal_code
  """;

  //language=PostgreSQL
  public final static String getPostalCodeById = """
      select id,
             postal_code,
             place_name,
             round_robin_id,
             notes,
             metro_area_id,
             disqualified,
             archived,
             active
      from flow.postal_code pc
      where pc.archived is false
      and pc.id = :id
  """;

  //language=PostgreSQL
  public final static String updatePostalCode = """
      update flow.postal_code
        set round_robin_id = :roundRobinId,
            place_name =  :placeName,
            notes = :notes,
            disqualified = :disqualified,
            active = :active,
            date_modified = now(),
            modified_by_id = :userId
      where id = :id
  """;

  //language=PostgreSQL
  public final static String insertPostalCode = """
      insert into flow.postal_code(country_code, postal_code, place_name, active)
      values ('US', :postalCode, :placeName, true)
  """;

  //language=PostgreSQL
  public final static String getPostalCodeZones = """
      select id,
             zone_name,
             metro_area_id,
             archived
      from flow.postal_code_zone pcz
      where pcz.archived is false
      order by pcz.zone_name
  """;

  //language=PostgreSQL
  public final static String getPostalCodeZoneById = """
      select id,
             zone_name,
             metro_area_id,
             archived,
             COALESCE((SELECT array_to_json(array_agg(rows))
                from (SELECT pczpc.id,
                             pczpc.postal_code_id as "postalCodeId",
                             pc.postal_code as "postalCode",
                             pc.active,
                             pc.archived
                      FROM flow.postal_code_zone_postal_code pczpc
                           INNER JOIN flow.postal_code pc on pc.id = pczpc.postal_code_id
                      WHERE pczpc.archived is false
                      ORDER BY pc.postal_code) rows), '[]') as postalCodes
      from flow.postal_code_zone pcz
      where pcz.id = :id
  """;

  //language=PostgreSQL
  public final static String updatePostalCodeZone = """
      update flow.postal_code_zone
        set zone_name = :zoneName,
            metro_area_id = :metroAreaId,
            date_modified = now(),
            modified_by_id = :userId
      where id = :id
  """;

  //language=PostgreSQL
  public final static String insertPostalCodeZone = """
      insert into flow.postal_code_zone(company_id, zone_name, created_by_id, modified_by_id, metro_area_id)
      values (:companyId, :zoneName, :userId, :userId, :metroAreaId)
  """;

  //language=PostgreSQL
  public final static String insertPostalCodeZonePostalCode = """
      insert into flow.postal_code_zone_postal_code(postal_code_id, postal_code_zone_id, created_by_id, modified_by_id)
      values (:postalCodeId, :zoneId, :userId, :userId)
  """;

  //language=PostgreSQL
  public final static String deletePostalCodeFromZone = """
    update flow.postal_code_zone_postal_code
    set archived = true,
        modified_by_id = :userId,
        date_modified = now()
    where id = :id
  """;

  //language=PostgreSQL
  public final static String getOnePostalCodeToZone = """
      select id,
             postal_code_zone_id,
             postal_code_id,
             date_created,
             date_modified,
             created_by_id,
             modified_by_id,
             archived
      from flow.postal_code_zone_postal_code
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
    and not exists (
        select id
        from flow.postal_code_zone_postal_code pczpc
        where pczpc.archived is false
          and pczpc.postal_code_id = pc.id
    )
  """;
}
