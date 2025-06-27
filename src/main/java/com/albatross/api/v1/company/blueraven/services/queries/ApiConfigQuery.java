package com.albatross.api.v1.company.blueraven.services.queries;

public class ApiConfigQuery {

  // API Config Type Queries
  public static final String getApiConfigTypes = """
    SELECT
      id,
      config_name as name,
      config_name_code as code,
      parent_list_of_value_id as listOfValuesId
    FROM flow.api_config_type
    WHERE archived = false
    ORDER BY config_name
    """;

  public static final String getApiConfigTypeById = """
    SELECT
      lov.id,
      lov.name,
      lov.code
    FROM flow.list_of_value lov
    WHERE lov.id IN (
      SELECT ac.list_of_value_id
      FROM flow.api_config ac
      WHERE ac.api_config_type_id = :configTypeId
        AND ac.archived = false
    )
    ORDER BY lov.id
    """;

  public static final String insertApiConfigType = """
    INSERT INTO flow.api_config_type (
      config_name,
      config_name_code,
      parent_list_of_value_id,
      created_by_id,
      date_created,
      archived
    ) VALUES (
      :name,
      :code,
      :listOfValuesId,
      :createdById,
      now(),
      false
    )
    """;

  public static final String updateApiConfigType = """
    UPDATE flow.api_config_type
    SET
      config_name = :name,
      config_name_code = :code,
      parent_list_of_value_id = :listOfValuesId,
      modified_by_id = :modifiedById,
      date_modified = now()
    WHERE id = :id
    """;

  public static final String getApiConfigsByTypeId = """
    SELECT
    lov.id,
    lov.parent_id,
    lov.name,
    lov.code
    FROM flow.list_of_value lov
    WHERE lov.parent_id = :listOfValuesId
    ORDER BY lov.id
    """;

  public static final String getApiConfigById = """
    SELECT
      ac.id,
      ac.api_config_type_id as apiConfigTypeId,
      ac.list_of_value_id as listOfValuesId,
      ac.value,
      lov.name as listOfValueName,
      lov.code as listOfValueCode
    FROM flow.api_config ac
    LEFT JOIN flow.list_of_value lov ON lov.id = ac.list_of_value_id
    WHERE ac.id = :id
      AND ac.archived = false
    """;

  public static final String insertApiConfig = """
    INSERT INTO flow.api_config (
      api_config_type_id,
      list_of_value_id,
      value,
      created_by_id,
      date_created,
      archived
    ) VALUES (
      :apiConfigTypeId,
      :listOfValuesId,
      :value,
      :createdById,
      now(),
      false
    )
    """;

  public static final String updateApiConfig = """
    UPDATE flow.api_config
    SET
      api_config_type_id = :apiConfigTypeId,
      list_of_value_id = :listOfValuesId,
      value = :value,
      modified_by_id = :modifiedById,
      date_modified = now()
    WHERE id = :id
      AND list_of_value_id = :listOfValuesId
      AND archived = false
    """;

  public static final String getAllApiConfigs = """
    SELECT
        ac.id,
        ac.api_config_type_id as apiConfigTypeId,
        ac.list_of_value_id as listOfValuesId,
        ac.value
    FROM flow.api_config ac
    WHERE ac.archived = false
    ORDER BY ac.id
    """;
}
