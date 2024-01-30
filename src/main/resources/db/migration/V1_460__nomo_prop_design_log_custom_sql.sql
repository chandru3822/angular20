-- Remove the report custom sql from these 2 fields. When fetching available fields in the v2 report editor, these
-- fields' custom sql was causing ~17 million rows to be queried
update flow.custom_field cf
set custom_field_sql_smartlist = null
where cf.custom_field_sql_key = any(array['customFieldSql.brs.designLogNumbers', 'customFieldSql.brs.proposalLogNumbers']);