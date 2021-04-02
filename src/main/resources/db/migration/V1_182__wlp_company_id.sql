
update flow.white_listed_position wlp
set company_id = (select cf.company_id from flow.custom_field_group_assignment cfga
                                                inner join flow.custom_field cf on cfga.custom_field_id = cf.id
                  where cfga.id = wlp.custom_field_group_assignment_id
)
