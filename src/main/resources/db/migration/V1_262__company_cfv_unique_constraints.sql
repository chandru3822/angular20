-- drop them all first so stage doesn't break
ALTER TABLE brs.proposal_custom_field_value drop CONSTRAINT if exists pcfv_proposal_id_cfga_id;
ALTER TABLE brs.commission_override_custom_field_value drop CONSTRAINT if exists cocfv_override_plan_id_cfga_id;
ALTER TABLE brs.ahj_utility_custom_field_value drop CONSTRAINT if exists aucfv_ahj_utility_id_cfga_id;
ALTER TABLE brs.ahj_design_custom_field_value drop CONSTRAINT if exists adcfv_ahj_design_id_cfga_id;
ALTER TABLE brs.ahj_inspection_custom_field_value drop CONSTRAINT if exists aicfv_ahj_inspection_id_cfga_id;
ALTER TABLE brs.ahj_permit_custom_field_value drop CONSTRAINT if exists apcfv_ahj_permit_id_cfga_id;

-- add constraints so upserts will work. and just cuz it is gooooooder
ALTER TABLE brs.proposal_custom_field_value
  ADD CONSTRAINT pcfv_proposal_id_cfga_id UNIQUE (proposal_id, custom_field_group_assignment_id);

ALTER TABLE brs.commission_override_custom_field_value
  ADD CONSTRAINT cocfv_override_plan_id_cfga_id UNIQUE (override_plan_id, custom_field_group_assignment_id);

ALTER TABLE brs.ahj_utility_custom_field_value
  ADD CONSTRAINT aucfv_ahj_utility_id_cfga_id UNIQUE (ahj_utility_id, custom_field_group_assignment_id);

ALTER TABLE brs.ahj_design_custom_field_value
  ADD CONSTRAINT adcfv_ahj_design_id_cfga_id UNIQUE (ahj_design_id, custom_field_group_assignment_id);

ALTER TABLE brs.ahj_inspection_custom_field_value
  ADD CONSTRAINT aicfv_ahj_inspection_id_cfga_id UNIQUE (ahj_inspection_id, custom_field_group_assignment_id);

ALTER TABLE brs.ahj_permit_custom_field_value
  ADD CONSTRAINT apcfv_ahj_permit_id_cfga_id UNIQUE (ahj_permit_id, custom_field_group_assignment_id);

--drop/add indexes that i screwed up
drop index if exists fki_pcfv_proposal_id;
drop index if exists fki_pcfv_custom_field_group_assignment_id;
CREATE INDEX if not exists fki_pcfv_proposal_id on brs.proposal_custom_field_value (proposal_id);
CREATE INDEX if not exists fki_pcfv_custom_field_group_assignment_id on brs.proposal_custom_field_value (custom_field_group_assignment_id);

--add indexes i forgot
CREATE INDEX if not exists fki_cocfv_override_plan_id on brs.commission_override_custom_field_value (override_plan_id);
CREATE INDEX if not exists fki_cocfv_custom_field_group_assignment_id on brs.commission_override_custom_field_value (custom_field_group_assignment_id);

CREATE INDEX if not exists fki_aucfv_ahj_utility_id on brs.ahj_utility_custom_field_value (ahj_utility_id);
CREATE INDEX if not exists fki_aucfv_custom_field_group_assignment_id on brs.ahj_utility_custom_field_value (custom_field_group_assignment_id);

CREATE INDEX if not exists fki_adcfv_ahj_design_id on brs.ahj_design_custom_field_value (ahj_design_id);
CREATE INDEX if not exists fki_adcfv_custom_field_group_assignment_id on brs.ahj_design_custom_field_value (custom_field_group_assignment_id);

CREATE INDEX if not exists fki_aicfv_ahj_inspection_id on brs.ahj_inspection_custom_field_value (ahj_inspection_id);
CREATE INDEX if not exists fki_aicfv_custom_field_group_assignment_id on brs.ahj_inspection_custom_field_value (custom_field_group_assignment_id);

CREATE INDEX if not exists fki_apcfv_ahj_permit_id on brs.ahj_permit_custom_field_value (ahj_permit_id);
CREATE INDEX if not exists fki_apcfv_custom_field_group_assignment_id on brs.ahj_permit_custom_field_value (custom_field_group_assignment_id);
