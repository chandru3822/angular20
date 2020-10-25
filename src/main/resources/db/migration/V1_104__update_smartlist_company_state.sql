update flow.smartlist_field
set
  join_column = 'company_state_id'
where
  name = 'Contact State' or
  name = 'Project State'