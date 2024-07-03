update brs.dashboard_milestone
set major_milestone = true
where dashboard_milestone_type_id = 2
  and name in ('Total Planned Appointments',
               'Total Eligible Planned Appointments',
               'Pitched',
               'Bookings Complete');



update brs.dashboard_milestone set display_order = 0 where name = 'Total Planned Appointments';
update brs.dashboard_milestone set display_order = 1 where name = 'Cancelled in advance';
update brs.dashboard_milestone set display_order = 2 where name = 'Ineligible for solar';
update brs.dashboard_milestone set display_order = 3 where name = 'Total Eligible Planned Appointments';
update brs.dashboard_milestone set display_order = 4 where name = 'Rescheduled';
update brs.dashboard_milestone set display_order = 5 where name = 'Homeowner no show';
update brs.dashboard_milestone set display_order = 6 where name = 'Closer missed appointment';
update brs.dashboard_milestone set display_order = 7 where name = 'Turned away at the door';
update brs.dashboard_milestone set display_order = 8 where name = 'No utility bill';
update brs.dashboard_milestone set display_order = 9 where name = 'Non-dispositioned appointments';
update brs.dashboard_milestone set display_order = 10 where name = 'Yet to occur';
update brs.dashboard_milestone set display_order = 11 where name = 'Pitched';
update brs.dashboard_milestone set display_order = 12 where name = 'Credits run';
update brs.dashboard_milestone set display_order = 13 where name = 'Credits passed';
update brs.dashboard_milestone set display_order = 14 where name = 'Bookings Complete';
update brs.dashboard_milestone set display_order = 15 where name = 'Site Surveys Verified';
update brs.dashboard_milestone set display_order = 16 where name = 'Final Designs sent to Homeowner';
update brs.dashboard_milestone set display_order = 17 where name = 'Final Designs Approved';
update brs.dashboard_milestone set display_order = 18 where name = 'Final Designs Completed';
update brs.dashboard_milestone set display_order = 19 where name = 'Installations Completed';

alter table brs.dashboard_milestone
    add column if not exists inverse_trend boolean not null default false;

update brs.dashboard_milestone
set inverse_trend = true
where dashboard_milestone_type_id = 2
  and name in (
               'Cancelled in advance',
               'Ineligible for solar',
               'Rescheduled',
               'Homeowner no show',
               'Closer missed appointment',
               'Turned away at the door',
               'No utility bill',
               'Non-dispositioned appointments'
    );

alter table brs.dashboard_milestone
    add column if not exists archived boolean not null default false;

