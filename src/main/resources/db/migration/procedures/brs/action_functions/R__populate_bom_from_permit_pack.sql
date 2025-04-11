drop FUNCTION if exists brs.populate_bom_from_permit_pack(p_project_id bigint);
CREATE OR REPLACE FUNCTION brs.populate_bom_from_permit_pack(p_project_id bigint)
	RETURNS VOID
	LANGUAGE plpgsql
AS
$function$
DECLARE
	permit_pack_log_number INT; --permit pack log number selected using cfgaId 26343
	permit_pack_id INT; --permit pack id selected using cfgaId 26343
	log_record RECORD; --used to hold the permit pack row
	json_item  JSONB; --used to hold a single part json item from the log_record's bom data
	part_num   TEXT; --used within a loop to hold each part_number
	part_name  TEXT; --used within a loop to hold each part_name/description
	quantity   INT; --used within a loop to hold the quantity of each part
	part_id    INT; --used within a loop to hold each part's part_master_id

BEGIN

	--get the permit pack log number for the project
	SELECT pplh.permit_pack_log_nbr, pplh.id
	INTO permit_pack_log_number, permit_pack_id
	FROM flow.project_process_step pps
		     INNER JOIN flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id
		     INNER JOIN brs.permit_pack_log_history pplh on pplh.id = ppscfv.int_value
	WHERE pps.project_id = p_project_id
	  AND pps.main = true
	  AND ppscfv.custom_field_group_assignment_id = 26343 --the custom field group assignment id for permit pack log number
	LIMIT 1;

	-- Exit if no matching permit pack log number is found
	IF NOT FOUND THEN
		RAISE NOTICE 'No permit pack log number found for project_id = %',
			p_project_id;
		RETURN;
	END IF;

	-- Select the specific permit pack row based on project_id and permit_pack_log_number
	SELECT pplh.id, pplh.bom
	INTO log_record
	FROM brs.permit_pack_log_history pplh
	WHERE pplh.project_id = p_project_id
	  AND pplh.permit_pack_log_nbr = permit_pack_log_number
	LIMIT 1;

	-- Exit if no matching record is found
	IF NOT FOUND THEN
		RAISE NOTICE 'No matching record found for project_id = %, permit_pack_log_number = %',
			p_project_id, permit_pack_log_number;
		RETURN;
	END IF;

	-- Archive permit_pack_log_number existing brs.bill_of_materials_parts for the given project_id
	IF EXISTS (
		SELECT 1
		FROM brs.bill_of_materials_parts bomp
		WHERE bomp.project_id = p_project_id
	) THEN
		UPDATE brs.bill_of_materials_parts
		SET archived = TRUE
		WHERE project_id = p_project_id;
		RAISE NOTICE 'Archived existing brs.bill_of_materials_parts for project_id = %', p_project_id;
	END IF;

	IF EXISTS (
		SELECT 1
		FROM brs.bill_of_materials_custom_parts bomcp
		WHERE bomcp.project_id = p_project_id
	) THEN
		UPDATE brs.bill_of_materials_custom_parts
		SET archived = TRUE
		WHERE project_id = p_project_id;

		RAISE NOTICE 'Archived existing brs.bill_of_materials_custom_parts for project_id = %', p_project_id;
	END IF;

	-- Use query to get the parts_master_data as a CTE so we can get the parts_master_id
	drop table if exists parts_master_data_temp;
	CREATE TEMP TABLE parts_master_data_temp AS
	SELECT
		pmvcfg.id AS parts_master_id,
		vw.parts_master_group_uuid,
		MAX(jsonb_extract_path_text(vw.value, 'value')) FILTER (WHERE vw.field_id = 728) AS description,
		MAX(jsonb_extract_path_text(vw.value, 'value')) FILTER (WHERE vw.field_id = 730) AS part_number
	FROM brs.parts_master_version_custom_field_value_vw AS vw
		     INNER JOIN brs.parts_master_version AS pmv
		                ON pmv.id = vw.parts_master_version_id
		     INNER JOIN brs.parts_master_version_custom_field_group AS pmvcfg
		                ON pmvcfg.parts_master_group_uuid = vw.parts_master_group_uuid
	WHERE pmv.parts_master_version_status_id = 2 --status 2 means it's the published version
	  AND vw.field_id IN (728, 730)
	GROUP BY pmvcfg.id, vw.parts_master_group_uuid;

	-- Process each JSON object in the bom field
	FOR json_item IN
		SELECT * FROM jsonb_array_elements(log_record.bom::jsonb)
		LOOP
			-- Extract part_number, name, and quantity
			part_num := json_item->>'number';
			part_name := json_item->>'name';
			quantity := (json_item->>'quantity')::INT;
			RAISE NOTICE 'json_item = %', json_item;

			-- Try matching by part_number first
			SELECT pmd.parts_master_id INTO part_id
			FROM parts_master_data_temp pmd
			WHERE LOWER(pmd.part_number) = LOWER(part_num)
			LIMIT 1;

			-- If no match, try matching by description
			IF part_id IS NULL THEN
				SELECT pmd.parts_master_id INTO part_id
				FROM parts_master_data_temp pmd
				WHERE LOWER(pmd.part_number) = LOWER(part_num)
				  AND LOWER(pmd.description) ILIKE '%' || LOWER(part_name) || '%'
				LIMIT 1;
			END IF;

			-- Insert into brs.bill_of_materials_parts table if match is found
			IF part_id IS NOT NULL AND quantity > 0 THEN
				INSERT INTO brs.bill_of_materials_parts (quantity, parts_master_id, project_id, permit_pack_id, date_created, date_modified, created_by_id, modified_by_id)
				VALUES (quantity, part_id, p_project_id, permit_pack_id, now(), now(), 99999999, 99999999);
			ELSE
				--if it's not in the parts_master table, we're going to use the custom_parts table
				RAISE NOTICE 'No matching part found for part_number = % and name = %', part_num, part_name;

				--try matching on the custom_parts table
				SELECT cp.id INTO part_id
				FROM brs.custom_parts cp
				WHERE LOWER(cp.part_number) = LOWER(part_num)
				  AND cp.name = part_name
				LIMIT 1;

				IF part_id IS NULL THEN
					-- if it's also not in the custom_parts table then add it.
					INSERT INTO brs.custom_parts (name, part_number, date_created, date_modified, created_by_id, modified_by_id)
					VALUES (part_name, part_num, now(), now(), 99999999, 99999999)
					RETURNING id into part_id;

					RAISE NOTICE 'Adding part_number = % to the custom_parts table', part_num;
				END IF;

				--no matter what, we should have a part_id now from the non_parts_master_part table (but it's usually safer to check)
				IF part_id IS NOT NULL THEN

					--increment the usage on the custom_parts table
					UPDATE brs.custom_parts
					SET usage=(SELECT COALESCE(MAX(usage), 0) + 1 FROM brs.custom_parts)
					WHERE id = part_id;

					--Insert into the bill_of_materials_custom_parts table
					IF quantity IS NOT NULL THEN
						INSERT INTO brs.bill_of_materials_custom_parts (quantity, custom_part_id, project_id, permit_pack_id, date_created, date_modified, created_by_id, modified_by_id)
						VALUES (quantity, part_id, p_project_id, permit_pack_id, now(), now(), 99999999, 99999999);

					ELSE
						RAISE NOTICE 'Something went wrong updating the custom_parts table for part_number = %', part_num;
					END IF;

				END IF;
			END IF;--end Insert into brs.bill_of_materials_parts table if/else
		END LOOP;
	drop table if exists parts_master_data_temp;
END;
$function$
