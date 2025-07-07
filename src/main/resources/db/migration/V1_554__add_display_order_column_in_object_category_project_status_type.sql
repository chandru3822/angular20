ALTER TABLE flow.object_category_company_project_status_type
ADD COLUMN IF NOT EXISTS display_order INTEGER;


-- Inserting entries for display order to each object category from company project status type
-- Category 1 - Residential standard
WITH ordered_rows AS (
  SELECT
    occpst.id,
    ROW_NUMBER() OVER (ORDER BY cpst.display_order) - 1 AS new_order
  FROM flow.object_category_company_project_status_type occpst
  INNER JOIN flow.company_project_status_type cpst
    ON cpst.id = occpst.company_project_status_type_id
  WHERE cpst.company_id = 3
    AND occpst.object_category_id = 1
    AND occpst.archived IS FALSE
)
UPDATE flow.object_category_company_project_status_type t
SET display_order = o.new_order
FROM ordered_rows o
WHERE t.id = o.id and t.display_order is null;


-- Category 2 - Retrofit
WITH ordered_rows AS (
  SELECT
    occpst.id,
    ROW_NUMBER() OVER (ORDER BY cpst.display_order) - 1 AS new_order
  FROM flow.object_category_company_project_status_type occpst
  INNER JOIN flow.company_project_status_type cpst
    ON cpst.id = occpst.company_project_status_type_id
  WHERE cpst.company_id = 3
    AND occpst.object_category_id = 2
    AND occpst.archived IS FALSE
)
UPDATE flow.object_category_company_project_status_type t
SET display_order = o.new_order
FROM ordered_rows o
WHERE t.id = o.id and t.display_order is null;

-- Category 3 - BatteryOnly

WITH ordered_rows AS (
  SELECT
    occpst.id,
    ROW_NUMBER() OVER (ORDER BY cpst.display_order) - 1 AS new_order
  FROM flow.object_category_company_project_status_type occpst
  INNER JOIN flow.company_project_status_type cpst
    ON cpst.id = occpst.company_project_status_type_id
  WHERE cpst.company_id = 3
    AND occpst.object_category_id = 3
    AND occpst.archived IS FALSE
)
UPDATE flow.object_category_company_project_status_type t
SET display_order = o.new_order
FROM ordered_rows o
WHERE t.id = o.id and t.display_order is null;

-- Category 4 - Removal and Re-installation

WITH ordered_rows AS (
  SELECT
    occpst.id,
    ROW_NUMBER() OVER (ORDER BY cpst.display_order) - 1 AS new_order
  FROM flow.object_category_company_project_status_type occpst
  INNER JOIN flow.company_project_status_type cpst
    ON cpst.id = occpst.company_project_status_type_id
  WHERE cpst.company_id = 3
    AND occpst.object_category_id = 4
    AND occpst.archived IS FALSE
)
UPDATE flow.object_category_company_project_status_type t
SET display_order = o.new_order
FROM ordered_rows o
WHERE t.id = o.id and t.display_order is null;

-- Category 5 - Community

WITH ordered_rows AS (
  SELECT
    occpst.id,
    ROW_NUMBER() OVER (ORDER BY cpst.display_order) - 1 AS new_order
  FROM flow.object_category_company_project_status_type occpst
  INNER JOIN flow.company_project_status_type cpst
    ON cpst.id = occpst.company_project_status_type_id
  WHERE cpst.company_id = 3
    AND occpst.object_category_id = 5
    AND occpst.archived IS FALSE
)
UPDATE flow.object_category_company_project_status_type t
SET display_order = o.new_order
FROM ordered_rows o
WHERE t.id = o.id and t.display_order is null;

-- Category 6 - New Home

WITH ordered_rows AS (
  SELECT
    occpst.id,
    ROW_NUMBER() OVER (ORDER BY cpst.display_order) - 1 AS new_order
  FROM flow.object_category_company_project_status_type occpst
  INNER JOIN flow.company_project_status_type cpst
    ON cpst.id = occpst.company_project_status_type_id
  WHERE cpst.company_id = 3
    AND occpst.object_category_id = 6
    AND occpst.archived IS FALSE
)
UPDATE flow.object_category_company_project_status_type t
SET display_order = o.new_order
FROM ordered_rows o
WHERE t.id = o.id and t.display_order is null;

-- Category 10 - Multi Family Project

WITH ordered_rows AS (
  SELECT
    occpst.id,
    ROW_NUMBER() OVER (ORDER BY cpst.display_order) - 1 AS new_order
  FROM flow.object_category_company_project_status_type occpst
  INNER JOIN flow.company_project_status_type cpst
    ON cpst.id = occpst.company_project_status_type_id
  WHERE cpst.company_id = 3
    AND occpst.object_category_id = 10
    AND occpst.archived IS FALSE
)
UPDATE flow.object_category_company_project_status_type t
SET display_order = o.new_order
FROM ordered_rows o
WHERE t.id = o.id and t.display_order is null;

-- Category 11 - Dealer Network

WITH ordered_rows AS (
  SELECT
    occpst.id,
    ROW_NUMBER() OVER (ORDER BY cpst.display_order) - 1 AS new_order
  FROM flow.object_category_company_project_status_type occpst
  INNER JOIN flow.company_project_status_type cpst
    ON cpst.id = occpst.company_project_status_type_id
  WHERE cpst.company_id = 3
    AND occpst.object_category_id = 11
    AND occpst.archived IS FALSE
)
UPDATE flow.object_category_company_project_status_type t
SET display_order = o.new_order
FROM ordered_rows o
WHERE t.id = o.id and t.display_order is null;

-- Category 12 - Multi Family Community

WITH ordered_rows AS (
  SELECT
    occpst.id,
    ROW_NUMBER() OVER (ORDER BY cpst.display_order) - 1 AS new_order
  FROM flow.object_category_company_project_status_type occpst
  INNER JOIN flow.company_project_status_type cpst
    ON cpst.id = occpst.company_project_status_type_id
  WHERE cpst.company_id = 3
    AND occpst.object_category_id = 12
    AND occpst.archived IS FALSE
)
UPDATE flow.object_category_company_project_status_type t
SET display_order = o.new_order
FROM ordered_rows o
WHERE t.id = o.id and t.display_order is null;
