package com.albatross.api.v1.company.blueraven.controllers.billOfMaterials.query;

public class BillOfMaterialsQuery {

    //language=PostgreSQL
    public final static String createBomForProject = """
        insert into brs.bill_of_materials(project_id, date_created, date_modified, created_by_id, modified_by_id)
        values (:projectId, now(), now(), :userId, :userId)
    """;

    //language=PostgreSQL
    public final static String upsertBomParts = """
            INSERT INTO brs.bill_of_materials_parts (quantity, parts_master_id, bom_id, supplier_id, supplier_confirmed, date_created, date_modified, created_by_id, modified_by_id)
            VALUES (:quantity, :partsMasterId, :bomId, :supplierId, :supplierConfirmed, now(), now(), :userId, :userId)
            on conflict (parts_master_id, bom_id)
            do update
            	set quantity = :quantity
            	    , supplier_id = :supplierId
            	    , supplier_confirmed = :supplierConfirmed
            	    , archived = :archived
            	    , modified_by_id = :userId
            	    , date_modified = now()
    """;

    //language=PostgreSQL
    public final static String updateBomParts = """
        insert into brs.bill_of_materials_parts (quantity, parts_master_uuid, bom_id, date_created, date_modified, created_by_id, modified_by_id)
        values(:quantity, :partsMasterUUID, :bomId, now(), now(), :userId, :userId)
    """;

    //language=PostgreSQL
    public final static String getPartsForBom = """
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
                   	WHERE 1=1
                   	  and pmv.parts_master_version_status_id = 1
                   	ORDER BY vw.parts_master_group_uuid, vw.custom_field_group_assignment_id, vw.date_modified DESC
                   )
                   SELECT
                   	bomp.id
                   	 , bomp.quantity
                   	 , bomp.bom_id
                   	 , bomp.parts_master_id
                   	 , pmvcfg.parts_master_group_uuid
                   	 , json_build_object(
                   			   'pk', pmvcfg.parts_master_group_uuid,
                   			   'versionId', MAX(vv.parts_master_version_id)
                   		   )::jsonb || json_object_agg(vv.field_id, vv.value)::jsonb AS "partDetails"
                   FROM brs.bill_of_materials_parts bomp
                   	     INNER JOIN brs.parts_master_version_custom_field_group pmvcfg
                   	                ON pmvcfg.id = bomp.parts_master_id
                   	     LEFT JOIN version_values vv
                   	               ON pmvcfg.parts_master_group_uuid = vv.parts_master_group_uuid
                   WHERE bomp.bom_id = :bomId
                   GROUP BY bomp.id
                          , pmvcfg.parts_master_group_uuid    
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
                bom.id
            , bom.project_id
            , date_created
            , date_modified
            , modified_by_id
            , created_by_id
            , coalesce((
                SELECT array_to_json(array_agg(row_to_json(bomp)))
                FROM (
            	         SELECT
            		         bomp.id
            		          , bomp.quantity
            		          , bomp.bom_id
            		          , bomp.parts_master_id
            		          , pmvcfg.parts_master_group_uuid
            		          , json_build_object(
            				            'pk', pmvcfg.parts_master_group_uuid,
            				            'versionId', MAX(vv.parts_master_version_id)
            			            )::jsonb || json_object_agg(vv.field_id, vv.value)::jsonb AS "partDetails"
            	         FROM brs.bill_of_materials_parts bomp
            		              INNER JOIN brs.parts_master_version_custom_field_group pmvcfg
            		                         ON pmvcfg.id = bomp.parts_master_id
            		              LEFT JOIN version_values vv
            		                        ON pmvcfg.parts_master_group_uuid = vv.parts_master_group_uuid
            	         WHERE bomp.bom_id = :bomId
            	         GROUP BY bomp.id
            	                , pmvcfg.parts_master_group_uuid
                     ) bomp
            	), '[]') AS "partsList"
            FROM brs.bill_of_materials bom
            WHERE bom.project_id = :projectId
    """;

    //language=PostgreSQL
    public final static String getBomById = """
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
                bom.id
            , bom.project_id
            , date_created
            , date_modified
            , modified_by_id
            , created_by_id
            , coalesce((
                SELECT array_to_json(array_agg(row_to_json(bomp)))
                FROM (
            	         SELECT
            		         bomp.id
            		          , bomp.quantity
            		          , bomp.bom_id
            		          , bomp.parts_master_id
            		          , pmvcfg.parts_master_group_uuid
            		          , json_build_object(
            				            'pk', pmvcfg.parts_master_group_uuid,
            				            'versionId', MAX(vv.parts_master_version_id)
            			            )::jsonb || json_object_agg(vv.field_id, vv.value)::jsonb AS "partDetails"
            	         FROM brs.bill_of_materials_parts bomp
            		              INNER JOIN brs.parts_master_version_custom_field_group pmvcfg
            		                         ON pmvcfg.id = bomp.parts_master_id
            		              LEFT JOIN version_values vv
            		                        ON pmvcfg.parts_master_group_uuid = vv.parts_master_group_uuid
            	         WHERE bomp.bom_id = :bomId
            	         GROUP BY bomp.id
            	                , pmvcfg.parts_master_group_uuid
                     ) bomp
            	), '[]') AS "partsList"
            FROM brs.bill_of_materials bom
            WHERE bom.id = :bomId
    """;

    //language=PostgreSQL
    public final static String deleteBom = """
    UPDATE brs.bill_of_materials
    SET
        archived = true,
        date_modified = now(),
        modified_by_id = :userId
    WHERE id = :bomId
    """;
}
