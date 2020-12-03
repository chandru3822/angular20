insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
        (select insp.id,
                (select cfga.id from brs.custom_field_group_assignment cfga
                    where cfga.custom_field_group_id = 19
                    and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Homeowner Required to be On-Site')),
                null,
                null,
                now(),
                99999999
         from blueraven.ahj_inspection insp
         where insp.homeowner_required_on_site is not null
        );
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Homeowner Required to be On-Site'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = a.homeowner_required_on_site
     ) as v
where id = cfv_id;
-- this one is like the one above it
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 18
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Fall Protection for Inspector Required')),
            null,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.fall_protection_required is not null
    );
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Fall Protection for Inspector Required'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = a.fall_protection_required
     ) as v
where id = cfv_id;
-- this one is like the one above it
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 19
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Call For Time Window')),
            null,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.call_for_time_window is not null
    );
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Call For Time Window'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = a.call_for_time_window
     ) as v
where id = cfv_id;

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 17
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Information to have Handy')),
            insp.handy_information_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.handy_information_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_handy_information_type hit on hit.id = a.handy_information_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Information to have Handy'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 17
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Inspection Capacity per Day')),
            insp.inspection_capacity_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.inspection_capacity_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_inspection_capacity_type hit on hit.id = a.inspection_capacity_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Inspection Capacity per Day'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 17
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Placard Required')),
            insp.placard_required_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.placard_required_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_placard_required_type hit on hit.id = a.placard_required_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Placard Required'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 18
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Plans Required On-Site')),
            insp.plans_required_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.plans_required_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_plans_required_type hit on hit.id = a.plans_required_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Plans Required On-Site'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 11
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Followup Method')),
            insp.followup_method_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_utility insp
     where insp.followup_method_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_utility a on a.id = cfv.source_id
                  inner join blueraven.ahj_pto_followup_type hit on hit.id = a.followup_method_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Followup Method'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 21
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Re-inspection Fee Required')),
            insp.reinspection_fee_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.reinspection_fee_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_reinspection_fee_type hit on hit.id = a.reinspection_fee_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Re-inspection Fee Required'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 18
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Representative Required On-Site')),
            insp.representative_required_onsite_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.representative_required_onsite_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_representative_required_onsite_type hit on hit.id = a.representative_required_onsite_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Representative Required On-Site'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 20
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Results Documentation')),
            insp.results_documentation_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.results_documentation_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_results_documentation_type hit on hit.id = a.results_documentation_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Results Documentation'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 17
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Mid-Point / Rough Inspection Required')),
            insp.rough_inspection_required_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.rough_inspection_required_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_rough_inspection_required_type hit on hit.id = a.rough_inspection_required_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Mid-Point / Rough Inspection Required'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 17
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Customer Scheduling Lead Time (Days)')),
            insp.scheduling_lead_time_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.scheduling_lead_time_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_scheduling_lead_time_type hit on hit.id = a.scheduling_lead_time_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Customer Scheduling Lead Time (Days)'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

with parent as (
    insert into brs.list_of_value( name, parent_id, display_order, date_created, created_by_id, archived)
        values('AHJ Maximum Advanced Scheduling (Days)',null,1,now(),99999999,false)
        returning id ),
     lov as ( insert into brs.list_of_value( name, parent_id, show_other, display_order, date_created, created_by_id, archived)
         ( select cdv.title,(select p.id from parent p), case when cdv.title = 'Other' then true else false end,1,now(),2350555, cdv.archived
           from blueraven.custom_dropdown_value cdv
           where cdv.custom_dropdown_field_id = 32)),
     cf as (insert into brs.custom_field(list_of_value_id, field_name, data_type_id, date_created, created_by_id, archived)
         ( select p.id, 'AHJ Maximum Advanced Scheduling (Days)', 7, now(), 99999999, false from parent p) returning id),
     cfga as (insert into brs.custom_field_group_assignment(custom_field_group_id, custom_field_id, field_order, archived, date_created, created_by_id)
         (select 17, cf.id, 1, false, now(), 99999999 from cf) returning id)
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 17
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'AHJ Maximum Advanced Scheduling (Days)')),
            insp.ahj_max_advanced_scheduling_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.ahj_max_advanced_scheduling_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.custom_dropdown_value cdv on cdv.id = a.ahj_max_advanced_scheduling_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'AHJ Maximum Advanced Scheduling (Days)'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = cdv.title
     ) as v
