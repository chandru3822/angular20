DROP FUNCTION IF EXISTS brs.ahj_update_requirement(
  INTEGER,
  INTEGER,
  INTEGER,
  TEXT,
  INTEGER,
  BOOLEAN,
  INTEGER,
  INTEGER,
  BOOLEAN
);
CREATE OR REPLACE FUNCTION brs.ahj_update_requirement(
  p_utility_id     INTEGER,
  p_ahj_id         INTEGER,
  p_requirement_id INTEGER,
  p_description    TEXT,
  p_position       INTEGER,
  p_complete       BOOLEAN,
  p_status_id      INTEGER,
  p_user_id        INTEGER,
  p_archived       BOOLEAN
)
  RETURNS VOID
AS $$
DECLARE
  o_req_id      INTEGER;
  o_req_type_id INTEGER;
  o_done        BOOLEAN;
BEGIN
  IF p_status_id IN (1, 3)
  THEN
    --
    -- IF THE NEW REQ STATUS IS "ACTIVE" OR "OPEN CHALLENGE"
    --

    IF p_status_id = 1
    THEN
      --
      -- IF THE NEW STATUS IS "ACTIVE", ATTEMPT TO UPDATE THE
      -- CURRENT REQUIREMENT IF IT WAS "OPEN CHALLENGE"
      --

      IF p_utility_id IS NOT NULL
      THEN
        --
        -- IF WE'RE DEALING WITH A UTILITY REQUIREMENT
        --

        -- mark challenge as active utility requirement
        UPDATE brs.ahj_utility_requirements
        SET
          status_id     = p_status_id,
          date_modified  = now(),
          modified_by_id = p_user_id
        WHERE utility_id = p_utility_id
              AND requirement_id = p_requirement_id
              AND status_id = 3
        RETURNING TRUE
          INTO o_done;

        IF o_done IS TRUE
        THEN
          -- archive the currently-active utility requirement
          UPDATE brs.ahj_utility_requirements
          SET
            status_id     = 2,
            date_modified  = now(),
            modified_by_id = p_user_id,
            archived = true
          WHERE utility_id = p_utility_id
                AND requirement_id <> p_requirement_id
                AND position = p_position
                AND status_id = 1
          RETURNING requirement_id
            INTO o_req_id;

          UPDATE brs.ahj_requirement
          SET
            archived = true
          WHERE
            id = o_req_id;
        END IF;


      ELSE
        --
        -- IF WE ARE *NOT* DEALING WITH A UTILITY REQUIREMENT
        --

        -- mark the challenge as the active requirement
        UPDATE brs.ahj_requirements
        SET
          status_id     = p_status_id,
          date_modified  = now(),
          modified_by_id = p_user_id
        WHERE ahj_id = p_ahj_id
              AND requirement_id = p_requirement_id
              AND status_id = 3
        RETURNING TRUE
          INTO o_done;

        IF o_done IS TRUE
        THEN
          -- archive the currently-active requirement
          UPDATE brs.ahj_requirements
          SET
            status_id     = 2,
            date_modified  = now(),
            modified_by_id = p_user_id,
            archived = true
          WHERE ahj_id = p_ahj_id
                AND requirement_id <> p_requirement_id
                AND position = p_position
                AND status_id = 1
          RETURNING requirement_id
            INTO o_req_id;

          UPDATE brs.ahj_requirement
          SET
            archived = true
          WHERE
            id = o_req_id;
        END IF;
      END IF;

      -- bail out early if we updated something
      IF o_done IS TRUE
      THEN
        RETURN;
      END IF;
    END IF;

    --  first insert a new requirement record
    INSERT INTO brs.ahj_requirement (
      requirement_type_id, description, created_by_id, modified_by_id
    )
      SELECT
        requirement_type_id,
        p_description,
        p_user_id,
        p_user_id
      FROM brs.ahj_requirement
      WHERE id = p_requirement_id
    RETURNING id
      INTO o_req_id;

    -- get the requirement type
    SELECT requirement_type_id
    INTO o_req_type_id
    FROM brs.ahj_requirement
    WHERE id = o_req_id;

    IF o_req_type_id = 4 AND p_utility_id IS NOT NULL
    THEN
      --
      -- IF WE'RE DEALING WITH A UTILITY REQUIREMENT
      --

      -- link the new utility requirement record with the AHJ
      INSERT INTO brs.ahj_utility_requirements (
        utility_id, requirement_id, original_requirement_id, status_id, position, complete, created_by_id, date_modified, modified_by_id, archived
      )
        SELECT
          p_utility_id,
          o_req_id,
          original_requirement_id,
          p_status_id,
          p_position,
          p_complete,
          p_user_id,
          now(),
          p_user_id,
          p_archived
        FROM brs.ahj_utility_requirements
        WHERE utility_id = p_utility_id
              AND requirement_id = p_requirement_id;

      IF p_status_id = 1
      THEN
        -- Archive the previous utility requirement if it was Active
        UPDATE brs.ahj_utility_requirements
        SET
          status_id     = 2, -- Archived
          date_modified  = now(),
          modified_by_id = p_user_id,
          archived = true
        WHERE utility_id = p_utility_id
              AND requirement_id = p_requirement_id
              AND status_id = 1;

        UPDATE brs.ahj_requirement
        SET
          archived = true
        WHERE
          id = p_requirement_id;
      END IF;


    ELSE
      --
      -- IF WE ARE *NOT* DEALING WITH A UTILITY REQUIREMENT
      --

      -- link the new requirement record with the AHJ
      INSERT INTO brs.ahj_requirements (
        ahj_id, requirement_id, original_requirement_id, status_id, position, complete, created_by_id, date_modified, modified_by_id, archived
      )
        SELECT
          p_ahj_id,
          o_req_id,
          original_requirement_id,
          p_status_id,
          p_position,
          p_complete,
          p_user_id,
          now(),
          p_user_id,
          p_archived
        FROM brs.ahj_requirements
        WHERE ahj_id = p_ahj_id
              AND requirement_id = p_requirement_id;

      IF p_status_id = 1
      THEN
        -- Archive the previous requirement if it was Active
        UPDATE brs.ahj_requirements
        SET
          status_id     = 2, -- Archived
          date_modified  = now(),
          modified_by_id = p_user_id,
          archived = true
        WHERE ahj_id = p_ahj_id
              AND requirement_id = p_requirement_id
              AND status_id = 1;


        UPDATE brs.ahj_requirement
        SET
          archived = true
        WHERE
          id = p_requirement_id;
      END IF;
    END IF;


  ELSEIF p_status_id = 4
    THEN
      --
      -- IF THE NEW REQUIREMENT STATUS IS "DENIED CHALLENGE"
      --

      --  get the requirement type
      SELECT requirement_type_id
      INTO o_req_type_id
      FROM brs.ahj_requirement
      WHERE id = p_requirement_id;

      IF o_req_type_id = 4 AND p_utility_id IS NOT NULL
      THEN
        --
        -- IF WE'RE DEALING WITH A UTILITY REQUIREMENT
        --

        UPDATE brs.ahj_utility_requirements
        SET
          status_id     = p_status_id,
          date_modified  = now(),
          modified_by_id = p_user_id
        WHERE utility_id = p_utility_id
              AND requirement_id = p_requirement_id
              AND status_id = 3;


      ELSE
        --
        -- IF WE ARE *NOT* DEALING WITH A UTILITY REQUIREMENT
        --

        UPDATE brs.ahj_requirements
        SET
          status_id     = p_status_id,
          date_modified  = now(),
          modified_by_id = p_user_id
        WHERE ahj_id = p_ahj_id
              AND requirement_id = p_requirement_id
              AND status_id = 3;
      END IF;
  END IF;
END
$$
LANGUAGE plpgsql;

