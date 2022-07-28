alter table if exists brs.design_log
add if not exists bom_with_part_number jsonb;

alter table if exists brs.design_log_history
add if not exists bom_with_part_number jsonb;