update flow.attachment a
set attachment_type_id = 1
where a.attachment_type_id = 462 and a.archived is not true;