where id = cfv_id;

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 17
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Primary Scheduling Method')),
            insp.scheduling_method_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.scheduling_method_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_scheduling_method_type hit on hit.id = a.scheduling_method_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Primary Scheduling Method'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 8
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Signature Requested At')),
            insp.signature_requested_at_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_utility insp
     where insp.signature_requested_at_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_utility a on a.id = cfv.source_id
                  inner join blueraven.ahj_signature_requested_at_type hit on hit.id = a.signature_requested_at_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Signature Requested At'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 8
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Interconnection Application Signature')),
            null, -- there was no 'other' type for this one
            null,
            now(),
            99999999
     from blueraven.ahj_utility insp
     where insp.signature_requested_at_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_utility a on a.id = cfv.source_id
                  inner join blueraven.ahj_interconnection_application_signature_type hit on hit.id = a.interconnection_application_signature_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Interconnection Application Signature'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 17
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Site Access Required')),
            insp.site_access_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.site_access_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_site_access_type hit on hit.id = a.site_access_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Site Access Required'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 17
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'SolaDeck Access Required')),
            insp.soladeck_access_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.soladeck_access_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_soladeck_access_type hit on hit.id = a.soladeck_access_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'SolaDeck Access Required'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 18
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Special Documents Required')),
            insp.special_documents_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.special_documents_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_special_documents_type hit on hit.id = a.special_documents_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Special Documents Required'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 18
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Special Equipment Needed')),
            insp.special_equipment_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_inspection insp
     where insp.special_equipment_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_inspection a on a.id = cfv.source_id
                  inner join blueraven.ahj_special_equipment_type hit on hit.id = a.special_equipment_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Special Equipment Needed'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 11
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Inspection Submission Method')),
            insp.inspection_submission_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_utility insp
     where insp.inspection_submission_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_utility a on a.id = cfv.source_id
                  inner join blueraven.ahj_utility_inspection_submission_type hit on hit.id = a.inspection_submission_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Inspection Submission Method'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 11
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Utility Method')),
            insp.utility_method_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_utility insp
     where insp.utility_method_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_utility a on a.id = cfv.source_id
                  inner join blueraven.ahj_utility_method_type hit on hit.id = a.utility_method_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Utility Method'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 10
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Submission Method')),
            insp.submission_method_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_utility insp
     where insp.submission_method_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_utility a on a.id = cfv.source_id
                  inner join blueraven.ahj_utility_submission_type hit on hit.id = a.submission_method_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Submission Method'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select insp.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 10
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'When to Create Application')),
            insp.when_to_create_application_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_utility insp
     where insp.when_to_create_application_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_utility a on a.id = cfv.source_id
                  inner join blueraven.ahj_when_to_create_application_type hit on hit.id = a.when_to_create_application_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'When to Create Application'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

-- these 2 are different because they are used for multiple fields
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_permit a on a.id = cfv.source_id
                  inner join blueraven.ahj_submit_type hit on hit.id = a.submission_payment_type_id --submission payment type id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Payment Method'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
