drop sequence if exists brs.proposal_excel_id_seq;
create sequence if not exists brs.proposal_excel_id_seq
  as integer
  minvalue 1000
  maxvalue 9999
  cycle;
