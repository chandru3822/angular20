-- alter table if exists brs.reimbursement_request
--     drop column if exists budget_type_id;
alter table if exists brs.reimbursement_request
add column if not exists budget_type_id integer references brs.budget_type(id);
CREATE INDEX if not exists rr_budget_type_id_idx ON brs.reimbursement_request (budget_type_id);

alter table if exists brs.reimbursement_request
    add column if not exists gl_code_id integer references brs.gl_code(id);
CREATE INDEX if not exists rr_gl_code_id_idx ON brs.reimbursement_request (gl_code_id);


--todo: ask carlin if this is cool
with t1 as (
    select e.expense_budget_id use_this_id,
           rr.id as rr_id
    from brs.expense e
             inner join brs.reimbursement_request rr on e.reimbursement_request_id = rr.id
    where (e.expense_budget_id is not null
        and rr.expense_budget_id is null)
       OR (e.expense_budget_id != rr.expense_budget_id)
)
update brs.reimbursement_request rr
set expense_budget_id = use_this_id
from t1
where t1.rr_id = rr.id;

update brs.reimbursement_request rr
set budget_type_id = (
    select deprecated_budget_type_id from brs.expense_budget eb
    where rr.expense_budget_id = eb.id
)
where rr.budget_type_id is null;

drop function if exists brs.get_available_budgets_for_user(p_platform_user_id bigint, p_expense_date date);

--todo: actually drop these when we do the release
alter table brs.expense_budget
rename budget_type_id to deprecated_budget_type_id;

alter table if exists brs.expense_budget
    rename original_expense_budget_id to deprecated_original_expense_budget_id;

--all the date tracking stuff
alter table if exists brs.reimbursement_request
add column if not exists date_submitted timestamp;
alter table if exists brs.reimbursement_request
    add column if not exists submitted_by_id bigint references flow.user(id);
CREATE INDEX if not exists rr_submitted_by_id_idx ON brs.reimbursement_request (submitted_by_id);

alter table if exists brs.reimbursement_request
    add column if not exists approval_date timestamp;
alter table if exists brs.reimbursement_request
    add column if not exists approved_by_id bigint references flow.user(id);
CREATE INDEX if not exists rr_approved_by_id_idx ON brs.reimbursement_request (approved_by_id);

alter table if exists brs.reimbursement_request
    add column if not exists paid_date timestamp;
alter table if exists brs.reimbursement_request
    add column if not exists paid_by_id bigint references flow.user(id);
CREATE INDEX if not exists rr_paid_by_id_idx ON brs.reimbursement_request (paid_by_id);

alter table if exists brs.reimbursement_request
    add column if not exists rejected_date timestamp;
alter table if exists brs.reimbursement_request
    add column if not exists rejected_by_id bigint references flow.user(id);
CREATE INDEX if not exists rr_rejected_by_id_idx ON brs.reimbursement_request (rejected_by_id);

update brs.reimbursement_request rr
set date_submitted = e.date_submitted,
    submitted_by_id = e.submitted_by_id,
    approval_date = e.approval_date,
    approved_by_id = e.approved_by_id,
    paid_by_id = e.paid_by_id,
    paid_date = e.paid_date,
    rejected_by_id = e.rejected_by_id,
    rejected_date = e.rejected_date
from brs.expense e
where e.reimbursement_request_id = rr.id;

drop function if exists brs.get_expense_drilldown(p_user_id bigint, p_start_date DATE, p_end_date DATE, p_status varchar, p_budget_id bigint);

ALTER TABLE IF EXISTS brs.expense
    RENAME TO deprecated_expense;

delete from brs.budget_template
where id > 0;


CREATE UNIQUE INDEX if not exists bt_unique_user_id ON brs.budget_template(user_id) WHERE (archived is false);

update brs.reimbursement_request
set approval_date = date_submitted,
    approved_by_id = submitted_by_id,
    reimbursement_request_status_id = 1
where approval_date is null
and submitted_by_id is not null;

insert into flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
select 31, 1, 2417170, 2417170
where not exists ( select fac.id from flow.feature_access_control fac where fac.feature_id = 31 and access_control_id = 1);

insert into flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
select 31, 2, 2417170, 2417170
where not exists ( select fac.id from flow.feature_access_control fac where fac.feature_id = 31 and access_control_id = 2);

insert into flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
select 31, 3, 2417170, 2417170
where not exists ( select fac.id from flow.feature_access_control fac where fac.feature_id = 31 and access_control_id = 3);

insert into flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
select 31, 5, 2417170, 2417170
where not exists ( select fac.id from flow.feature_access_control fac where fac.feature_id = 31 and access_control_id = 5);

insert into flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
select 31, 8, 2417170, 2417170
where not exists ( select fac.id from flow.feature_access_control fac where fac.feature_id = 31 and access_control_id = 8);