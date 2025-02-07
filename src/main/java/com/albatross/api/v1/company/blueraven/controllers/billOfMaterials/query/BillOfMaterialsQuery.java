package com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.query;

public class BillOfMaterialsQuery {

    //language=PostgreSQL
    public final static String upsertBomParts = """
            INSERT INTO brs.bill_of_materials_parts (quantity, parts_master_id, project_id, supplier_id, supplier_confirmed, date_created, date_modified, created_by_id, modified_by_id)
            VALUES (:quantity, :partsMasterId, :projectId, :supplierId, :supplierConfirmed, now(), now(), :userId, :userId)
            on conflict (id)
            do update
            	set quantity = :quantity
            	    , supplier_id = :supplierId
            	    , supplier_confirmed = :supplierConfirmed
            	    , archived = :archived
            	    , modified_by_id = :userId
            	    , date_modified = now()
    """;

    //language=PostgreSQL
    public final static String getBomForProject = """
       WITH version_values AS (
                   	SELECT DISTINCT ON (vw.parts_master_group_uuid, vw.custom_field_group_assignment_id)
                   		vw.parts_master_group_uuid,
                   		vw.custom_field_group_assignment_id,
                   		pmv.version AS parts_master_version_id,
                   		vw.value,
                   		vw.field_id,
                   		vw.field_code,
                   		vw.modified_by_id,
                   		vw.modified_by,
                   		vw.date_modified
                   	FROM brs.parts_master_version_custom_field_value_vw vw
                   		     INNER JOIN brs.parts_master_version pmv
                   		                ON pmv.id = vw.parts_master_version_id
                   	WHERE pmv.parts_master_version_status_id = 1
                   	ORDER BY vw.parts_master_group_uuid, vw.custom_field_group_assignment_id, vw.date_modified DESC
                   )
                   SELECT
                   	bomp.id
                   	 , bomp.quantity
                   	 , bomp.project_id
                   	 , bomp.parts_master_id
                   	 , bomp.supplier_id
                   	 , s.name
                   	 , bomp.supplier_confirmed
                   	 , pmvcfg.parts_master_group_uuid
                   	 , json_build_object(
                   			   'pk', pmvcfg.parts_master_group_uuid,
                   			   'versionId', MAX(vv.parts_master_version_id)
                   		   )::jsonb || json_object_agg(vv.field_id, vv.value)::jsonb AS "partDetails"
                   FROM brs.bill_of_materials_parts bomp
                   	     INNER JOIN brs.parts_master_version_custom_field_group pmvcfg
                   	                ON pmvcfg.id = bomp.parts_master_id
                   	    LEFT JOIN brs.feat_db_supplier s
                   	                ON s.id = bomp.supplier_id
                   	     LEFT JOIN version_values vv
                   	               ON pmvcfg.parts_master_group_uuid = vv.parts_master_group_uuid
                   WHERE bomp.project_id = :projectId
                   GROUP BY bomp.id
                          , pmvcfg.id
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
}
