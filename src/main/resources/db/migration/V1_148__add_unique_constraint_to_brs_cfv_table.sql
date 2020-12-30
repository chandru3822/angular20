--delete existing/known rows that violate the new unique constraint (row with most recent date_modified or date_created (if date_modified is null) is being kept for each set of duplicated source_id / custom_field_group_assignment_id pairs)
delete from brs.custom_field_value where id in (44309, 31633, 31634, 33071, 33069, 33067, 33065, 33063, 33061, 33059, 33072, 33070, 33068, 33066, 33064, 33062, 33060, 33913, 48914, 32993);

alter table brs.custom_field_value
    drop constraint if exists cfv_unique_cfga_source_id;

alter table brs.custom_field_value
    add constraint cfv_unique_cfga_source_id unique (source_id, custom_field_group_assignment_id);
