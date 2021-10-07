CREATE TABLE if not exists flow.feature_access_control
(
  id                       serial  NOT NULL,
  feature_id       integer NOT NULL,
  access_control_id       integer NOT NULL,
  date_created     timestamp without time zone DEFAULT now(),
  date_modified   timestamp without time zone,
  created_by_id    integer      not null,
  modified_by_id  integer,
  archived       boolean not null default false,
  CONSTRAINT flow_feature_access_control_pk PRIMARY KEY (id),
  CONSTRAINT flow_fac_feature_id_fk FOREIGN KEY (feature_id)
    REFERENCES flow.feature (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_fac_access_control_id_fk FOREIGN KEY (access_control_id)
    REFERENCES flow.access_control (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_fac_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_fac_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

alter table flow.feature_access_control drop constraint if exists fac_feature_id_access_control_id_uk;

ALTER TABLE flow.feature_access_control
  ADD CONSTRAINT fac_feature_id_access_control_id_uk UNIQUE (feature_id, access_control_id);

delete from flow.feature_access_control where id > 0;

-- process steps
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(1, 1, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(1, 3, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(1, 2, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(1, 5, 2417170);

-- contacts
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(2, 1, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(2, 2, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(2, 3, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(2, 4, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(2, 5, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(2, 6, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(2, 7, 2417170);

-- schedule
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(4, 1, 2417170);

-- ahj db
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(6, 1, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(6, 2, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(6, 3, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(6, 4, 2417170);

-- work queue
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(7, 1, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(7, 5, 2417170);

-- users
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(8, 1, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(8, 2, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(8, 3, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(8, 4, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(8, 5, 2417170);

-- orgs
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(9, 1, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(9, 2, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(9, 3, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(9, 5, 2417170);

-- settings
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(10, 1, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(10, 2, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(10, 3, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(10, 4, 2417170);

-- projects
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(11, 1, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(11, 2, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(11, 3, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(11, 4, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(11, 5, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(11, 6, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(11, 7, 2417170);

-- commissions
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(13, 1, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(13, 2, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(13, 3, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(13, 4, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(13, 5, 2417170);

-- closer dashboard
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(14, 1, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(14, 6, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(14, 7, 2417170);

-- setter dashboard
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(15, 1, 2417170);

-- rebates
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(16, 1, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(16, 2, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(16, 3, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(16, 4, 2417170);

-- install agreement
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(18, 1, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(18, 3, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(18, 6, 2417170);

-- smartlist
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(19, 1, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(19, 2, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(19, 3, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(19, 4, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(19, 5, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(19, 6, 2417170);

-- availablitiyt
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(20, 1, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(20, 2, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(20, 3, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(20, 4, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(20, 5, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(20, 6, 2417170);

-- access control
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(21, 1, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(21, 2, 2417170);

-- closer availaaiblity
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(22, 1, 2417170);

-- electronic docs
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(23, 1, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(23, 3, 2417170);

-- company dash
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(24, 1, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(24, 5, 2417170);

-- round robin
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(25, 1, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(25, 2, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(25, 3, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(25, 4, 2417170);

-- call groups
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(26, 1, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(26, 2, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(26, 3, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(26, 4, 2417170);

-- tournaments
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(27, 1, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(27, 2, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(27, 3, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(27, 5, 2417170);

-- sms queue
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(28, 1, 2417170);

-- installer dash
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values(29, 1, 2417170);

-- masquerade -- these last 3 are the only ones where the ids dont match in prod
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values((select id
from flow.feature where feature_code = 'MASQUERADE' ), 5, 2417170);

-- expenses -- these last 3 are the only ones where the ids dont match in prod
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values((select id
        from flow.feature where feature_code = 'EXPENSES' ), 1, 2417170);
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values((select id
        from flow.feature where feature_code = 'EXPENSES' ), 5, 2417170);

-- reimbursement -- these last 3 are the only ones where the ids dont match in prod
insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
values((select id
        from flow.feature where feature_code = 'REIMBURSEMENT' ), 1, 2417170);

-- dont do this yet till you put the feature out there
-- delete all irrelevant position_feature_access_control rows
-- DELETE FROM flow.position_feature_access_control
-- WHERE id not IN (
--   SELECT pfac.id
--   FROM flow.position_feature_access_control pfac
--          inner join flow.company_feature cf on pfac.company_feature_id = cf.id
--          inner join flow.access_control ac on pfac.access_control_id = ac.id
--          inner join flow.feature_access_control fac on ac.id = fac.access_control_id and fac.feature_id = cf.feature_id
-- );
-- delete all irrelevant user_feature_access_control rows
-- DELETE FROM flow.user_feature_access_control
-- WHERE id not IN (
--   SELECT pfac.id
--   FROM flow.user_feature_access_control pfac
--          inner join flow.company_feature cf on pfac.company_feature_id = cf.id
--          inner join flow.access_control ac on pfac.access_control_id = ac.id
--          inner join flow.feature_access_control fac on ac.id = fac.access_control_id and fac.feature_id = cf.feature_id
-- );
