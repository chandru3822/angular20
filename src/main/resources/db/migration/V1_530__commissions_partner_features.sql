------------- NEW MILESTONE TYPES -------------
-- Insert new Milestone Types for source selection on `Dealer`/`Installation Partner`
-- Add 2 records each role with the IDs of 743, 828; 4 records total
-----------------------------------------------

-- #1: Insert 'M1 - Pay Eligible' for position ID of 743
INSERT INTO brs.milestone_type (milestone_type, active, display_order, position_id)
SELECT
  'M1 - Pay Eligible',
  true,
  1,
  743
WHERE NOT EXISTS (
  SELECT id
  FROM brs.milestone_type
  WHERE milestone_type = 'M1 - Pay Eligible'
    AND position_id = 743
    AND active = true
);

-- #2: Insert 'M2 - Substantial Completion' for position ID of 743
INSERT INTO brs.milestone_type (milestone_type, active, display_order, position_id)
SELECT
  'M2 - Substantial Completion',
  true,
  2,
  743
WHERE NOT EXISTS (
  SELECT id
  FROM brs.milestone_type
  WHERE milestone_type = 'M2 - Substantial Completion'
    AND position_id = 743
    AND active = true
);

-- #3: Insert 'M1 - Pay Eligible' for position ID of 828
INSERT INTO brs.milestone_type (milestone_type, active, display_order, position_id)
SELECT
  'M1 - Pay Eligible',
  true,
  1,
  828
WHERE NOT EXISTS (
  SELECT id
  FROM brs.milestone_type
  WHERE milestone_type = 'M1 - Pay Eligible'
    AND position_id = 828
    AND active = true
);

-- #4: Insert 'M2 - Substantial Completion' for position ID of 828
INSERT INTO brs.milestone_type (milestone_type, active, display_order, position_id)
SELECT
  'M2 - Substantial Completion',
  true,
  2,
  828
WHERE NOT EXISTS (
  SELECT id
  FROM brs.milestone_type
  WHERE milestone_type = 'M2 - Substantial Completion'
    AND position_id = 828
    AND active = true
);

------- UPSERT FEATURE ACCESS CONTROLS --------
-- Update the `Commissions` access control to the below name & code:
--   + Commissions - Closer                ::   COMMISSIONS_CLOSER

-- Insert below names & codes using `DO` block to capture new feature ID:
--   + Commissions - Setter                ::   COMMISSIONS_SETTER
--   + Commissions - Dealer                ::   COMMISSIONS_DEALER
--   + Commissions - Installation Partner  ::   COMMISSIONS_INSTALLATION_PARTNER
-----------------------------------------------

-- Update feature id 13 from `COMMISSIONS` to "COMMISSIONS - CLOSER"
UPDATE flow.feature
SET
  feature_code = 'COMMISSIONS_CLOSER',
  feature_name = 'Commissions - Closer'
WHERE id=13
  AND feature_name = 'Commissions'
  AND feature_code = 'COMMISSIONS';


-- Update company feature code from `Commissions` to "COMMISSIONS_CLOSER"
UPDATE flow.company_feature
SET feature_name = 'Commissions - Closer'
WHERE feature_id=13
  AND company_id=3
  AND feature_name = 'Commissions';

DO
$$
  DECLARE
    -- Variable to store `new_feature_id` returned from first `feature` table insertion
    new_feature_id BIGINT;

    -- Feature paths needs to be set as /commissions for `Dealer` & `Installation Partner`
    feature_paths TEXT[] := ARRAY['/commissionManagement/users', '/commissionManagement/commissions', '/commissionManagement/commissions'];
    feature_codes TEXT[] := ARRAY['COMMISSIONS_SETTER', 'COMMISSIONS_DEALER', 'COMMISSIONS_INSTALLATION_PARTNER'];
    feature_names TEXT[] := ARRAY['Commissions - Setter', 'Commissions - Dealer', 'Commissions - Installation Partner'];

    -- Will represent the index of each loop below
    i INTEGER;
    j INTEGER;

  -- Arrays are same length, so using either inside the loop will give correct index
  BEGIN
    FOR i IN 1 .. array_length(feature_names, 1) LOOP

      -- First check if the feature already exists and get its ID if it does
      SELECT id INTO new_feature_id
      FROM flow.feature
      WHERE feature_name = feature_names[i]
        AND feature_code = feature_codes[i];

      -- If the feature doesn't exist, insert it and get the new ID
      IF new_feature_id IS NULL THEN
        INSERT INTO flow.feature (feature_name, feature_code, archived, is_system, feature_path)
        VALUES (
          feature_names[i],
          feature_codes[i],
          false,
          false,
          feature_paths[i]
        )
        RETURNING id INTO new_feature_id;
      END IF;

      -- Insert corresponding rows into flow.company_feature using returned ID from feature table
      INSERT INTO flow.company_feature (feature_name, company_id, feature_id, archived, home_page, hidden, parent_company_feature_id, has_permissions, show_in_tools)
      SELECT
        feature_names[i],
        3,
        new_feature_id,
        false,
        true,
        false,
        null,
        true,
        true
      WHERE NOT EXISTS (
        SELECT id
        FROM flow.company_feature
        WHERE feature_name = feature_names[i]
          AND company_id = 3
          AND feature_id = new_feature_id
      );

      -- Access control values are 1,2,3,4,5 on previous `Commission` feature ID, confirmed that we are using same values.
      -- Instead of doing additional query to obtain the values, it iterates 5 times giving the same result.
      FOR j IN 1 .. 5 LOOP
        INSERT INTO flow.feature_access_control (feature_id, access_control_id, date_created, date_modified, created_by_id, modified_by_id, archived)
        SELECT
          new_feature_id,
          j,
          now(),
          now(),
          2417170,
          2417170,
          false
        WHERE NOT EXISTS (
          SELECT id
          FROM flow.feature_access_control
          WHERE feature_id = new_feature_id
            AND access_control_id = j
        );
      END LOOP;
    END LOOP;
  END
$$;
