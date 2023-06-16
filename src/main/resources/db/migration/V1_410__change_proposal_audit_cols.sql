alter table brs.proposal
  alter column date_created type timestamptz using date_created::timestamptz;

alter table brs.proposal
  alter column date_modified type timestamptz using date_modified::timestamptz;

