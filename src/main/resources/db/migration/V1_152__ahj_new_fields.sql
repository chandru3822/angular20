alter table brs.ahj_permit
add column if not exists brs_technician_permit_submission_instructions text;

alter table brs.ahj_permit
    add column if not exists approval_instructions text;

alter table brs.ahj_permit
    add column if not exists brs_technician_permit_pickup_and_delivery_instructions text;

alter table brs.ahj_permit
    add column if not exists cancellation_and_refund_instructions text;
