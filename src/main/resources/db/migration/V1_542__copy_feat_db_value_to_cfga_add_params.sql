
-- Add another param called Process step ID to function Copy Feat DB Value to CFGA

INSERT INTO flow.db_function_param
(db_function_id, parameter_name, archived, display_order, data_type_id, parameter_type_id, system_value_id, description, "nullable", system_list_id)
SELECT 76,'Process step ID', false, 6, 6, 1, 4, '', false, 0 WHERE NOT EXISTS (SELECT id FROM flow.db_function_param WHERE
db_function_id = 76 AND parameter_name = 'Process step ID' AND display_order = 6);

-- Updating param AHJ Custom Field ID to Custom Field Group Assignment ID

UPDATE flow.db_function_param  SET parameter_name = 'AHJ Custom Field Group Assignment ID' WHERE db_function_id = 2
AND parameter_name = 'AHJ Custom Field ID' AND display_order = 2;

-- Dropping old copy_ahj_value_to_other_cfga function

drop function if exists brs.copy_ahj_value_to_other_cfga(p_project_id bigint, p_ppse_id bigint,
                                                         p_user_id bigint,
                                                         p_cfga_copy_from bigint, p_cfga_copy_to bigint,
                                                         p_override_existing boolean);

-- Dropping old get_brs_feat_db_value_for_copy function

DROP FUNCTION IF EXISTS brs.get_brs_feat_db_value_for_copy(p_project_id bigint, p_brs_feat_db_table character varying,
                                                           p_brs_feat_db_cfga_id bigint, p_cfga_data_type_id bigint,
                                                            p_use_list_of_values boolean);



