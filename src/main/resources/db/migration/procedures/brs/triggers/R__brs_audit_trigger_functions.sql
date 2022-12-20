-- ### DESIGN ###
drop trigger if exists ahj_design_custom_field_value_audit_trg ON brs.feat_db_ahj_design_custom_field_value;

drop function if exists brs.ahj_design_audit();
CREATE OR REPLACE FUNCTION brs.ahj_design_audit()
    RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        insert into brs.feat_db_ahj_design_custom_field_value_audit(ahj_design_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(new.id,null,case when new.date_value is not null then new.date_value::text
                                when new.timestamp_value is not null then new.timestamp_value::text
                                when new.text_value is not null then new.text_value
                                when new.numeric_value is not null then new.numeric_value::text
                                when new.int_value is not null then new.int_value::text
                                when new.int_array_value is not null then new.int_array_value::text
                                when new.boolean_value is not null then new.boolean_value::text end,
               now(),
               new.modified_by_id);
    elsif (TG_OP = 'UPDATE') THEN
        insert into brs.feat_db_ahj_design_custom_field_value_audit(ahj_design_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(old.id,case when old.date_value is not null then old.date_value::text
                           when old.timestamp_value is not null then old.timestamp_value::text
                           when old.text_value is not null then old.text_value
                           when old.numeric_value is not null then old.numeric_value::text
                           when old.int_value is not null then old.int_value::text
                           when old.int_array_value is not null then old.int_array_value::text
                           when old.boolean_value is not null then old.boolean_value::text end,
               case when new.date_value is not null then new.date_value::text
                    when new.timestamp_value is not null then new.timestamp_value::text
                    when new.text_value is not null then new.text_value
                    when new.numeric_value is not null then new.numeric_value::text
                    when new.int_value is not null then new.int_value::text
                    when new.int_array_value is not null then new.int_array_value::text
                    when new.boolean_value is not null then new.boolean_value::text end,
               now(),
               new.modified_by_id);
    ELSIF (TG_OP = 'DELETE') THEN
        insert into brs.feat_db_ahj_design_custom_field_value_audit(ahj_design_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(old.id,case when old.date_value is not null then old.date_value::text
                           when old.timestamp_value is not null then old.timestamp_value::text
                           when old.text_value is not null then old.text_value
                           when old.numeric_value is not null then old.numeric_value::text
                           when old.int_value is not null then old.int_value::text
                           when old.int_array_value is not null then old.int_array_value::text
                           when old.boolean_value is not null then old.boolean_value::text end,
               null,
               now(),
               new.modified_by_id);
    end if;

    RETURN NULL;
END
$$
    LANGUAGE plpgsql;

CREATE TRIGGER ahj_design_custom_field_value_audit_trg
    after INSERT or update or delete ON brs.feat_db_ahj_design_custom_field_value
    FOR EACH ROW EXECUTE PROCEDURE brs.ahj_design_audit();

-- ### INSPECTION ###
drop trigger if exists ahj_inspection_custom_field_value_audit_trg ON brs.feat_db_ahj_inspection_custom_field_value;

drop function if exists brs.ahj_inspection_audit();
CREATE OR REPLACE FUNCTION brs.ahj_inspection_audit()
  RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    insert into brs.feat_db_ahj_inspection_custom_field_value_audit(ahj_inspection_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(new.id,null,case when new.date_value is not null then new.date_value::text
                            when new.timestamp_value is not null then new.timestamp_value::text
                            when new.text_value is not null then new.text_value
                            when new.numeric_value is not null then new.numeric_value::text
                            when new.int_value is not null then new.int_value::text
                            when new.int_array_value is not null then new.int_array_value::text
                            when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  elsif (TG_OP = 'UPDATE') THEN
    insert into brs.feat_db_ahj_inspection_custom_field_value_audit(ahj_inspection_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           case when new.date_value is not null then new.date_value::text
                when new.timestamp_value is not null then new.timestamp_value::text
                when new.text_value is not null then new.text_value
                when new.numeric_value is not null then new.numeric_value::text
                when new.int_value is not null then new.int_value::text
                when new.int_array_value is not null then new.int_array_value::text
                when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  ELSIF (TG_OP = 'DELETE') THEN
    insert into brs.feat_db_ahj_inspection_custom_field_value_audit(ahj_inspection_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           null,
           now(),
           new.modified_by_id);
  end if;

  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

CREATE TRIGGER ahj_inspection_custom_field_value_audit_trg
  after INSERT or update or delete ON brs.feat_db_ahj_inspection_custom_field_value
  FOR EACH ROW EXECUTE PROCEDURE brs.ahj_inspection_audit();

-- ### PERMIT ###
drop trigger if exists ahj_permit_custom_field_value_audit_trg ON brs.feat_db_ahj_permit_custom_field_value;

drop function if exists brs.ahj_permit_audit();
CREATE OR REPLACE FUNCTION brs.ahj_permit_audit()
  RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    insert into brs.feat_db_ahj_permit_custom_field_value_audit(ahj_permit_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(new.id,null,case when new.date_value is not null then new.date_value::text
                            when new.timestamp_value is not null then new.timestamp_value::text
                            when new.text_value is not null then new.text_value
                            when new.numeric_value is not null then new.numeric_value::text
                            when new.int_value is not null then new.int_value::text
                            when new.int_array_value is not null then new.int_array_value::text
                            when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  elsif (TG_OP = 'UPDATE') THEN
    insert into brs.feat_db_ahj_permit_custom_field_value_audit(ahj_permit_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           case when new.date_value is not null then new.date_value::text
                when new.timestamp_value is not null then new.timestamp_value::text
                when new.text_value is not null then new.text_value
                when new.numeric_value is not null then new.numeric_value::text
                when new.int_value is not null then new.int_value::text
                when new.int_array_value is not null then new.int_array_value::text
                when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  ELSIF (TG_OP = 'DELETE') THEN
    insert into brs.feat_db_ahj_permit_custom_field_value_audit(ahj_permit_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           null,
           now(),
           new.modified_by_id);
  end if;

  RETURN NULL;
END
$$
  LANGUAGE plpgsql;


CREATE TRIGGER ahj_permit_custom_field_value_audit_trg
  after INSERT or update or delete ON brs.feat_db_ahj_permit_custom_field_value
  FOR EACH ROW EXECUTE PROCEDURE brs.ahj_permit_audit();

-- ### UTILITY ###
drop trigger if exists utility_custom_field_value_audit_trg ON brs.feat_db_utility_custom_field_value;

drop function if exists brs.utility_audit();
CREATE OR REPLACE FUNCTION brs.utility_audit()
  RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    insert into brs.feat_db_utility_custom_field_value_audit(utility_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(new.id,null,case when new.date_value is not null then new.date_value::text
                            when new.timestamp_value is not null then new.timestamp_value::text
                            when new.text_value is not null then new.text_value
                            when new.numeric_value is not null then new.numeric_value::text
                            when new.int_value is not null then new.int_value::text
                            when new.int_array_value is not null then new.int_array_value::text
                            when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  elsif (TG_OP = 'UPDATE') THEN
    insert into brs.feat_db_utility_custom_field_value_audit(utility_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           case when new.date_value is not null then new.date_value::text
                when new.timestamp_value is not null then new.timestamp_value::text
                when new.text_value is not null then new.text_value
                when new.numeric_value is not null then new.numeric_value::text
                when new.int_value is not null then new.int_value::text
                when new.int_array_value is not null then new.int_array_value::text
                when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  ELSIF (TG_OP = 'DELETE') THEN
    insert into brs.feat_db_utility_custom_field_value_audit(utility_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           null,
           now(),
           new.modified_by_id);
  end if;

  RETURN NULL;
END
$$
  LANGUAGE plpgsql;


CREATE TRIGGER utility_custom_field_value_audit_trg
  after INSERT or update or delete ON brs.feat_db_utility_custom_field_value
  FOR EACH ROW EXECUTE PROCEDURE brs.utility_audit();

-- ### COMMISSION OVERRIDE ###
drop trigger if exists commission_override_custom_field_value_audit_trg ON brs.commission_override_custom_field_value;

drop function if exists brs.commission_override_audit();
CREATE OR REPLACE FUNCTION brs.commission_override_audit()
  RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    insert into brs.commission_override_custom_field_value_audit(commission_override_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(new.id,null,case when new.date_value is not null then new.date_value::text
                            when new.timestamp_value is not null then new.timestamp_value::text
                            when new.text_value is not null then new.text_value
                            when new.numeric_value is not null then new.numeric_value::text
                            when new.int_value is not null then new.int_value::text
                            when new.int_array_value is not null then new.int_array_value::text
                            when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  elsif (TG_OP = 'UPDATE') THEN
    insert into brs.commission_override_custom_field_value_audit(commission_override_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           case when new.date_value is not null then new.date_value::text
                when new.timestamp_value is not null then new.timestamp_value::text
                when new.text_value is not null then new.text_value
                when new.numeric_value is not null then new.numeric_value::text
                when new.int_value is not null then new.int_value::text
                when new.int_array_value is not null then new.int_array_value::text
                when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  ELSIF (TG_OP = 'DELETE') THEN
    insert into brs.commission_override_custom_field_value_audit(commission_override_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           null,
           now(),
           new.modified_by_id);
  end if;

  RETURN NULL;
END
$$
  LANGUAGE plpgsql;


CREATE TRIGGER commission_override_custom_field_value_audit_trg
  after INSERT or update or delete ON brs.commission_override_custom_field_value
  FOR EACH ROW EXECUTE PROCEDURE brs.commission_override_audit();

-- ### PROPOSAL ###
drop trigger if exists proposal_custom_field_value_audit_trg ON brs.proposal_custom_field_value;

drop function if exists brs.proposal_audit();
CREATE OR REPLACE FUNCTION brs.proposal_audit()
  RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    insert into brs.proposal_custom_field_value_audit(proposal_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(new.id,null,case when new.date_value is not null then new.date_value::text
                            when new.timestamp_value is not null then new.timestamp_value::text
                            when new.text_value is not null then new.text_value
                            when new.numeric_value is not null then new.numeric_value::text
                            when new.int_value is not null then new.int_value::text
                            when new.int_array_value is not null then new.int_array_value::text
                            when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  elsif (TG_OP = 'UPDATE') THEN
    insert into brs.proposal_custom_field_value_audit(proposal_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           case when new.date_value is not null then new.date_value::text
                when new.timestamp_value is not null then new.timestamp_value::text
                when new.text_value is not null then new.text_value
                when new.numeric_value is not null then new.numeric_value::text
                when new.int_value is not null then new.int_value::text
                when new.int_array_value is not null then new.int_array_value::text
                when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  ELSIF (TG_OP = 'DELETE') THEN
    insert into brs.proposal_custom_field_value_audit(proposal_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           null,
           now(),
           new.modified_by_id);
  end if;

  RETURN NULL;
END
$$
  LANGUAGE plpgsql;


CREATE TRIGGER proposal_custom_field_value_audit_trg
  after INSERT or update or delete ON brs.proposal_custom_field_value
  FOR EACH ROW EXECUTE PROCEDURE brs.proposal_audit();

-- ### PROPOSAL VERSION ###
drop trigger if exists proposal_version_custom_field_value_audit_trg ON brs.proposal_version_custom_field_value;

drop function if exists brs.proposal_version_audit();
CREATE OR REPLACE FUNCTION brs.proposal_version_audit()
  RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    insert into brs.proposal_version_custom_field_value_audit(proposal_version_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(new.id,null,new.value,
           now(),
           new.modified_by_id);
  elsif (TG_OP = 'UPDATE') THEN
    insert into brs.proposal_version_custom_field_value_audit(proposal_version_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,old.value,
           new.value,
           now(),
           new.modified_by_id);
  ELSIF (TG_OP = 'DELETE') THEN
    insert into brs.proposal_version_custom_field_value_audit(proposal_version_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,old.value,
           null,
           now(),
           new.modified_by_id);
  end if;

  RETURN NULL;
END
$$
  LANGUAGE plpgsql;


CREATE TRIGGER proposal_version_custom_field_value_audit_trg
  after INSERT or update or delete ON brs.proposal_version_custom_field_value
  FOR EACH ROW EXECUTE PROCEDURE brs.proposal_version_audit();

-- ### HOA ###
drop trigger if exists hoa_custom_field_value_audit_trg ON brs.feat_db_hoa_custom_field_value;

drop function if exists brs.hoa_audit();
CREATE OR REPLACE FUNCTION brs.hoa_audit()
  RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    insert into brs.feat_db_hoa_custom_field_value_audit(hoa_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(new.id,null,case when new.date_value is not null then new.date_value::text
                            when new.timestamp_value is not null then new.timestamp_value::text
                            when new.text_value is not null then new.text_value
                            when new.numeric_value is not null then new.numeric_value::text
                            when new.int_value is not null then new.int_value::text
                            when new.int_array_value is not null then new.int_array_value::text
                            when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  elsif (TG_OP = 'UPDATE') THEN
    insert into brs.feat_db_hoa_custom_field_value_audit(hoa_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           case when new.date_value is not null then new.date_value::text
                when new.timestamp_value is not null then new.timestamp_value::text
                when new.text_value is not null then new.text_value
                when new.numeric_value is not null then new.numeric_value::text
                when new.int_value is not null then new.int_value::text
                when new.int_array_value is not null then new.int_array_value::text
                when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  ELSIF (TG_OP = 'DELETE') THEN
    insert into brs.feat_db_hoa_custom_field_value_audit(hoa_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           null,
           now(),
           new.modified_by_id);
  end if;

  RETURN NULL;
END
$$
  LANGUAGE plpgsql;

CREATE TRIGGER hoa_custom_field_value_audit_trg
  after INSERT or update or delete ON brs.feat_db_hoa_custom_field_value
  FOR EACH ROW EXECUTE PROCEDURE brs.hoa_audit();
