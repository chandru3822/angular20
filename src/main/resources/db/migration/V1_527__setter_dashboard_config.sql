---------------------------------------------------------
-- Update company configuration value to include the
-- `Setter Team Lead` positions on the Setter Dashboard
----------------------------------------------------------
UPDATE flow.company_configuration_value
SET value='4,5,6,573,73,773'
WHERE id=2
  AND company_id=3
  AND code='SETTER_POSITION_IDS';
