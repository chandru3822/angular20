--renaming since smartlists v2 is adding actual sharing
alter table if exists flow.smartlist rename column shared to public;

--this functionality is being removed
alter table if exists flow.smartlist drop column if exists view_object_type_id;