-- update all the lovs for the custom_field_value rows that were just created
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select perm.id,
                 (select cfga.id from brs.custom_field_group_assignment cfga
                  where cfga.custom_field_group_id = 1
                    and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Payment Method')),
                 perm.submission_payment_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_permit perm
          where perm.submission_payment_type_id is not null
         );
    insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select perm.id,
                 (select cfga.id from brs.custom_field_group_assignment cfga
                  where cfga.custom_field_group_id = 2
                    and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Payment Method')),
                 perm.revision_payment_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_permit perm
          where perm.revision_payment_type_id is not null
         );
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select perm.id,
                 (select cfga.id from brs.custom_field_group_assignment cfga
                  where cfga.custom_field_group_id = 3
                    and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Payment Method')),
                 perm.as_built_submittal_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_permit perm
          where perm.as_built_payment_type_id is not null
         );
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select perm.id,
                 (select cfga.id from brs.custom_field_group_assignment cfga
                  where cfga.custom_field_group_id = 4
                    and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Payment Method')),
                 perm.follow_up_payment_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_permit perm
          where perm.follow_up_payment_type_id is not null
         );
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select perm.id,
                 (select cfga.id from brs.custom_field_group_assignment cfga
                  where cfga.custom_field_group_id = 5
                    and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Payment Method')),
                 perm.delivery_payment_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_permit perm
          where perm.delivery_payment_type_id is not null
         );
     insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select perm.id,
                 (select cfga.id from brs.custom_field_group_assignment cfga
                  where cfga.custom_field_group_id = 1
                    and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Submittal Method')),
                 perm.submittal_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_permit perm
          where perm.submittal_type_id is not null
         );
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select perm.id,
                 (select cfga.id from brs.custom_field_group_assignment cfga
                  where cfga.custom_field_group_id = 2
                    and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Submittal Method')),
                 perm.revision_submittal_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_permit perm
          where perm.revision_submittal_type_id is not null
         );

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select perm.id,
                 (select cfga.id from brs.custom_field_group_assignment cfga
                  where cfga.custom_field_group_id = 3
                    and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Submittal Method')),
                 perm.as_built_submittal_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_permit perm
          where perm.as_built_submittal_type_id is not null
         )

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
    (select perm.id,
            (select cfga.id from brs.custom_field_group_assignment cfga
             where cfga.custom_field_group_id = 5
               and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Pickup Method')),
            perm.delivery_pickup_type_other,
            null,
            now(),
            99999999
     from blueraven.ahj_permit perm
     where perm.delivery_pickup_type_id is not null
    )
;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_permit a on a.id = cfv.source_id
                  inner join blueraven.ahj_submit_type hit on hit.id = a.revision_payment_type_id -- revision payment
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Payment Method'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_permit a on a.id = cfv.source_id
                  inner join blueraven.ahj_submit_type hit on hit.id = a.as_built_payment_type_id -- as built payment
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Payment Method'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_permit a on a.id = cfv.source_id
                  inner join blueraven.ahj_submit_type hit on hit.id = a.follow_up_payment_type_id --follow up payment
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Payment Method'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_permit a on a.id = cfv.source_id
                  inner join blueraven.ahj_submit_type hit on hit.id = a.delivery_payment_type_id -- delivery payment type
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Payment Method'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_permit a on a.id = cfv.source_id
                  inner join blueraven.ahj_submit_type hit on hit.id = a.submittal_type_id -- submittal type
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Submittal Method'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_permit a on a.id = cfv.source_id
                  inner join blueraven.ahj_submit_type hit on hit.id = a.revision_submittal_type_id  -- revision sub
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Submittal Method'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_permit a on a.id = cfv.source_id
                  inner join blueraven.ahj_submit_type hit on hit.id = a.as_built_submittal_type_id -- as buil sub
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Submittal Method'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_permit a on a.id = cfv.source_id
                  inner join blueraven.ahj_submit_type hit on hit.id = a.delivery_pickup_type_id -- delivery pickup
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Pickup Method'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;

insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select perm.id,
                 (select cfga.id from brs.custom_field_group_assignment cfga
                  where cfga.custom_field_group_id = 1
                    and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'HOA Approval Required for Submission')),
                 perm.hoa_approval_required_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_permit perm
          where perm.hoa_approval_required_type_id is not null
         );
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select perm.id,
                 (select cfga.id from brs.custom_field_group_assignment cfga
                  where cfga.custom_field_group_id = 1
                    and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'NEM Approval Required for Submission')),
                 perm.nem_approval_required_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_permit perm
          where perm.nem_approval_required_type_id is not null
         );
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select util.id,
                 (select cfga.id from brs.custom_field_group_assignment cfga
                  where cfga.custom_field_group_id = 7
                    and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Rebate Program')),
                 util.rebate_program_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_utility util
          where util.rebate_program_type_id is not null
         );
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select util.id,
                 (select cfga.id from brs.custom_field_group_assignment cfga
                  where cfga.custom_field_group_id = 8
                    and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Signature Req''d Prior to Submission')),
                 util.signature_required_prior_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_utility util
          where util.signature_required_prior_type_id is not null
         );
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
         (select util.id,
                 (select cfga.id from brs.custom_field_group_assignment cfga
                  where cfga.custom_field_group_id = 23
                    and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Customer Signature Required for Resubmission')),
                 util.customer_signature_resubmission_type_other,
                 null,
                 now(),
                 99999999
          from blueraven.ahj_utility util
          where util.customer_signature_resubmission_type_id is not null
         );
insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
        (select util.id,
                (select cfga.id from brs.custom_field_group_assignment cfga
                 where cfga.custom_field_group_id = 10
                   and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Interconnection Fee')),
                util.interconnection_fee_type_other,
                null,
                now(),
                99999999
            from blueraven.ahj_utility util
            where util.interconnection_fee_type_id is not null
        );
 insert into brs.custom_field_value(source_id, custom_field_group_assignment_id, text_value, int_value, date_created, created_by_id)
        (select util.id,
                (select cfga.id from brs.custom_field_group_assignment cfga
                 where cfga.custom_field_group_id = 11
                   and cfga.custom_field_id = (select id from brs.custom_field where field_name = 'Utility Inspection Required')),
                util.utility_inspection_required_type_other,
                null,
                now(),
                99999999
            from blueraven.ahj_utility util
            where util.utility_inspection_required_type_id is not null
        );

-- update lovs for the custom_field_value rows just added
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_permit a on a.id = cfv.source_id
                  inner join blueraven.ahj_simple_list_type hit on hit.id = a.hoa_approval_required_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'HOA Approval Required for Submission'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_permit a on a.id = cfv.source_id
                  inner join blueraven.ahj_simple_list_type hit on hit.id = a.nem_approval_required_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'NEM Approval Required for Submission'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_utility a on a.id = cfv.source_id
                  inner join blueraven.ahj_simple_list_type hit on hit.id = a.rebate_program_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Rebate Program'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_utility a on a.id = cfv.source_id
                  inner join blueraven.ahj_simple_list_type hit on hit.id = a.signature_required_prior_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Signature Req''d Prior to Submission'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_utility a on a.id = cfv.source_id
                  inner join blueraven.ahj_simple_list_type hit on hit.id = a.customer_signature_resubmission_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Customer Signature Required for Resubmission'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_utility a on a.id = cfv.source_id
                  inner join blueraven.ahj_simple_list_type hit on hit.id = a.interconnection_fee_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Interconnection Fee'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
update brs.custom_field_value
set int_value = v.lov_id
from (
         select lov.id as lov_id,
                cfv.id as cfv_id
         from brs.custom_field_value cfv
                  inner join blueraven.ahj_utility a on a.id = cfv.source_id
                  inner join blueraven.ahj_simple_list_type hit on hit.id = a.utility_inspection_required_type_id
                  inner join brs.custom_field_group_assignment cfga on cfga.id = cfv.custom_field_group_assignment_id
                  inner join brs.custom_field cf on cf.id = cfga.custom_field_id and cf.field_name = 'Utility Inspection Required'
                  inner join brs.list_of_value lov on lov.parent_id = cf.list_of_value_id and lov.name = hit.name
     ) as v
where id = cfv_id;
