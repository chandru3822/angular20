alter table if exists flow.smartlist
add column if not exists project_details boolean default false not null;

alter table if exists flow.smartlist_field_assignment
add column if not exists project_details_column varchar(100);

alter table if exists flow.smartlist_requirement
add column if not exists project_details_column varchar(100);