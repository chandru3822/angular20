create sequence if not exists brs.rebate_check_nbr_seq START WITH 1;
SELECT setval('brs.rebate_check_nbr_seq', COALESCE((SELECT MAX(check_number) + 1 FROM brs.project_rebate_payment), 1), false);
