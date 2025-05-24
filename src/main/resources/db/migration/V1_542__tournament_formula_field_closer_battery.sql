-- Add Battery FDC Score Value field to the tournament formula
INSERT INTO brs.tournament_formula_field(
  display_order,
  field_name,
  field_code,
  tournament_formula_id,
  data_type_id,
  created_by_id,
  date_created,
  archived
)
SELECT
  (SELECT COALESCE(MAX(display_order), 0) + 1 FROM brs.tournament_formula_field WHERE tournament_formula_id = 1),
  'Battery FDC Score Value',
  'BATTERY_FDC_SCORE_VALUE',
  1,
  6,
  2417170,
  NOW(),
  false
  WHERE NOT EXISTS(
    SELECT *
    FROM brs.tournament_formula_field
    WHERE field_code = 'BATTERY_FDC_SCORE_VALUE'
    AND tournament_formula_id = 1
);
