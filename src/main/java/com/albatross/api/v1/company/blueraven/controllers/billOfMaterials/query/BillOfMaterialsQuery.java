package com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.query;

public class BillOfMaterialsQuery {

    //language=PostgreSQL
    public final static String insertBomParts = """
            INSERT INTO brs.bill_of_materials_parts (quantity, parts_master_id, project_id, supplier_id, supplier_confirmed, date_created, date_modified, created_by_id, modified_by_id)
            VALUES (:quantity, :partsMasterId, :projectId, :supplierId, :supplierConfirmed, now(), now(), :userId, :userId)
    """;

    //language=PostgreSQL
    public final static String updateBomParts = """
             UPDATE brs.bill_of_materials_parts
                set quantity = coalesce(:quantity, quantity)
                    , supplier_id = coalesce(:supplierId, supplier_id)
                    , supplier_confirmed = :supplierConfirmed
                    , archived = :archived
                    , modified_by_id = :userId
                    , date_modified = now()
            WHERE id = :id
    """;

    //language=PostgreSQL
    public final static String insertBomNonPartsMasterParts = """
            INSERT INTO brs.bill_of_materials_custom_parts (quantity, non_parts_master_parts_id, project_id, supplier_id, supplier_confirmed, date_created, date_modified, created_by_id, modified_by_id)
            VALUES (:quantity, :nonPartsMasterId, :projectId, :supplierId, :supplierConfirmed, now(), now(), :userId, :userId)
    """;

    //language=PostgreSQL
    public final static String updateBomNonPartsMasterParts = """
             UPDATE brs.bill_of_materials_custom_parts
                set quantity = coalesce(:quantity, quantity)
                    , supplier_id = coalesce(:supplierId, supplier_id)
                    , supplier_confirmed = :supplierConfirmed
                    , archived = :archived
                    , modified_by_id = :userId
                    , date_modified = now()
            WHERE id = :id
    """;

    //language=PostgreSQL
    public final static String getBomForProject = """
      WITH parts_data AS (
                          SELECT
                              parts_master_group_uuid,
                              jsonb_extract_path_text(value, 'value') AS part_value,
                              field_id,
                              object_code,
                              object_type
                          FROM brs.parts_master_version_custom_field_value_vw vw
                                   INNER JOIN brs.parts_master_version pmv
                                              ON pmv.id = vw.parts_master_version_id
                          WHERE pmv.parts_master_version_status_id = 2
                              and field_id IN (728, 729, 730)
                          ORDER BY vw.parts_master_group_uuid, vw.custom_field_group_assignment_id, vw.date_modified DESC
                      )
                      SELECT
                          bomp.id
                           , bomp.quantity
                           , bomp.project_id
                           , bomp.parts_master_id
                           , bomp.supplier_id
                           , pplh.permit_pack_log_nbr
                           , s.name as "supplierName"
                           , bomp.supplier_confirmed
                           , pmvcfg.parts_master_group_uuid
                           , vv.object_code as "objectCode"
                           , vv.object_type as "objectType"
                           , MAX(CASE WHEN field_id = 728 THEN part_value END) AS description
                           , MAX(CASE WHEN field_id = 729 THEN part_value END) AS brand
                           , MAX(CASE WHEN field_id = 730 THEN part_value END) AS part_number
                      FROM brs.bill_of_materials_parts bomp
                               INNER JOIN brs.parts_master_version_custom_field_group pmvcfg
                                          ON pmvcfg.id = bomp.parts_master_id
                               LEFT JOIN brs.feat_db_supplier s
                                         ON s.id = bomp.supplier_id
                               LEFT JOIN parts_data vv
                                         ON pmvcfg.parts_master_group_uuid = vv.parts_master_group_uuid
                                LEFT JOIN brs.permit_pack_log_history pplh on pplh.id = bomp.permit_pack_id
                      WHERE bomp.project_id = :projectId
                        and bomp.archived is false
                      GROUP BY bomp.id
                             , pmvcfg.id
                             , pplh.permit_pack_log_nbr
                             , s.name
                             , object_code
                             , object_type
    """;


    //language=PostgreSQL
    public final static String getNonPartsMasterPartsForProjectBom = """
        select  bomcp.id
        	 , bomcp.quantity
        	 , bomcp.project_id
        	 , bomcp.custom_part_id
        	 , bomcp.supplier_id
        	 , pplh.permit_pack_log_nbr
        	 , s.name as "supplierName"
        	 , bomcp.supplier_confirmed
        	 , cp.name as description
        	 , cp.part_number
        	 , 'PARTS_OTHER' as "objectCode"
        	 , 'Parts Other' as "objectType"
        from brs.bill_of_materials_custom_parts bomcp
        	left join brs.custom_parts cp on bomcp.custom_part_id = cp.id
        	left join brs.permit_pack_log_history pplh on pplh.id = bomcp.permit_pack_id
        	left join brs.feat_db_supplier s
        	          ON s.id = bomcp.supplier_id
        	where bomcp.project_id = :projectId and bomcp.archived = false;
    """;

    //language=PostgreSQL
    public final static String deleteAllBomParts = """
    UPDATE brs.bill_of_materials_parts
    SET
        archived = true,
        date_modified = now(),
        modified_by_id = :userId
    WHERE project_id = :projectId
    """;

    //language=PostgreSQL
    public final static String getDesignLogNumber = """
    select dlh.reference_nbr
        from flow.project_process_step pps
        inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
        inner join brs.design_log_history dlh on dlh.id = ppscfv.int_value
        where pps.project_id = :projectId and
            pps.main = true and
            ppscfv.custom_field_group_assignment_id = 24211
            """; //24211 is the custom field group assignment id for design log number

    //language=PostgreSQL
    public final static String getPermitPackLogNumber = """
    select pplh.permit_pack_log_nbr
        from flow.project_process_step pps
        inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
        inner join brs.permit_pack_log_history pplh on pplh.id = ppscfv.int_value
        where pps.project_id = :projectId and
            pps.main = true and
            ppscfv.custom_field_group_assignment_id = 26343
    """; //26343 is the custom field group assignment id for permit pack log number

    //language=PostgreSQL
    public final static String getBomPermitPacksForProject = """
      select pplh.id, pplh.permit_pack_log_nbr, pps.main as "primary"
           from flow.project_process_step pps
                 inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
                 inner join brs.permit_pack_log_history pplh on pplh.id = ppscfv.int_value
           where pps.project_id = :projectId
           and  ppscfv.custom_field_group_assignment_id = 26343
      """;//26343 is the custom field group assignment id for permit pack log number
    //todo: this is NOT right
}
