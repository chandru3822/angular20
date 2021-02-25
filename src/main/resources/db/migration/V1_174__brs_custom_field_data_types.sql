--do this when randa forgets to set it back first:
-- alter table brs.custom_field
--     rename column company_data_type_id to data_type_id;

-- rename the column
alter table brs.custom_field
    rename column data_type_id to company_data_type_id;

ALTER TABLE brs.custom_field
    DROP CONSTRAINT if exists brs_cf_company_data_type_id_fk;

ALTER TABLE brs.custom_field
    add CONSTRAINT brs_cf_company_data_type_id_fk FOREIGN KEY (company_data_type_id)
        REFERENCES flow.company_data_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE brs.custom_field
    DROP CONSTRAINT if exists brs_cf_data_type_id_fk;

drop table if exists brs.data_type;
