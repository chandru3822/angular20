alter table brs.project_details add column if not exists archived boolean;

update brs.project_details pd set archived = (select archived from flow.project p
                                           where p.id = pd.project_id)
where pd.archived is null;


ALTER TABLE brs.project_details ALTER COLUMN archived SET NOT NULL;
ALTER TABLE brs.project_details ALTER COLUMN archived SET default false;
