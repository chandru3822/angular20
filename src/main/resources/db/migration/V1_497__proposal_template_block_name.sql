alter table if exists brs.proposal_template_block
	add column if not exists block_name varchar(50) default null;
