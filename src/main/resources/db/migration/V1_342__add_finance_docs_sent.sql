alter table brs.installation_agreement_requests
    add column if not exists send_installation_agreement boolean;
