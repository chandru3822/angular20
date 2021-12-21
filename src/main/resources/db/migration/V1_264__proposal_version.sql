alter table brs.proposal
  add column if not exists proposal_version_id int references brs.proposal_version(id);

CREATE INDEX if not exists fki_brsp_proposal_version_id on brs.proposal (proposal_version_id);

alter table brs.proposal alter column proposal_version_id set not null;
