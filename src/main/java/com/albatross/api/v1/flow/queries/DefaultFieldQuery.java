package com.albatross.api.v1.flow.queries;

public class DefaultFieldQuery {

  //language=PostgreSQL
  public final static String getCompanyDefaultFieldsByObjectType = """
    select cdf.id,
           df.data_type_id,
           df.object_type_id,
           cdf.company_id,
           cdf.default_field_id,
           df.field_name,
           df.column_name,
           df.property_name,
           cdf.archived,
           cdf.show_on_user_profile
    from flow.company_default_field cdf
    inner join flow.default_field df on cdf.default_field_id = df.id
    where cdf.company_id = :companyId
    and df.object_type_id = :objectTypeId
    order by df.field_name
    """;

  //language=PostgreSQL
  public final static String saveCompanyDefaultField = """
    update flow.company_default_field
    set show_on_user_profile = :showOnUserProfile,
        modified_by_id = :userId,
        date_modified = now()
    where id = :id
    """;


}
