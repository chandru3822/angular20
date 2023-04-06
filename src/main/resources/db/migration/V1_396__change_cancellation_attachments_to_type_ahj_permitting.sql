update flow.attachment a
set attachment_type_id = 1
where a.attachment_type_id = 462 and a.archived is not true;

insert into brs.feat_db_link_type (name, object_type_id)
select 'Permit - All', 4 WHERE not exists (select id from brs.feat_db_link_type where feat_db_link_type.name = 'Permit - All');

update brs.feat_db_ahj_permit_link apl
set link_type_id = (select fdlt.id from brs.feat_db_link_type fdlt where fdlt.name = 'Permit - All')
where apl.link_type_id = 4 or apl.link_type_id = 5;
update brs.feat_db_link_type set archived = true where id = 4;
update brs.feat_db_link_type set archived = true where id = 5;
