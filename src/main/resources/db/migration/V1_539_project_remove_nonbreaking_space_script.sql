
-- Update NonBreaking Space to Regular Space Script
UPDATE flow.project p
SET
  project_name = REPLACE(project_name, CHR(160), ' '),
  street1 = REPLACE(street1, CHR(160), ' '),
  city = REPLACE(city, CHR(160), ' '),
  postal_code = REPLACE(postal_code, CHR(160), ' ')
WHERE
  project_name LIKE '%' || CHR(160) || '%' OR
  street1 LIKE '%' || CHR(160) || '%' OR
  city LIKE '%' || CHR(160) || '%' OR
  postal_code LIKE '%' || CHR(160) || '%';
