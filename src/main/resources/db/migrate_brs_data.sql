--------------------------------------------------------------------------------
-- start fresh: wipe out any data previously migrated
--------------------------------------------------------------------------------
-- ha, kidding! i can't think of a clean way to reverse just the
-- changes made in this file


--------------------------------------------------------------------------------
-- copy over brs data
--------------------------------------------------------------------------------

drop trigger if exists organization_audit_trg ON flow.organization_custom_field_value;
drop trigger if exists contact_audit_trg ON flow.contact_custom_field_value;
drop trigger if exists user_audit_trg ON flow.user_custom_field_value;
drop trigger if exists project_audit_trg ON flow.project_custom_field_value;
drop trigger if exists user_view_trg on flow.user;
drop trigger if exists org_view_trg on flow.org;
drop trigger if exists user_position_trg on flow.user_position;
drop trigger if exists update_project_details_project_trg on flow.project_custom_field_value;
drop trigger if exists update_contact_details_project_details_trg on flow.contact_custom_field_value;
drop trigger if exists concrete_project_audit_trg ON flow.project;
drop trigger if exists concrete_contact_audit_trg ON flow.contact;
drop trigger if exists concrete_user_audit_trg ON flow.user;


/*
INSERT INTO flow.org_level (company_id, level,level_name)
VALUES ((select id from flow.company where company_name = 'Blue Raven Corporate'), 1,'Parent'),
       ((select id from flow.company where company_name = 'Blue Raven Corporate'), 2,'Organization'),
       ((select id from flow.company where company_name = 'Blue Raven Corporate'), 3,'Department'),
       ((select id from flow.company where company_name = 'Blue Raven Corporate'), 4,'Region'),
       ((select id from flow.company where company_name = 'Blue Raven Corporate'), 5,'Office');

INSERT INTO flow.org_level (company_id, level,level_name)
VALUES ((select id from flow.company where company_name = 'Blue Raven Solar'), 1,'Parent'),
       ((select id from flow.company where company_name = 'Blue Raven Solar'), 2,'Organization'),
       ((select id from flow.company where company_name = 'Blue Raven Solar'), 3,'Department'),
       ((select id from flow.company where company_name = 'Blue Raven Solar'), 4,'District'),
       ((select id from flow.company where company_name = 'Blue Raven Solar'), 5,'Region'),
       ((select id from flow.company where company_name = 'Blue Raven Solar'), 6,'Office');

INSERT INTO flow.org_filter (org_level_id, rank, show_type)
VALUES ((select id from flow.org_level where company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
    and level = 2), 1, false),
       ((select id from flow.org_level where company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
                                         and level = 3), 2, false),
       ((select id from flow.org_level where company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
                                         and level = 4), 3, false),
       ((select id from flow.org_level where company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
                                         and level = 5), 4, true),
       ((select id from flow.org_level where company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
                                         and level = 6), 5, true);

INSERT INTO flow.org_filter (org_level_id, rank, show_type)
VALUES ((select id from flow.org_level where company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
                                         and level = 2), 1, false),
       ((select id from flow.org_level where company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
                                         and level = 3), 2, false),
       ((select id from flow.org_level where company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
                                         and level = 4), 3, true),
       ((select id from flow.org_level where company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
                                         and level = 5), 4, true);

insert into flow.org_type(id,org_type, org_parent_type_id, org_level_id, company_id)
    (  with org_types as (
        select distinct ot.id,ot.org_type,ot.org_parent_type_id,level
        from blueraven.org_hierarchy_filter_down('{215}') a
                 inner join blueraven.org_type ot on ot.id = a.org_type_id
        where org_type_id not in (15,16)
        union
        select distinct ot.id,ot.org_type,ot.org_parent_type_id,level
        from blueraven.org_hierarchy_filter_up('{215}') a
                 inner join blueraven.org_type ot on ot.id = a.org_type_id
        where org_type_id not in (15,16))
       select ot2.id, ot2.org_type, ot2.org_parent_type_id,
              case when ot2.level is null then (select id from flow.org_level ol
                                                where ol.company_id = (select id from flow.company where company_name = 'Blue Raven Solar') and
                                                        ol.level = 1) else
                       (select id from flow.org_level ol2
                        where ol2.company_id = (select id from flow.company where company_name = 'Blue Raven Solar') and
                            case when ot2.level = 2 then  ol2.level = 2
                                 when ot2.level = 3 then ol2.level = 3
                                 when ot2.level = 4 then ol2.level = 4
                                 when ot2.level in (5,6) then ol2.level = 5
                                 when ot2.level in (7,8) then ol2.level = 6 end)  end,
              (select id from flow.company where company_name = 'Blue Raven Solar')
       from blueraven.org_type ot2
                inner join org_types ot3 on ot3.id = ot2.id);

SELECT setval('flow.org_type_id_seq', COALESCE((SELECT MAX(id) + 50 FROM flow.org_type), 1), false);

insert into flow.org_type(org_type, org_parent_type_id, org_level_id, company_id)
    (  with org_types as (
        select distinct ot.id,ot.org_type,ot.org_parent_type_id,level
        from blueraven.org_hierarchy_filter_down('{216,217}') a
                 inner join blueraven.org_type ot on ot.id = a.org_type_id
        where org_type_id not in (15,16) and ot.id = 10
        union
        select distinct ot.id,ot.org_type,ot.org_parent_type_id,level
        from blueraven.org_hierarchy_filter_up('{216,217}') a
                 inner join blueraven.org_type ot on ot.id = a.org_type_id
        where org_type_id not in (15,16))
       select ot2.org_type, null,
              case when ot2.level is null then (select id from flow.org_level ol
                                                where ol.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate') and
                                                        ol.level = 1) else
                       (select id from flow.org_level ol2
                        where ol2.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate') and
                            case when ot2.level = 2 then  ol2.level = 2
                                 when ot2.level = 3 then ol2.level = 3
                                  end)  end, (select id from flow.company where company_name = 'Blue Raven Corporate')
       from blueraven.org_type ot2
                inner join org_types ot3 on ot3.id = ot2.id);

update flow.org_type ot
    set org_parent_type_id = (select id from flow.org_type ot1 where ot1.org_type = 'Organization' and ot1.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate'))
where ot.org_type = 'Department'
and ot.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate');

update flow.org_type ot
set org_parent_type_id = (select id from flow.org_type ot1 where ot1.org_type = 'Parent' and ot1.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate'))
where ot.org_type = 'Organization'
  and ot.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate');

insert into flow.org_type(id,org_type, org_parent_type_id, org_level_id, company_id)
(  with org_types as (
    select distinct ot.id,ot.org_type,ot.org_parent_type_id,level
    from blueraven.org_hierarchy_filter_down('{216,217}') a
             inner join blueraven.org_type ot on ot.id = a.org_type_id
    where org_type_id not in (15,16) and ot.id not in (1,10))
    select ot2.id, ot2.org_type, case when ot2.org_parent_type_id = 10 then (select id from flow.org_type where org_type = 'Department' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate'))
                                      when ot2.org_parent_type_id = 1 then (select id from flow.org_type where org_type = 'Organization' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate'))
                                      when ot2.org_parent_type_id = 9 then (select id from flow.org_type where org_type = 'Parent' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate'))
                                      else ot2.org_parent_type_id end,
                    (select id from flow.org_level ol2
                     where ol2.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate') and
                         case when ot2.level = 5 then  ol2.level = 4
                              when ot2.level = 7 then ol2.level = 5 end),
           (select id from flow.company where company_name = 'Blue Raven Corporate')
from blueraven.org_type ot2
    inner join org_types ot3 on ot3.id = ot2.id);



SELECT setval('flow.org_type_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.org_type), 1), false);*/

-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id,list_of_value_id)
-- VALUES ('Metro Area',77,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'),172);
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Org Email',71,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Metro Area',7,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Org Email',1,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
--
--
--
--
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Metro Area' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Org Email' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
--
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Metro Area' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Org Email' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
--
-- INSERT INTO flow.custom_field_group(
--     group_name,company_object_type_id, group_order)
-- VALUES ('Org PlaceHolder',35, 1);
--
-- INSERT INTO flow.custom_field_group(
--     group_name,company_object_type_id, group_order, archived)
-- VALUES ('Org PlaceHolder',5, 6, true);
--
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Org PlaceHolder' and company_object_type_id = 35),
--             (select id from flow.custom_field where field_name = 'Metro Area' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Org PlaceHolder' and company_object_type_id = 35),
--             (select id from flow.custom_field where field_name = 'Org Email' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Org PlaceHolder' and company_object_type_id = 5),
--             (select id from flow.custom_field where field_name = 'Metro Area' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Org PlaceHolder' and company_object_type_id = 5),
--             (select id from flow.custom_field where field_name = 'Org Email' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);

--Migrate only orgs with originator_id = 1
--Randa thinks she want s to rename active_flag to active

INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (
        with org_types as (
            select distinct ot.id,ot.org_type,ot.org_parent_type_id,level
            from blueraven.org_hierarchy_filter_down('{215}') a
                     inner join blueraven.org_type ot on ot.id = a.org_type_id
            where org_type_id not in (15,16)
            union
            select distinct ot.id,ot.org_type,ot.org_parent_type_id,level
            from blueraven.org_hierarchy_filter_up(
                         '{215}') a
                     inner join blueraven.org_type ot on ot.id = a.org_type_id
            where org_type_id not in (15,16))
        select (select id from flow.company where company_name = 'Blue Raven Solar'),
            o.id,
               o.org_name,
               o.parent_org_id,
               o.org_type_id,
               o.active_flag,
               o.has_calendar,
               case when o.active_flag is true then false else true end,
               2350555,
               now(),
               2350555,
               now()
     from blueraven.org o
        inner join org_types ot on ot.id = o.org_type_id
        where o.id not in (216,217)
          and o.id not in (select id from blueraven.org_hierarchy_filter_down('{216,217}')));

SELECT setval('flow.org_id_seq', COALESCE((SELECT MAX(id) + 2000 FROM flow.org), 1), false);

INSERT INTO flow.org(company_id, org_name, parent_org_id, org_type_id
                     , active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
(select (select id from flow.company where company_name = 'Blue Raven Corporate'), org_name, parent_org_id,
        (select id from flow.org_type where org_type = 'Parent' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),
     active_flag,
    false,
        case when o.active_flag is true then false else true end,
        2350555,
        now(),
        2350555,
        now()
    from blueraven.org o where id = 40);

INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                    active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (
        with org_types as (
            select distinct ot.id,ot.org_type,ot.org_parent_type_id,level
            from blueraven.org_hierarchy_filter_down('{216,217}') a
                     inner join blueraven.org_type ot on ot.id = a.org_type_id
            where org_type_id not in (15,16)
            union
            select distinct ot.id,ot.org_type,ot.org_parent_type_id,level
            from blueraven.org_hierarchy_filter_up(
                         '{216,217}') a
                     inner join blueraven.org_type ot on ot.id = a.org_type_id
            where org_type_id not in (15,16))
        select (select id from flow.company where company_name = 'Blue Raven Corporate'),
               o.id,
               o.org_name,
               o.parent_org_id,
               case when o.org_type_id = 10 then (select id from flow.org_type where org_type = 'Department' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate'))
                    when o.org_type_id = 1 then (select id from flow.org_type where org_type = 'Organization' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate'))
                    when o.org_type_id = 9 then (select id from flow.org_type where org_type = 'Parent' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate'))
                    else o.org_type_id  end,
               o.active_flag,
               o.has_calendar,
               case when o.active_flag is true then false else true end,
               2350555,
               now(),
               2350555,
               now()
        from blueraven.org o
                 inner join org_types ot on ot.id = o.org_type_id
        and o.id not in (215,218,40)
    and o.id not in (select id from blueraven.org_hierarchy_filter_down('{215,218}')));

update flow.org set parent_org_id = (select id from flow.org where org_name = 'Blue Raven Corporation' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate'))
where id in (216,217);

/*
INSERT INTO flow."position"(id, company_id, "position", org_type_id,
                           active)
    (
        with positions as (
            select position_id,org_id, count(1)
            from blueraven.user_position
            group by position_id,org_id),
        all_positions as (
        select distinct p.id,p.position
        from blueraven.user_position up
                 inner join blueraven.position p on p.id = up.position_id
                 inner join positions p1 on p1.position_id = p.id
        where up.org_id in (
            select a.id from blueraven.org_hierarchy_filter_down(
                                     '{215}') a
            where a.id = up.org_id))
        select p.id,
            (select id from flow.company where company_name = 'Blue Raven Solar'),
               p."position",
               p.org_type_id,
               p.active
     from blueraven.position p
        inner join all_positions p1 on p1.id = p.id
        where p.id not in (176,175,197,156,149,174,10,23,33,78));


INSERT INTO flow."position"(id, company_id, "position", org_type_id,
                            active)
    (
        with positions as (
            select position_id,org_id, count(1)
            from blueraven.user_position
            group by position_id,org_id),
             all_positions as (
                 select distinct p.id,p.position
                 from blueraven.user_position up
                          inner join blueraven.position p on p.id = up.position_id
                          inner join positions p1 on p1.position_id = p.id
                 where up.org_id in (
                     select a.id from blueraven.org_hierarchy_filter_down(
                                              '{216,217}') a
                     where a.id = up.org_id))
        select p.id,
               (select id from flow.company where company_name = 'Blue Raven Corporate'),
               p."position",
               case when p.org_type_id = 10 then (select id from flow.org_type where org_type = 'Department' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate'))
                    when p.org_type_id = 1 then (select id from flow.org_type where org_type = 'Organization' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate'))
                    when p.org_type_id = 9 then (select id from flow.org_type where org_type = 'Parent' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate'))
                    else p.org_type_id  end,
               p.active
        from blueraven.position p
                 inner join all_positions p1 on p1.id = p.id
        where p.id not in (176,175,197,156,149,174,10,23,33,78));

INSERT INTO flow."position"(id, company_id, "position", org_type_id,
                            active)
select p.id,
       (select id from flow.company where company_name = 'Blue Raven Corporate'),
       p."position",
       case when p.org_type_id = 10 then (select id from flow.org_type where org_type = 'Department' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate'))
            when p.org_type_id = 1 then (select id from flow.org_type where org_type = 'Organization' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate'))
            when p.org_type_id = 9 then (select id from flow.org_type where org_type = 'Parent' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate'))
            else p.org_type_id  end,
       p.active
from blueraven.position p
where p.org_type_id in (1,9);*/

/*with companies as (
    select id from flow.company where id != 1
)
insert into flow.company_user_status_type( user_status_type, company_id,has_access)
    (select user_status_type,c.id,true
     from blueraven.user_status_type ust
     cross join companies c );*/


--I want employment_type_id,compensation_type_id,personal_email,recruited_by_user_id,referred_by_user_id make custom field


-- with parent as (
--     insert into flow.list_of_value( name, parent_id, display_order, date_created,
--                                     created_by_id, archived)
--         values('Employment Type',null,1,now(),2350555,false)
--         returning id ),
--      t as (insert into flow.list_of_value( name, parent_id, display_order, date_created,
--                                            created_by_id, archived)
--          (select et.employment_type,(select p.id from parent p),1,now(),2350555,false
--           from blueraven.employment_type et))
-- INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id,list_of_value_id)
--     (select 'Employment Type',
--             7,
--             now(),
--             2350555,
--             (select id from flow.company where company_name = 'Blue Raven Solar'),
--             p.id
--      from parent p
--     );


-- INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id,list_of_value_id)
--     (select 'Employment Type',
--             77,
--             now(),
--             2350555,
--             (select id from flow.company where company_name = 'Blue Raven Corporate'),
--             (select id from flow.list_of_value where name = 'Employment Type')
--     );

-- with parent as (
--     insert into flow.list_of_value( name, parent_id, display_order, date_created,
--                                     created_by_id, archived)
--         values('Compensation Type',null,1,now(),2350555,false)
--         returning id ),
--      t as (insert into flow.list_of_value( name, parent_id, display_order, date_created,
--                                            created_by_id, archived)
--          (select ct.compensation_type,(select p.id from parent p),1,now(),2350555,false
--           from blueraven.compensation_type ct))
-- INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id,list_of_value_id)
--     (select 'Compensation Type',
--             7,
--             now(),
--             2350555,
--             (select id from flow.company where company_name = 'Blue Raven Solar'),
--             p.id
--      from parent p
--     );
--
-- INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id,list_of_value_id)
--     (select 'Compensation Type',
--             77,
--             now(),
--             2350555,
--             (select id from flow.company where company_name = 'Blue Raven Corporate'),
--             (select id from flow.list_of_value where name = 'Compensation Type')
--     );

-- with parent as (
--     insert into flow.list_of_value( name, parent_id, display_order, date_created,
--                                     created_by_id, archived)
--         values('Finding Source',null,1,now(),2350555,false)
--         returning id ),
--      t as (insert into flow.list_of_value( name, parent_id, display_order, date_created,
--                                            created_by_id, archived)
--          (select fs.finding_source,(select p.id from parent p),1,now(),2350555,false
--           from blueraven.finding_source fs))
-- INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id,list_of_value_id)
--     (select 'Finding Source',
--             7,
--             now(),
--             2350555,
--             (select id from flow.company where company_name = 'Blue Raven Solar'),
--             p.id
--      from parent p
--     );
--
-- INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id,list_of_value_id)
--     (select 'Finding Source',
--             77,
--             now(),
--             2350555,
--             (select id from flow.company where company_name = 'Blue Raven Corporate'),
--             (select id from flow.list_of_value where name = 'Finding Source')
--     );

--------------------------------------------------------------------------------
-- import user data from blueraven schema
--------------------------------------------------------------------------------

INSERT INTO flow."user" (
                         phone_number,
                         id,
                         email,
                         created_by_id,
                         last_name,
                         first_name,
                         date_created,
                         password,
                         date_modified,
                         modified_by_id,
                         username)
    (SELECT
            phone_number,
            id,
            email,
            created_by,
            last_name,
            first_name,
            created_dt,
            password,
            modified_dt,
            modified_by,
            email
     FROM blueraven."user"
        where id not in (2350555,99999999,2405363, 2356764, 2410143)
        and id not in ( select distinct u.id
                        from blueraven.user u
                                 inner join blueraven.user_position up on up.user_id = u.id
                                 inner join blueraven.org o on o.id = up.org_id
                            and o.org_type_id in (15,16)));


insert into flow.user_company(company_id,user_id,is_default)
(
 select (select id from flow.company where company_name = 'Blue Raven Solar'),u1.id,true
 FROM blueraven."user" u1
 where u1.id not in (2350555,99999999,2405363, 2356764, 2410143)
   and u1.id not in ( select distinct u.id
                      from blueraven.user u
                               inner join blueraven.user_position up on up.user_id = u.id and up.primary_flag is true
                               inner join blueraven.org o on o.id = up.org_id
                          and o.org_type_id in (15,16))
   and u1.id in (select up1.user_id from blueraven.user_position up1
                                    inner join blueraven.org o1 on o1.id = up1.org_id
                                    where up1.primary_flag is true and
                                          up1.org_id in (select distinct a.id
                                                         from blueraven.org_hierarchy_filter_down(
                                                                      '{215}') a
                                                                  inner join blueraven.org_type ot on ot.id = a.org_type_id
                                                         where org_type_id not in (15,16)))
 union
 select (select id from flow.company where company_name = 'Blue Raven Solar'),u2.id,true
 FROM blueraven."user" u2
 where u2.id not in (select user_id from blueraven.user_position)
      and u2.id not in (2350555,99999999,2405363, 2356764, 2410143));

insert into flow.company_user_status(user_id, user_status_type_id, archived, date_created, date_modified, created_by_id, modified_by_id)
    (select u.id,ust.id,false,now(),now(),2350555,2350555
     from blueraven.user u
              inner join blueraven.user_status_type ust2 on u.user_status_type_id = ust2.id
              inner join flow.user_company uc on uc.user_id = u.id
              inner join flow.user_status_type ust  on ust.company_id = uc.company_id
     where ust2.user_status_type = ust.user_status_type
       and u.id not in (2350555,99999999,2405363, 2356764, 2410143)
       and u.id in (
         select u1.id
         FROM blueraven."user" u1
         where u1.id not in (2350555,99999999,2405363, 2356764, 2410143)
           and u1.id not in ( select distinct u.id
                              from blueraven.user u
                                       inner join blueraven.user_position up on up.user_id = u.id and up.primary_flag is true
                                       inner join blueraven.org o on o.id = up.org_id
                                  and o.org_type_id in (15,16))
           and u1.id in (select up1.user_id from blueraven.user_position up1
                                                     inner join blueraven.org o1 on o1.id = up1.org_id
                         where up1.primary_flag is true and
                                 up1.org_id in (select distinct a.id
                                                from blueraven.org_hierarchy_filter_down(
                                                             '{215}') a
                                                         inner join blueraven.org_type ot on ot.id = a.org_type_id
                                                where org_type_id not in (15,16)))
         union
         select u2.id
         FROM blueraven."user" u2
         where u2.id not in (select user_id from blueraven.user_position)
           and u2.id not in (2350555,99999999,2405363, 2356764, 2410143)));



insert into flow.user_company(company_id,user_id,is_default)
(with
      companies as (
          select id from flow.company where company_name = 'Blue Raven Corporate'
          union
          select id from flow.company where company_name = 'Blue Raven Solar'
          union
          select id from flow.company where company_name = 'B+C Electric'
          union
          select id from flow.company where company_name = 'Eco Lux Solar'
          union
          select id from flow.company where company_name = 'Salient Solar'
          union
          select id from flow.company where company_name = 'Solenrgi'
          union
          select id from flow.company where company_name = 'Sun Run'
          union
          select id from flow.company where company_name = 'Solar 101'
          union
          select id from flow.company where company_name = 'TGE Solar'
          union
          select id from flow.company where company_name = 'Atlas Solar Advisors'
          union
          select id from flow.company where company_name = 'Direct Solar of America'
          union
          select id from flow.company where company_name = 'Smart Money Solar'
          union
          select id from flow.company where company_name = 'Revolution Solar'
          union
          select id from flow.company where company_name = 'Supernova Energy'
          union
          select id from flow.company where company_name = 'Energy Pal'
          union
          select id from flow.company where company_name = 'Code 7 Roof and Solar'
      )
 select c.id,u1.id,case when c.id = (select id from flow.company where company_name = 'Blue Raven Corporate') then true else false end
 FROM blueraven."user" u1
          cross join companies c
 where u1.id not in (2350555,99999999,2405363, 2356764, 2410143)
   and u1.id not in ( select distinct u.id
                      from blueraven.user u
                               inner join blueraven.user_position up on up.user_id = u.id and up.primary_flag is true
                               inner join blueraven.org o on o.id = up.org_id
                          and o.org_type_id in (15,16))
   and u1.id in (select up1.user_id from blueraven.user_position up1
                                             inner join blueraven.org o1 on o1.id = up1.org_id
                                             where up1.primary_flag is true and
                                                   up1.org_id in (select distinct a.id
                                                                  from blueraven.org_hierarchy_filter_down(
                                                                               '{216,217}') a
                                                                           inner join blueraven.org_type ot on ot.id = a.org_type_id
                                                                  where org_type_id not in (15,16))));


insert into flow.company_user_status(user_id, user_status_type_id, archived, date_created, date_modified, created_by_id, modified_by_id)
    (select u.id,ust.id,false,now(),now(),2350555,2350555
     from blueraven.user u
              inner join blueraven.user_status_type ust2 on u.user_status_type_id = ust2.id
              inner join flow.user_company uc on uc.user_id = u.id
              inner join flow.user_status_type ust  on ust.company_id = uc.company_id
     where ust2.user_status_type = ust.user_status_type
       and u.id not in (2350555,99999999,2405363, 2356764, 2410143)
       and u.id in (
         select u1.id
         FROM blueraven."user" u1
         where u1.id not in (2350555,99999999,2405363, 2356764, 2410143)
           and u1.id not in ( select distinct u.id
                              from blueraven.user u
                                       inner join blueraven.user_position up on up.user_id = u.id and up.primary_flag is true
                                       inner join blueraven.org o on o.id = up.org_id
                                  and o.org_type_id in (15,16))
           and u1.id in (select up1.user_id from blueraven.user_position up1
                                                     inner join blueraven.org o1 on o1.id = up1.org_id
                         where up1.primary_flag is true and
                                 up1.org_id in (select distinct a.id
                                                from blueraven.org_hierarchy_filter_down(
                                                             '{216,217}') a
                                                         inner join blueraven.org_type ot on ot.id = a.org_type_id
                                                where org_type_id not in (15,16)))));



insert into flow.user_position(id, user_id, position_id, start_date, end_date, org_id, primary_flag,created_by_id)
select id,
       user_id,
       position_id,
       start_date,
       end_date,
       org_id,
       primary_flag,
       2350555
from blueraven.user_position
where user_id not in (select distinct u.id
                      from blueraven.user u
                               inner join blueraven.user_position up on up.user_id = u.id
                               inner join blueraven.org o on o.id = up.org_id
                          and o.org_type_id in (15,16))
and position_id not in (176,175,197,156,149,174,10,23,78,31);


insert into flow.user_position(id, user_id, position_id, start_date, end_date, org_id, primary_flag,created_by_id)
select up2.id,
       up2.user_id,
       p.id,
       up2.start_date,
       up2.end_date,
       up2.org_id,
       up2.primary_flag,
       2350555
from blueraven.user_position up2
         inner join blueraven.position p2  on p2.id = up2.position_id
         inner join flow.position p on p.position  = p2.position and p.company_id = 2
where user_id not in (select distinct u.id
                      from blueraven.user u
                               inner join blueraven.user_position up on up.user_id = u.id
                               inner join blueraven.org o on o.id = up.org_id
                          and o.org_type_id in (15,16))
  and position_id  in (10,23,78)
  and org_id in (select distinct id
                 from blueraven.org_hierarchy_filter_down(
                         '{216,217}'));


insert into flow.user_position(id, user_id, position_id, start_date, end_date, org_id, primary_flag,created_by_id)
select up2.id,
       up2.user_id,
       up2.position_id,
       up2.start_date,
       up2.end_date,
       up2.org_id,
       up2.primary_flag,
       2350555
from blueraven.user_position up2
where user_id not in (select distinct u.id
                      from blueraven.user u
                               inner join blueraven.user_position up on up.user_id = u.id
                               inner join blueraven.org o on o.id = up.org_id
                          and o.org_type_id in (15,16))
  and position_id  in (10,23,78)
  and org_id in (select distinct id
                 from blueraven.org_hierarchy_filter_down(
                         '{215}'));


-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'Code 7 Roof and Solar'), 1, 'Parent');
-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'Code 7 Roof and Solar'), 2, 'Region');
-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'Code 7 Roof and Solar'), 3, 'Office');
--
--
--
-- INSERT INTO flow.org_type (org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Parent', null, (select id from flow.org_level where level_name = 'Parent' and company_id in (select id from flow.company where company_name = 'Code 7 Roof and Solar')),(select id from flow.company where company_name = 'Code 7 Roof and Solar'), false,now(),2350555);
-- INSERT INTO flow.org_type (org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Region', (select id from flow.org_type where org_type.org_type = 'Parent' and company_id in (select id from flow.company where company_name = 'Code 7 Roof and Solar')), (select id from flow.org_level where level_name = 'Region' and company_id in (select id from flow.company where company_name = 'Code 7 Roof and Solar')), (select id from flow.company where company_name = 'Code 7 Roof and Solar'), false, now(),2350555);
-- INSERT INTO flow.org_type ( org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Office', (select id from flow.org_type where org_type.org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Code 7 Roof and Solar')), (select id from flow.org_level where level_name = 'Office' and company_id in (select id from flow.company where company_name = 'Code 7 Roof and Solar')), (select id from flow.company where company_name = 'Code 7 Roof and Solar'), false,now(),2350555);


INSERT INTO flow.org (company_id, org_name, parent_org_id,  org_type_id, active_flag, schedulable, state_id,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Code 7 Roof and Solar'), 'Code 7 Roof and Solar', null,
            (select id from flow.org_type where org_type.org_type = 'Parent' and
                    company_id in (select id from flow.company where company_name = 'Code 7 Roof and Solar')), true,   false,null,false,
            2350555,
            now(),
            2350555,
            now());

INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Code 7 Roof and Solar'),
            id,
            org_name,
            (select id
             from flow.org where org_name = 'Code 7 Roof and Solar' and company_id in (select id from flow.company where company_name = 'Code 7 Roof and Solar')),
            (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Code 7 Roof and Solar')),
            active_flag,
            has_calendar,case when active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org
     where originator_id = 17 and org_type_id = 15);



INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Code 7 Roof and Solar'),
            o.id,
            o.org_name,
            (select id
             from flow.org where org_type_id in (select id from flow.org_type where org_type =  'Region') and company_id in (select id from flow.company where company_name = 'Code 7 Roof and Solar')),
            (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Code 7 Roof and Solar')),
            o.active_flag,
            o.has_calendar,
            case when o.active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org o
              inner join blueraven.org  p on p.id = o.parent_org_id
     where p.originator_id = 17 and p.org_type_id = 15);

-- SELECT setval('flow.position_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.position), 1), false);
--
-- INSERT INTO flow.position (company_id, position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Code 7 Roof and Solar'), 'Closer', (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Code 7 Roof and Solar')), true,now(),2350555);
-- INSERT INTO flow.position ( company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Code 7 Roof and Solar'), 'Closer Office Manager',(select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Code 7 Roof and Solar')), true,now(),2350555);
-- INSERT INTO flow.position (company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Code 7 Roof and Solar'), 'Closer Regional Manager', (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Code 7 Roof and Solar')), true,now(),2350555);



INSERT INTO flow."user" (
    phone_number,
    id,
    email,
    created_by_id,
    last_name,
    first_name,
    date_created,
    password,
    date_modified,
    modified_by_id,
    username)
    (SELECT
         phone_number,
         id,
         email,
         created_by,
         last_name,
         first_name,
         created_dt,
         password,
         modified_dt,
         modified_by,
         email
     FROM blueraven."user"
     where id in ( select distinct u.id
                   from blueraven.user u
                            inner join blueraven.user_position up on up.user_id = u.id
                            inner join blueraven.org o on o.id = up.org_id
                       and o.org_type_id in (15,16) and o.id in (931)));

insert into flow.user_company(company_id,user_id,is_default)
    (select (select id from flow.company where company_name = 'Code 7 Roof and Solar'),id,true
     FROM blueraven."user"
     where id not in (2350555,99999999,2405363, 2356764, 2410143)
       and id in ( select distinct u.id
                   from blueraven.user u
                            inner join blueraven.user_position up on up.user_id = u.id and up.primary_flag is true
                            inner join blueraven.org o on o.id = up.org_id
                       and o.org_type_id in (15,16) and o.id in (931)));

insert into flow.company_user_status(user_id, user_status_type_id, archived, date_created, date_modified, created_by_id, modified_by_id)
    (select u.id,ust.id,false,now(),now(),2350555,2350555
     from blueraven.user u
              inner join blueraven.user_status_type ust2 on u.user_status_type_id = ust2.id
              inner join flow.user_company uc on uc.user_id = u.id
              inner join flow.user_status_type ust  on ust.company_id = uc.company_id
     where ust2.user_status_type = ust.user_status_type
       and u.id not in (2350555,99999999,2405363, 2356764, 2410143)
       and u.id in (select distinct u.id
                    from blueraven.user u
                             inner join blueraven.user_position up on up.user_id = u.id
                             inner join blueraven.org o on o.id = up.org_id
                        and o.org_type_id in (15,16) and o.id in (931)));


insert into flow.user_position( user_id, position_id, start_date, end_date, org_id, primary_flag,created_by_id)
    (select u.id,case when up.position_id = 174 then
                          (select id from flow.position
                           where position = 'Closer Regional Manager'
                             and company_id in (select id from flow.company where company_name = 'Code 7 Roof and Solar'))
                      when up.position_id = 175 then
                          (select id from flow.position
                           where position = 'Closer Office Manager'
                             and company_id in (select id from flow.company where company_name = 'Code 7 Roof and Solar'))
                      when up.position_id = 176 then
                          (select id from flow.position
                           where position = 'Closer'
                             and company_id in (select id from flow.company where company_name = 'Code 7 Roof and Solar')) end ,up.start_date,up.end_date,
            case when o.org_type_id = 15 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Region' and
                                                      company_id in (select id from flow.company where company_name = 'Code 7 Roof and Solar')))
                 when o.org_type_id = 16 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Office' and
                                                      company_id in (select id from flow.company where company_name = 'Code 7 Roof and Solar'))
                        and o1.id = o.id) end,up.primary_flag,
            2350555
     from blueraven."user" u
              inner join blueraven.user_position up on up.user_id = u.id
              inner join blueraven.org o on o.id = up.org_id and o.org_type_id in (15,16) and o.id in (931));



-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'Energy Pal'), 1, 'Parent');
-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'Energy Pal'), 2, 'Region');
-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'Energy Pal'), 3, 'Office');
--
--
--
-- INSERT INTO flow.org_type (org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Parent', null, (select id from flow.org_level where level_name = 'Parent' and company_id in (select id from flow.company where company_name = 'Energy Pal')),(select id from flow.company where company_name = 'Energy Pal'), false,now(),2350555);
-- INSERT INTO flow.org_type (org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Region', (select id from flow.org_type where org_type.org_type = 'Parent' and company_id in (select id from flow.company where company_name = 'Energy Pal')), (select id from flow.org_level where level_name = 'Region' and company_id in (select id from flow.company where company_name = 'Energy Pal')), (select id from flow.company where company_name = 'Energy Pal'), false, now(),2350555);
-- INSERT INTO flow.org_type ( org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Office', (select id from flow.org_type where org_type.org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Energy Pal')), (select id from flow.org_level where level_name = 'Office' and company_id in (select id from flow.company where company_name = 'Energy Pal')), (select id from flow.company where company_name = 'Energy Pal'), false,now(),2350555);


INSERT INTO flow.org (company_id, org_name, parent_org_id,  org_type_id, active_flag, schedulable, state_id,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Energy Pal'), 'Energy Pal', null,
            (select id from flow.org_type where org_type.org_type = 'Parent' and
                    company_id in (select id from flow.company where company_name = 'Energy Pal')), true,   false,null,false,
            2350555,
            now(),
            2350555,
            now());

INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Energy Pal'),
            id,
            org_name,
            (select id
             from flow.org where org_name = 'Energy Pal' and company_id in (select id from flow.company where company_name = 'Energy Pal')),
            (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Energy Pal')),
            active_flag,
            has_calendar,case when active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org
     where originator_id = 16 and org_type_id = 15);



INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Energy Pal'),
            o.id,
            o.org_name,
            (select id
             from flow.org where org_type_id in (select id from flow.org_type where org_type =  'Region') and company_id in (select id from flow.company where company_name = 'Energy Pal')),
            (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Energy Pal')),
            o.active_flag,
            o.has_calendar,
            case when o.active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org o
              inner join blueraven.org  p on p.id = o.parent_org_id
     where p.originator_id = 16 and p.org_type_id = 15);

-- SELECT setval('flow.position_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.position), 1), false);
--
-- INSERT INTO flow.position (company_id, position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Energy Pal'), 'Closer', (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Energy Pal')), true,now(),2350555);
-- INSERT INTO flow.position ( company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Energy Pal'), 'Closer Office Manager',(select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Energy Pal')), true,now(),2350555);
-- INSERT INTO flow.position (company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Energy Pal'), 'Closer Regional Manager', (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Energy Pal')), true,now(),2350555);



INSERT INTO flow."user" (
    phone_number,
    id,
    email,
    created_by_id,
    last_name,
    first_name,
    date_created,
    password,
    date_modified,
    modified_by_id,
    username)
    (SELECT
         phone_number,
         id,
         email,
         created_by,
         last_name,
         first_name,
         created_dt,
         password,
         modified_dt,
         modified_by,
         email
     FROM blueraven."user"
     where id in ( select distinct u.id
                   from blueraven.user u
                            inner join blueraven.user_position up on up.user_id = u.id
                            inner join blueraven.org o on o.id = up.org_id
                       and o.org_type_id in (15,16) and o.id in (911,910)));

insert into flow.user_company(company_id,user_id,is_default)
    (select (select id from flow.company where company_name = 'Energy Pal'),id,true
     FROM blueraven."user"
     where id not in (2350555,99999999,2405363, 2356764, 2410143)
       and id in ( select distinct u.id
                   from blueraven.user u
                            inner join blueraven.user_position up on up.user_id = u.id and up.primary_flag is true
                            inner join blueraven.org o on o.id = up.org_id
                       and o.org_type_id in (15,16) and o.id in (911,910)));

insert into flow.company_user_status(user_id, user_status_type_id, archived, date_created, date_modified, created_by_id, modified_by_id)
    (select u.id,ust.id,false,now(),now(),2350555,2350555
     from blueraven.user u
              inner join blueraven.user_status_type ust2 on u.user_status_type_id = ust2.id
              inner join flow.user_company uc on uc.user_id = u.id
              inner join flow.user_status_type ust  on ust.company_id = uc.company_id
     where ust2.user_status_type = ust.user_status_type
       and u.id not in (2350555,99999999,2405363, 2356764, 2410143)
       and u.id in (select distinct u.id
                    from blueraven.user u
                             inner join blueraven.user_position up on up.user_id = u.id
                             inner join blueraven.org o on o.id = up.org_id
                        and o.org_type_id in (15,16) and o.id in (911,910)));


insert into flow.user_position( user_id, position_id, start_date, end_date, org_id, primary_flag,created_by_id)
    (select u.id,case when up.position_id = 174 then
                          (select id from flow.position
                           where position = 'Closer Regional Manager'
                             and company_id in (select id from flow.company where company_name = 'Energy Pal'))
                      when up.position_id = 175 then
                          (select id from flow.position
                           where position = 'Closer Office Manager'
                             and company_id in (select id from flow.company where company_name = 'Energy Pal'))
                      when up.position_id = 176 then
                          (select id from flow.position
                           where position = 'Closer'
                             and company_id in (select id from flow.company where company_name = 'Energy Pal')) end ,up.start_date,up.end_date,
            case when o.org_type_id = 15 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Region' and
                                                      company_id in (select id from flow.company where company_name = 'Energy Pal')))
                 when o.org_type_id = 16 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Office' and
                                                      company_id in (select id from flow.company where company_name = 'Energy Pal'))
                        and o1.id = o.id) end,up.primary_flag,
            2350555
     from blueraven."user" u
              inner join blueraven.user_position up on up.user_id = u.id
              inner join blueraven.org o on o.id = up.org_id and o.org_type_id in (15,16) and o.id in (911,910));



-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'B+C Electric'), 1, 'Parent');
-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'B+C Electric'), 2, 'Region');
-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'B+C Electric'), 3, 'Office');
--
--
--
-- INSERT INTO flow.org_type (org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Parent', null, (select id from flow.org_level where level_name = 'Parent' and company_id in (select id from flow.company where company_name = 'B+C Electric')),(select id from flow.company where company_name = 'B+C Electric'), false,now(),2350555);
-- INSERT INTO flow.org_type (org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Region', (select id from flow.org_type where org_type.org_type = 'Parent' and company_id in (select id from flow.company where company_name = 'B+C Electric')), (select id from flow.org_level where level_name = 'Region' and company_id in (select id from flow.company where company_name = 'B+C Electric')), (select id from flow.company where company_name = 'B+C Electric'), false, now(),2350555);
-- INSERT INTO flow.org_type ( org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Office', (select id from flow.org_type where org_type.org_type = 'Region' and company_id in (select id from flow.company where company_name = 'B+C Electric')), (select id from flow.org_level where level_name = 'Office' and company_id in (select id from flow.company where company_name = 'B+C Electric')), (select id from flow.company where company_name = 'B+C Electric'), false,now(),2350555);


INSERT INTO flow.org (company_id, org_name, parent_org_id,  org_type_id, active_flag, schedulable, state_id,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'B+C Electric'), 'B+C Electric', null,
            (select id from flow.org_type where org_type.org_type = 'Parent' and
    company_id in (select id from flow.company where company_name = 'B+C Electric')), true,   false,null,false,
            2350555,
            now(),
            2350555,
            now());

INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'B+C Electric'),
            id,
            org_name,
            (select id
             from flow.org where org_name = 'B+C Electric' and company_id in (select id from flow.company where company_name = 'B+C Electric')),
            (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'B+C Electric')),
            active_flag,
            has_calendar,case when active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org
     where originator_id = 4 and org_type_id = 15);



INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'B+C Electric'),
            o.id,
            o.org_name,
            (select id
             from flow.org where org_type_id in (select id from flow.org_type where org_type =  'Region') and company_id in (select id from flow.company where company_name = 'B+C Electric')),
            (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'B+C Electric')),
             o.active_flag,
            o.has_calendar,
            case when o.active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org o
              inner join blueraven.org  p on p.id = o.parent_org_id
     where p.originator_id = 4 and p.org_type_id = 15);

-- SELECT setval('flow.position_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.position), 1), false);
--
-- INSERT INTO flow.position (company_id, position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'B+C Electric'), 'Closer', (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'B+C Electric')), true,now(),2350555);
-- INSERT INTO flow.position ( company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'B+C Electric'), 'Closer Office Manager',(select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'B+C Electric')), true,now(),2350555);
-- INSERT INTO flow.position (company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'B+C Electric'), 'Closer Regional Manager', (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'B+C Electric')), true,now(),2350555);



INSERT INTO flow."user" (
                         phone_number,
                         id,
                         email,
                         created_by_id,
                         last_name,
                         first_name,
                         date_created,
                         password,
                         date_modified,
                         modified_by_id,
                         username)
    (SELECT
            phone_number,
            id,
            email,
            created_by,
            last_name,
            first_name,
            created_dt,
            password,
            modified_dt,
            modified_by,
            email
     FROM blueraven."user"
     where id in ( select distinct u.id
                   from blueraven.user u
                            inner join blueraven.user_position up on up.user_id = u.id
                            inner join blueraven.org o on o.id = up.org_id
                       and o.org_type_id in (15,16) and o.id in (575,574)));

insert into flow.user_company(company_id,user_id,is_default)
    (select (select id from flow.company where company_name = 'B+C Electric'),id,true
     FROM blueraven."user"
     where id not in (2350555,99999999,2405363, 2356764, 2410143)
       and id in ( select distinct u.id
                       from blueraven.user u
                                inner join blueraven.user_position up on up.user_id = u.id and up.primary_flag is true
                                inner join blueraven.org o on o.id = up.org_id
                           and o.org_type_id in (15,16) and o.id in (575,574)));

insert into flow.company_user_status(user_id, user_status_type_id, archived, date_created, date_modified, created_by_id, modified_by_id)
    (select u.id,ust.id,false,now(),now(),2350555,2350555
     from blueraven.user u
              inner join blueraven.user_status_type ust2 on u.user_status_type_id = ust2.id
              inner join flow.user_company uc on uc.user_id = u.id
              inner join flow.user_status_type ust  on ust.company_id = uc.company_id
     where ust2.user_status_type = ust.user_status_type
       and u.id not in (2350555,99999999,2405363, 2356764, 2410143)
       and u.id in (select distinct u.id
                    from blueraven.user u
                             inner join blueraven.user_position up on up.user_id = u.id
                             inner join blueraven.org o on o.id = up.org_id
                        and o.org_type_id in (15,16) and o.id in (575,574)));


insert into flow.user_position( user_id, position_id, start_date, end_date, org_id, primary_flag,created_by_id)
    (select u.id,case when up.position_id = 174 then
                          (select id from flow.position
                           where position = 'Closer Regional Manager'
                             and company_id in (select id from flow.company where company_name = 'B+C Electric'))
                      when up.position_id = 175 then
                          (select id from flow.position
                           where position = 'Closer Office Manager'
                             and company_id in (select id from flow.company where company_name = 'B+C Electric'))
                      when up.position_id = 176 then
                          (select id from flow.position
                           where position = 'Closer'
                             and company_id in (select id from flow.company where company_name = 'B+C Electric')) end ,up.start_date,up.end_date,
            case when o.org_type_id = 15 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Region' and
                                                      company_id in (select id from flow.company where company_name = 'B+C Electric')))
                 when o.org_type_id = 16 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Office' and
                                                      company_id in (select id from flow.company where company_name = 'B+C Electric'))
                        and o1.id = o.id) end,up.primary_flag,
            2350555
     from blueraven."user" u
              inner join blueraven.user_position up on up.user_id = u.id
              inner join blueraven.org o on o.id = up.org_id and o.org_type_id in (15,16) and o.id in (575,574));


-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'Supernova Energy'), 1, 'Parent');
-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'Supernova Energy'), 2, 'Region');
-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'Supernova Energy'), 3, 'Office');
--
--
--
-- INSERT INTO flow.org_type (org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Parent', null, (select id from flow.org_level where level_name = 'Parent' and company_id in (select id from flow.company where company_name = 'Supernova Energy')),(select id from flow.company where company_name = 'Supernova Energy'), false,now(),2350555);
-- INSERT INTO flow.org_type (org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Region', (select id from flow.org_type where org_type.org_type = 'Parent' and company_id in (select id from flow.company where company_name = 'Supernova Energy')), (select id from flow.org_level where level_name = 'Region' and company_id in (select id from flow.company where company_name = 'Supernova Energy')), (select id from flow.company where company_name = 'Supernova Energy'), false, now(),2350555);
-- INSERT INTO flow.org_type ( org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Office', (select id from flow.org_type where org_type.org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Supernova Energy')), (select id from flow.org_level where level_name = 'Office' and company_id in (select id from flow.company where company_name = 'Supernova Energy')), (select id from flow.company where company_name = 'Supernova Energy'), false,now(),2350555);


INSERT INTO flow.org (company_id, org_name, parent_org_id,  org_type_id, active_flag, schedulable, state_id,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Supernova Energy'), 'Supernova Energy', null,
            (select id from flow.org_type where org_type.org_type = 'Parent' and
                    company_id in (select id from flow.company where company_name = 'Supernova Energy')), true,   false,null,false,
            2350555,
            now(),
            2350555,
            now());

INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Supernova Energy'),
            id,
            org_name,
            (select id
             from flow.org where org_name = 'Supernova Energy' and company_id in (select id from flow.company where company_name = 'Supernova Energy')),
            (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Supernova Energy')),
            active_flag,
            has_calendar,case when active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org
     where originator_id = 15 and org_type_id = 15);



INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Supernova Energy'),
            o.id,
            o.org_name,
            (select id
             from flow.org where org_type_id in (select id from flow.org_type where org_type =  'Region') and company_id in (select id from flow.company where company_name = 'Supernova Energy')),
            (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Supernova Energy')),
            o.active_flag,
            o.has_calendar,
            case when o.active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org o
              inner join blueraven.org  p on p.id = o.parent_org_id
     where p.originator_id = 15 and p.org_type_id = 15);

-- SELECT setval('flow.position_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.position), 1), false);
--
-- INSERT INTO flow.position (company_id, position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Supernova Energy'), 'Closer', (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Supernova Energy')), true,now(),2350555);
-- INSERT INTO flow.position ( company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Supernova Energy'), 'Closer Office Manager',(select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Supernova Energy')), true,now(),2350555);
-- INSERT INTO flow.position (company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Supernova Energy'), 'Closer Regional Manager', (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Supernova Energy')), true,now(),2350555);



INSERT INTO flow."user" (
    phone_number,
    id,
    email,
    created_by_id,
    last_name,
    first_name,
    date_created,
    password,
    date_modified,
    modified_by_id,
    username)
    (SELECT
         phone_number,
         id,
         email,
         created_by,
         last_name,
         first_name,
         created_dt,
         password,
         modified_dt,
         modified_by,
         email
     FROM blueraven."user"
     where id in ( select distinct u.id
                   from blueraven.user u
                            inner join blueraven.user_position up on up.user_id = u.id
                            inner join blueraven.org o on o.id = up.org_id
                       and o.org_type_id in (15,16) and o.id in (883,888)));

insert into flow.user_company(company_id,user_id,is_default)
    (select (select id from flow.company where company_name = 'Supernova Energy'),id,true
     FROM blueraven."user"
     where id not in (2350555,99999999,2405363, 2356764, 2410143)
       and id in ( select distinct u.id
                   from blueraven.user u
                            inner join blueraven.user_position up on up.user_id = u.id and up.primary_flag is true
                            inner join blueraven.org o on o.id = up.org_id
                       and o.org_type_id in (15,16) and o.id in (883,888)));

insert into flow.company_user_status(user_id, user_status_type_id, archived, date_created, date_modified, created_by_id, modified_by_id)
    (select u.id,ust.id,false,now(),now(),2350555,2350555
     from blueraven.user u
              inner join blueraven.user_status_type ust2 on u.user_status_type_id = ust2.id
              inner join flow.user_company uc on uc.user_id = u.id
              inner join flow.user_status_type ust  on ust.company_id = uc.company_id
     where ust2.user_status_type = ust.user_status_type
       and u.id not in (2350555,99999999,2405363, 2356764, 2410143)
       and u.id in (select distinct u.id
                    from blueraven.user u
                             inner join blueraven.user_position up on up.user_id = u.id
                             inner join blueraven.org o on o.id = up.org_id
                        and o.org_type_id in (15,16) and o.id in (883,888)));


insert into flow.user_position( user_id, position_id, start_date, end_date, org_id, primary_flag,created_by_id)
    (select u.id,case when up.position_id = 174 then
                          (select id from flow.position
                           where position = 'Closer Regional Manager'
                             and company_id in (select id from flow.company where company_name = 'Supernova Energy'))
                      when up.position_id = 175 then
                          (select id from flow.position
                           where position = 'Closer Office Manager'
                             and company_id in (select id from flow.company where company_name = 'Supernova Energy'))
                      when up.position_id = 176 then
                          (select id from flow.position
                           where position = 'Closer'
                             and company_id in (select id from flow.company where company_name = 'Supernova Energy')) end ,up.start_date,up.end_date,
            case when o.org_type_id = 15 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Region' and
                                                      company_id in (select id from flow.company where company_name = 'Supernova Energy')))
                 when o.org_type_id = 16 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Office' and
                                                      company_id in (select id from flow.company where company_name = 'Supernova Energy'))
                        and o1.id = o.id) end,up.primary_flag,
            2350555
     from blueraven."user" u
              inner join blueraven.user_position up on up.user_id = u.id
              inner join blueraven.org o on o.id = up.org_id and o.org_type_id in (15,16) and o.id in (883,888));




-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'Eco Lux Solar'), 1, 'Parent');
-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'Eco Lux Solar'), 2, 'Region');
-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'Eco Lux Solar'), 3, 'Office');
--
--
--
-- INSERT INTO flow.org_type (org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Parent', null, (select id from flow.org_level where level_name = 'Parent' and company_id in (select id from flow.company where company_name = 'Eco Lux Solar')),(select id from flow.company where company_name = 'Eco Lux Solar'), false,now(),2350555);
-- INSERT INTO flow.org_type (org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Region', (select id from flow.org_type where org_type.org_type = 'Parent' and company_id in (select id from flow.company where company_name = 'Eco Lux Solar')), (select id from flow.org_level where level_name = 'Region' and company_id in (select id from flow.company where company_name = 'Eco Lux Solar')), (select id from flow.company where company_name = 'Eco Lux Solar'), false, now(),2350555);
-- INSERT INTO flow.org_type ( org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Office', (select id from flow.org_type where org_type.org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Eco Lux Solar')), (select id from flow.org_level where level_name = 'Office' and company_id in (select id from flow.company where company_name = 'Eco Lux Solar')), (select id from flow.company where company_name = 'Eco Lux Solar'), false,now(),2350555);


INSERT INTO flow.org (company_id, org_name, parent_org_id,  org_type_id, active_flag, schedulable, state_id,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Eco Lux Solar'), 'Eco Lux Solar', null,
            (select id from flow.org_type where org_type.org_type = 'Parent' and company_id in (select id from flow.company where company_name = 'Eco Lux Solar')),
             true,   false,null,false,
            2350555,
            now(),
            2350555,
            now());

INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Eco Lux Solar'),
            id,
            org_name,
            (select id
             from flow.org where org_name = 'Eco Lux Solar' and company_id in (select id from flow.company where company_name = 'Eco Lux Solar')),
            (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Eco Lux Solar')),
            active_flag,
            has_calendar,
            case when active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org
     where originator_id = 8 and org_type_id = 15);



INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Eco Lux Solar'),
            o.id,
            o.org_name,
            (select id
             from flow.org where org_type_id in (select id from flow.org_type where org_type =  'Region') and company_id in (select id from flow.company where company_name = 'Eco Lux Solar')),
            (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Eco Lux Solar')),
            o.active_flag,
            o.has_calendar,
            case when o.active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org o
              inner join blueraven.org  p on p.id = o.parent_org_id
     where p.originator_id = 8 and p.org_type_id = 15);


-- INSERT INTO flow.position (company_id, position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Eco Lux Solar'), 'Closer', (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Eco Lux Solar')), true,now(),2350555);
-- INSERT INTO flow.position ( company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Eco Lux Solar'), 'Closer Office Manager',(select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Eco Lux Solar')), true,now(),2350555);
-- INSERT INTO flow.position (company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Eco Lux Solar'), 'Closer Regional Manager', (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Eco Lux Solar')), true,now(),2350555);



INSERT INTO flow."user" (
                         phone_number,
                         id,
                         email,
                         created_by_id,
                         last_name,
                         first_name,
                         date_created,
                         password,
                         date_modified,
                         modified_by_id,
                         username)
    (SELECT
            phone_number,
            id,
            email,
            created_by,
            last_name,
            first_name,
            created_dt,
            password,
            modified_dt,
            modified_by,
            email
     FROM blueraven."user"
     where id in ( select distinct u.id
                   from blueraven.user u
                            inner join blueraven.user_position up on up.user_id = u.id
                            inner join blueraven.org o on o.id = up.org_id
                       and o.org_type_id in (15,16) and o.id in (684,683)));

insert into flow.user_company(company_id,user_id,is_default)
    (select (select id from flow.company where company_name = 'Eco Lux Solar'),id,true
     FROM blueraven."user"
     where id not in (2350555,99999999,2405363, 2356764, 2410143)
       and id in ( select distinct u.id
                       from blueraven.user u
                                inner join blueraven.user_position up on up.user_id = u.id and up.primary_flag is true
                                inner join blueraven.org o on o.id = up.org_id
                           and o.org_type_id in (15,16) and o.id in (684,683)));

insert into flow.company_user_status(user_id, user_status_type_id, archived, date_created, date_modified, created_by_id, modified_by_id)
    (select u.id,ust.id,false,now(),now(),2350555,2350555
     from blueraven.user u
              inner join blueraven.user_status_type ust2 on u.user_status_type_id = ust2.id
              inner join flow.user_company uc on uc.user_id = u.id
              inner join flow.user_status_type ust  on ust.company_id = uc.company_id
     where ust2.user_status_type = ust.user_status_type
       and u.id not in (2350555,99999999,2405363, 2356764, 2410143)
       and u.id in (select distinct u.id
                    from blueraven.user u
                             inner join blueraven.user_position up on up.user_id = u.id
                             inner join blueraven.org o on o.id = up.org_id
                        and o.org_type_id in (15,16) and o.id in (684,683)));


insert into flow.user_position( user_id, position_id, start_date, end_date, org_id, primary_flag,created_by_id)
    (select u.id,case when up.position_id = 174 then
                          (select id from flow.position
                           where position = 'Closer Regional Manager'
                             and company_id in (select id from flow.company where company_name = 'Eco Lux Solar'))
                      when up.position_id = 175 then
                          (select id from flow.position
                           where position = 'Closer Office Manager'
                             and company_id in (select id from flow.company where company_name = 'Eco Lux Solar'))
                      when up.position_id = 176 then
                          (select id from flow.position
                           where position = 'Closer'
                             and company_id in (select id from flow.company where company_name = 'Eco Lux Solar')) end ,up.start_date,up.end_date,
            case when o.org_type_id = 15 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Region' and
                                                      company_id in (select id from flow.company where company_name = 'Eco Lux Solar')))
                 when o.org_type_id = 16 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Office' and
                                                      company_id in (select id from flow.company where company_name = 'Eco Lux Solar'))
                        and o1.id = o.id) end,up.primary_flag,2350555
     from blueraven."user" u
              inner join blueraven.user_position up on up.user_id = u.id
              inner join blueraven.org o on o.id = up.org_id and o.org_type_id in (15,16) and o.id in (684,683));





-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'Salient Solar'), 1, 'Parent');
-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'Salient Solar'), 2, 'Region');
-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'Salient Solar'), 3, 'Office');
--
--
--
-- INSERT INTO flow.org_type (org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Parent', null, (select id from flow.org_level where level_name = 'Parent' and company_id in (select id from flow.company where company_name = 'Salient Solar')),(select id from flow.company where company_name = 'Salient Solar'), false,now(),2350555);
-- INSERT INTO flow.org_type (org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Region', (select id from flow.org_type where org_type.org_type = 'Parent' and company_id in (select id from flow.company where company_name = 'Salient Solar')), (select id from flow.org_level where level_name = 'Region' and company_id in (select id from flow.company where company_name = 'Salient Solar')), (select id from flow.company where company_name = 'Salient Solar'), false, now(),2350555);
-- INSERT INTO flow.org_type ( org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Office', (select id from flow.org_type where org_type.org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Salient Solar')), (select id from flow.org_level where level_name = 'Office' and company_id in (select id from flow.company where company_name = 'Salient Solar')), (select id from flow.company where company_name = 'Salient Solar'), false,now(),2350555);


INSERT INTO flow.org (company_id, org_name, parent_org_id,  org_type_id, active_flag, schedulable, state_id,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Salient Solar'), 'Salient Solar', null,
            (select id from flow.org_type where org_type.org_type = 'Parent' and company_id in (select id from flow.company where company_name = 'Salient Solar')),
            true,  false,null,false,
            2350555,
            now(),
            2350555,
            now());

INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Salient Solar'),
            id,
            org_name,
            (select id
             from flow.org where org_name = 'Salient Solar' and company_id in (select id from flow.company where company_name = 'Salient Solar')),
            (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Salient Solar')),
            active_flag,
            has_calendar,
            case when active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org
     where originator_id = 6 and org_type_id = 15);



INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Salient Solar'),
            o.id,
            o.org_name,
            (select id
             from flow.org where org_type_id in (select id from flow.org_type where org_type =  'Region') and company_id in (select id from flow.company where company_name = 'Salient Solar')),
            (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Salient Solar')),
            o.active_flag,
            o.has_calendar,
            case when o.active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org o
              inner join blueraven.org  p on p.id = o.parent_org_id
     where p.originator_id = 6 and p.org_type_id = 15);


-- INSERT INTO flow.position (company_id, position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Salient Solar'), 'Closer', (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Salient Solar')), true,now(),2350555);
-- INSERT INTO flow.position ( company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Salient Solar'), 'Closer Office Manager',(select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Salient Solar')), true,now(),2350555);
-- INSERT INTO flow.position (company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Salient Solar'), 'Closer Regional Manager', (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Salient Solar')), true,now(),2350555);



INSERT INTO flow."user" (
                         phone_number,
                         id,
                         email,
                         created_by_id,
                         last_name,
                         first_name,
                         date_created,
                         password,
                         date_modified,
                         modified_by_id,
                         username)
    (SELECT
            phone_number,
            id,
            email,
            created_by,
            last_name,
            first_name,
            created_dt,
            password,
            modified_dt,
            modified_by,
            email
     FROM blueraven."user"
     where id in ( select distinct u.id
                   from blueraven.user u
                            inner join blueraven.user_position up on up.user_id = u.id
                            inner join blueraven.org o on o.id = up.org_id
                       and o.org_type_id in (15,16) and o.id in (572,573)));

insert into flow.user_company(company_id,user_id,is_default)
    (select (select id from flow.company where company_name = 'Salient Solar'),id,true
     FROM blueraven."user"
     where id not in (2350555,99999999,2405363, 2356764, 2410143)
       and id in ( select distinct u.id
                       from blueraven.user u
                                inner join blueraven.user_position up on up.user_id = u.id and up.primary_flag is true
                                inner join blueraven.org o on o.id = up.org_id
                           and o.org_type_id in (15,16) and o.id in (572,573)));

insert into flow.company_user_status(user_id, user_status_type_id, archived, date_created, date_modified, created_by_id, modified_by_id)
    (select u.id,ust.id,false,now(),now(),2350555,2350555
     from blueraven.user u
              inner join blueraven.user_status_type ust2 on u.user_status_type_id = ust2.id
              inner join flow.user_company uc on uc.user_id = u.id
              inner join flow.user_status_type ust  on ust.company_id = uc.company_id
     where ust2.user_status_type = ust.user_status_type
       and u.id not in (2350555,99999999,2405363, 2356764, 2410143)
       and u.id in (select distinct u.id
                    from blueraven.user u
                             inner join blueraven.user_position up on up.user_id = u.id
                             inner join blueraven.org o on o.id = up.org_id
                        and o.org_type_id in (15,16) and o.id in (572,573)));


insert into flow.user_position( user_id, position_id, start_date, end_date, org_id, primary_flag,created_by_id)
    (select u.id,case when up.position_id = 174 then
                          (select id from flow.position
                           where position = 'Closer Regional Manager'
                             and company_id in (select id from flow.company where company_name = 'Salient Solar'))
                      when up.position_id = 175 then
                          (select id from flow.position
                           where position = 'Closer Office Manager'
                             and company_id in (select id from flow.company where company_name = 'Salient Solar'))
                      when up.position_id = 176 then
                          (select id from flow.position
                           where position = 'Closer'
                             and company_id in (select id from flow.company where company_name = 'Salient Solar')) end ,up.start_date,up.end_date,
            case when o.org_type_id = 15 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Region' and
                                                      company_id in (select id from flow.company where company_name = 'Salient Solar')))
                 when o.org_type_id = 16 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Office' and
                                                      company_id in (select id from flow.company where company_name = 'Salient Solar'))
                        and o1.id = o.id) end,up.primary_flag,2350555
     from blueraven."user" u
              inner join blueraven.user_position up on up.user_id = u.id
              inner join blueraven.org o on o.id = up.org_id and o.org_type_id in (15,16) and o.id in (572,573));




-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'Solenrgi'), 1, 'Parent');
-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'Solenrgi'), 2, 'Region');
-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'Solenrgi'), 3, 'Office');
--
--
--
-- INSERT INTO flow.org_type (org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Parent', null, (select id from flow.org_level where level_name = 'Parent' and company_id in (select id from flow.company where company_name = 'Solenrgi')),(select id from flow.company where company_name = 'Solenrgi'), false,now(),2350555);
-- INSERT INTO flow.org_type (org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Region', (select id from flow.org_type where org_type.org_type = 'Parent' and company_id in (select id from flow.company where company_name = 'Solenrgi')), (select id from flow.org_level where level_name = 'Region' and company_id in (select id from flow.company where company_name = 'Solenrgi')), (select id from flow.company where company_name = 'Solenrgi'), false, now(),2350555);
-- INSERT INTO flow.org_type ( org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Office', (select id from flow.org_type where org_type.org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Solenrgi')), (select id from flow.org_level where level_name = 'Office' and company_id in (select id from flow.company where company_name = 'Solenrgi')), (select id from flow.company where company_name = 'Solenrgi'), false,now(),2350555);


INSERT INTO flow.org (company_id, org_name, parent_org_id,  org_type_id, active_flag, schedulable, state_id,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Solenrgi'), 'Solenrgi', null,
            (select id from flow.org_type where org_type.org_type = 'Parent' and company_id in (select id from flow.company where company_name = 'Solenrgi')),
            true,   false,null,false,
            2350555,
            now(),
            2350555,
            now());

INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Solenrgi'),
            id,
            org_name,
            (select id
             from flow.org where org_name = 'Solenrgi' and company_id in (select id from flow.company where company_name = 'Solenrgi')),
            (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Solenrgi')),
            active_flag,
            has_calendar,
            case when active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org
     where originator_id = 2 and org_type_id = 15);



INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Solenrgi'),
            o.id,
            o.org_name,
            (select id
             from flow.org where org_type_id in (select id from flow.org_type where org_type =  'Region') and company_id in (select id from flow.company where company_name = 'Solenrgi')),
            (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Solenrgi')),
            o.active_flag,
            o.has_calendar,
            case when o.active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org o
              inner join blueraven.org  p on p.id = o.parent_org_id
     where p.originator_id = 2 and p.org_type_id = 15);


-- INSERT INTO flow.position (company_id, position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Solenrgi'), 'Closer', (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Solenrgi')), true,now(),2350555);
-- INSERT INTO flow.position ( company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Solenrgi'), 'Closer Office Manager',(select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Solenrgi')), true,now(),2350555);
-- INSERT INTO flow.position (company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Solenrgi'), 'Closer Regional Manager', (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Solenrgi')), true,now(),2350555);



INSERT INTO flow."user" (
                         phone_number,
                         id,
                         email,
                         created_by_id,
                         last_name,
                         first_name,
                         date_created,
                         password,
                         date_modified,
                         modified_by_id,
                         username)
    (SELECT
            phone_number,
            id,
            email,
            created_by,
            last_name,
            first_name,
            created_dt,
            password,
            modified_dt,
            modified_by,
            email
     FROM blueraven."user"
     where id in ( select distinct u.id
                   from blueraven.user u
                            inner join blueraven.user_position up on up.user_id = u.id
                            inner join blueraven.org o on o.id = up.org_id
                       and o.org_type_id in (15,16) and o.id in (569,571,570)));

insert into flow.user_company(company_id,user_id,is_default)
    (select (select id from flow.company where company_name = 'Solenrgi'),id,true
     FROM blueraven."user"
     where id not in (2350555,99999999,2405363, 2356764, 2410143)
       and id in ( select distinct u.id
                       from blueraven.user u
                                inner join blueraven.user_position up on up.user_id = u.id and up.primary_flag is true
                                inner join blueraven.org o on o.id = up.org_id
                           and o.org_type_id in (15,16) and o.id in (569,571,570)));

insert into flow.company_user_status(user_id, user_status_type_id, archived, date_created, date_modified, created_by_id, modified_by_id)
    (select u.id,ust.id,false,now(),now(),2350555,2350555
     from blueraven.user u
              inner join blueraven.user_status_type ust2 on u.user_status_type_id = ust2.id
              inner join flow.user_company uc on uc.user_id = u.id
              inner join flow.user_status_type ust  on ust.company_id = uc.company_id
     where ust2.user_status_type = ust.user_status_type
       and u.id not in (2350555,99999999,2405363, 2356764, 2410143)
       and u.id in (select distinct u.id
                    from blueraven.user u
                             inner join blueraven.user_position up on up.user_id = u.id
                             inner join blueraven.org o on o.id = up.org_id
                        and o.org_type_id in (15,16) and o.id in (569,571,570)));


insert into flow.user_position( user_id, position_id, start_date, end_date, org_id, primary_flag,created_by_id)
    (select u.id,case when up.position_id = 174 then
                          (select id from flow.position
                           where position = 'Closer Regional Manager'
                             and company_id in (select id from flow.company where company_name = 'Solenrgi'))
                      when up.position_id = 175 then
                          (select id from flow.position
                           where position = 'Closer Office Manager'
                             and company_id in (select id from flow.company where company_name = 'Solenrgi'))
                      when up.position_id = 176 then
                          (select id from flow.position
                           where position = 'Closer'
                             and company_id in (select id from flow.company where company_name = 'Solenrgi')) end ,up.start_date,up.end_date,
            case when o.org_type_id = 15 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Region' and
                                                      company_id in (select id from flow.company where company_name = 'Solenrgi')))
                 when o.org_type_id = 16 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Office' and
                                                      company_id in (select id from flow.company where company_name = 'Solenrgi'))
                        and o1.id = o.id) end,up.primary_flag,2350555
     from blueraven."user" u
              inner join blueraven.user_position up on up.user_id = u.id
              inner join blueraven.org o on o.id = up.org_id and o.org_type_id in (15,16) and o.id in (569,571,570));






-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'Sun Run'), 1, 'Parent');
-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'Sun Run'), 2, 'Region');
-- INSERT INTO flow.org_level (company_id, level, level_name) VALUES ( (select id from flow.company where company_name = 'Sun Run'), 3, 'Office');
--
--
--
-- INSERT INTO flow.org_type (org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Parent', null, (select id from flow.org_level where level_name = 'Parent' and company_id in (select id from flow.company where company_name = 'Sun Run')),(select id from flow.company where company_name = 'Sun Run'), false,now(),2350555);
-- INSERT INTO flow.org_type (org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Region', (select id from flow.org_type where org_type.org_type = 'Parent' and company_id in (select id from flow.company where company_name = 'Sun Run')), (select id from flow.org_level where level_name = 'Region' and company_id in (select id from flow.company where company_name = 'Sun Run')), (select id from flow.company where company_name = 'Sun Run'), false, now(),2350555);
-- INSERT INTO flow.org_type ( org_type, org_parent_type_id, org_level_id, company_id, archived, date_created, created_by_id) VALUES
-- ('Office', (select id from flow.org_type where org_type.org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Sun Run')), (select id from flow.org_level where level_name = 'Office' and company_id in (select id from flow.company where company_name = 'Sun Run')), (select id from flow.company where company_name = 'Sun Run'), false,now(),2350555);


INSERT INTO flow.org (company_id, org_name, parent_org_id,  org_type_id, active_flag, schedulable, state_id,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Sun Run'), 'Sun Run', null,
            (select id from flow.org_type where org_type.org_type = 'Parent' and company_id in (select id from flow.company where company_name = 'Sun Run')),
            true,   false,null,false,
            2350555,
            now(),
            2350555,
            now());

INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Sun Run'),
            id,
            org_name,
            (select id
             from flow.org where org_name = 'Sun Run' and company_id in (select id from flow.company where company_name = 'Sun Run')),
            (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Sun Run')),
            active_flag,
            has_calendar,
            case when active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org
     where originator_id = 7 and org_type_id = 15);



INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Sun Run'),
            o.id,
            o.org_name,
            (select id
             from flow.org where org_type_id in (select id from flow.org_type where org_type =  'Region') and company_id in (select id from flow.company where company_name = 'Sun Run')),
            (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Sun Run')),
            o.active_flag,
            o.has_calendar,
            case when o.active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org o
              inner join blueraven.org  p on p.id = o.parent_org_id
     where p.originator_id = 7 and p.org_type_id = 15);


-- INSERT INTO flow.position (company_id, position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Sun Run'), 'Closer', (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Sun Run')), true,now(),2350555);
-- INSERT INTO flow.position ( company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Sun Run'), 'Closer Office Manager',(select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Sun Run')), true,now(),2350555);
-- INSERT INTO flow.position (company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Sun Run'), 'Closer Regional Manager', (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Sun Run')), true,now(),2350555);



INSERT INTO flow."user" (
                         phone_number,
                         id,
                         email,
                         created_by_id,
                         last_name,
                         first_name,
                         date_created,
                         password,
                         date_modified,
                         modified_by_id,
                         username)
    (SELECT
            phone_number,
            id,
            email,
            created_by,
            last_name,
            first_name,
            created_dt,
            password,
            modified_dt,
            modified_by,
            email
     FROM blueraven."user"
     where id in ( select distinct u.id
                   from blueraven.user u
                            inner join blueraven.user_position up on up.user_id = u.id
                            inner join blueraven.org o on o.id = up.org_id
                       and o.org_type_id in (15,16) and o.id in (620,619)));

insert into flow.user_company(company_id,user_id,is_default)
    (select (select id from flow.company where company_name = 'Sun Run'),id,true
     FROM blueraven."user"
     where id not in (2350555,99999999,2405363, 2356764, 2410143)
       and id in ( select distinct u.id
                       from blueraven.user u
                                inner join blueraven.user_position up on up.user_id = u.id and up.primary_flag is true
                                inner join blueraven.org o on o.id = up.org_id
                           and o.org_type_id in (15,16) and o.id in (620,619)));

insert into flow.company_user_status(user_id, user_status_type_id, archived, date_created, date_modified, created_by_id, modified_by_id)
    (select u.id,ust.id,false,now(),now(),2350555,2350555
     from blueraven.user u
              inner join blueraven.user_status_type ust2 on u.user_status_type_id = ust2.id
              inner join flow.user_company uc on uc.user_id = u.id
              inner join flow.user_status_type ust  on ust.company_id = uc.company_id
     where ust2.user_status_type = ust.user_status_type
       and u.id not in (2350555,99999999,2405363, 2356764, 2410143)
       and u.id in (select distinct u.id
                    from blueraven.user u
                             inner join blueraven.user_position up on up.user_id = u.id
                             inner join blueraven.org o on o.id = up.org_id
                        and o.org_type_id in (15,16) and o.id in (620,619)));


insert into flow.user_position( user_id, position_id, start_date, end_date, org_id, primary_flag,created_by_id)
    (select u.id,case when up.position_id = 174 then
                          (select id from flow.position
                           where position = 'Closer Regional Manager'
                             and company_id in (select id from flow.company where company_name = 'Sun Run'))
                      when up.position_id = 175 then
                          (select id from flow.position
                           where position = 'Closer Office Manager'
                             and company_id in (select id from flow.company where company_name = 'Sun Run'))
                      when up.position_id = 176 then
                          (select id from flow.position
                           where position = 'Closer'
                             and company_id in (select id from flow.company where company_name = 'Sun Run')) end ,up.start_date,up.end_date,
            case when o.org_type_id = 15 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Region' and
                                                      company_id in (select id from flow.company where company_name = 'Sun Run')))
                 when o.org_type_id = 16 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Office' and
                                                      company_id in (select id from flow.company where company_name = 'Sun Run'))
                        and o1.id = o.id) end,up.primary_flag,2350555
     from blueraven."user" u
              inner join blueraven.user_position up on up.user_id = u.id
              inner join blueraven.org o on o.id = up.org_id and o.org_type_id in (15,16) and o.id in (620,619));

INSERT INTO flow.org (company_id, org_name, parent_org_id,  org_type_id, active_flag, schedulable, state_id,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Solar 101'), 'Solar 101', null,
            (select id from flow.org_type where org_type.org_type = 'Parent' and
                    company_id in (select id from flow.company where company_name = 'Solar 101')), true,   false,null,false,
            2350555,
            now(),
            2350555,
            now());

INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Solar 101'),
            id,
            org_name,
            (select id
             from flow.org where org_name = 'Solar 101' and company_id in (select id from flow.company where company_name = 'Solar 101')),
            (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Solar 101')),
            active_flag,
            has_calendar,case when active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org
     where originator_id = 9 and org_type_id = 15);



INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Solar 101'),
            o.id,
            o.org_name,
            (select id
             from flow.org where org_type_id in (select id from flow.org_type where org_type =  'Region') and company_id in (select id from flow.company where company_name = 'Solar 101')),
            (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Solar 101')),
            o.active_flag,
            o.has_calendar,
            case when o.active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org o
              inner join blueraven.org  p on p.id = o.parent_org_id
     where p.originator_id = 9 and p.org_type_id = 15);

-- SELECT setval('flow.position_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.position), 1), false);
--
-- INSERT INTO flow.position (company_id, position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'B+C Electric'), 'Closer', (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'B+C Electric')), true,now(),2350555);
-- INSERT INTO flow.position ( company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'B+C Electric'), 'Closer Office Manager',(select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'B+C Electric')), true,now(),2350555);
-- INSERT INTO flow.position (company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'B+C Electric'), 'Closer Regional Manager', (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'B+C Electric')), true,now(),2350555);



INSERT INTO flow."user" (
    phone_number,
    id,
    email,
    created_by_id,
    last_name,
    first_name,
    date_created,
    password,
    date_modified,
    modified_by_id,
    username)
    (SELECT
         phone_number,
         id,
         email,
         created_by,
         last_name,
         first_name,
         created_dt,
         password,
         modified_dt,
         modified_by,
         email
     FROM blueraven."user"
     where id in ( select distinct u.id
                   from blueraven.user u
                            inner join blueraven.user_position up on up.user_id = u.id
                            inner join blueraven.org o on o.id = up.org_id
                       and o.org_type_id in (15,16) and o.id in (860,861,862)));

insert into flow.user_company(company_id,user_id,is_default)
    (select (select id from flow.company where company_name = 'Solar 101'),id,true
     FROM blueraven."user"
     where id not in (2350555,99999999,2405363, 2356764, 2410143)
       and id in ( select distinct u.id
                   from blueraven.user u
                            inner join blueraven.user_position up on up.user_id = u.id and up.primary_flag is true
                            inner join blueraven.org o on o.id = up.org_id
                       and o.org_type_id in (15,16) and o.id in (860,861,862)));

insert into flow.company_user_status(user_id, user_status_type_id, archived, date_created, date_modified, created_by_id, modified_by_id)
    (select u.id,ust.id,false,now(),now(),2350555,2350555
     from blueraven.user u
              inner join blueraven.user_status_type ust2 on u.user_status_type_id = ust2.id
              inner join flow.user_company uc on uc.user_id = u.id
              inner join flow.user_status_type ust  on ust.company_id = uc.company_id
     where ust2.user_status_type = ust.user_status_type
       and u.id not in (2350555,99999999,2405363, 2356764, 2410143)
       and u.id in (select distinct u.id
                    from blueraven.user u
                             inner join blueraven.user_position up on up.user_id = u.id
                             inner join blueraven.org o on o.id = up.org_id
                        and o.org_type_id in (15,16) and o.id in (860,861,862)));


insert into flow.user_position( user_id, position_id, start_date, end_date, org_id, primary_flag,created_by_id)
    (select u.id,case when up.position_id = 174 then
                          (select id from flow.position
                           where position = 'Closer Regional Manager'
                             and company_id in (select id from flow.company where company_name = 'Solar 101'))
                      when up.position_id = 175 then
                          (select id from flow.position
                           where position = 'Closer Office Manager'
                             and company_id in (select id from flow.company where company_name = 'Solar 101'))
                      when up.position_id = 176 then
                          (select id from flow.position
                           where position = 'Closer'
                             and company_id in (select id from flow.company where company_name = 'Solar 101')) end ,up.start_date,up.end_date,
            case when o.org_type_id = 15 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Region' and
                                                      company_id in (select id from flow.company where company_name = 'Solar 101')))
                 when o.org_type_id = 16 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Office' and
                                                      company_id in (select id from flow.company where company_name = 'Solar 101'))
                        and o1.id = o.id) end,up.primary_flag,
            2350555
     from blueraven."user" u
              inner join blueraven.user_position up on up.user_id = u.id
              inner join blueraven.org o on o.id = up.org_id and o.org_type_id in (15,16) and o.id in (860,861,862));




INSERT INTO flow.org (company_id, org_name, parent_org_id,  org_type_id, active_flag, schedulable, state_id,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'TGE Solar'), 'TGE Solar', null,
            (select id from flow.org_type where org_type.org_type = 'Parent' and
                    company_id in (select id from flow.company where company_name = 'TGE Solar')), true,   false,null,false,
            2350555,
            now(),
            2350555,
            now());

INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'TGE Solar'),
            id,
            org_name,
            (select id
             from flow.org where org_name = 'TGE Solar' and company_id in (select id from flow.company where company_name = 'TGE Solar')),
            (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'TGE Solar')),
            active_flag,
            has_calendar,case when active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org
     where originator_id = 10 and org_type_id = 15);



INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'TGE Solar'),
            o.id,
            o.org_name,
            (select id
             from flow.org where org_type_id in (select id from flow.org_type where org_type =  'Region') and company_id in (select id from flow.company where company_name = 'TGE Solar')),
            (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'TGE Solar')),
            o.active_flag,
            o.has_calendar,
            case when o.active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org o
              inner join blueraven.org  p on p.id = o.parent_org_id
     where p.originator_id = 10 and p.org_type_id = 15);

-- SELECT setval('flow.position_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.position), 1), false);
--
-- INSERT INTO flow.position (company_id, position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'TGE Solar'), 'Closer', (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'TGE Solar')), true,now(),2350555);
-- INSERT INTO flow.position ( company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'TGE Solar'), 'Closer Office Manager',(select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'TGE Solar')), true,now(),2350555);
-- INSERT INTO flow.position (company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'TGE Solar'), 'Closer Regional Manager', (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'TGE Solar')), true,now(),2350555);



INSERT INTO flow."user" (
    phone_number,
    id,
    email,
    created_by_id,
    last_name,
    first_name,
    date_created,
    password,
    date_modified,
    modified_by_id,
    username)
    (SELECT
         phone_number,
         id,
         email,
         created_by,
         last_name,
         first_name,
         created_dt,
         password,
         modified_dt,
         modified_by,
         email
     FROM blueraven."user"
     where id in ( select distinct u.id
                   from blueraven.user u
                            inner join blueraven.user_position up on up.user_id = u.id
                            inner join blueraven.org o on o.id = up.org_id
                       and o.org_type_id in (15,16) and o.id in (863,864)));

insert into flow.user_company(company_id,user_id,is_default)
    (select (select id from flow.company where company_name = 'TGE Solar'),id,true
     FROM blueraven."user"
     where id not in (2350555,99999999,2405363, 2356764, 2410143)
       and id in ( select distinct u.id
                   from blueraven.user u
                            inner join blueraven.user_position up on up.user_id = u.id and up.primary_flag is true
                            inner join blueraven.org o on o.id = up.org_id
                       and o.org_type_id in (15,16) and o.id in (863,864)));

insert into flow.company_user_status(user_id, user_status_type_id, archived, date_created, date_modified, created_by_id, modified_by_id)
    (select u.id,ust.id,false,now(),now(),2350555,2350555
     from blueraven.user u
              inner join blueraven.user_status_type ust2 on u.user_status_type_id = ust2.id
              inner join flow.user_company uc on uc.user_id = u.id
              inner join flow.user_status_type ust  on ust.company_id = uc.company_id
     where ust2.user_status_type = ust.user_status_type
       and u.id not in (2350555,99999999,2405363, 2356764, 2410143)
       and u.id in (select distinct u.id
                    from blueraven.user u
                             inner join blueraven.user_position up on up.user_id = u.id
                             inner join blueraven.org o on o.id = up.org_id
                        and o.org_type_id in (15,16) and o.id in (863,864)));


insert into flow.user_position( user_id, position_id, start_date, end_date, org_id, primary_flag,created_by_id)
    (select u.id,case when up.position_id = 174 then
                          (select id from flow.position
                           where position = 'Closer Regional Manager'
                             and company_id in (select id from flow.company where company_name = 'TGE Solar'))
                      when up.position_id = 175 then
                          (select id from flow.position
                           where position = 'Closer Office Manager'
                             and company_id in (select id from flow.company where company_name = 'TGE Solar'))
                      when up.position_id = 176 then
                          (select id from flow.position
                           where position = 'Closer'
                             and company_id in (select id from flow.company where company_name = 'TGE Solar')) end ,up.start_date,up.end_date,
            case when o.org_type_id = 15 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Region' and
                                                      company_id in (select id from flow.company where company_name = 'TGE Solar')))
                 when o.org_type_id = 16 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Office' and
                                                      company_id in (select id from flow.company where company_name = 'TGE Solar'))
                        and o1.id = o.id) end,up.primary_flag,
            2350555
     from blueraven."user" u
              inner join blueraven.user_position up on up.user_id = u.id
              inner join blueraven.org o on o.id = up.org_id and o.org_type_id in (15,16) and o.id in (863,864));

INSERT INTO flow.org (company_id, org_name, parent_org_id,  org_type_id, active_flag, schedulable, state_id,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Atlas Solar Advisors'), 'Atlas Solar Advisors', null,
            (select id from flow.org_type where org_type.org_type = 'Parent' and
                    company_id in (select id from flow.company where company_name = 'Atlas Solar Advisors')), true,   false,null,false,
            2350555,
            now(),
            2350555,
            now());

INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Atlas Solar Advisors'),
            id,
            org_name,
            (select id
             from flow.org where org_name = 'Atlas Solar Advisors' and company_id in (select id from flow.company where company_name = 'Atlas Solar Advisors')),
            (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Atlas Solar Advisors')),
            active_flag,
            has_calendar,case when active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org
     where originator_id =11 and org_type_id = 15);



INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Atlas Solar Advisors'),
            o.id,
            o.org_name,
            (select id
             from flow.org where org_type_id in (select id from flow.org_type where org_type =  'Region') and company_id in (select id from flow.company where company_name = 'Atlas Solar Advisors')),
            (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Atlas Solar Advisors')),
            o.active_flag,
            o.has_calendar,
            case when o.active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org o
              inner join blueraven.org  p on p.id = o.parent_org_id
     where p.originator_id = 11 and p.org_type_id = 15);

-- SELECT setval('flow.position_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.position), 1), false);
--
-- INSERT INTO flow.position (company_id, position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Atlas Solar Advisors'), 'Closer', (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Atlas Solar Advisors')), true,now(),2350555);
-- INSERT INTO flow.position ( company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Atlas Solar Advisors'), 'Closer Office Manager',(select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Atlas Solar Advisors')), true,now(),2350555);
-- INSERT INTO flow.position (company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Atlas Solar Advisors'), 'Closer Regional Manager', (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Atlas Solar Advisors')), true,now(),2350555);



INSERT INTO flow."user" (
    phone_number,
    id,
    email,
    created_by_id,
    last_name,
    first_name,
    date_created,
    password,
    date_modified,
    modified_by_id,
    username)
    (SELECT
         phone_number,
         id,
         email,
         created_by,
         last_name,
         first_name,
         created_dt,
         password,
         modified_dt,
         modified_by,
         email
     FROM blueraven."user"
     where id in ( select distinct u.id
                   from blueraven.user u
                            inner join blueraven.user_position up on up.user_id = u.id
                            inner join blueraven.org o on o.id = up.org_id
                       and o.org_type_id in (15,16) and o.id in (867,870)));

insert into flow.user_company(company_id,user_id,is_default)
    (select (select id from flow.company where company_name = 'Atlas Solar Advisors'),id,true
     FROM blueraven."user"
     where id not in (2350555,99999999,2405363, 2356764, 2410143)
       and id in ( select distinct u.id
                   from blueraven.user u
                            inner join blueraven.user_position up on up.user_id = u.id and up.primary_flag is true
                            inner join blueraven.org o on o.id = up.org_id
                       and o.org_type_id in (15,16) and o.id in (867,870)));
insert into flow.company_user_status(user_id, user_status_type_id, archived, date_created, date_modified, created_by_id, modified_by_id)
    (select u.id,ust.id,false,now(),now(),2350555,2350555
     from blueraven.user u
              inner join blueraven.user_status_type ust2 on u.user_status_type_id = ust2.id
              inner join flow.user_company uc on uc.user_id = u.id
              inner join flow.user_status_type ust  on ust.company_id = uc.company_id
     where ust2.user_status_type = ust.user_status_type
       and u.id not in (2350555,99999999,2405363, 2356764, 2410143)
       and u.id in (select distinct u.id
                    from blueraven.user u
                             inner join blueraven.user_position up on up.user_id = u.id
                             inner join blueraven.org o on o.id = up.org_id
                        and o.org_type_id in (15,16) and o.id in (867,870)));


insert into flow.user_position( user_id, position_id, start_date, end_date, org_id, primary_flag,created_by_id)
    (select u.id,case when up.position_id = 174 then
                          (select id from flow.position
                           where position = 'Closer Regional Manager'
                             and company_id in (select id from flow.company where company_name = 'Atlas Solar Advisors'))
                      when up.position_id = 175 then
                          (select id from flow.position
                           where position = 'Closer Office Manager'
                             and company_id in (select id from flow.company where company_name = 'Atlas Solar Advisors'))
                      when up.position_id = 176 then
                          (select id from flow.position
                           where position = 'Closer'
                             and company_id in (select id from flow.company where company_name = 'Atlas Solar Advisors')) end ,up.start_date,up.end_date,
            case when o.org_type_id = 15 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Region' and
                                                      company_id in (select id from flow.company where company_name = 'Atlas Solar Advisors')))
                 when o.org_type_id = 16 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Office' and
                                                      company_id in (select id from flow.company where company_name = 'Atlas Solar Advisors'))
                        and o1.id = o.id) end,up.primary_flag,
            2350555
     from blueraven."user" u
              inner join blueraven.user_position up on up.user_id = u.id
              inner join blueraven.org o on o.id = up.org_id and o.org_type_id in (15,16) and o.id in (867,870));



INSERT INTO flow.org (company_id, org_name, parent_org_id,  org_type_id, active_flag, schedulable, state_id,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Direct Solar of America'), 'Direct Solar of America', null,
            (select id from flow.org_type where org_type.org_type = 'Parent' and
                    company_id in (select id from flow.company where company_name = 'Direct Solar of America')), true,   false,null,false,
            2350555,
            now(),
            2350555,
            now());

INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Direct Solar of America'),
            id,
            org_name,
            (select id
             from flow.org where org_name = 'Direct Solar of America' and company_id in (select id from flow.company where company_name = 'Direct Solar of America')),
            (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Direct Solar of America')),
            active_flag,
            has_calendar,case when active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org
     where originator_id = 12 and org_type_id = 15);



INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Direct Solar of America'),
            o.id,
            o.org_name,
            (select id
             from flow.org where org_type_id in (select id from flow.org_type where org_type =  'Region') and company_id in (select id from flow.company where company_name = 'Direct Solar of America')),
            (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Direct Solar of America')),
            o.active_flag,
            o.has_calendar,
            case when o.active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org o
              inner join blueraven.org  p on p.id = o.parent_org_id
     where p.originator_id = 12 and p.org_type_id = 15);

-- SELECT setval('flow.position_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.position), 1), false);
--
-- INSERT INTO flow.position (company_id, position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Direct Solar of America'), 'Closer', (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Direct Solar of America')), true,now(),2350555);
-- INSERT INTO flow.position ( company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Direct Solar of America'), 'Closer Office Manager',(select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Direct Solar of America')), true,now(),2350555);
-- INSERT INTO flow.position (company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Direct Solar of America'), 'Closer Regional Manager', (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Direct Solar of America')), true,now(),2350555);



INSERT INTO flow."user" (
    phone_number,
    id,
    email,
    created_by_id,
    last_name,
    first_name,
    date_created,
    password,
    date_modified,
    modified_by_id,
    username)
    (SELECT
         phone_number,
         id,
         email,
         created_by,
         last_name,
         first_name,
         created_dt,
         password,
         modified_dt,
         modified_by,
         email
     FROM blueraven."user"
     where id in ( select distinct u.id
                   from blueraven.user u
                            inner join blueraven.user_position up on up.user_id = u.id
                            inner join blueraven.org o on o.id = up.org_id
                       and o.org_type_id in (15,16) and o.id in (868,871)));

insert into flow.user_company(company_id,user_id,is_default)
    (select (select id from flow.company where company_name = 'Direct Solar of America'),id,true
     FROM blueraven."user"
     where id not in (2350555,99999999,2405363, 2356764, 2410143)
       and id in ( select distinct u.id
                   from blueraven.user u
                            inner join blueraven.user_position up on up.user_id = u.id and up.primary_flag is true
                            inner join blueraven.org o on o.id = up.org_id
                       and o.org_type_id in (15,16) and o.id in (868,871)));

insert into flow.company_user_status(user_id, user_status_type_id, archived, date_created, date_modified, created_by_id, modified_by_id)
    (select u.id,ust.id,false,now(),now(),2350555,2350555
     from blueraven.user u
              inner join blueraven.user_status_type ust2 on u.user_status_type_id = ust2.id
              inner join flow.user_company uc on uc.user_id = u.id
              inner join flow.user_status_type ust  on ust.company_id = uc.company_id
     where ust2.user_status_type = ust.user_status_type
       and u.id not in (2350555,99999999,2405363, 2356764, 2410143)
       and u.id in (select distinct u.id
                    from blueraven.user u
                             inner join blueraven.user_position up on up.user_id = u.id
                             inner join blueraven.org o on o.id = up.org_id
                        and o.org_type_id in (15,16) and o.id in (868,871)));


insert into flow.user_position( user_id, position_id, start_date, end_date, org_id, primary_flag,created_by_id)
    (select u.id,case when up.position_id = 174 then
                          (select id from flow.position
                           where position = 'Closer Regional Manager'
                             and company_id in (select id from flow.company where company_name = 'Direct Solar of America'))
                      when up.position_id = 175 then
                          (select id from flow.position
                           where position = 'Closer Office Manager'
                             and company_id in (select id from flow.company where company_name = 'Direct Solar of America'))
                      when up.position_id = 176 then
                          (select id from flow.position
                           where position = 'Closer'
                             and company_id in (select id from flow.company where company_name = 'Direct Solar of America')) end ,up.start_date,up.end_date,
            case when o.org_type_id = 15 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Region' and
                                                      company_id in (select id from flow.company where company_name = 'Direct Solar of America')))
                 when o.org_type_id = 16 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Office' and
                                                      company_id in (select id from flow.company where company_name = 'Direct Solar of America'))
                        and o1.id = o.id) end,up.primary_flag,
            2350555
     from blueraven."user" u
              inner join blueraven.user_position up on up.user_id = u.id
              inner join blueraven.org o on o.id = up.org_id and o.org_type_id in (15,16) and o.id in (868,871));

INSERT INTO flow.org (company_id, org_name, parent_org_id,  org_type_id, active_flag, schedulable, state_id,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Revolution Solar'), 'Revolution Solar', null,
            (select id from flow.org_type where org_type.org_type = 'Parent' and
                    company_id in (select id from flow.company where company_name = 'Revolution Solar')), true,   false,null,false,
            2350555,
            now(),
            2350555,
            now());

INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Revolution Solar'),
            id,
            org_name,
            (select id
             from flow.org where org_name = 'Revolution Solar' and company_id in (select id from flow.company where company_name = 'Revolution Solar')),
            (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Revolution Solar')),
            active_flag,
            has_calendar,case when active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org
     where originator_id = 13 and org_type_id = 15);



INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Revolution Solar'),
            o.id,
            o.org_name,
            (select id
             from flow.org where org_type_id in (select id from flow.org_type where org_type =  'Region') and company_id in (select id from flow.company where company_name = 'Revolution Solar')),
            (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Revolution Solar')),
            o.active_flag,
            o.has_calendar,
            case when o.active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org o
              inner join blueraven.org  p on p.id = o.parent_org_id
     where p.originator_id = 13 and p.org_type_id = 15);

-- SELECT setval('flow.position_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.position), 1), false);
--
-- INSERT INTO flow.position (company_id, position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Revolution Solar'), 'Closer', (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Revolution Solar')), true,now(),2350555);
-- INSERT INTO flow.position ( company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Revolution Solar'), 'Closer Office Manager',(select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Revolution Solar')), true,now(),2350555);
-- INSERT INTO flow.position (company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Revolution Solar'), 'Closer Regional Manager', (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Revolution Solar')), true,now(),2350555);



INSERT INTO flow."user" (
    phone_number,
    id,
    email,
    created_by_id,
    last_name,
    first_name,
    date_created,
    password,
    date_modified,
    modified_by_id,
    username)
    (SELECT
         phone_number,
         id,
         email,
         created_by,
         last_name,
         first_name,
         created_dt,
         password,
         modified_dt,
         modified_by,
         email
     FROM blueraven."user"
     where id in ( select distinct u.id
                   from blueraven.user u
                            inner join blueraven.user_position up on up.user_id = u.id
                            inner join blueraven.org o on o.id = up.org_id
                       and o.org_type_id in (15,16) and o.id in (869,872)));

insert into flow.user_company(company_id,user_id,is_default)
    (select (select id from flow.company where company_name = 'Revolution Solar'),id,true
     FROM blueraven."user"
     where id not in (2350555,99999999,2405363, 2356764, 2410143)
       and id in ( select distinct u.id
                   from blueraven.user u
                            inner join blueraven.user_position up on up.user_id = u.id and up.primary_flag is true
                            inner join blueraven.org o on o.id = up.org_id
                       and o.org_type_id in (15,16) and o.id in (869,872)));

insert into flow.company_user_status(user_id, user_status_type_id, archived, date_created, date_modified, created_by_id, modified_by_id)
    (select u.id,ust.id,false,now(),now(),2350555,2350555
     from blueraven.user u
              inner join blueraven.user_status_type ust2 on u.user_status_type_id = ust2.id
              inner join flow.user_company uc on uc.user_id = u.id
              inner join flow.user_status_type ust  on ust.company_id = uc.company_id
     where ust2.user_status_type = ust.user_status_type
       and u.id not in (2350555,99999999,2405363, 2356764, 2410143)
       and u.id in (select distinct u.id
                    from blueraven.user u
                             inner join blueraven.user_position up on up.user_id = u.id
                             inner join blueraven.org o on o.id = up.org_id
                        and o.org_type_id in (15,16) and o.id in (869,872)));


insert into flow.user_position( user_id, position_id, start_date, end_date, org_id, primary_flag,created_by_id)
    (select u.id,case when up.position_id = 174 then
                          (select id from flow.position
                           where position = 'Closer Regional Manager'
                             and company_id in (select id from flow.company where company_name = 'Revolution Solar'))
                      when up.position_id = 175 then
                          (select id from flow.position
                           where position = 'Closer Office Manager'
                             and company_id in (select id from flow.company where company_name = 'Revolution Solar'))
                      when up.position_id = 176 then
                          (select id from flow.position
                           where position = 'Closer'
                             and company_id in (select id from flow.company where company_name = 'Revolution Solar')) end ,up.start_date,up.end_date,
            case when o.org_type_id = 15 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Region' and
                                                      company_id in (select id from flow.company where company_name = 'Revolution Solar')))
                 when o.org_type_id = 16 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Office' and
                                                      company_id in (select id from flow.company where company_name = 'Revolution Solar'))
                        and o1.id = o.id) end,up.primary_flag,
            2350555
     from blueraven."user" u
              inner join blueraven.user_position up on up.user_id = u.id
              inner join blueraven.org o on o.id = up.org_id and o.org_type_id in (15,16) and o.id in (869,872));

INSERT INTO flow.org (company_id, org_name, parent_org_id,  org_type_id, active_flag, schedulable, state_id,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Smart Money Solar'), 'Smart Money Solar', null,
            (select id from flow.org_type where org_type.org_type = 'Parent' and
                    company_id in (select id from flow.company where company_name = 'Smart Money Solar')), true,   false,null,false,
            2350555,
            now(),
            2350555,
            now());

INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Smart Money Solar'),
            id,
            org_name,
            (select id
             from flow.org where org_name = 'Smart Money Solar' and company_id in (select id from flow.company where company_name = 'Smart Money Solar')),
            (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Smart Money Solar')),
            active_flag,
            has_calendar,case when active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org
     where originator_id = 14 and org_type_id = 15);



INSERT INTO flow.org(company_id, id, org_name, parent_org_id, org_type_id,
                     active_flag,
                     schedulable,archived,modified_by_id,date_modified,created_by_id,date_created)
    (select (select id from flow.company where company_name = 'Smart Money Solar'),
            o.id,
            o.org_name,
            (select id
             from flow.org where org_type_id in (select id from flow.org_type where org_type =  'Region') and company_id in (select id from flow.company where company_name = 'Smart Money Solar')),
            (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Smart Money Solar')),
            o.active_flag,
            o.has_calendar,
            case when o.active_flag is true then false else true end,
            2350555,
            now(),
            2350555,
            now()
     from blueraven.org o
              inner join blueraven.org  p on p.id = o.parent_org_id
     where p.originator_id = 14 and p.org_type_id = 15);

-- SELECT setval('flow.position_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.position), 1), false);
--
-- INSERT INTO flow.position (company_id, position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Smart Money Solar'), 'Closer', (select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Smart Money Solar')), true,now(),2350555);
-- INSERT INTO flow.position ( company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Smart Money Solar'), 'Closer Office Manager',(select id from flow.org_type where org_type = 'Office' and company_id in (select id from flow.company where company_name = 'Smart Money Solar')), true,now(),2350555);
-- INSERT INTO flow.position (company_id,position, org_type_id, active,date_created,created_by_id) VALUES ((select id from flow.company where company_name = 'Smart Money Solar'), 'Closer Regional Manager', (select id from flow.org_type where org_type = 'Region' and company_id in (select id from flow.company where company_name = 'Smart Money Solar')), true,now(),2350555);



INSERT INTO flow."user" (
    phone_number,
    id,
    email,
    created_by_id,
    last_name,
    first_name,
    date_created,
    password,
    date_modified,
    modified_by_id,
    username)
    (SELECT
         phone_number,
         id,
         email,
         created_by,
         last_name,
         first_name,
         created_dt,
         password,
         modified_dt,
         modified_by,
         email
     FROM blueraven."user"
     where id in ( select distinct u.id
                   from blueraven.user u
                            inner join blueraven.user_position up on up.user_id = u.id
                            inner join blueraven.org o on o.id = up.org_id
                       and o.org_type_id in (15,16) and o.id in (874,875)));

insert into flow.user_company(company_id,user_id,is_default)
    (select (select id from flow.company where company_name = 'Smart Money Solar'),id,true
     FROM blueraven."user"
     where id not in (2350555,99999999,2405363, 2356764, 2410143)
       and id in ( select distinct u.id
                   from blueraven.user u
                            inner join blueraven.user_position up on up.user_id = u.id and up.primary_flag is true
                            inner join blueraven.org o on o.id = up.org_id
                       and o.org_type_id in (15,16) and o.id in (874,875)));

insert into flow.company_user_status(user_id, user_status_type_id, archived, date_created, date_modified, created_by_id, modified_by_id)
    (select u.id,ust.id,false,now(),now(),2350555,2350555
     from blueraven.user u
              inner join blueraven.user_status_type ust2 on u.user_status_type_id = ust2.id
              inner join flow.user_company uc on uc.user_id = u.id
              inner join flow.user_status_type ust  on ust.company_id = uc.company_id
     where ust2.user_status_type = ust.user_status_type
       and u.id not in (2350555,99999999,2405363, 2356764, 2410143)
       and u.id in (select distinct u.id
                    from blueraven.user u
                             inner join blueraven.user_position up on up.user_id = u.id
                             inner join blueraven.org o on o.id = up.org_id
                        and o.org_type_id in (15,16) and o.id in (874,875)));


insert into flow.user_position( user_id, position_id, start_date, end_date, org_id, primary_flag,created_by_id)
    (select u.id,case when up.position_id = 174 then
                          (select id from flow.position
                           where position = 'Closer Regional Manager'
                             and company_id in (select id from flow.company where company_name = 'Smart Money Solar'))
                      when up.position_id = 175 then
                          (select id from flow.position
                           where position = 'Closer Office Manager'
                             and company_id in (select id from flow.company where company_name = 'Smart Money Solar'))
                      when up.position_id = 176 then
                          (select id from flow.position
                           where position = 'Closer'
                             and company_id in (select id from flow.company where company_name = 'Smart Money Solar')) end ,up.start_date,up.end_date,
            case when o.org_type_id = 15 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Region' and
                                                      company_id in (select id from flow.company where company_name = 'Smart Money Solar')))
                 when o.org_type_id = 16 then
                     (select o1.id from flow.org o1
                      where o1.org_type_id = (select id from flow.org_type
                                              where org_type = 'Office' and
                                                      company_id in (select id from flow.company where company_name = 'Smart Money Solar'))
                        and o1.id = o.id) end,up.primary_flag,
            2350555
     from blueraven."user" u
              inner join blueraven.user_position up on up.user_id = u.id
              inner join blueraven.org o on o.id = up.org_id and o.org_type_id in (15,16) and o.id in (874,875));


SELECT setval('flow.user_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.user where id != 99999999), 1), false);
SELECT setval('flow.org_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.org), 1), false);
SELECT setval('flow.user_position_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.user_position), 1), false);
SELECT setval('flow.org_type_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.org_type), 1), false);


-- INSERT INTO flow.organization_custom_field_value (org_id, custom_field_group_assignment_id, text_value, created_by_id)
--     (SELECT o.id,
--             (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Birdeye Business ID' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
--             o.birdeye_business_id,
--             2350555 as created_by_id
--      FROM blueraven.org o
--      WHERE birdeye_business_id IS NOT NULL);


INSERT INTO flow.organization_custom_field_value (org_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT o.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Birdeye Business ID' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            o.birdeye_business_id,
            2350555 as created_by_id
     FROM blueraven.org o
     WHERE birdeye_business_id IS NOT NULL);


-- insert into brs.sales_area_type(id, sales_area_type)
--     (select id, sales_area_type
--      from blueraven.sales_area_type);
--
-- SELECT setval('brs.sales_area_type_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.sales_area_type), 1), false);


-- insert into brs.sales_area(id, area, sales_area_type_id, state_id)
--     (select id, area, sales_area_type_id, state_id
--      from blueraven.sales_area);
--
-- SELECT setval('brs.sales_area_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.sales_area), 1), false);


-- insert into brs.sales_metro_area(id, sales_metro_area, sales_area_id, archived, final_design_minimum, fixed_grace_days)
--     (select id,
--             sales_metro_area,
--             sales_area_id,
--             CASE WHEN active IS FALSE THEN TRUE ELSE FALSE END,
--             final_design_minimum,
--             fixed_grace_days
--      from blueraven.sales_metro_area);
--
-- SELECT setval('brs.sales_metro_area_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.sales_metro_area), 1), false);


insert into brs.podium_location(id, podium_id, name, date_created, date_modified)
    (select id, podium_id, name, date_created, date_updated
     from blueraven.podium_location);

SELECT setval('brs.podium_location_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.podium_location), 1), false);


insert into brs.birdeye_location(business_id, alias)
    (select business_id, alias
     from blueraven.birdeye_locations);

insert into flow.asset_type
select *
from blueraven.asset_type;

SELECT setval('flow.asset_type_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.asset_type), 1), false);


INSERT INTO flow.asset(id, company_id, tag, model, asset_type_id, active, archived)
    (select id, (select id from flow.company where company_name = 'Blue Raven Solar'), tag, model, asset_type_id, active, archived
     from blueraven.asset);

SELECT setval('flow.asset_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.asset), 1), false);


insert into flow.user_asset
select *
from blueraven.user_asset;

SELECT setval('flow.user_asset_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.user_asset), 1), false);


insert into brs.budget_type(id, name, archived, date_created, date_modified)
    (select id,
            name,
            CASE WHEN active IS FALSE THEN TRUE ELSE FALSE END,
            date_created,
            date_updated
     from blueraven.budget_type);

SELECT setval('brs.budget_type_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.budget_type), 1), false);


insert into brs.budget_template(id, user_id, budget_type_id, amount, archived, date_created, created_by_id, date_modified, modified_by_id)
    (select id,
            user_id,
            budget_type_id,
            amount,
            CASE WHEN active IS FALSE THEN TRUE ELSE FALSE END,
            date_created,
            created_by_id,
            date_updated,
            updated_by_id
     from blueraven.budget_template);

SELECT setval('brs.budget_template_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.budget_template), 1), false);


insert into brs.expense_budget(id, user_id, budget_type_id, amount, archived, date_created, created_by_id, date_modified, modified_by_id, start_date, end_date, original_expense_budget_id, notes)
    (select id, user_id, budget_type_id, amount, archived, date_created, created_by_id, date_updated, updated_by_id, start_date, end_date, original_expense_budget_id, notes
     from blueraven.expense_budget);

SELECT setval('brs.expense_budget_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.expense_budget), 1), false);

delete from flow.attachment_source;
delete from flow.attachment;
INSERT INTO flow.attachment(id, filename, content_type, s3_key, size, archived, date_created, date_modified,attachment_type_id, company_id)
    (select a.id, filename, content_type, s3_key, size, deleted, created, updated,as1.attachment_source_type_id, (select id from flow.company where company_name = 'Blue Raven Solar')
     from blueraven.attachment a
              inner join blueraven.attachment_source as1 on as1.attachment_id = a.id
        where a.id not in (select id from flow.attachment));

SELECT setval('flow.attachment_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.attachment), 1), false);

insert into brs.reimbursement_request_status(id, reimbursement_request_status)
    (select id, reimbursement_request_status
     from blueraven.reimbursement_request_status);

SELECT setval('brs.reimbursement_request_status_id_seq',
              COALESCE((SELECT MAX(id) + 1 FROM brs.reimbursement_request_status), 1), false);


insert into brs.reimbursement_request(id, details, notes, amount, expense_budget_id, attachment_id, expense_date, archived, date_created, created_by_id, date_modified, reimbursement_request_status_id)
    (select id, details, notes, amount, expense_budget_id, attachment_id, expense_date, archived, date_created, created_by_user_id, date_updated, reimbursement_request_status_id
     from blueraven.reimbursement_request);

SELECT setval('brs.reimbursement_request_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.reimbursement_request), 1),
              false);


insert into brs.gl_code(id, code, description, archived, date_created, date_modified)
    (select id,
            code,
            description,
            CASE WHEN active IS FALSE THEN TRUE ELSE FALSE END,
            date_created,
            date_updated
     from blueraven.gl_code);

SELECT setval('brs.gl_code_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.gl_code), 1), false);


insert into brs.expense(id, user_id, expense_budget_id, gl_code_id, notes, expense_date, expense_amount, archived, date_created, date_modified, modified_by_id, date_submitted, submitted_by_id, reimbursement_request_id, approval_date, approved_by_id, paid_date, paid_by_id, skip_approval, rejected_date, rejected_by_id)
    (select id, user_id, expense_budget_id, gl_code_id, notes, expense_date, expense_amount, archived, date_created, date_updated, updated_by_id, date_submitted, submitted_by_id, reimbursement_request_id, approval_date, approved_by_id, paid_date, paid_by_id, skip_approval, rejected_date, rejected_by_id
     from blueraven.expense);

SELECT setval('brs.expense_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.expense), 1), false);


INSERT INTO brs.expense_gl_code(expense_id, gl_code_id, amount, date_created, date_modified)
    (select expense_id, gl_code_id, amount, date_created, date_updated
     from blueraven.expense_gl_code);

SELECT setval('brs.expense_gl_code_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.expense_gl_code), 1), false);


-- insert into brs.metro_area(id, metro_area, sales_area_id, archived)
--     (select id,
--             metro_area,
--             sales_area_id,
--             CASE WHEN active IS FALSE THEN TRUE ELSE FALSE END
--      from blueraven.metro_area);
--
-- SELECT setval('brs.metro_area_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.metro_area), 1), false);
--
--
-- insert into brs.org_metro_area
-- select *
-- from blueraven.org_metro_area;
--
-- SELECT setval('brs.org_metro_area_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.org_metro_area), 1), false);


insert into flow.associated_org_type
select *
from blueraven.associated_org_type;

SELECT setval('flow.org_type_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.associated_org_type), 1), false);


insert into flow.associated_org
select *
from blueraven.associated_org;

SELECT setval('flow.associated_org_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.associated_org), 1), false);




insert into flow.attachment_source(id,attachment_id,source_id)
select id,attachment_id,source_id
from blueraven.attachment_source;


SELECT setval('flow.attachment_source_id_seq', COALESCE((SELECT MAX(id) + 1 FROM flow.attachment_source), 1), false);

insert into brs.ahj(id, name, archived, date_created, created_by_id, date_modified, modified_by_id)
    (select id, name, archived, created, created_by_id, updated, updated_by_id
     from blueraven.ahj);

SELECT setval('brs.ahj_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj), 1), false);

insert into brs.financier(id, name, submission_method, archived, date_created, created_by_id, date_modified, modified_by_id)
    (select id, name, submission_method, archived, now(), 2350555, null, null
     from blueraven.financier);

insert into props.financier(id,company_id, name, submission_method, archived, date_created, created_by_id, date_modified, modified_by_id)
    (select id,(select id from flow.company where company_name = 'Blue Raven Corporate'), name, submission_method, archived, now(), 2350555, null, null
     from blueraven.financier);

SELECT setval('brs.financier_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.financier), 1), false);

insert into brs.ahj_utility(id, name, archived, date_created, date_modified, timelines_and_stages, regulated_by, monthly_facility_charge, population_of_service, net_metering_rate, rebate_rates, utility_rate_notes, customer_signature_instructions, expected_approval_timeline, rejection_instructions, notes, submission_instructions, final_completion_instructions, overview_of_submission_process, timelines, pto_followup_instructions, financier_id)
    (select id, name, CASE WHEN active IS FALSE THEN TRUE ELSE FALSE END, date_created, date_updated, timelines_and_stages, regulated_by, monthly_facility_charge, population_of_service, net_metering_rate, rebate_rates, utility_rate_notes, customer_signature_instructions, expected_approval_timeline, rejection_instructions, notes, submission_instructions, final_completion_instructions, overview_of_submission_process, timelines, pto_followup_instructions, financier_id
     from blueraven.ahj_utility);

SELECT setval('brs.ahj_utility_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_utility), 1), false);

-- --1 General blue raven coroporate
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Qualifier',4,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Hire Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Qualifer',74,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Leave of Absence Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Reactivation Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Termination Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Employee ID',71,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Submitted By',75,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Phone Directory Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Greenlight Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Dividend Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Request Sunops App',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Ignition Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Application Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Dropbox Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Oneroof Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Dividend Spoof',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('i9 Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Confidentiality Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('W4 Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Quickbase Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Dividend Spoof Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Removed From Directory Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Cancelled Greenlight Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Cancelled Dividend Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Removed Sunops Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Removed Sales Rabbit Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Cancelled Ignition Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Reason for Termination',71,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Termination Notes',71,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Department',71,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Crew',71,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Employee Handbook Signed Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Enter in Timeforce Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Expiry Date',73,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Dropbox Cancel Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Timeforce Cancel Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('E-Mail Opt Out Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Request T-Sheets Flag',74,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Phone Extension',71,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Drivers License Number',71,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Humanity Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('IT Onboarding Complete Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('IT Termination Complete Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Exit Interview Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Deactivate Badge Request Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Values Meeting Invite Sent Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Cooperate Meeting Invite Sent Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Values Meeting Attended Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('New Hire Orientation Meeting Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('BRU Pass Off Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- --1 General blue raven solar
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Qualifier',4,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Hire Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Leave of Absence Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Reactivation Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Termination Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Employee ID',1,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Submitted By',5,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Phone Directory Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Greenlight Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Dividend Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Request Sunops App',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Ignition Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Application Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Dropbox Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Oneroof Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Dividend Spoof',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('i9 Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Confidentiality Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('W4 Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Quickbase Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Dividend Spoof Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Removed From Directory Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Cancelled Greenlight Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Cancelled Dividend Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Removed Sunops Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Removed Sales Rabbit Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Cancelled Ignition Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Reason for Termination',1,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Termination Notes',1,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Department',1,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Crew',1,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Employee Handbook Signed Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Enter in Timeforce Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Expiry Date',3,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Dropbox Cancel Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Timeforce Cancel Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('E-Mail Opt Out Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Request T-Sheets Flag',4,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Phone Extension',1,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Drivers License Number',1,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Humanity Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('IT Onboarding Complete Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('IT Termination Complete Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Exit Interview Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Deactivate Badge Request Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Values Meeting Invite Sent Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Cooperate Meeting Invite Sent Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Values Meeting Attended Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('New Hire Orientation Meeting Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('BRU Pass Off Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- --group 2 blueraven corporate
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Uniform/Badge Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Shirt Size',71,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Hat',71,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Accuity Appointment ID',75,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Personal Email',71,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- --group 2 blueraven solar
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Uniform/Badge Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Shirt Size',1,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Hat',1,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Accuity Appointment ID',5,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Personal Email',1,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- ---systems group 5 blue raven corporate
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Namely Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Email Setup Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Request Base Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Base Contact Created Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Mosiac Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Litmos Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('T-Sheets Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
--
-- ---systems group 5 blue raven solar
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Namely Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Email Setup Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Request Base Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Base Contact Created Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Mosiac Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Litmos Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('T-Sheets Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- ---onboarding group 3 blueraven corporate
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Offer Letter Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Contract Request Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Contract Received Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Contract Saved Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Background Check Submitted Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Background Check Received Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Welcome E-Mail Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Photo Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Voided Check Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
--
-- ---onboarding group 3 blueraven solar
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Offer Letter Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Contract Request Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Contract Received Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Contract Saved Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Background Check Submitted Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Background Check Received Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Welcome E-Mail Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Photo Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Voided Check Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- --HR 4 blueraven corporate
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Re-Hire Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Pending Termination Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Termination Reason',71,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Leave of Absence Reason',71,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id,system_list_option_ids,company_system_list_id)
-- VALUES ('Recruited By',75,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'),'{10}',2);
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id,system_list_option_ids,company_system_list_id)
-- VALUES ('Referred By',75,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'),null,4);
--
--
-- --HR 4 blueraven solar
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Re-Hire Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Pending Termination Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Termination Reason',1,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Leave of Absence Reason',1,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id,system_list_option_ids,company_system_list_id)
-- VALUES ('Recruited By',5,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'),'{10}',2);
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id,system_list_option_ids,company_system_list_id)
-- VALUES ('Referred By',5,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'),null,4);
--
-- --6 termination blueraven corporate
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Cancelled Namely Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('E-Mail Removed Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Cancelled Base Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Base Contact Deleted Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Cancelled Mosiac Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Cancelled Litmos Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Cancelled T-Sheets Date',72,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Corporate'));
--
-- --6 termination blueraven solar
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Cancelled Namely Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('E-Mail Removed Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Cancelled Base Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Base Contact Deleted Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Cancelled Mosiac Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Cancelled Litmos Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id ,company_id)
-- VALUES ('Cancelled T-Sheets Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));

--blueraven corporate
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Submitted By' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Qualifier' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Leave of Absence Reason' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Leave of Absence Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Reactivation Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'BRU Pass Off Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Termination Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Employee ID' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Hire Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Phone Directory Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
--
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Greenlight Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Dividend Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Request Sunops App' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Ignition Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Application Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Dropbox Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Oneroof Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Dividend Spoof' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'i9 Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Confidentiality Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'W4 Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Quickbase Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Dividend Spoof Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Removed From Directory Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Cancelled Greenlight Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Cancelled Dividend Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Removed Sunops Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Removed Sales Rabbit Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Cancelled Ignition Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Reason for Termination' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Termination Notes' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Department' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Crew' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Employee Handbook Signed Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Enter in Timeforce Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Expiry Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Dropbox Cancel Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Timeforce Cancel Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'E-Mail Opt Out Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Request T-Sheets Flag' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Phone Extension' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Drivers License Number' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Humanity Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'IT Onboarding Complete Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'IT Termination Complete Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Exit Interview Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Deactivate Badge Request Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Values Meeting Invite Sent Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Cooperate Meeting Invite Sent Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Values Meeting Attended Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'New Hire Orientation Meeting Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Uniform/Badge Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Shirt Size' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Hat' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Accuity Appointment ID' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Namely Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Email Setup Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Request Base Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Base Contact Created Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Mosiac Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Litmos Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'T-Sheets Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Offer Letter Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Contract Request Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Contract Received Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Contract Saved Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Background Check Submitted Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Background Check Received Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Welcome E-Mail Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Photo Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Voided Check Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Re-Hire Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Pending Termination Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Termination Reason' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Cancelled Namely Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'E-Mail Removed Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Cancelled Base Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Base Contact Deleted Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Cancelled Mosiac Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Cancelled Litmos Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Cancelled T-Sheets Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
--
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Employment Type' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
--
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Compensation Type' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
--
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Finding Source' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
--
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Personal Email' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
--
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Referred By' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
--
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Corporate'))
--      from flow.custom_field cf
--      where cf.field_name = 'Recruited By' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')
--     );
--
-- --blueraven solar
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Submitted By' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Qualifier' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Leave of Absence Reason' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Leave of Absence Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Reactivation Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--           (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--            from flow.custom_field cf
--            where cf.field_name = 'BRU Pass Off Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--           );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Termination Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Employee ID' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Hire Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Phone Directory Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
--
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Greenlight Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Dividend Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Request Sunops App' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Ignition Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Application Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Dropbox Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Oneroof Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Dividend Spoof' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'i9 Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Confidentiality Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'W4 Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Quickbase Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Dividend Spoof Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Removed From Directory Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Cancelled Greenlight Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Cancelled Dividend Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Removed Sunops Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Removed Sales Rabbit Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Cancelled Ignition Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Reason for Termination' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Termination Notes' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Department' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Crew' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Employee Handbook Signed Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Enter in Timeforce Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Expiry Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Dropbox Cancel Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Timeforce Cancel Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'E-Mail Opt Out Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Request T-Sheets Flag' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Phone Extension' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Drivers License Number' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Humanity Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'IT Onboarding Complete Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'IT Termination Complete Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Exit Interview Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Deactivate Badge Request Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Values Meeting Invite Sent Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Cooperate Meeting Invite Sent Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Values Meeting Attended Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'New Hire Orientation Meeting Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Uniform/Badge Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Shirt Size' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Hat' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Accuity Appointment ID' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Namely Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Email Setup Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Request Base Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Base Contact Created Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Mosiac Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Litmos Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'T-Sheets Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Offer Letter Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Contract Request Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Contract Received Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Contract Saved Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Background Check Submitted Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Background Check Received Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Welcome E-Mail Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Photo Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Voided Check Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Re-Hire Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Pending Termination Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Termination Reason' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Cancelled Namely Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'E-Mail Removed Date'
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Cancelled Base Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Base Contact Deleted Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Cancelled Mosiac Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Cancelled Litmos Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Cancelled T-Sheets Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
--
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Employment Type' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
--
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Compensation Type' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
--
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Finding Source' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
--
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Personal Email' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
--
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Referred By' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );
--
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,(select id from flow.company_object_type where object_type_id = 3 and company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
--      from flow.custom_field cf
--      where cf.field_name = 'Recruited By' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--     );


-- --blueraven corporate
-- INSERT INTO flow.custom_field_group(
--     group_name,company_object_type_id, group_order, archived)
-- VALUES ('General',33, 6, true);
--
-- INSERT INTO flow.custom_field_group(
--     group_name,company_object_type_id, group_order)
-- VALUES ('Personal',33, 1);
--
-- INSERT INTO flow.custom_field_group(
--     group_name,company_object_type_id, group_order)
-- VALUES ('Onboarding',33, 2);
--
-- INSERT INTO flow.custom_field_group(
--     group_name,company_object_type_id, group_order)
-- VALUES ('HR',33, 3);
--
-- INSERT INTO flow.custom_field_group(
--     group_name,company_object_type_id, group_order)
-- VALUES ('Systems',33, 4);
--
-- INSERT INTO flow.custom_field_group(
--     group_name,company_object_type_id, group_order)
-- VALUES ('Termination',33, 5);
--
-- -- INSERT INTO flow.custom_field_group(
-- --     group_name,company_object_type_id, group_order)
-- -- VALUES ('Project PlaceHolder',31, 1);
-- --
-- -- INSERT INTO flow.custom_field_group(
-- --     group_name,company_object_type_id, group_order)
-- -- VALUES ('Contact PlaceHolder',32, 1);
--
-- --blueraven solar
-- INSERT INTO flow.custom_field_group(
--     group_name,company_object_type_id, group_order, archived)
-- VALUES ('General',3, 6, true);
--
-- INSERT INTO flow.custom_field_group(
--     group_name,company_object_type_id, group_order)
-- VALUES ('Personal',3, 1);
--
-- INSERT INTO flow.custom_field_group(
--     group_name,company_object_type_id, group_order)
-- VALUES ('Onboarding',3, 2);
--
-- INSERT INTO flow.custom_field_group(
--     group_name,company_object_type_id, group_order)
-- VALUES ('HR',3, 3);
--
-- INSERT INTO flow.custom_field_group(
--     group_name,company_object_type_id, group_order)
-- VALUES ('Systems',3, 4);
--
-- INSERT INTO flow.custom_field_group(
--     group_name,company_object_type_id, group_order)
-- VALUES ('Termination',3, 5);
--
-- INSERT INTO flow.custom_field_group(
--     group_name,company_object_type_id, group_order)
-- VALUES ('Project PlaceHolder',1, 1);
--
-- INSERT INTO flow.custom_field_group(
--     group_name,company_object_type_id, group_order)
-- VALUES ('Contact PlaceHolder',2, 1);
--
-- INSERT INTO flow.custom_field_group(
--     group_name,company_object_type_id, group_order)
-- VALUES ('Process Step PlaceHolder',4, 1);


-- --blueraven corporate
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Personal' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Employee ID' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Qualifier' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Termination Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Leave of Absence Reason' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Leave of Absence Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Reactivation Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'BRU Pass Off Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Personal' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Uniform/Badge Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Personal' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Shirt Size' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Personal' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Hat' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Personal' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Accuity Appointment ID' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Personal' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Personal Email' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
--
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Systems' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Namely Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Systems' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Email Setup Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Systems' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Request Base Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Systems' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Base Contact Created Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Systems' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Mosiac Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Systems' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Litmos Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Systems' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'T-Sheets Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
--
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Onboarding' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Offer Letter Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Onboarding' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Contract Request Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Onboarding' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Contract Received Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Onboarding' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Contract Saved Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Onboarding' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Background Check Submitted Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Onboarding' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Background Check Received Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Onboarding' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Welcome E-Mail Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Onboarding' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Photo Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Onboarding' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Voided Check Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Submitted By' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Hire Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Compensation Type' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Employment Type' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Finding Source' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Re-Hire Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Pending Termination Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Termination Reason' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Referred By' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Recruited By' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Termination' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Cancelled Namely Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Termination' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'E-Mail Removed Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Termination' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Cancelled Base Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Termination' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Base Contact Deleted Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Termination' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Cancelled Mosiac Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Termination' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Cancelled Litmos Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Termination' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Cancelled T-Sheets Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
--
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Phone Directory Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Greenlight Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Dividend Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Request Sunops App' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Ignition Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Application Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Dropbox Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Oneroof Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Dividend Spoof' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'i9 Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Confidentiality Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'W4 Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Quickbase Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Dividend Spoof Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Removed From Directory Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Cancelled Greenlight Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Cancelled Dividend Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Removed Sunops Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Removed Sales Rabbit Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Cancelled Ignition Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Reason for Termination' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Termination Notes' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Department' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Crew' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Employee Handbook Signed Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Enter in Timeforce Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Expiry Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Dropbox Cancel Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Timeforce Cancel Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'E-Mail Opt Out Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Request T-Sheets Flag' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Personal' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Phone Extension' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Drivers License Number' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Humanity Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'IT Onboarding Complete Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'IT Termination Complete Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Exit Interview Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Deactivate Badge Request Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Values Meeting Invite Sent Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Cooperate Meeting Invite Sent Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'Values Meeting Attended Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 33),
--             (select id from flow.custom_field where field_name = 'New Hire Orientation Meeting Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')),1,false, 2350555);
--
-- --blueraven solar********************************************
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Leave of Absence Reason' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Qualifier' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Leave of Absence Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Reactivation Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Termination Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'BRU Pass Off Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Personal' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Employee ID' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--  (select (select id from flow.custom_field_group where group_name = 'Personal' and company_object_type_id = 3),
--   (select id from flow.custom_field where field_name = 'Uniform/Badge Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Personal' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Shirt Size' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Personal' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Hat' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Personal' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Accuity Appointment ID' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Personal' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Personal Email' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
--
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Systems' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Namely Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Systems' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Email Setup Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Systems' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Request Base Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Systems' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Base Contact Created Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Systems' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Mosiac Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Systems' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Litmos Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Systems' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'T-Sheets Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
--
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Onboarding' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Offer Letter Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Onboarding' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Contract Request Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Onboarding' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Contract Received Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Onboarding' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Contract Saved Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Onboarding' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Background Check Submitted Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Onboarding' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Background Check Received Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Onboarding' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Welcome E-Mail Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Onboarding' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Photo Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Onboarding' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Voided Check Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Submitted By' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Hire Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Compensation Type' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Employment Type' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Finding Source' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Re-Hire Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Pending Termination Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Termination Reason' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Referred By' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'HR' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Recruited By' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Termination' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Cancelled Namely Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Termination' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'E-Mail Removed Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Termination' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Cancelled Base Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Termination' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Base Contact Deleted Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Termination' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Cancelled Mosiac Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Termination' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Cancelled Litmos Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Termination' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Cancelled T-Sheets Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
--
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Phone Directory Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Greenlight Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Dividend Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Request Sunops App' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Ignition Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Application Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Dropbox Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Oneroof Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Dividend Spoof' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'i9 Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Confidentiality Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'W4 Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Quickbase Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Dividend Spoof Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Removed From Directory Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Cancelled Greenlight Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Cancelled Dividend Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Removed Sunops Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Removed Sales Rabbit Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Cancelled Ignition Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Reason for Termination' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Termination Notes' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Department' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Crew' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Employee Handbook Signed Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Enter in Timeforce Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Expiry Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Dropbox Cancel Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Timeforce Cancel Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'E-Mail Opt Out Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Request T-Sheets Flag' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Personal' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Phone Extension' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Drivers License Number' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Humanity Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'IT Onboarding Complete Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'IT Termination Complete Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Exit Interview Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Deactivate Badge Request Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Values Meeting Invite Sent Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Cooperate Meeting Invite Sent Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'Values Meeting Attended Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'General' and company_object_type_id = 3),
--             (select id from flow.custom_field where field_name = 'New Hire Orientation Meeting Date' and company_id = (select id from flow.company where company_name = 'Blue Raven Solar')),1,false, 2350555);
--

--blueraven corporate
INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Leave of Absence Reason' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            leave_of_absence_reason,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE leave_of_absence_reason IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, boolean_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Qualifier' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            qualifier,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE qualifier IS NOT NULL);
INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Leave of Absence Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            leave_of_absence_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE leave_of_absence_date IS NOT NULL);
INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Reactivation Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            reactivation_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE reactivation_date IS NOT NULL);
INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'BRU Pass Off Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            bru_pass_off_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE bru_pass_off_date IS NOT NULL);
INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Termination Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            termination_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE termination_date IS NOT NULL);
INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Submitted By' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            onboarded_by_user_id,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE onboarded_by_user_id IS NOT NULL);
INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE  field_name = 'Referred By (Employee)' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            referred_by_user_id,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE referred_by_user_id IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Recruited By' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            recruited_by_user_id,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE recruited_by_user_id IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Compensation Type' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            lov.id,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join blueraven.compensation_type ct on ct.id = u.compensation_type_id
              inner join flow.list_of_value lov on lov.name = ct.compensation_type and parent_id = (select lov.id from flow.list_of_value lov
                                                                                                                           inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                                    where name = 'Compensation Type' and
                                                                                                            cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate'))
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE compensation_type_id IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Employment Type' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            lov.id,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join blueraven.employment_type et on et.id = u.employment_type_id
              inner join flow.list_of_value lov on lov.name = et.employment_type and parent_id = (select lov.id from flow.list_of_value lov
                                                                                                                         inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                                  where name = 'Employment Type' and
                                                                                                          cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate'))
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE employment_type_id IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Finding Source' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            lov.id,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.list_of_value lov on lov.name = u.finding_source and parent_id = (select lov.id from flow.list_of_value lov
                                                                                                                       inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                                where name = 'Finding Source' and
                                                                                                        cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate'))
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE finding_source IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Employee ID' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            employee_id,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE employee_id IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Personal Email' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            personal_email,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE personal_email IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Hire Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            hire_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE hire_date IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Phone Directory Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            phone_directory_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE phone_directory_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Greenlight Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            greenlight_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE greenlight_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Dividend Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            dividend_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE dividend_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Request Sunops App' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            request_sunops_app,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE request_sunops_app IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Ignition Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            ignition_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE ignition_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Application Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            application_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE application_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Dropbox Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            dropbox_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE dropbox_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Oneroof Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            oneroof_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE oneroof_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Dividend Spoof' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            dividend_spoof,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE dividend_spoof IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'i9 Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            i9_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE i9_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'W4 Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            w4_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE w4_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Quickbase Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            quickbase_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE quickbase_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Dividend Spoof Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            dividend_spoof_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE dividend_spoof_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Removed From Directory Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            removed_from_directory_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE removed_from_directory_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled Greenlight Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            cancelled_greenlight_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE cancelled_greenlight_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled Dividend Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            cancelled_dividend_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE cancelled_dividend_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Removed Sunops Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            removed_sunops_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE removed_sunops_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Removed Sales Rabbit Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            removed_sales_rabbit_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE removed_sales_rabbit_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled Ignition Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            cancelled_ignition_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE cancelled_ignition_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Reason for Termination' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            reason_for_termination,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE reason_for_termination IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Termination Notes' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            termination_notes,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE termination_notes IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Department' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            department,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE department IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Crew' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            crew,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE crew IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Employee Handbook Signed Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            employee_handbook_signed_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE employee_handbook_signed_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Enter in Timeforce Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            enter_in_timeforce_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE enter_in_timeforce_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, timestamp_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Expiry Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            expiry_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE expiry_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Dropbox Cancel Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            dropbox_cancel_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE dropbox_cancel_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Timeforce Cancel Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            timeforce_cancel_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE timeforce_cancel_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'E-Mail Opt Out Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            email_opt_out_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE email_opt_out_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, boolean_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Request T-Sheets Flag' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            request_tsheets_flag,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE request_tsheets_flag IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Phone Extension' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            phone_extension,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE phone_extension IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Drivers License Number' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            drivers_license_number,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE drivers_license_number IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Humanity Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            humanity_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE humanity_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'IT Onboarding Complete Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            it_onboarding_complete_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE it_onboarding_complete_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'IT Termination Complete Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            it_termination_complete_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE it_termination_complete_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Exit Interview Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            exit_interview_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE exit_interview_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Deactivate Badge Request Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            deactivate_badge_request_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE deactivate_badge_request_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Values Meeting Invite Sent Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            values_meeting_invite_sent_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE values_meeting_invite_sent_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cooperate Meeting Invite Sent Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            corporate_meeting_invite_sent_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE corporate_meeting_invite_sent_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Values Meeting Attended Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            values_meeting_attended_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE values_meeting_attended_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'New Hire Orientation Meeting Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            new_hire_orientation_meeting_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE new_hire_orientation_meeting_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Uniform/Badge Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            tshirt_hat_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE tshirt_hat_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Shirt Size' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            shirt_size,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE shirt_size IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Hat' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            hat,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE hat IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, numeric_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Accuity Appointment ID' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            accuity_appointment_id,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE accuity_appointment_id IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Training Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            enter_in_solved_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE enter_in_solved_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Email Setup Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            email_setup_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE email_setup_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Request Base Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            request_base_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE request_base_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Base Contact Created Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            base_contact_created_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE base_contact_created_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Mosiac Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            mosaic_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE mosaic_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Kronos/Payroll Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            trumpia_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE trumpia_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'T-Sheets Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            timesheets_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE timesheets_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Offer Letter Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            offer_letter_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE offer_letter_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Contract Request Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            docusign_requested_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE docusign_requested_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Contract Received Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            docusign_received_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE docusign_received_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Background Check Submitted Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            background_check_submitted_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE background_check_submitted_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Background Check Received Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            background_check_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE background_check_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Welcome E-Mail Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            welcome_email_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE welcome_email_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Photo Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            photo_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE photo_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Voided Check Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            voided_check_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE voided_check_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Re-Hire Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            re_hire_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE re_hire_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Pending Termination Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            pending_termination_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE pending_termination_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Termination Reason' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            termination_reason,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE termination_reason IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled Namely Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            cancelled_isolved_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE cancelled_isolved_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'E-Mail Removed Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            email_removed_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE email_removed_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled Base Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            removed_base_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE removed_base_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Base Contact Deleted Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            cancelled_base_contact_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE cancelled_base_contact_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled Mosiac Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            cancelled_mosaic_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE cancelled_mosaic_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled Litmos Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            cancelled_trumpia_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE cancelled_trumpia_date IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Confidentiality Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            confidentiality_agreement_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE confidentiality_agreement_date IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Contract Saved Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            docusign_saved_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE docusign_saved_date IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled T-Sheets Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Corporate')) as custom_field_id,
            timesheet_cancel_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 2
     WHERE timesheet_cancel_date IS NOT NULL);


--blueraven solar
INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Leave of Absence Reason' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            leave_of_absence_reason,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 3
     WHERE leave_of_absence_reason IS NOT NULL);
INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, boolean_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Qualifier' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            qualifier,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 3
     WHERE qualifier IS NOT NULL);
INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Leave of Absence Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            leave_of_absence_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 3
     WHERE leave_of_absence_date IS NOT NULL);
INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Reactivation Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            reactivation_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 3
     WHERE reactivation_date IS NOT NULL);
INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Termination Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            termination_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 3
     WHERE termination_date IS NOT NULL);
INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'BRU Pass Off Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            bru_pass_off_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 3
     WHERE bru_pass_off_date IS NOT NULL);
INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Submitted By' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            onboarded_by_user_id,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 3
     WHERE onboarded_by_user_id IS NOT NULL);
INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Referred By (Employee)' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            referred_by_user_id,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 3
    WHERE referred_by_user_id IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Recruited By' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            recruited_by_user_id,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE recruited_by_user_id IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Compensation Type' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            lov.id,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join blueraven.compensation_type ct on ct.id = u.compensation_type_id
              inner join flow.list_of_value lov on lov.name = ct.compensation_type and parent_id = (select lov.id from flow.list_of_value lov
                                                                                                                           inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                                    where name = 'Compensation Type' and
                                                                                                            cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar'))
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 3
     WHERE compensation_type_id IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Employment Type' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            lov.id,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join blueraven.employment_type et on et.id = u.employment_type_id
              inner join flow.list_of_value lov on lov.name = et.employment_type and parent_id = (select lov.id from flow.list_of_value lov
                                                                                                                         inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                                  where name = 'Employment Type' and
                                                                                                          cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar'))
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 3
     WHERE employment_type_id IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Finding Source' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            lov.id,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.list_of_value lov on lov.name = u.finding_source and parent_id = (select lov.id from flow.list_of_value lov
                                                                                                                       inner join flow.custom_field cf on cf.list_of_value_id = lov.id
                                                                                                where name = 'Finding Source' and
                                                                                                        cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar'))
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 3
     WHERE finding_source IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Employee ID' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            employee_id,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 3
     WHERE employee_id IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Personal Email' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            personal_email,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE personal_email IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Hire Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            hire_date,
            2350555 as created_by_id
     FROM blueraven.user u
              inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
              inner join flow.org o on o.id = up.org_id and company_id = 3
     WHERE hire_date IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id WHERE field_name = 'Phone Directory Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            phone_directory_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE phone_directory_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Greenlight Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            greenlight_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE greenlight_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Dividend Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            dividend_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE dividend_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Request Sunops App' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            request_sunops_app,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE request_sunops_app IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Ignition Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            ignition_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE ignition_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Application Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            application_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE application_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Dropbox Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            dropbox_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE dropbox_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Oneroof Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            oneroof_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE oneroof_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Dividend Spoof' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            dividend_spoof,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE dividend_spoof IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'i9 Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            i9_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE i9_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'W4 Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            w4_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE w4_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Quickbase Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            quickbase_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE quickbase_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Dividend Spoof Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            dividend_spoof_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE dividend_spoof_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Removed From Directory Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            removed_from_directory_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE removed_from_directory_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled Greenlight Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            cancelled_greenlight_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE cancelled_greenlight_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled Dividend Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            cancelled_dividend_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE cancelled_dividend_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Removed Sunops Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            removed_sunops_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE removed_sunops_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Removed Sales Rabbit Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            removed_sales_rabbit_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE removed_sales_rabbit_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled Ignition Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            cancelled_ignition_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE cancelled_ignition_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Reason for Termination' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            reason_for_termination,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE reason_for_termination IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Termination Notes' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            termination_notes,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE termination_notes IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Department' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            department,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE department IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Crew' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            crew,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE crew IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Employee Handbook Signed Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            employee_handbook_signed_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE employee_handbook_signed_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Enter in Timeforce Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            enter_in_timeforce_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE enter_in_timeforce_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, timestamp_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Expiry Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            expiry_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE expiry_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Dropbox Cancel Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            dropbox_cancel_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE dropbox_cancel_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Timeforce Cancel Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            timeforce_cancel_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE timeforce_cancel_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'E-Mail Opt Out Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            email_opt_out_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE email_opt_out_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, boolean_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Request T-Sheets Flag' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            request_tsheets_flag,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE request_tsheets_flag IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Phone Extension' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            phone_extension,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE phone_extension IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Drivers License Number' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            drivers_license_number,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE drivers_license_number IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Humanity Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            humanity_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE humanity_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'IT Onboarding Complete Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            it_onboarding_complete_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE it_onboarding_complete_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'IT Termination Complete Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            it_termination_complete_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE it_termination_complete_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Exit Interview Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            exit_interview_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE exit_interview_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Deactivate Badge Request Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            deactivate_badge_request_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE deactivate_badge_request_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Values Meeting Invite Sent Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            values_meeting_invite_sent_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE values_meeting_invite_sent_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cooperate Meeting Invite Sent Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            corporate_meeting_invite_sent_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE corporate_meeting_invite_sent_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Values Meeting Attended Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            values_meeting_attended_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE values_meeting_attended_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'New Hire Orientation Meeting Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            new_hire_orientation_meeting_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE new_hire_orientation_meeting_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Uniform/Badge Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            tshirt_hat_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE tshirt_hat_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Shirt Size' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            shirt_size,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE shirt_size IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Hat' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            hat,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE hat IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, numeric_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Accuity Appointment ID' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            accuity_appointment_id,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE accuity_appointment_id IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Training Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            enter_in_solved_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE enter_in_solved_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Email Setup Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            email_setup_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE email_setup_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Request Base Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            request_base_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE request_base_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Base Contact Created Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            base_contact_created_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE base_contact_created_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Mosiac Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            mosaic_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE mosaic_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Kronos/Payroll Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            trumpia_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE trumpia_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'T-Sheets Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            timesheets_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE timesheets_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Offer Letter Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            offer_letter_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE offer_letter_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Contract Request Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            docusign_requested_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE docusign_requested_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Contract Received Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            docusign_received_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE docusign_received_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Background Check Submitted Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            background_check_submitted_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE background_check_submitted_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Background Check Received Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            background_check_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE background_check_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Welcome E-Mail Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            welcome_email_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE welcome_email_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Photo Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            photo_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE photo_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Voided Check Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            voided_check_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE voided_check_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Re-Hire Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            re_hire_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE re_hire_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Pending Termination Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            pending_termination_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE pending_termination_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Termination Reason' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            termination_reason,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE termination_reason IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled Namely Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            cancelled_isolved_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE cancelled_isolved_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'E-Mail Removed Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            email_removed_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE email_removed_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled Base Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            removed_base_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE removed_base_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Base Contact Deleted Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            cancelled_base_contact_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE cancelled_base_contact_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled Mosiac Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            cancelled_mosaic_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE cancelled_mosaic_date IS NOT NULL);


INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled Litmos Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            cancelled_trumpia_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE cancelled_trumpia_date IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Confidentiality Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            confidentiality_agreement_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE confidentiality_agreement_date IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Contract Saved Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            docusign_saved_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE docusign_saved_date IS NOT NULL);

INSERT INTO flow.user_custom_field_value (user_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT u.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled T-Sheets Date' and cf.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')) as custom_field_id,
            timesheet_cancel_date,
            2350555 as created_by_id
     FROM blueraven.user u
inner join flow.user_position up on up.user_id = u.id and up.primary_flag is true
inner join flow.org o on o.id = up.org_id and company_id = 3
 WHERE timesheet_cancel_date IS NOT NULL);


--------------------------------------------------------------------------------
-- Migrate Customer Data
--------------------------------------------------------------------------------
-- create dummy customer type
INSERT INTO flow.contact_type (contact_type)
VALUES ('Customer');

INSERT INTO flow.contact_type (contact_type)
VALUES ('Lead');

-- migrate common contact data
INSERT INTO flow.contact (city,
                           company_country_id,
                           email,
                           first_name,
                           id,
                           last_name,
                           mailing_city,
                           mailing_postal_code,
                           mailing_state,
                           mailing_street1,
                           mailing_street2,
                           mobile,
                           phone,
                           postal_code,
                           prospect_status,
                           state,
                           street1,
                           street2,
                           contact_type_id,
                           created_by_id,
                           date_created,
                           company_id,
                          owner_user_position_id)
    (SELECT city,
            (select cc.id
            from flow.company_country cc
            inner join flow.country cy on cy.id = cc.country_id
                where cc.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
                and cy.id = 1),
            email,
            first_name,
            c.id,
            last_name,
            mailing_city,
            mailing_postal_code,
            mailing_state,
            mailing_street1,
            mailing_street2,
            mobile,
            phone,
            postal_code,
            prospect_status,
            state,
            street1,
            street2,
            (select id from flow.contact_type where contact_type='Customer'),
            2350555 as created_by_id,
            created_date,
            (select id from flow.company where company_name = 'Blue Raven Solar'),
            (select up.id
             from flow.user_position up
            inner join flow.user u on u.id = up.user_id
            inner join blueraven.deal d on d.setter_user_id = u.id
             where d.customer_id = c.id and up.primary_flag is true limit 1)
      from blueraven.customer c
     where  c.id in (select customer_id from blueraven.deal d  where (d.originator_id =1 or d.originator_id is null)));

-- INSERT INTO flow.contact (city,
--                           company_country_id,
--                           email,
--                           first_name,
--                           id,
--                           last_name,
--                           mailing_city,
--                           mailing_postal_code,
--                           mailing_state,
--                           mailing_street1,
--                           mailing_street2,
--                           mobile,
--                           phone,
--                           postal_code,
--                           prospect_status,
--                           state,
--                           street1,
--                           street2,
--                           contact_type_id,
--                           created_by_id,
--                           date_created,
--                           company_id)
--     (SELECT city,
--             (select cc.id
--              from flow.company_country cc
--                       inner join flow.country cy on cy.id = cc.country_id
--              where cc.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
--                and cy.id = 1),
--             email,
--             first_name,
--             c.id,
--             last_name,
--             mailing_city,
--             mailing_postal_code,
--             mailing_state,
--             mailing_street1,
--             mailing_street2,
--             mobile,
--             phone,
--             postal_code,
--             prospect_status,
--             state,
--             street1,
--             street2,
--             (select id from flow.contact_type where contact_type='Customer'),
--             2350555 as created_by_id,
--             created_date,
--             (select id from flow.company where company_name = 'Blue Raven Solar')
--      from blueraven.customer c
--
--      where  c.id = 238126);

with contacts_no_deals as (
    select c2.id as customer_id
    from blueraven.customer c2
             left join blueraven.deal d on d.customer_id = c2.id
    where d.id is null
)
INSERT INTO flow.contact (city,
                          company_country_id,
                          email,
                          first_name,
                          id,
                          last_name,
                          mailing_city,
                          mailing_postal_code,
                          mailing_state,
                          mailing_street1,
                          mailing_street2,
                          mobile,
                          phone,
                          postal_code,
                          prospect_status,
                          state,
                          street1,
                          street2,
                          contact_type_id,
                          created_by_id,
                          date_created,
                          company_id)
    (SELECT city,
            (select cc.id
             from flow.company_country cc
                      inner join flow.country cy on cy.id = cc.country_id
             where cc.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
               and cy.id = 1),
            email,
            first_name,
            c.id,
            last_name,
            mailing_city,
            mailing_postal_code,
            mailing_state,
            mailing_street1,
            mailing_street2,
            mobile,
            phone,
            postal_code,
            prospect_status,
            state,
            street1,
            street2,
            (select id from flow.contact_type where contact_type='Lead'),
            2350555 as created_by_id,
            created_date,
            (select id from flow.company where company_name = 'Blue Raven Solar')
     from blueraven.customer c
              inner join contacts_no_deals cnd on cnd.customer_id = c.id);

INSERT INTO flow.contact (city,
                          company_country_id,
                          email,
                          first_name,
                          id,
                          last_name,
                          mailing_city,
                          mailing_postal_code,
                          mailing_state,
                          mailing_street1,
                          mailing_street2,
                          mobile,
                          phone,
                          postal_code,
                          prospect_status,
                          state,
                          street1,
                          street2,
                          contact_type_id,
                          created_by_id,
                          date_created,
                          company_id,
                          owner_user_position_id)
    (SELECT city,
            (select cc.id
             from flow.company_country cc
                      inner join flow.country cy on cy.id = cc.country_id
             where cc.company_id = (select id from flow.company where company_name = 'Code 7 Roof and Solar')
               and cy.id = 1),
            email,
            first_name,
            id,
            last_name,
            mailing_city,
            mailing_postal_code,
            mailing_state,
            mailing_street1,
            mailing_street2,
            mobile,
            phone,
            postal_code,
            prospect_status,
            state,
            street1,
            street2,
            (select id from flow.contact_type where contact_type='Customer'),
            2350555 as created_by_id,
            created_date,
            (select id from flow.company where company_name = 'Code 7 Roof and Solar'),
            (select up.id
             from flow.user_position up
                      inner join flow.user u on u.id = up.user_id
                      inner join blueraven.deal d on d.setter_user_id = u.id
             where d.customer_id = c.id and up.primary_flag is true limit 1)
     from blueraven.customer c
     where  c.id in (select customer_id from blueraven.deal d  where d.originator_id =17));

INSERT INTO flow.contact (city,
                          company_country_id,
                          email,
                          first_name,
                          id,
                          last_name,
                          mailing_city,
                          mailing_postal_code,
                          mailing_state,
                          mailing_street1,
                          mailing_street2,
                          mobile,
                          phone,
                          postal_code,
                          prospect_status,
                          state,
                          street1,
                          street2,
                          contact_type_id,
                          created_by_id,
                          date_created,
                          company_id,
                          owner_user_position_id)
    (SELECT city,
            (select cc.id
             from flow.company_country cc
                      inner join flow.country cy on cy.id = cc.country_id
             where cc.company_id = (select id from flow.company where company_name = 'Energy Pal')
               and cy.id = 1),
            email,
            first_name,
            id,
            last_name,
            mailing_city,
            mailing_postal_code,
            mailing_state,
            mailing_street1,
            mailing_street2,
            mobile,
            phone,
            postal_code,
            prospect_status,
            state,
            street1,
            street2,
            (select id from flow.contact_type where contact_type='Customer'),
            2350555 as created_by_id,
            created_date,
            (select id from flow.company where company_name = 'Energy Pal'),
            (select up.id
             from flow.user_position up
                      inner join flow.user u on u.id = up.user_id
                      inner join blueraven.deal d on d.setter_user_id = u.id
             where d.customer_id = c.id and up.primary_flag is true limit 1)
     from blueraven.customer c
     where  c.id in (select customer_id from blueraven.deal d  where d.originator_id =16));

INSERT INTO flow.contact (city,
                          company_country_id,
                          email,
                          first_name,
                          id,
                          last_name,
                          mailing_city,
                          mailing_postal_code,
                          mailing_state,
                          mailing_street1,
                          mailing_street2,
                          mobile,
                          phone,
                          postal_code,
                          prospect_status,
                          state,
                          street1,
                          street2,
                          contact_type_id,
                          created_by_id,
                          date_created,
                          company_id,
                          owner_user_position_id)
    (SELECT city,
            (select cc.id
             from flow.company_country cc
                      inner join flow.country cy on cy.id = cc.country_id
             where cc.company_id = (select id from flow.company where company_name = 'Supernova Energy')
               and cy.id = 1),
            email,
            first_name,
            id,
            last_name,
            mailing_city,
            mailing_postal_code,
            mailing_state,
            mailing_street1,
            mailing_street2,
            mobile,
            phone,
            postal_code,
            prospect_status,
            state,
            street1,
            street2,
            (select id from flow.contact_type where contact_type='Customer'),
            2350555 as created_by_id,
            created_date,
            (select id from flow.company where company_name = 'Supernova Energy'),
            (select up.id
             from flow.user_position up
                      inner join flow.user u on u.id = up.user_id
                      inner join blueraven.deal d on d.setter_user_id = u.id
             where d.customer_id = c.id and up.primary_flag is true limit 1)
     from blueraven.customer c
     where  c.id in (select customer_id from blueraven.deal d  where d.originator_id =15));

INSERT INTO flow.contact (city,
                          company_country_id,
                          email,
                          first_name,
                          id,
                          last_name,
                          mailing_city,
                          mailing_postal_code,
                          mailing_state,
                          mailing_street1,
                          mailing_street2,
                          mobile,
                          phone,
                          postal_code,
                          prospect_status,
                          state,
                          street1,
                          street2,
                          contact_type_id,
                          created_by_id,
                          date_created,
                          company_id,
                          owner_user_position_id)
    (SELECT city,
            (select cc.id
             from flow.company_country cc
                      inner join flow.country cy on cy.id = cc.country_id
             where cc.company_id = (select id from flow.company where company_name = 'Solar 101')
               and cy.id = 1),
            email,
            first_name,
            id,
            last_name,
            mailing_city,
            mailing_postal_code,
            mailing_state,
            mailing_street1,
            mailing_street2,
            mobile,
            phone,
            postal_code,
            prospect_status,
            state,
            street1,
            street2,
            (select id from flow.contact_type where contact_type='Customer'),
            2350555 as created_by_id,
            created_date,
            (select id from flow.company where company_name = 'Solar 101'),
            (select up.id
             from flow.user_position up
                      inner join flow.user u on u.id = up.user_id
                      inner join blueraven.deal d on d.setter_user_id = u.id
             where d.customer_id = c.id and up.primary_flag is true limit 1)
     from blueraven.customer c
     where  c.id in (select customer_id from blueraven.deal d  where d.originator_id =9));

INSERT INTO flow.contact (city,
                          company_country_id,
                          email,
                          first_name,
                          id,
                          last_name,
                          mailing_city,
                          mailing_postal_code,
                          mailing_state,
                          mailing_street1,
                          mailing_street2,
                          mobile,
                          phone,
                          postal_code,
                          prospect_status,
                          state,
                          street1,
                          street2,
                          contact_type_id,
                          created_by_id,
                          date_created,
                          company_id)
    (SELECT city,
            (select cc.id
             from flow.company_country cc
                      inner join flow.country cy on cy.id = cc.country_id
             where cc.company_id = (select id from flow.company where company_name = 'TGE Solar')
               and cy.id = 1),
            email,
            first_name,
            id,
            last_name,
            mailing_city,
            mailing_postal_code,
            mailing_state,
            mailing_street1,
            mailing_street2,
            mobile,
            phone,
            postal_code,
            prospect_status,
            state,
            street1,
            street2,
            (select id from flow.contact_type where contact_type='Customer'),
            2350555 as created_by_id,
            created_date,
            (select id from flow.company where company_name = 'TGE Solar')
     from blueraven.customer c
     where  c.id in (select customer_id from blueraven.deal d  where d.originator_id =10));

INSERT INTO flow.contact (city,
                          company_country_id,
                          email,
                          first_name,
                          id,
                          last_name,
                          mailing_city,
                          mailing_postal_code,
                          mailing_state,
                          mailing_street1,
                          mailing_street2,
                          mobile,
                          phone,
                          postal_code,
                          prospect_status,
                          state,
                          street1,
                          street2,
                          contact_type_id,
                          created_by_id,
                          date_created,
                          company_id,
                          owner_user_position_id)
    (SELECT city,
            (select cc.id
             from flow.company_country cc
                      inner join flow.country cy on cy.id = cc.country_id
             where cc.company_id = (select id from flow.company where company_name = 'Atlas Solar Advisors')
               and cy.id = 1),
            email,
            first_name,
            id,
            last_name,
            mailing_city,
            mailing_postal_code,
            mailing_state,
            mailing_street1,
            mailing_street2,
            mobile,
            phone,
            postal_code,
            prospect_status,
            state,
            street1,
            street2,
            (select id from flow.contact_type where contact_type='Customer'),
            2350555 as created_by_id,
            created_date,
            (select id from flow.company where company_name = 'Atlas Solar Advisors'),
            (select up.id
             from flow.user_position up
                      inner join flow.user u on u.id = up.user_id
                      inner join blueraven.deal d on d.setter_user_id = u.id
             where d.customer_id = c.id and up.primary_flag is true limit 1)
     from blueraven.customer c
     where  c.id in (select customer_id from blueraven.deal d  where d.originator_id =11));

INSERT INTO flow.contact (city,
                          company_country_id,
                          email,
                          first_name,
                          id,
                          last_name,
                          mailing_city,
                          mailing_postal_code,
                          mailing_state,
                          mailing_street1,
                          mailing_street2,
                          mobile,
                          phone,
                          postal_code,
                          prospect_status,
                          state,
                          street1,
                          street2,
                          contact_type_id,
                          created_by_id,
                          date_created,
                          company_id,
                          owner_user_position_id)
    (SELECT city,
            (select cc.id
             from flow.company_country cc
                      inner join flow.country cy on cy.id = cc.country_id
             where cc.company_id = (select id from flow.company where company_name = 'Direct Solar of America')
               and cy.id = 1),
            email,
            first_name,
            id,
            last_name,
            mailing_city,
            mailing_postal_code,
            mailing_state,
            mailing_street1,
            mailing_street2,
            mobile,
            phone,
            postal_code,
            prospect_status,
            state,
            street1,
            street2,
            (select id from flow.contact_type where contact_type='Customer'),
            2350555 as created_by_id,
            created_date,
            (select id from flow.company where company_name = 'Direct Solar of America'),
            (select up.id
             from flow.user_position up
                      inner join flow.user u on u.id = up.user_id
                      inner join blueraven.deal d on d.setter_user_id = u.id
             where d.customer_id = c.id and up.primary_flag is true limit 1)
     from blueraven.customer c
     where  c.id in (select customer_id from blueraven.deal d  where d.originator_id =12));

INSERT INTO flow.contact (city,
                          company_country_id,
                          email,
                          first_name,
                          id,
                          last_name,
                          mailing_city,
                          mailing_postal_code,
                          mailing_state,
                          mailing_street1,
                          mailing_street2,
                          mobile,
                          phone,
                          postal_code,
                          prospect_status,
                          state,
                          street1,
                          street2,
                          contact_type_id,
                          created_by_id,
                          date_created,
                          company_id,
                          owner_user_position_id)
    (SELECT city,
            (select cc.id
             from flow.company_country cc
                      inner join flow.country cy on cy.id = cc.country_id
             where cc.company_id = (select id from flow.company where company_name = 'Revolution Solar')
               and cy.id = 1),
            email,
            first_name,
            id,
            last_name,
            mailing_city,
            mailing_postal_code,
            mailing_state,
            mailing_street1,
            mailing_street2,
            mobile,
            phone,
            postal_code,
            prospect_status,
            state,
            street1,
            street2,
            (select id from flow.contact_type where contact_type='Customer'),
            2350555 as created_by_id,
            created_date,
            (select id from flow.company where company_name = 'Revolution Solar'),
            (select up.id
             from flow.user_position up
                      inner join flow.user u on u.id = up.user_id
                      inner join blueraven.deal d on d.setter_user_id = u.id
             where d.customer_id = c.id and up.primary_flag is true limit 1)
     from blueraven.customer c
     where  c.id in (select customer_id from blueraven.deal d  where d.originator_id =13));

INSERT INTO flow.contact (city,
                          company_country_id,
                          email,
                          first_name,
                          id,
                          last_name,
                          mailing_city,
                          mailing_postal_code,
                          mailing_state,
                          mailing_street1,
                          mailing_street2,
                          mobile,
                          phone,
                          postal_code,
                          prospect_status,
                          state,
                          street1,
                          street2,
                          contact_type_id,
                          created_by_id,
                          date_created,
                          company_id,
                          owner_user_position_id)
    (SELECT city,
            (select cc.id
             from flow.company_country cc
                      inner join flow.country cy on cy.id = cc.country_id
             where cc.company_id = (select id from flow.company where company_name = 'Smart Money Solar')
               and cy.id = 1),
            email,
            first_name,
            id,
            last_name,
            mailing_city,
            mailing_postal_code,
            mailing_state,
            mailing_street1,
            mailing_street2,
            mobile,
            phone,
            postal_code,
            prospect_status,
            state,
            street1,
            street2,
            (select id from flow.contact_type where contact_type='Customer'),
            2350555 as created_by_id,
            created_date,
            (select id from flow.company where company_name = 'Smart Money Solar'),
            (select up.id
             from flow.user_position up
                      inner join flow.user u on u.id = up.user_id
                      inner join blueraven.deal d on d.setter_user_id = u.id
             where d.customer_id = c.id and up.primary_flag is true limit 1)
     from blueraven.customer c
     where  c.id in (select customer_id from blueraven.deal d  where d.originator_id =14));

INSERT INTO flow.contact (city,
                           company_country_id,
                           email,
                           first_name,
                           id,
                           last_name,
                           mailing_city,
                           mailing_postal_code,
                           mailing_state,
                           mailing_street1,
                           mailing_street2,
                           mobile,
                           phone,
                           postal_code,
                           prospect_status,
                           state,
                           street1,
                           street2,
                           contact_type_id,
                           created_by_id,
                           date_created,
                           company_id,
                          owner_user_position_id)
    (SELECT city,
            (select cc.id
             from flow.company_country cc
                      inner join flow.country cy on cy.id = cc.country_id
             where cc.company_id = (select id from flow.company where company_name = 'Sun Run')
               and cy.id = 1),
            email,
            first_name,
            id,
            last_name,
            mailing_city,
            mailing_postal_code,
            mailing_state,
            mailing_street1,
            mailing_street2,
            mobile,
            phone,
            postal_code,
            prospect_status,
            state,
            street1,
            street2,
            (select id from flow.contact_type where contact_type='Customer'),
            2350555 as created_by_id,
            created_date,
            (select id from flow.company where company_name = 'Sun Run'),
            (select up.id
             from flow.user_position up
                      inner join flow.user u on u.id = up.user_id
                      inner join blueraven.deal d on d.setter_user_id = u.id
             where d.customer_id = c.id and up.primary_flag is true limit 1)
     from blueraven.customer c
        where  c.id in (select customer_id from blueraven.deal d  where d.originator_id =7));

INSERT INTO flow.contact (city,
                           company_country_id,
                           email,
                           first_name,
                           id,
                           last_name,
                           mailing_city,
                           mailing_postal_code,
                           mailing_state,
                           mailing_street1,
                           mailing_street2,
                           mobile,
                           phone,
                           postal_code,
                           prospect_status,
                           state,
                           street1,
                           street2,
                           contact_type_id,
                           created_by_id,
                           date_created,
                           company_id,
                          owner_user_position_id)
    (SELECT city,
            (select cc.id
             from flow.company_country cc
                      inner join flow.country cy on cy.id = cc.country_id
             where cc.company_id = (select id from flow.company where company_name = 'Solenrgi')
               and cy.id = 1),
            email,
            first_name,
            id,
            last_name,
            mailing_city,
            mailing_postal_code,
            mailing_state,
            mailing_street1,
            mailing_street2,
            mobile,
            phone,
            postal_code,
            prospect_status,
            state,
            street1,
            street2,
            (select id from flow.contact_type where contact_type='Customer'),
            2350555 as created_by_id,
            created_date,
            (select id from flow.company where company_name = 'Solenrgi'),
            (select up.id
             from flow.user_position up
                      inner join flow.user u on u.id = up.user_id
                      inner join blueraven.deal d on d.setter_user_id = u.id
             where d.customer_id = c.id and up.primary_flag is true limit 1)
     from blueraven.customer c
     where  c.id in (select customer_id from blueraven.deal d  where d.originator_id =2)
        and c.id != 109137 and  c.id != 135115);

INSERT INTO flow.contact (city,
                           company_country_id,
                           email,
                           first_name,
                           id,
                           last_name,
                           mailing_city,
                           mailing_postal_code,
                           mailing_state,
                           mailing_street1,
                           mailing_street2,
                           mobile,
                           phone,
                           postal_code,
                           prospect_status,
                           state,
                           street1,
                           street2,
                           contact_type_id,
                           created_by_id,
                           date_created,
                           company_id,
                          owner_user_position_id)
    (SELECT city,
            (select cc.id
             from flow.company_country cc
                      inner join flow.country cy on cy.id = cc.country_id
             where cc.company_id = (select id from flow.company where company_name = 'Salient Solar')
               and cy.id = 1),
            email,
            first_name,
            id,
            last_name,
            mailing_city,
            mailing_postal_code,
            mailing_state,
            mailing_street1,
            mailing_street2,
            mobile,
            phone,
            postal_code,
            prospect_status,
            state,
            street1,
            street2,
            (select id from flow.contact_type where contact_type='Customer'),
            2350555 as created_by_id,
            created_date,
            (select id from flow.company where company_name = 'Salient Solar'),
            (select up.id
             from flow.user_position up
                      inner join flow.user u on u.id = up.user_id
                      inner join blueraven.deal d on d.setter_user_id = u.id
             where d.customer_id = c.id and up.primary_flag is true limit 1)
     from blueraven.customer c
     where  c.id in (select customer_id from blueraven.deal d  where d.originator_id =6));

INSERT INTO flow.contact (city,
                           company_country_id,
                           email,
                           first_name,
                           id,
                           last_name,
                           mailing_city,
                           mailing_postal_code,
                           mailing_state,
                           mailing_street1,
                           mailing_street2,
                           mobile,
                           phone,
                           postal_code,
                           prospect_status,
                           state,
                           street1,
                           street2,
                           contact_type_id,
                           created_by_id,
                           date_created,
                           company_id,
                          owner_user_position_id)
    (SELECT city,
            (select cc.id
             from flow.company_country cc
                      inner join flow.country cy on cy.id = cc.country_id
             where cc.company_id = (select id from flow.company where company_name = 'B+C Electric')
               and cy.id = 1),
            email,
            first_name,
            id,
            last_name,
            mailing_city,
            mailing_postal_code,
            mailing_state,
            mailing_street1,
            mailing_street2,
            mobile,
            phone,
            postal_code,
            prospect_status,
            state,
            street1,
            street2,
            (select id from flow.contact_type where contact_type='Customer'),
            2350555 as created_by_id,
            created_date,
            (select id from flow.company where company_name = 'B+C Electric'),
            (select up.id
             from flow.user_position up
                      inner join flow.user u on u.id = up.user_id
                      inner join blueraven.deal d on d.setter_user_id = u.id
             where d.customer_id = c.id and up.primary_flag is true limit 1)
     from blueraven.customer c
     where  c.id in (select customer_id from blueraven.deal d  where d.originator_id =4));

INSERT INTO flow.contact (city,
                           company_country_id,
                           email,
                           first_name,
                           id,
                           last_name,
                           mailing_city,
                           mailing_postal_code,
                           mailing_state,
                           mailing_street1,
                           mailing_street2,
                           mobile,
                           phone,
                           postal_code,
                           prospect_status,
                           state,
                           street1,
                           street2,
                           contact_type_id,
                           created_by_id,
                           date_created,
                           company_id,
                          owner_user_position_id)
    (SELECT city,
            (select cc.id
             from flow.company_country cc
                      inner join flow.country cy on cy.id = cc.country_id
             where cc.company_id = (select id from flow.company where company_name = 'Eco Lux Solar')
               and cy.id = 1),
            email,
            first_name,
            id,
            last_name,
            mailing_city,
            mailing_postal_code,
            mailing_state,
            mailing_street1,
            mailing_street2,
            mobile,
            phone,
            postal_code,
            prospect_status,
            state,
            street1,
            street2,
            (select id from flow.contact_type where contact_type='Customer'),
            2350555 as created_by_id,
            created_date,
            (select id from flow.company where company_name = 'Eco Lux Solar'),
            (select up.id
             from flow.user_position up
                      inner join flow.user u on u.id = up.user_id
                      inner join blueraven.deal d on d.setter_user_id = u.id
             where d.customer_id = c.id and up.primary_flag is true limit 1)
     from blueraven.customer c
     where  c.id in (select customer_id from blueraven.deal d  where d.originator_id =8));

-- change the flow.contact id sequence so the imported ids don't cause problems
SELECT setval('flow.customer_id_seq',
              COALESCE((SELECT MAX(id) + 1
                        FROM flow.contact), 1), false);


--TODO as Judson if we should mover over description from LEAD

INSERT INTO flow.contact (city,
                           company_country_id,
                           email,
                           first_name,
                           last_name,
                           mobile,
                           phone,
                           postal_code,
                           state,
                           street1,
                           street2,
                           contact_type_id,
                           created_by_id,
                           date_created,
                           company_id,
                           title,
                           owner_user_position_id,
                           migrate_lead_id)
    (SELECT city,
            (select cc.id
             from flow.company_country cc
                      inner join flow.country cy on cy.id = cc.country_id
             where cc.company_id = (select id from flow.company where company_name = 'Blue Raven Solar')
               and cy.id = 1),
            email,
            substr(first_name,1,100),
            substr(last_name,1,100),
            mobile,
            phone,
            postal_code,
            state,
            street1,
            street2,
            (select id from flow.contact_type where contact_type='Lead'),
            2350555 as created_by_id,
            created_date,
            (select id from flow.company where company_name = 'Blue Raven Solar'),
            title,
            (select up.id
             from flow.user_position up
             where up.user_id = l.setter_user_id and primary_flag is true),
            id
     FROM blueraven.lead l);

INSERT INTO flow.contact (city,
                          company_country_id,
                          email,
                          first_name,
                          last_name,
                          mailing_city,
                          mailing_postal_code,
                          mailing_state,
                          mailing_street1,
                          mailing_street2,
                          mobile,
                          phone,
                          postal_code,
                          prospect_status,
                          state,
                          street1,
                          street2,
                          contact_type_id,
                          created_by_id,
                          date_created,
                          company_id,
                          owner_user_position_id)
    (SELECT city,
            (select cc.id
             from flow.company_country cc
                      inner join flow.country cy on cy.id = cc.country_id
             where cc.company_id = (select id from flow.company where company_name = 'Solenrgi')
               and cy.id = 1),
            email,
            first_name,
            last_name,
            mailing_city,
            mailing_postal_code,
            mailing_state,
            mailing_street1,
            mailing_street2,
            mobile,
            phone,
            postal_code,
            prospect_status,
            state,
            street1,
            street2,
            (select id from flow.contact_type where contact_type='Customer'),
            2350555 as created_by_id,
            created_date,
            (select id from flow.company where company_name = 'Solenrgi'),
            (select up.id
             from flow.user_position up
                      inner join flow.user u on u.id = up.user_id
                      inner join blueraven.deal d on d.setter_user_id = u.id
             where d.customer_id = c.id and up.primary_flag is true limit 1)
     from blueraven.customer c
     where  c.id in (select customer_id from blueraven.deal d  where d.originator_id =2)
       and c.id in ( 109137,135115));


update flow.contact c2
set company_state_id = (select cs.id
                from flow.contact c
                    inner join flow.company_state cs on cs.company_id = c.company_id
                         inner join flow.state s on s.id = cs.state_id and s.state =  c.state
                where c.id = c2.id);

update flow.contact c2
set mailing_company_state_id = (select cs.id
                        from flow.contact c
                                 inner join flow.company_state cs on cs.company_id = c.company_id
                                 inner join flow.state s on s.id = cs.state_id and s.abbreviation =  c.mailing_state
                        where c.id = c2.id);

alter table flow.contact drop column if exists state;
alter table flow.contact drop column if exists state_id;
alter table flow.contact drop column if exists mailing_state;


-- with parent as (
--     insert into flow.list_of_value( name, parent_id, display_order, date_created,
--                                     created_by_id, archived)
--         values('Lead Source',null,1,now(),2350555,false)
--         returning id ),
--      t as (insert into flow.list_of_value( name, parent_id, display_order, date_created,
--                                            created_by_id, archived)
--          (select s.source_name,(select p.id from parent p),1,now(),2350555,s.archived
--           from blueraven.source s
--           where source_type = 'lead'))
-- INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id,list_of_value_id)
--     (select 'Lead Source',
--             7,
--             now(),
--             2350555,
--             (select id from flow.company where company_name = 'Blue Raven Solar'),
--             p.id
--      from parent p
--     );



-- with parent as (
--     insert into flow.list_of_value( name, parent_id, display_order, date_created,
--                                     created_by_id, archived)
--         values('Lead Source Detail',null,1,now(),2350555,false)
--         returning id ),
--      t as (insert into flow.list_of_value( name, parent_id, display_order, date_created,
--                                            created_by_id, archived)
--          (select s.lead_source_detail,(select p.id from parent p),1,now(),2350555,false
--           from blueraven.lead s
--           where s.lead_source_detail is not null
--           group by s.lead_source_detail))
-- INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id,list_of_value_id)
--     (select 'Lead Source Detail',
--             7,
--             now(),
--             2350555,
--             (select id from flow.company where company_name = 'Blue Raven Solar'),
--             p.id
--      from parent p
--     );

-- INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id)
-- VALUES ('Hubspot ID',
--         5,
--         now(),
--         2350555,
--         (select id from flow.company where company_name = 'Blue Raven Solar'));
-- INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id)
-- VALUES ('Ricochet Lead ID',
--         5,
--         now(),
--         2350555,
--         (select id from flow.company where company_name = 'Blue Raven Solar'));



-- with parent as (
--     insert into flow.list_of_value( name, parent_id, display_order, date_created,
--                                     created_by_id, archived)
--         values('Lead Status',null,1,now(),2350555,false)
--         returning id ),
--      t as (insert into flow.list_of_value( name, parent_id, display_order, date_created,
--                                            created_by_id, archived)
--          (select s.status,(select p.id from parent p),1,now(),2350555,false
--           from blueraven.lead s
--           where s.lead_source_detail is not null
--           group by s.status))
-- INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id,list_of_value_id)
--     (select 'Lead Status',
--             7,
--             now(),
--             2350555,
--             (select id from flow.company where company_name = 'Blue Raven Solar'),
--             p.id
--      from parent p
--     );



-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,2
--      from flow.custom_field cf
--      where cf.field_name = 'Lead Source'
--     );
--
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,2
--      from flow.custom_field cf
--      where cf.field_name = 'Lead Source Detail'
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,2
--      from flow.custom_field cf
--      where cf.field_name = 'Hubspot ID'
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,2
--      from flow.custom_field cf
--      where cf.field_name = 'Ricochet Lead ID'
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,2
--      from flow.custom_field cf
--      where cf.field_name = 'Lead Status'
--     );

-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Contact PlaceHolder'),
--             (select id from flow.custom_field where field_name = 'Lead Source'),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Contact PlaceHolder'),
--             (select id from flow.custom_field where field_name = 'Lead Source Detail' and company_data_type_id = 7),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Contact PlaceHolder'),
--             (select id from flow.custom_field where field_name = 'Hubspot ID'),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Contact PlaceHolder'),
--             (select id from flow.custom_field where field_name = 'Ricochet Lead ID'),1,false, 2350555);
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Contact PlaceHolder'),
--             (select id from flow.custom_field where field_name = 'Lead Status'),1,false, 2350555);




-- migrate custom field values

with leads as (
    SELECT c.id as contact_id,
           company_id,
           l.lead_source_detail,
           2350555 as created_by_id
    FROM blueraven.lead l
             inner join flow.contact c on c.migrate_lead_id = l.id
    WHERE lead_source_detail IS NOT NULL
),
     list_of_values as (
         select lov2.id as list_of_value_id,lov2.name,cf2.company_id,cfga.id as custom_field_group_assignemnt_id
         from flow.list_of_value lov
                  inner join flow.custom_field cf2 on lov.id = cf2.list_of_value_id
                  inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                  inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
         where cf2.field_name = 'Lead Source Detail' and lov.name = 'Lead Source Detail' and lov.parent_id is null)
INSERT INTO flow.contact_custom_field_value (contact_id, custom_field_group_assignment_id,int_value , created_by_id)
    (SELECT l.contact_id,
            lov.custom_field_group_assignemnt_id,
            lov.list_of_value_id,
            2350555 as created_by_id
         from leads l
         inner join list_of_values lov on lov.company_id = l.company_id and lov.name = l.lead_source_detail);


with leads as (
    SELECT c.id as contact_id,
           company_id,
           s.source_name,
           2350555 as created_by_id
    FROM blueraven.lead l
             inner join blueraven.source s on s.id = l.source_id
             inner join flow.contact c on c.migrate_lead_id = l.id
    WHERE l.source_id IS NOT NULL
),
     list_of_values as (
         select lov2.id as list_of_value_id,lov2.name,cf2.company_id,cfga.id as custom_field_group_assignemnt_id
         from flow.list_of_value lov
                  inner join flow.custom_field cf2 on lov.id = cf2.list_of_value_id
                  inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.company_object_type cot on cot.id = cfg.company_object_type_id
                  inner join flow.object_type ot on ot.id = cot.object_type_id and object_type_id = 2
                  inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
         where cf2.field_name = 'Lead Source' and lov.name = 'Lead Source' and lov.parent_id is null)
INSERT INTO flow.contact_custom_field_value (contact_id, custom_field_group_assignment_id,int_value , created_by_id)
    (SELECT l.contact_id,
            lov.custom_field_group_assignemnt_id,
            lov.list_of_value_id,
            2350555 as created_by_id
     from leads l
              inner join list_of_values lov on lov.company_id = l.company_id and lov.name = l.source_name);

INSERT INTO flow.contact_custom_field_value (contact_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT c.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Referred By' and cf.company_id = c.company_id) as custom_field_id,
            referred_by,
            2350555 as created_by_id
     FROM blueraven.customer c1
              inner join flow.contact c on c.id = c1.id
     WHERE referred_by IS NOT NULL);

INSERT INTO flow.contact_custom_field_value (contact_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT c.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Lead Created Date' and cf.company_id = c.company_id) as custom_field_id,
            lead_created_date,
            2350555 as created_by_id
     FROM blueraven.customer c1
              inner join flow.contact c on c.id = c1.id
     WHERE lead_created_date IS NOT NULL);

INSERT INTO flow.contact_custom_field_value (contact_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT c.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'LG Unique ID' and cf.company_id = c.company_id) as custom_field_id,
            lg_unique_id,
            2350555 as created_by_id
     FROM blueraven.customer c1
              inner join flow.contact c on c.id = c1.id
     WHERE lg_unique_id IS NOT NULL);

INSERT INTO flow.contact_custom_field_value (contact_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT c.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Hubspot ID' and cf.company_id = c.company_id) as custom_field_id,
            hub_spot_id,
            2350555 as created_by_id
     FROM blueraven.lead l
              inner join flow.contact c on c.migrate_lead_id = l.id
     WHERE hub_spot_id IS NOT NULL);
INSERT INTO flow.contact_custom_field_value (contact_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT c.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Ricochet Lead ID' and cf.company_id = c.company_id) as custom_field_id,
            ricochet_lead_id,
            2350555 as created_by_id
     FROM blueraven.lead l  inner join flow.contact c on c.migrate_lead_id = l.id
     WHERE ricochet_lead_id IS NOT NULL);


with leads as (
    SELECT c.id as contact_id,
           company_id,
           l.status,
           2350555 as created_by_id
    FROM blueraven.lead l
             inner join flow.contact c on c.migrate_lead_id = l.id
    WHERE l.status IS NOT NULL
),
     list_of_values as (
         select lov2.id as list_of_value_id,lov2.name,cf2.company_id,cfga.id as custom_field_group_assignemnt_id
         from flow.list_of_value lov
                  inner join flow.custom_field cf2 on lov.id = cf2.list_of_value_id
                  inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                  inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
         where cf2.field_name = 'Lead Status' and lov.name = 'Lead Status' and lov.parent_id is null)
INSERT INTO flow.contact_custom_field_value (contact_id, custom_field_group_assignment_id,int_value , created_by_id)
    (SELECT l.contact_id,
            lov.custom_field_group_assignemnt_id,
            lov.list_of_value_id,
            2350555 as created_by_id
     from leads l
              inner join list_of_values lov on lov.company_id = l.company_id and lov.name = l.status);


-- add the company project status types
-- insert into flow.project_status_type (project_status_type)
-- values ('Active'), ('Cancelled'), ('On Hold');

-- insert into flow.company_project_status_type (project_status_type_id, company_id, project_status_type, created_by_id)
-- values ((select id from flow.project_status_type where project_status_type.project_status_type = 'Active'), (select id from flow.company where company_name = 'Blue Raven Solar'), 'Active', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'Cancelled'), (select id from flow.company where company_name = 'Blue Raven Solar'), 'Cancelled', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'On Hold'), (select id from flow.company where company_name = 'Blue Raven Solar'), 'On Hold', 2350555);
--
-- insert into flow.company_project_status_type (project_status_type_id, company_id, project_status_type, created_by_id)
-- values ((select id from flow.project_status_type where project_status_type.project_status_type = 'Active'), (select id from flow.company where company_name =    'B+C Electric'), 'Active', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'Cancelled'), (select id from flow.company where company_name = 'B+C Electric'), 'Cancelled', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'On Hold'), (select id from flow.company where company_name =   'B+C Electric'), 'On Hold', 2350555);
--
-- insert into flow.company_project_status_type (project_status_type_id, company_id, project_status_type, created_by_id)
-- values ((select id from flow.project_status_type where project_status_type.project_status_type = 'Active'), (select id from flow.company where company_name =    'Eco Lux Solar'), 'Active', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'Cancelled'), (select id from flow.company where company_name = 'Eco Lux Solar'), 'Cancelled', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'On Hold'), (select id from flow.company where company_name =   'Eco Lux Solar'), 'On Hold', 2350555);
--
-- insert into flow.company_project_status_type (project_status_type_id, company_id, project_status_type, created_by_id)
-- values ((select id from flow.project_status_type where project_status_type.project_status_type = 'Active'), (select id from flow.company where company_name =    'Salient Solar'), 'Active', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'Cancelled'), (select id from flow.company where company_name = 'Salient Solar'), 'Cancelled', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'On Hold'), (select id from flow.company where company_name =   'Salient Solar'), 'On Hold', 2350555);
--
-- insert into flow.company_project_status_type (project_status_type_id, company_id, project_status_type, created_by_id)
-- values ((select id from flow.project_status_type where project_status_type.project_status_type = 'Active'), (select id from flow.company where company_name =    'Solenrgi'), 'Active', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'Cancelled'), (select id from flow.company where company_name = 'Solenrgi'), 'Cancelled', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'On Hold'), (select id from flow.company where company_name =   'Solenrgi'), 'On Hold', 2350555);
--
-- insert into flow.company_project_status_type (project_status_type_id, company_id, project_status_type, created_by_id)
-- values ((select id from flow.project_status_type where project_status_type.project_status_type = 'Active'), (select id from flow.company where company_name =    'Sun Run'), 'Active', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'Cancelled'), (select id from flow.company where company_name = 'Sun Run'), 'Cancelled', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'On Hold'), (select id from flow.company where company_name =   'Sun Run'), 'On Hold', 2350555);
--
-- insert into flow.company_project_status_type (project_status_type_id, company_id, project_status_type, created_by_id)
-- values ((select id from flow.project_status_type where project_status_type.project_status_type = 'Active'), (select id from flow.company where company_name =    'Solar 101'), 'Active', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'Cancelled'), (select id from flow.company where company_name = 'Solar 101'), 'Cancelled', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'On Hold'), (select id from flow.company where company_name =   'Solar 101'), 'On Hold', 2350555);
--
-- insert into flow.company_project_status_type (project_status_type_id, company_id, project_status_type, created_by_id)
-- values ((select id from flow.project_status_type where project_status_type.project_status_type = 'Active'), (select id from flow.company where company_name =    'TGE Solar'), 'Active', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'Cancelled'), (select id from flow.company where company_name = 'TGE Solar'), 'Cancelled', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'On Hold'), (select id from flow.company where company_name =   'TGE Solar'), 'On Hold', 2350555);
--
-- insert into flow.company_project_status_type (project_status_type_id, company_id, project_status_type, created_by_id)
-- values ((select id from flow.project_status_type where project_status_type.project_status_type = 'Active'), (select id from flow.company where company_name =    'Atlas Solar Advisors'), 'Active', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'Cancelled'), (select id from flow.company where company_name = 'Atlas Solar Advisors'), 'Cancelled', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'On Hold'), (select id from flow.company where company_name =   'Atlas Solar Advisors'), 'On Hold', 2350555);
--
-- insert into flow.company_project_status_type (project_status_type_id, company_id, project_status_type, created_by_id)
-- values ((select id from flow.project_status_type where project_status_type.project_status_type = 'Active'), (select id from flow.company where company_name =    'Direct Solar of America'), 'Active', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'Cancelled'), (select id from flow.company where company_name = 'Direct Solar of America'), 'Cancelled', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'On Hold'), (select id from flow.company where company_name =   'Direct Solar of America'), 'On Hold', 2350555);
--
-- insert into flow.company_project_status_type (project_status_type_id, company_id, project_status_type, created_by_id)
-- values ((select id from flow.project_status_type where project_status_type.project_status_type = 'Active'), (select id from flow.company where company_name =    'Revolution Solar'), 'Active', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'Cancelled'), (select id from flow.company where company_name = 'Revolution Solar'), 'Cancelled', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'On Hold'), (select id from flow.company where company_name =   'Revolution Solar'), 'On Hold', 2350555);
--
-- insert into flow.company_project_status_type (project_status_type_id, company_id, project_status_type, created_by_id)
-- values ((select id from flow.project_status_type where project_status_type.project_status_type = 'Active'), (select id from flow.company where company_name =    'Smart Money Solar'), 'Active', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'Cancelled'), (select id from flow.company where company_name = 'Smart Money Solar'), 'Cancelled', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'On Hold'), (select id from flow.company where company_name =   'Smart Money Solar'), 'On Hold', 2350555);
--
-- insert into flow.company_project_status_type (project_status_type_id, company_id, project_status_type, created_by_id)
-- values ((select id from flow.project_status_type where project_status_type.project_status_type = 'Active'), (select id from flow.company where company_name =    'Supernova Energy'), 'Active', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'Cancelled'), (select id from flow.company where company_name = 'Supernova Energy'), 'Cancelled', 2350555),
--        ((select id from flow.project_status_type where project_status_type.project_status_type = 'On Hold'), (select id from flow.company where company_name =   'Supernova Energy'), 'On Hold', 2350555);


-- copy over the common deal/project fields

INSERT INTO flow.project (id,
                          contact_id,
                          project_name,
                          created_by_id,
                          company_process_id,
                          date_created,
                          company_project_status_type_id,
                          latitude,
                          longitude,
                          time_zone)
    (SELECT d.id,
            customer_id,
            customer_name,
            2350555,
            case when d.originator_id = 1 then
            (SELECT cp.id FROM flow.company_process cp INNER JOIN flow.process p ON p.id = cp.process_id WHERE cp.company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
                 when d.originator_id = 2 then
                     (SELECT cp.id FROM flow.company_process cp INNER JOIN flow.process p ON p.id = cp.process_id WHERE cp.company_id in (select id from flow.company where company_name = 'Solenrgi'))
                 when d.originator_id = 4 then
                     (SELECT cp.id FROM flow.company_process cp INNER JOIN flow.process p ON p.id = cp.process_id WHERE cp.company_id in (select id from flow.company where company_name = 'B+C Electric'))
                 when d.originator_id = 6 then
                     (SELECT cp.id FROM flow.company_process cp INNER JOIN flow.process p ON p.id = cp.process_id WHERE cp.company_id in (select id from flow.company where company_name = 'Salient Solar'))
                 when d.originator_id = 7 then
                     (SELECT cp.id FROM flow.company_process cp INNER JOIN flow.process p ON p.id = cp.process_id WHERE cp.company_id in (select id from flow.company where company_name = 'Sun Run'))
                 when d.originator_id = 8 then
                     (SELECT cp.id FROM flow.company_process cp INNER JOIN flow.process p ON p.id = cp.process_id WHERE cp.company_id in (select id from flow.company where company_name = 'Eco Lux Solar'))
                 when d.originator_id = 9 then
                     (SELECT cp.id FROM flow.company_process cp INNER JOIN flow.process p ON p.id = cp.process_id WHERE cp.company_id in (select id from flow.company where company_name = 'Solar 101'))
                 when d.originator_id = 10 then
                     (SELECT cp.id FROM flow.company_process cp INNER JOIN flow.process p ON p.id = cp.process_id WHERE cp.company_id in (select id from flow.company where company_name = 'TGE Solar'))
                 when d.originator_id = 11 then
                     (SELECT cp.id FROM flow.company_process cp INNER JOIN flow.process p ON p.id = cp.process_id WHERE cp.company_id in (select id from flow.company where company_name = 'Atlas Solar Advisors'))
                 when d.originator_id = 12 then
                     (SELECT cp.id FROM flow.company_process cp INNER JOIN flow.process p ON p.id = cp.process_id WHERE cp.company_id in (select id from flow.company where company_name = 'Direct Solar of America'))
                 when d.originator_id = 13 then
                     (SELECT cp.id FROM flow.company_process cp INNER JOIN flow.process p ON p.id = cp.process_id WHERE cp.company_id in (select id from flow.company where company_name = 'Revolution Solar'))
                 when d.originator_id = 14 then
                     (SELECT cp.id FROM flow.company_process cp INNER JOIN flow.process p ON p.id = cp.process_id WHERE cp.company_id in (select id from flow.company where company_name = 'Smart Money Solar'))
                 when d.originator_id = 15 then
                     (SELECT cp.id FROM flow.company_process cp INNER JOIN flow.process p ON p.id = cp.process_id WHERE cp.company_id in (select id from flow.company where company_name = 'Supernova Energy'))
                 when d.originator_id = 16 then
                     (SELECT cp.id FROM flow.company_process cp INNER JOIN flow.process p ON p.id = cp.process_id WHERE cp.company_id in (select id from flow.company where company_name = 'Energy Pal'))
                 when d.originator_id = 17 then
                     (SELECT cp.id FROM flow.company_process cp INNER JOIN flow.process p ON p.id = cp.process_id WHERE cp.company_id in (select id from flow.company where company_name = 'Code 7 Roof and Solar'))
                else
                     (SELECT cp.id FROM flow.company_process cp INNER JOIN flow.process p ON p.id = cp.process_id WHERE cp.company_id in (select id from flow.company where company_name = 'Blue Raven Solar'))
                     end ,
            added_on,
            case when current_stage_id in (2,3) then
                (select id
                from flow.company_project_status_type
                where project_status_type = 'Cancelled' and company_id =
                                      case when d.originator_id = 1 then
                                      (select id from flow.company where company_name = 'Blue Raven Solar')
                                           when d.originator_id = 2 then
                                               (select id from flow.company where company_name = 'Solenrgi')
                                           when d.originator_id = 4 then
                                               (select id from flow.company where company_name = 'B+C Electric')
                                           when d.originator_id = 6 then
                                               (select id from flow.company where company_name = 'Salient Solar')
                                           when d.originator_id = 7 then
                                               (select id from flow.company where company_name = 'Sun Run')
                                           when d.originator_id = 8 then
                                               (select id from flow.company where company_name = 'Eco Lux Solar')
                                           when d.originator_id = 9 then
                                               (select id from flow.company where company_name = 'Solar 101')
                                           when d.originator_id = 10 then
                                               (select id from flow.company where company_name = 'TGE Solar')
                                           when d.originator_id = 11 then
                                               (select id from flow.company where company_name = 'Atlas Solar Advisors')
                                           when d.originator_id = 12 then
                                               (select id from flow.company where company_name = 'Direct Solar of America')
                                           when d.originator_id = 13 then
                                               (select id from flow.company where company_name = 'Revolution Solar')
                                           when d.originator_id = 14 then
                                               (select id from flow.company where company_name = 'Smart Money Solar')
                                           when d.originator_id = 15 then
                                               (select id from flow.company where company_name = 'Supernova Energy')
                                           when d.originator_id = 16 then
                                               (select id from flow.company where company_name = 'Energy Pal')
                                           when d.originator_id = 17 then
                                               (select id from flow.company where company_name = 'Code 7 Roof and Solar')end)
                 when current_stage_id not in (2,3) and on_hold is true then
                     (select id from flow.company_project_status_type where project_status_type = 'On Hold' and company_id =
                                                                                                                case when d.originator_id = 1 then
                                                                                                                         (select id from flow.company where company_name = 'Blue Raven Solar')
                                                                                                                     when d.originator_id = 2 then
                                                                                                                         (select id from flow.company where company_name = 'Solenrgi')
                                                                                                                     when d.originator_id = 4 then
                                                                                                                         (select id from flow.company where company_name = 'B+C Electric')
                                                                                                                     when d.originator_id = 6 then
                                                                                                                         (select id from flow.company where company_name = 'Salient Solar')
                                                                                                                     when d.originator_id = 7 then
                                                                                                                         (select id from flow.company where company_name = 'Sun Run')
                                                                                                                     when d.originator_id = 8 then
                                                                                                                         (select id from flow.company where company_name = 'Eco Lux Solar')
                                                                                                                     when d.originator_id = 9 then
                                                                                                                         (select id from flow.company where company_name = 'Solar 101')
                                                                                                                     when d.originator_id = 10 then
                                                                                                                         (select id from flow.company where company_name = 'TGE Solar')
                                                                                                                     when d.originator_id = 11 then
                                                                                                                         (select id from flow.company where company_name = 'Atlas Solar Advisors')
                                                                                                                     when d.originator_id = 12 then
                                                                                                                         (select id from flow.company where company_name = 'Direct Solar of America')
                                                                                                                     when d.originator_id = 13 then
                                                                                                                         (select id from flow.company where company_name = 'Revolution Solar')
                                                                                                                     when d.originator_id = 14 then
                                                                                                                         (select id from flow.company where company_name = 'Smart Money Solar')
                                                                                                                     when d.originator_id = 15 then
                                                                                                                         (select id from flow.company where company_name = 'Supernova Energy')
                                                                                                                     when d.originator_id = 16 then
                                                                                                                         (select id from flow.company where company_name = 'Energy Pal')
                                                                                                                     when d.originator_id = 17 then
                                                                                                                         (select id from flow.company where company_name = 'Code 7 Roof and Solar')end)
                 when (financier = '["Dividend Solar"]' or financier = '["One Roof Energy"]') then
                     (select id from flow.company_project_status_type where project_status_type = 'Complete' and company_id =
                                                                                                                 case when d.originator_id = 1 then
                                                                                                                          (select id from flow.company where company_name = 'Blue Raven Solar')
                                                                                                                      when d.originator_id = 2 then
                                                                                                                          (select id from flow.company where company_name = 'Solenrgi')
                                                                                                                      when d.originator_id = 4 then
                                                                                                                          (select id from flow.company where company_name = 'B+C Electric')
                                                                                                                      when d.originator_id = 6 then
                                                                                                                          (select id from flow.company where company_name = 'Salient Solar')
                                                                                                                      when d.originator_id = 7 then
                                                                                                                          (select id from flow.company where company_name = 'Sun Run')
                                                                                                                      when d.originator_id = 8 then
                                                                                                                          (select id from flow.company where company_name = 'Eco Lux Solar')
                                                                                                                      when d.originator_id = 9 then
                                                                                                                          (select id from flow.company where company_name = 'Solar 101')
                                                                                                                      when d.originator_id = 10 then
                                                                                                                          (select id from flow.company where company_name = 'TGE Solar')
                                                                                                                      when d.originator_id = 11 then
                                                                                                                          (select id from flow.company where company_name = 'Atlas Solar Advisors')
                                                                                                                      when d.originator_id = 12 then
                                                                                                                          (select id from flow.company where company_name = 'Direct Solar of America')
                                                                                                                      when d.originator_id = 13 then
                                                                                                                          (select id from flow.company where company_name = 'Revolution Solar')
                                                                                                                      when d.originator_id = 14 then
                                                                                                                          (select id from flow.company where company_name = 'Smart Money Solar')
                                                                                                                      when d.originator_id = 15 then
                                                                                                                          (select id from flow.company where company_name = 'Supernova Energy')
                                                                                                                      when d.originator_id = 16 then
                                                                                                                          (select id from flow.company where company_name = 'Energy Pal')
                                                                                                                      when d.originator_id = 17 then
                                                                                                                          (select id from flow.company where company_name = 'Code 7 Roof and Solar')end)
                 else (select id from flow.company_project_status_type where project_status_type = 'Active' and company_id =
                                                                                                                case when d.originator_id = 1 then
                                                                                                                         (select id from flow.company where company_name = 'Blue Raven Solar')
                                                                                                                     when d.originator_id = 2 then
                                                                                                                         (select id from flow.company where company_name = 'Solenrgi')
                                                                                                                     when d.originator_id = 4 then
                                                                                                                         (select id from flow.company where company_name = 'B+C Electric')
                                                                                                                     when d.originator_id = 6 then
                                                                                                                         (select id from flow.company where company_name = 'Salient Solar')
                                                                                                                     when d.originator_id = 7 then
                                                                                                                         (select id from flow.company where company_name = 'Sun Run')
                                                                                                                     when d.originator_id = 8 then
                                                                                                                         (select id from flow.company where company_name = 'Eco Lux Solar')
                                                                                                                     when d.originator_id = 9 then
                                                                                                                         (select id from flow.company where company_name = 'Solar 101')
                                                                                                                     when d.originator_id = 10 then
                                                                                                                         (select id from flow.company where company_name = 'TGE Solar')
                                                                                                                     when d.originator_id = 11 then
                                                                                                                         (select id from flow.company where company_name = 'Atlas Solar Advisors')
                                                                                                                     when d.originator_id = 12 then
                                                                                                                         (select id from flow.company where company_name = 'Direct Solar of America')
                                                                                                                     when d.originator_id = 13 then
                                                                                                                         (select id from flow.company where company_name = 'Revolution Solar')
                                                                                                                     when d.originator_id = 14 then
                                                                                                                         (select id from flow.company where company_name = 'Smart Money Solar')
                                                                                                                     when d.originator_id = 15 then
                                                                                                                         (select id from flow.company where company_name = 'Supernova Energy')
                                                                                                                     when d.originator_id = 16 then
                                                                                                                         (select id from flow.company where company_name = 'Energy Pal')
                                                                                                                     when d.originator_id = 17 then
                                                                                                                         (select id from flow.company where company_name = 'Code 7 Roof and Solar')end)end ,
            c.latitude,
            c.longitude,
            c.time_zone
     FROM blueraven.deal d
    inner join blueraven.customer c on c.id = d.customer_id
    where  d.originator_id !=5);  -- TODO Add all the other companies projects

update flow.project set contact_id = (select id from flow.contact where first_name = 'Robert' and last_name = 'Earl' and city = 'Pahrump' and  company_id = 7)
where id =153066;
update flow.project set contact_id = (select id from flow.contact where first_name = 'Arturo' and last_name = 'Gonzalez' and city = 'Joliet' and  company_id = 7)
where id =179198;


with no_dups as (
    select max(d.id) as deal_id,c.id as contact_id
    from blueraven.deal d
             inner join flow.project p on p.id = d.id
             inner join flow.contact c on c.id = p.contact_id
    group by c.id
),
leads as (
    SELECT c.id as contact_id,
           company_id,
           s.source_name,
           2350555 as created_by_id
    FROM blueraven.deal d
             inner join flow.project p on p.id = d.id
             inner join flow.contact c on c.id = p.contact_id
             inner join blueraven.source s on s.id = d.source_id
             inner join no_dups nd on nd.deal_id = p.id and nd.contact_id = c.id
    WHERE d.source_id IS NOT NULL and c.contact_type_id = 1
),
     list_of_values as (
         select lov2.id as list_of_value_id,lov2.name,cf2.company_id,cfga.id as custom_field_group_assignemnt_id
         from flow.list_of_value lov
                  inner join flow.custom_field cf2 on lov.id = cf2.list_of_value_id
                  inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.company_object_type cot on cot.id = cfg.company_object_type_id
                  inner join flow.object_type ot on ot.id = cot.object_type_id and object_type_id = 2
                  inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
         where cf2.field_name = 'Lead Source' and lov.name = 'Lead Source' and lov.parent_id is null)
INSERT INTO flow.contact_custom_field_value (contact_id, custom_field_group_assignment_id,int_value , created_by_id)
    (SELECT l.contact_id,
            lov.custom_field_group_assignemnt_id,
            lov.list_of_value_id,
            2350555 as created_by_id
     from leads l
              inner join list_of_values lov on lov.company_id = l.company_id and lov.name = l.source_name);

with no_dups as (
    select max(d.id) as deal_id,c.id as contact_id
    from blueraven.deal d
             inner join flow.project p on p.id = d.id
             inner join flow.contact c on c.id = p.contact_id
    group by c.id
),
     leads as (
    SELECT c.id as contact_id,
           company_id,
           lead_source_detail,
           2350555 as created_by_id
    FROM blueraven.deal d
             inner join flow.project p on p.id = d.id
             inner join flow.contact c on c.id = p.contact_id
             inner join no_dups nd on nd.deal_id = p.id and nd.contact_id = c.id
    WHERE d.lead_source_detail IS NOT NULL and c.contact_type_id = 1
),
     list_of_values as (
         select lov2.id as list_of_value_id,lov2.name,cf2.company_id,cfga.id as custom_field_group_assignemnt_id
         from flow.list_of_value lov
                  inner join flow.custom_field cf2 on lov.id = cf2.list_of_value_id
                  inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                  inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
         where cf2.field_name = 'Lead Source Detail' and lov.name = 'Lead Source Detail' and lov.parent_id is null)
INSERT INTO flow.contact_custom_field_value (contact_id, custom_field_group_assignment_id,int_value , created_by_id)
    (SELECT l.contact_id,
            lov.custom_field_group_assignemnt_id,
            lov.list_of_value_id,
            2350555 as created_by_id
     from leads l
              inner join list_of_values lov on lov.company_id = l.company_id and lov.name = l.lead_source_detail);

with leads as (
         SELECT p.id as project_id,
                company_id,
                s.source_name,
                2350555 as created_by_id
         FROM blueraven.deal d
                  inner join flow.project p on p.id = d.id
                  inner join flow.contact c on c.id = p.contact_id
                  inner join blueraven.source s on s.id = d.source_id
         WHERE d.source_id IS NOT NULL and c.contact_type_id = 1
     ),
     list_of_values as (
         select lov2.id as list_of_value_id,lov2.name,cf2.company_id,cfga.id as custom_field_group_assignemnt_id
         from flow.list_of_value lov
                  inner join flow.custom_field cf2 on lov.id = cf2.list_of_value_id
                  inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                  inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
                  inner join flow.company_object_type cot on cot.id = cfg.company_object_type_id
                  inner join flow.object_type ot on ot.id = cot.object_type_id and object_type_id = 1
                  inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
         where cf2.field_name = 'Lead Source' and lov.name = 'Lead Source' and lov.parent_id is null)
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id,int_value , created_by_id)
    (SELECT l.project_id,
            lov.custom_field_group_assignemnt_id,
            lov.list_of_value_id,
            2350555 as created_by_id
     from leads l
              inner join list_of_values lov on lov.company_id = l.company_id and lov.name = l.source_name);


INSERT INTO flow.contact_custom_field_value (contact_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT c.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Final Referral Follow-up' and cf.company_id = c.company_id) as custom_field_id,
            needs_final_referral_followup_date,
            2350555 as created_by_id
     FROM blueraven.deal d
         inner join flow.project p on p.id= d.id
         inner join blueraven.customer c1 on c1.id = d.customer_id
          inner join flow.contact c on c.id = c1.id
     WHERE needs_final_referral_followup_date IS NOT NULL
        limit 1);



-- ask Judson how to resolve these deals
-- select * from blueraven.deal where customer_id is null;


-- change the flow.project id sequence so the imported ids don't cause problems
SELECT setval('flow.project_id_seq',
              COALESCE((SELECT MAX(id) + 1
                        FROM flow.project), 1), false);

-- migrate closer and setter to flow.user_project
-- INSERT INTO flow.user_project (project_id, user_position_id, created_by_id, date_created,start_date)
--     (SELECT *
--      FROM
--          (SELECT d.id AS project_id,
--                  (select up.id
--                   from blueraven.user_position up
--                   where user_id = d.closer_user_id
--                     and position_id = 1
--                     and  ((up.end_date is null and primary_flag is true and d.pre_design_complete_date >= up.start_date)
--                       or (up.end_date is null and d.pre_design_complete_date >= up.start_date)
--                       or (up.end_date is not null and  primary_flag is true and d.pre_design_complete_date >= up.start_date and d.pre_design_complete_date <= up.end_date)
--                       or (up.end_date is not null and d.pre_design_complete_date >= up.start_date and d.pre_design_complete_date <= up.end_date)
--                       or (up.primary_flag is true))
--                   limit 1) AS user_position_id,
--                  2350555 AS created_by_id,
--                  now() AS date_created,
--                  (select up.start_date
--                   from blueraven.user_position up
--                   where user_id = d.closer_user_id
--                     and position_id = 1 and
--                       ((up.end_date is null and primary_flag is true and d.pre_design_complete_date >= up.start_date)
--                           or (up.end_date is null and d.pre_design_complete_date >= up.start_date)
--                           or (up.end_date is not null and  primary_flag is true and d.pre_design_complete_date >= up.start_date and d.pre_design_complete_date <= up.end_date)
--                           or (up.end_date is not null and d.pre_design_complete_date >= up.start_date and d.pre_design_complete_date <= up.end_date)
--                           or (up.primary_flag is true))
--                   limit 1) as start_date
--           FROM blueraven.deal d
--                    INNER JOIN flow.project p ON p.id = d.id
--           WHERE d.closer_user_id IS NOT NULL) AS foo
--      WHERE foo.user_position_id IS NOT NULL);
--
--
-- INSERT INTO flow.user_project (project_id, user_position_id, created_by_id, date_created,start_date)
--     (SELECT *
--      FROM
--          (SELECT d.id AS project_id,
--                  (select up.id
--                   from blueraven.user_position up
--                   where user_id = d.setter_user_id
--                     and position_id = 4
--                     and  ((up.end_date is null and primary_flag is true and d.pre_design_complete_date >= up.start_date)
--                       or (up.end_date is null and d.pre_design_complete_date >= up.start_date)
--                       or (up.end_date is not null and  primary_flag is true and d.pre_design_complete_date >= up.start_date and d.pre_design_complete_date <= up.end_date)
--                       or (up.end_date is not null and d.pre_design_complete_date >= up.start_date and d.pre_design_complete_date <= up.end_date)
--                       or (up.primary_flag is true))
--                   limit 1) AS user_position_id,
--                  2350555 AS created_by_id,
--                  now() AS date_created,
--                  (select up.start_date
--                   from blueraven.user_position up
--                   where user_id = d.setter_user_id
--                     and position_id = 4
--                     and  ((up.end_date is null and primary_flag is true and d.pre_design_complete_date >= up.start_date)
--                       or (up.end_date is null and d.pre_design_complete_date >= up.start_date)
--                       or (up.end_date is not null and  primary_flag is true and d.pre_design_complete_date >= up.start_date and d.pre_design_complete_date <= up.end_date)
--                       or (up.end_date is not null and d.pre_design_complete_date >= up.start_date and d.pre_design_complete_date <= up.end_date)
--                       or (up.primary_flag is true))
--                   limit 1) AS start_date
--           FROM blueraven.deal d
--                    INNER JOIN flow.project p
--                               ON p.id = d.id
--           WHERE d.setter_user_id IS NOT NULL) AS foo
--      WHERE foo.user_position_id IS NOT NULL);

-- INSERT INTO flow.custom_field(
--     field_name, company_data_type_id, date_created,
--     created_by_id, company_id)
-- VALUES ('Entered into Payment System Date',2,now(), 2350555,(select id from flow.company where company_name = 'Blue Raven Solar'));
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,1
--      from flow.custom_field cf
--      where cf.field_name = 'Entered into Payment System Date'
--     );

-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Project PlaceHolder'),
--             (select id from flow.custom_field where field_name = 'Entered into Payment System Date'),1,false, 2350555);
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT p.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE cfg.id = 400 and field_name = 'Entered into Payment System Date' and cf.company_id = c.company_id) as custom_field_id,
            entered_into_payment_system_date,
            2350555 as created_by_id
     FROM blueraven.deal d
     inner join flow.project p on p.id = d.id
     inner join flow.contact c on c.id = p.contact_id
    WHERE entered_into_payment_system_date IS NOT NULL and originator_id = 1
   );

-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Project PlaceHolder'),
--             (select id from flow.custom_field where field_name = 'Source'),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Project PlaceHolder'),
--             (select id from flow.custom_field where field_name = 'Stage'),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Project PlaceHolder'),
--             (select id from flow.custom_field where field_name = 'Cancelled'),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Project PlaceHolder'),
--             (select id from flow.custom_field where field_name = 'On Hold'),1,false, 2350555);
--
-- INSERT INTO flow.custom_field_group_assignment(
--     custom_field_group_id,
--     custom_field_id,field_order,archived,created_by_id)
--     (select (select id from flow.custom_field_group where group_name = 'Project PlaceHolder'),
--             (select id from flow.custom_field where field_name = 'AHJ'),1,false, 2350555);
--
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,1
--      from flow.custom_field cf
--      where cf.field_name = 'Cancelled'
--     );
-- insert into flow.custom_field_object_type(custom_field_id, company_object_type_id)
--     (select id,1
--      from flow.custom_field cf
--      where cf.field_name = 'On Hold'
--     );
--

--TODO Judson made executive decision not to bring source on deal
-- INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
--     (SELECT p.id,
--             (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Source') as custom_field_id,
--             lov.id,
--             2350555 as created_by_id
--      FROM blueraven.deal d
--               inner join flow.project p on d.id = p.id
--               inner join blueraven.source s on s.id = d.source_id
--               inner join flow.list_of_value lov on lov.name = s.source_name
--      WHERE d.source_id IS NOT NULL
--        and parent_id in (select id from flow.list_of_value lov2 where parent_id is null and lov2.name = 'Source'));

-- INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
--     (SELECT p.id,
--             (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Stage') as custom_field_id,
--             lov.id,
--             2350555 as created_by_id
--      FROM blueraven.deal d
--               inner join flow.project p on d.id = p.id
--               inner join blueraven.stage s on s.id = d.current_stage_id
--               inner join flow.list_of_value lov on lov.name = s.stage_name
--      WHERE d.current_stage_id IS NOT NULL
--        and parent_id in (select id from flow.list_of_value lov2 where parent_id is null and lov2.name = 'Stage'));

INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT p.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Deal ID' and cfg.archived is false and c.company_id = cf.company_id) as custom_field_id,
            deal_base_oid,
            2350555 as created_by_id
     FROM blueraven.deal d
              inner join flow.project p on p.id = d.id
              inner join flow.contact c on c.id = p.contact_id
    WHERE deal_base_oid IS NOT NULL
            and customer_id is not null);

-- INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, date_value, created_by_id)
--     (SELECT id,
--             (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Cancelled' and cfg.archived is false) as custom_field_id,
--             cancelled_date,
--             2350555 as created_by_id
--      FROM blueraven.deal WHERE cancelled_date IS NOT NULL
--         and  originator_id = 1);

INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT p.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg
                inner join flow.custom_field cf on  cf.id = cfg.custom_field_id
                inner join flow.custom_field_group cfg1 on cfg1.id = cfg.custom_field_group_id and cfg1.archived is false
            WHERE field_name = 'AHJ'  and cfg.archived is false and cf.archived is false and c.company_id = cf.company_id) as custom_field_id,
            ahj_id,
            2350555 as created_by_id
     FROM blueraven.deal d
              inner join flow.project p on p.id = d.id
              inner join flow.contact c on c.id = p.contact_id
    WHERE ahj_id IS NOT NULL
            );

-- INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, boolean_value, created_by_id)
--     (SELECT id,
--             (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'On Hold' and cfg.archived is false) as custom_field_id,
--             on_hold,
--             2350555 as created_by_id
--      FROM blueraven.deal WHERE on_hold IS NOT NULL
--                            and originator_id = 1);

INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT d.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg
                                    inner join flow.custom_field cf on  cf.id = cfg.custom_field_id
             WHERE field_name = 'Utility Company' and cfg.archived is false and cf.archived is false and c.company_id = cf.company_id) as custom_field_id,
            au.id,
            2350555 as created_by_id
     FROM blueraven.deal d
              inner join flow.project p on p.id = d.id
              inner join flow.contact c on c.id = p.contact_id
              inner join blueraven.ahj_utility au on au.name = substring(d.utility_company, 6)
     WHERE utility_company IS NOT NULL
       and d.customer_id is not null
    );


with deals as (
    SELECT p.id as project_id,
           c.company_id,
           d.metro_area,
           2350555 as created_by_id
    FROM blueraven.deal d
             inner join flow.project p on p.id = d.id
             inner join flow.contact c on c.id = p.contact_id
    WHERE metro_area is not null

),
     list_of_values as (
         select lov2.id as list_of_value_id,lov2.name,cf2.company_id,cfga.id as custom_field_group_assignemnt_id
         from flow.list_of_value lov
                  inner join flow.custom_field cf2 on lov.id = cf2.list_of_value_id
                  inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                  inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
         where cf2.field_name = 'Metro Area' and lov.name = 'Metro Area' and lov.parent_id is null
           and cf2.archived is false and cfga.archived is false)
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT d.project_id,
            lov.custom_field_group_assignemnt_id,
            lov.list_of_value_id,
            2350555 as created_by_id
     from deals d
              inner join list_of_values lov on lov.company_id = d.company_id and lov.name = d.metro_area);


with deals as (
    SELECT p.id as project_id,
           c.company_id,
           d.non_standard_installation_work,
           2350555 as created_by_id
    FROM blueraven.deal d
             inner join flow.project p on p.id = d.id
             inner join flow.contact c on c.id = p.contact_id
    WHERE non_standard_installation_work is not null

),
     list_of_values as (
         select lov2.id as list_of_value_id,lov2.name,cf2.company_id,cfga.id as custom_field_group_assignemnt_id
         from flow.list_of_value lov
                  inner join flow.custom_field cf2 on lov.id = cf2.list_of_value_id
                  inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                  inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
         where cf2.field_name = 'AC Compressor Relocation Required' and lov.name = 'AC Compressor Relocation Required' and lov.parent_id is null)
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT d.project_id,
            lov.custom_field_group_assignemnt_id,
            lov.list_of_value_id,
            2350555 as created_by_id
     from deals d
              inner join list_of_values lov on lov.company_id = d.company_id and lov.name::boolean = case when non_standard_installation_work like any (array['%A/C Compressor Relocation%'])
                                                                                                              then true else false end);

with deals as (
    SELECT p.id as project_id,
           c.company_id,
           d.non_standard_installation_work,
           2350555 as created_by_id
    FROM blueraven.deal d
             inner join flow.project p on p.id = d.id
             inner join flow.contact c on c.id = p.contact_id
    WHERE non_standard_installation_work is not null

),
     list_of_values as (
         select lov2.id as list_of_value_id,lov2.name,cf2.company_id,cfga.id as custom_field_group_assignemnt_id
         from flow.list_of_value lov
                  inner join flow.custom_field cf2 on lov.id = cf2.list_of_value_id
                  inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                  inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
         where cf2.field_name = 'Main Panel Upgrade Required - In-house' and lov.name = 'Main Panel Upgrade - In-house' and lov.parent_id is null)
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT d.project_id,
            lov.custom_field_group_assignemnt_id,
            lov.list_of_value_id,
            2350555 as created_by_id
     from deals d
              inner join list_of_values lov on lov.company_id = d.company_id and lov.name::boolean = case when non_standard_installation_work like any (array['%Main Panel Upgrade - In House%'])
                                                                                                              then true else false end);

with deals as (
    SELECT p.id as project_id,
           c.company_id,
           d.non_standard_installation_work,
           2350555 as created_by_id
    FROM blueraven.deal d
             inner join flow.project p on p.id = d.id
             inner join flow.contact c on c.id = p.contact_id
    WHERE non_standard_installation_work is not null

),
     list_of_values as (
         select lov2.id as list_of_value_id,lov2.name,cf2.company_id,cfga.id as custom_field_group_assignemnt_id
         from flow.list_of_value lov
                  inner join flow.custom_field cf2 on lov.id = cf2.list_of_value_id
                  inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                  inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
         where cf2.field_name = 'Main Panel Upgrade Required - Outsource' and lov.name = 'Main Panel Upgrade - Outsource' and lov.parent_id is null)
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT d.project_id,
            lov.custom_field_group_assignemnt_id,
            lov.list_of_value_id,
            2350555 as created_by_id
     from deals d
              inner join list_of_values lov on lov.company_id = d.company_id and lov.name::boolean = case when non_standard_installation_work like any (array['%Main Panel Upgrade - Outsource%'])
                                                                                                              then true else false end);


with deals as (
    SELECT p.id as project_id,
           c.company_id,
           d.non_standard_installation_work,
           2350555 as created_by_id
    FROM blueraven.deal d
             inner join flow.project p on p.id = d.id
             inner join flow.contact c on c.id = p.contact_id
    WHERE non_standard_installation_work is not null

),
     list_of_values as (
         select lov2.id as list_of_value_id,lov2.name,cf2.company_id,cfga.id as custom_field_group_assignemnt_id
         from flow.list_of_value lov
                  inner join flow.custom_field cf2 on lov.id = cf2.list_of_value_id
                  inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                  inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
         where cf2.field_name = 'New Deadfront Required' and lov.name = 'New Deadfront Required' and lov.parent_id is null)
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT d.project_id,
            lov.custom_field_group_assignemnt_id,
            lov.list_of_value_id,
            2350555 as created_by_id
     from deals d
              inner join list_of_values lov on lov.company_id = d.company_id and lov.name::boolean = case when non_standard_installation_work like any (array['%Source Deadfront%'])
                                                                                                              then true else false end);


with deals as (
    SELECT p.id as project_id,
           c.company_id,
           d.non_standard_installation_work,
           2350555 as created_by_id
    FROM blueraven.deal d
             inner join flow.project p on p.id = d.id
             inner join flow.contact c on c.id = p.contact_id
    WHERE non_standard_installation_work is not null

),
     list_of_values as (
         select lov2.id as list_of_value_id,lov2.name,cf2.company_id,cfga.id as custom_field_group_assignemnt_id
         from flow.list_of_value lov
                  inner join flow.custom_field cf2 on lov.id = cf2.list_of_value_id
                  inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                  inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
         where cf2.field_name = 'Non-Standard Breaker Required' and lov.name = 'Non-Standard Breaker Required' and lov.parent_id is null)
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT d.project_id,
            lov.custom_field_group_assignemnt_id,
            lov.list_of_value_id,
            2350555 as created_by_id
     from deals d
              inner join list_of_values lov on lov.company_id = d.company_id and lov.name::boolean = case when non_standard_installation_work like any (array['%Main Breaker Derate%','%Non-standard Breaker%'])
                                                                                                              then true else false end);

with deals as (
    SELECT p.id as project_id,
           c.company_id,
           d.non_standard_installation_work,
           2350555 as created_by_id
    FROM blueraven.deal d
             inner join flow.project p on p.id = d.id
             inner join flow.contact c on c.id = p.contact_id
    WHERE non_standard_installation_work is not null

),
     list_of_values as (
         select lov2.id as list_of_value_id,lov2.name,cf2.company_id,cfga.id as custom_field_group_assignemnt_id
         from flow.list_of_value lov
                  inner join flow.custom_field cf2 on lov.id = cf2.list_of_value_id
                  inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                  inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
         where cf2.field_name = 'Other Non-Standard Work Required - In-house' and lov.name = 'Other Non-Standard Work Required - In-house' and lov.parent_id is null)
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT d.project_id,
            lov.custom_field_group_assignemnt_id,
            lov.list_of_value_id,
            2350555 as created_by_id
     from deals d
              inner join list_of_values lov on lov.company_id = d.company_id and lov.name::boolean = case when non_standard_installation_work like any (array['%Other - In House%'])
                                                                                                              then true else false end);

with deals as (
    SELECT p.id as project_id,
           c.company_id,
           d.non_standard_installation_work,
           2350555 as created_by_id
    FROM blueraven.deal d
             inner join flow.project p on p.id = d.id
             inner join flow.contact c on c.id = p.contact_id
    WHERE non_standard_installation_work is not null

),
     list_of_values as (
         select lov2.id as list_of_value_id,lov2.name,cf2.company_id,cfga.id as custom_field_group_assignemnt_id
         from flow.list_of_value lov
                  inner join flow.custom_field cf2 on lov.id = cf2.list_of_value_id
                  inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                  inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
         where cf2.field_name = 'Other Non-Standard Work Required - Outsource' and lov.name = 'Other Non-Standard Work Required - Outsource' and lov.parent_id is null)
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT d.project_id,
            lov.custom_field_group_assignemnt_id,
            lov.list_of_value_id,
            2350555 as created_by_id
     from deals d
              inner join list_of_values lov on lov.company_id = d.company_id and lov.name::boolean = case when non_standard_installation_work like any (array['%Other - Outsource%'])
                                                                                                              then true else false end);

with deals as (
    SELECT p.id as project_id,
           c.company_id,
           d.non_standard_installation_work,
           2350555 as created_by_id
    FROM blueraven.deal d
             inner join flow.project p on p.id = d.id
             inner join flow.contact c on c.id = p.contact_id
    WHERE non_standard_installation_work is not null

),
     list_of_values as (
         select lov2.id as list_of_value_id,lov2.name,cf2.company_id,cfga.id as custom_field_group_assignemnt_id
         from flow.list_of_value lov
                  inner join flow.custom_field cf2 on lov.id = cf2.list_of_value_id
                  inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                  inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
         where cf2.field_name = 'Structural Upgrade Required' and lov.name = 'Structural Upgrade Required' and lov.parent_id is null)
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT d.project_id,
            lov.custom_field_group_assignemnt_id,
            lov.list_of_value_id,
            2350555 as created_by_id
     from deals d
              inner join list_of_values lov on lov.company_id = d.company_id and lov.name::boolean = case when non_standard_installation_work like any (array['%Structural Upgrade%'])
                                                                                                              then true else false end);

with deals as (
    SELECT p.id as project_id,
           c.company_id,
           d.non_standard_installation_work,
           2350555 as created_by_id
    FROM blueraven.deal d
             inner join flow.project p on p.id = d.id
             inner join flow.contact c on c.id = p.contact_id
    WHERE non_standard_installation_work is not null

),
     list_of_values as (
         select lov2.id as list_of_value_id,lov2.name,cf2.company_id,cfga.id as custom_field_group_assignemnt_id
         from flow.list_of_value lov
                  inner join flow.custom_field cf2 on lov.id = cf2.list_of_value_id
                  inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                  inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
         where cf2.field_name = 'Tree Trim Required' and lov.name = 'Tree Trim Required' and lov.parent_id is null)
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT d.project_id,
            lov.custom_field_group_assignemnt_id,
            lov.list_of_value_id,
            2350555 as created_by_id
     from deals d
              inner join list_of_values lov on lov.company_id = d.company_id and lov.name::boolean = case when non_standard_installation_work like any (array['%Tree Trimming%'])
                                                                                                              then true else false end);

with deals as (
    SELECT p.id as project_id,
           c.company_id,
           d.non_standard_installation_work,
           2350555 as created_by_id
    FROM blueraven.deal d
             inner join flow.project p on p.id = d.id
             inner join flow.contact c on c.id = p.contact_id
    WHERE non_standard_installation_work is not null

),
     list_of_values as (
         select lov2.id as list_of_value_id,lov2.name,cf2.company_id,cfga.id as custom_field_group_assignemnt_id
         from flow.list_of_value lov
                  inner join flow.custom_field cf2 on lov.id = cf2.list_of_value_id
                  inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                  inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
         where cf2.field_name = 'Trenching Required' and lov.name = 'Trenching Required' and lov.parent_id is null)
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT d.project_id,
            lov.custom_field_group_assignemnt_id,
            lov.list_of_value_id,
            2350555 as created_by_id
     from deals d
              inner join list_of_values lov on lov.company_id = d.company_id and lov.name::boolean = case when non_standard_installation_work like any (array['%Trenching%'])
                                                                                                              then true else false end);

with deals as (
    SELECT p.id as project_id,
           c.company_id,
           d.non_standard_installation_work,
           2350555 as created_by_id
    FROM blueraven.deal d
             inner join flow.project p on p.id = d.id
             inner join flow.contact c on c.id = p.contact_id
    WHERE non_standard_installation_work is not null

),
     list_of_values as (
         select lov2.id as list_of_value_id,lov2.name,cf2.company_id,cfga.id as custom_field_group_assignemnt_id
         from flow.list_of_value lov
                  inner join flow.custom_field cf2 on lov.id = cf2.list_of_value_id
                  inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                  inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
         where cf2.field_name = 'Reroof Required' and lov.name = 'Reroof Required' and lov.parent_id is null)
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT d.project_id,
            lov.custom_field_group_assignemnt_id,
            lov.list_of_value_id,
            2350555 as created_by_id
     from deals d
              inner join list_of_values lov on lov.company_id = d.company_id and lov.name::boolean = case when non_standard_installation_work like any (array['%Reroof%'])
                                                                                                              then true else false end);

with deals as (
    SELECT p.id as project_id,
           c.company_id,
           d.ancillary_expense_type_1,
           2350555 as created_by_id
    FROM blueraven.deal d
             inner join flow.project p on p.id = d.id
             inner join flow.contact c on c.id = p.contact_id
    WHERE ancillary_expense_type_1 is not null

),
     list_of_values as (
         select lov2.id as list_of_value_id,lov2.name,cf2.company_id,cfga.id as custom_field_group_assignemnt_id
         from flow.list_of_value lov
                  inner join flow.custom_field cf2 on lov.id = cf2.list_of_value_id
                  inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                  inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
         where cf2.field_name = 'Ancillary Expense Type 1' and lov.name = 'Ancillary Expense Type 1' and lov.parent_id is null)
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT d.project_id,
            lov.custom_field_group_assignemnt_id,
            lov.list_of_value_id,
            2350555 as created_by_id
     from deals d
              inner join list_of_values lov on lov.company_id = d.company_id and lov.name = d.ancillary_expense_type_1);

with deals as (
    SELECT p.id as project_id,
           c.company_id,
           d.ancillary_expense_type_2,
           2350555 as created_by_id
    FROM blueraven.deal d
             inner join flow.project p on p.id = d.id
             inner join flow.contact c on c.id = p.contact_id
    WHERE ancillary_expense_type_2 is not null

),
     list_of_values as (
         select lov2.id as list_of_value_id,lov2.name,cf2.company_id,cfga.id as custom_field_group_assignemnt_id
         from flow.list_of_value lov
                  inner join flow.custom_field cf2 on lov.id = cf2.list_of_value_id
                  inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                  inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
         where cf2.field_name = 'Ancillary Expense Type 2' and lov.name = 'Ancillary Expense Type 2' and lov.parent_id is null)
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT d.project_id,
            lov.custom_field_group_assignemnt_id,
            lov.list_of_value_id,
            2350555 as created_by_id
     from deals d
              inner join list_of_values lov on lov.company_id = d.company_id and lov.name = d.ancillary_expense_type_2);

with deals as (
    SELECT p.id as project_id,
           c.company_id,
           d.ancillary_expense_type_3,
           2350555 as created_by_id
    FROM blueraven.deal d
             inner join flow.project p on p.id = d.id
             inner join flow.contact c on c.id = p.contact_id
    WHERE ancillary_expense_type_3 is not null

),
     list_of_values as (
         select lov2.id as list_of_value_id,lov2.name,cf2.company_id,cfga.id as custom_field_group_assignemnt_id
         from flow.list_of_value lov
                  inner join flow.custom_field cf2 on lov.id = cf2.list_of_value_id
                  inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                  inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
         where cf2.field_name = 'Ancillary Expense Type 3' and lov.name = 'Ancillary Expense Type 3' and lov.parent_id is null)
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT d.project_id,
            lov.custom_field_group_assignemnt_id,
            lov.list_of_value_id,
            2350555 as created_by_id
     from deals d
              inner join list_of_values lov on lov.company_id = d.company_id and lov.name = d.ancillary_expense_type_3);

with deals as (
    SELECT p.id as project_id,
           c.company_id,
           d.homeowner_review_score,
           2350555 as created_by_id
    FROM blueraven.deal d
             inner join flow.project p on p.id = d.id
             inner join flow.contact c on c.id = p.contact_id
    WHERE homeowner_review_score is not null

),
     list_of_values as (
         select lov2.id as list_of_value_id,lov2.name,cf2.company_id,cfga.id as custom_field_group_assignemnt_id
         from flow.list_of_value lov
                  inner join flow.custom_field cf2 on lov.id = cf2.list_of_value_id
                  inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                  inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
         where cf2.field_name = 'Homeowner Review Score' and lov.name = 'Homeowner Review Score' and lov.parent_id is null)
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT d.project_id,
            lov.custom_field_group_assignemnt_id,
            lov.list_of_value_id,
            2350555 as created_by_id
     from deals d
              inner join list_of_values lov on lov.company_id = d.company_id and lov.name::integer = d.homeowner_review_score);




-- INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
--     (SELECT d.id,
--             (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Maximum Loan Amount' and cf.company_id = c.company_id),
--             d.maximum_loan_amount,
--             2350555 as created_by_id
--      FROM blueraven.deal d
--     inner join flow.project p on p.id = d.id
--     inner join flow.contact c on c.id = p.contact_id
--      WHERE maximum_loan_amount is not null
--        and  originator_id = 1);

INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT d.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Annual Utility Usage (kWh)' and cf.company_id = c.company_id),
            d.annual_utility_usage,
            2350555 as created_by_id
     FROM blueraven.deal d
              inner join flow.project p on p.id = d.id
              inner join flow.contact c on c.id = p.contact_id
     WHERE annual_utility_usage is not null
      );

INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT d.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Ancillary Expense Bid Price 1' and cf.company_id = c.company_id),
            d.ancillary_expense_actual_price_1 ,
            2350555 as created_by_id
     FROM blueraven.deal d
              inner join flow.project p on p.id = d.id
              inner join flow.contact c on c.id = p.contact_id
     WHERE ancillary_expense_actual_price_1 is not null
       );
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT d.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Ancillary Expense Bid Price 2' and cf.company_id = c.company_id),
            d.ancillary_expense_actual_price_2 ,
            2350555 as created_by_id
     FROM blueraven.deal d
              inner join flow.project p on p.id = d.id
              inner join flow.contact c on c.id = p.contact_id
     WHERE ancillary_expense_actual_price_2 is not null
       );
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT d.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Ancillary Expense Bid Price 3' and cf.company_id = c.company_id),
            d.ancillary_expense_actual_price_3 ,
            2350555 as created_by_id
     FROM blueraven.deal d
              inner join flow.project p on p.id = d.id
              inner join flow.contact c on c.id = p.contact_id
     WHERE ancillary_expense_actual_price_3 is not null
       );

INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT d.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Ancillary Expense Estimated Price 1' and cf.company_id = c.company_id),
            d.ancillary_expense_estimated_price_1 ,
            2350555 as created_by_id
     FROM blueraven.deal d
              inner join flow.project p on p.id = d.id
              inner join flow.contact c on c.id = p.contact_id
     WHERE ancillary_expense_estimated_price_1 is not null
       );
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT d.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Ancillary Expense Estimated Price 2' and cf.company_id = c.company_id),
            d.ancillary_expense_estimated_price_2 ,
            2350555 as created_by_id
     FROM blueraven.deal d
              inner join flow.project p on p.id = d.id
              inner join flow.contact c on c.id = p.contact_id
     WHERE ancillary_expense_estimated_price_2 is not null
      );
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT d.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Ancillary Expense Estimated Price 3' and cf.company_id = c.company_id),
            d.ancillary_expense_estimated_price_3 ,
            2350555 as created_by_id
     FROM blueraven.deal d
              inner join flow.project p on p.id = d.id
              inner join flow.contact c on c.id = p.contact_id
     WHERE ancillary_expense_estimated_price_3 is not null
       );
-- INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
--     (SELECT d.id,
--             (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Annual Utility Usage (kWh)' and cf.company_id = c.company_id),
--             d.annual_utility_usage::integer,
--             2350555 as created_by_id
--      FROM blueraven.deal d
--               inner join flow.project p on p.id = d.id
--               inner join flow.contact c on c.id = p.contact_id
--      WHERE annual_utility_usage is not null
--       );

INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT d.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Homeowner Review Date' and cf.company_id = c.company_id),
            d.homeowner_review_date,
            2350555 as created_by_id
     FROM blueraven.deal d
              inner join flow.project p on p.id = d.id
              inner join flow.contact c on c.id = p.contact_id
     WHERE homeowner_review_date is not null
      );

INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, date_value, created_by_id)
    (SELECT d.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Notice of Cancellation Deadline' and cf.company_id = c.company_id),
            d.notice_of_cancellation_deadline_date,
            2350555 as created_by_id
     FROM blueraven.deal d
              inner join flow.project p on p.id = d.id
              inner join flow.contact c on c.id = p.contact_id
     WHERE notice_of_cancellation_deadline_date is not null
       );

INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, numeric_value, created_by_id)
    (SELECT d.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Maximum Loan Amount' and cf.company_id = c.company_id),
            d.maximum_loan_amount::numeric,
            2350555 as created_by_id
     FROM blueraven.deal d
              inner join flow.project p on p.id = d.id
              inner join flow.contact c on c.id = p.contact_id
     WHERE maximum_loan_amount is not null
      );
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, numeric_value, created_by_id)
    (SELECT d.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Retention: Customer Concession ($ Amount)' and cf.company_id = c.company_id
                                                                                                                                          and cfg.archived is false and cf.archived is false),
            d.retention_customer_concession_amount::numeric,
            2350555 as created_by_id
     FROM blueraven.deal d
              inner join flow.project p on p.id = d.id
              inner join flow.contact c on c.id = p.contact_id
     WHERE retention_customer_concession_amount is not null
      );
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, numeric_value, created_by_id)
    (SELECT d.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg inner join flow.custom_field cf on  cf.id = cfg.custom_field_id  WHERE field_name = 'Total BRS Covered Ancillary Cost' and cf.company_id = c.company_id
                                                                                                                                          and cfg.archived is false and cf.archived is false),
            d.total_brs_covered_ancillary_cost::numeric,
            2350555 as created_by_id
     FROM blueraven.deal d
              inner join flow.project p on p.id = d.id
              inner join flow.contact c on c.id = p.contact_id
     WHERE total_brs_covered_ancillary_cost is not null
       );

INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT d.id,
            (SELECT cfg.id
             FROM flow.custom_field_group_assignment cfg
                      inner join flow.custom_field cf on  cf.id = cfg.custom_field_id
                      inner join flow.custom_field_group cfg1 on cfg1.id = cfg.custom_field_group_id and cfg1.process_step_id is null
             WHERE  field_name = 'Building Permit Number' and cf.company_id = c.company_id
               and cfg.archived is false and cf.archived is false),
            d.permit_number,
            2350555 as created_by_id
     FROM blueraven.deal d
              inner join flow.project p on p.id = d.id
              inner join flow.contact c on c.id = p.contact_id
     WHERE permit_number is not null
      );

INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT d.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg
                                    inner join flow.custom_field cf on  cf.id = cfg.custom_field_id
                                    inner join flow.custom_field_group cfg2 on cfg2.id = cfg.custom_field_group_id
             WHERE field_name = 'Electrical Permit Number' and cf.company_id = c.company_id
               and cfg.archived is false and cfg2.process_step_id is null),
            d.electrical_permit_number,
            2350555 as created_by_id
     FROM blueraven.deal d
              inner join flow.project p on p.id = d.id
              inner join flow.contact c on c.id = p.contact_id
     WHERE electrical_permit_number is not null
       );

INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, boolean_value, created_by_id)
    (SELECT d.id,
            (SELECT cfg.id FROM flow.custom_field_group_assignment cfg
                inner join flow.custom_field cf on  cf.id = cfg.custom_field_id
            WHERE field_name = 'Homeowner Review' and cf.company_id = c.company_id
                and cfg.archived is false),
            d.customer_review::boolean,
            2350555 as created_by_id
     FROM blueraven.deal d
              inner join flow.project p on p.id = d.id
              inner join flow.contact c on c.id = p.contact_id
     WHERE customer_review is not null
      );

INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, text_value, created_by_id)
    (SELECT d.id,
            (SELECT cfg.id
             FROM flow.custom_field_group_assignment cfg
                      inner join flow.custom_field cf on  cf.id = cfg.custom_field_id
                      inner join flow.custom_field_group cfg1 on cfg1.id = cfg.custom_field_group_id and cfg1.archived is false
                 and cfg1.process_step_id is null
             WHERE field_name = 'Non-Standard Installation Work Details' and cf.company_id = c.company_id),
            d.non_standard_installation_work_details,
            2350555 as created_by_id
     FROM blueraven.deal d
              inner join flow.project p on p.id = d.id
              inner join flow.contact c on c.id = p.contact_id
     WHERE non_standard_installation_work_details is not null
       );

with deals as (
    SELECT p.id as project_id,
           c.company_id,
           d.installation_partner,
           2350555 as created_by_id
    FROM blueraven.deal d
             inner join flow.project p on p.id = d.id
             inner join flow.contact c on c.id = p.contact_id
    WHERE installation_partner is not null

),
     list_of_values as (
         select lov2.id as list_of_value_id,lov2.name,cf2.company_id,cfga.id as custom_field_group_assignemnt_id
         from flow.list_of_value lov
                  inner join flow.custom_field cf2 on lov.id = cf2.list_of_value_id
                  inner join flow.custom_field_group_assignment cfga on cfga.custom_field_id = cf2.id
                  inner join flow.list_of_value lov2 on lov2.parent_id = lov.id
         where cf2.field_name = 'Installation Partner' and lov.name = 'Installation Partner' and lov.parent_id is null)
INSERT INTO flow.project_custom_field_value (project_id, custom_field_group_assignment_id, int_value, created_by_id)
    (SELECT d.project_id,
            lov.custom_field_group_assignemnt_id,
            lov.list_of_value_id,
            2350555 as created_by_id
     from deals d
              inner join list_of_values lov on lov.company_id = d.company_id and lov.name = d.installation_partner);



insert into brs.ahj_checklist_type(id, name, archived)
    (select id,
            name,
            CASE WHEN active IS FALSE THEN TRUE ELSE FALSE END
     from blueraven.ahj_checklist_type);

SELECT setval('brs.ahj_checklist_type_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_checklist_type), 1), false);


insert into brs.ahj_checklist(id, description, display_order, archived, date_created, created_by_id, date_modified, modified_by_id, checklist_type_id, failed_inspection_resource_id, failed_inspection_date, failed_inspection_project)
    (select id, description, display_order, archived, created, created_by_id, updated, updated_by_id, checklist_type_id, failed_inspection_resource_id, failed_inspection_date, failed_inspection_project
     from blueraven.ahj_checklist);

SELECT setval('brs.ahj_checklist_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_checklist), 1), false);


insert into brs.ahj_contact_type(id, type)
    (select id, type
     from blueraven.ahj_contact_type);

SELECT setval('brs.ahj_contact_type_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_contact_type), 1), false);


insert into brs.ahj_contact(id, name, title, email, phone_number, address, notes, hours, archived, date_created, created_by_id, date_modified, modified_by_id, contact_type_id)
    (select id, name, title, email, phone_number, address, notes, hours, archived, created, created_by_id, updated, updated_by_id, contact_type_id
     from blueraven.ahj_contact);

SELECT setval('brs.ahj_contact_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_contact), 1), false);


insert into brs.ahj_link_type(id, name, archived)
    (select id,
            name,
            CASE WHEN active IS FALSE THEN TRUE ELSE FALSE END
     from blueraven.ahj_link_type);

SELECT setval('brs.ahj_link_type_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_link_type), 1), false);



insert into brs.ahj_inspection(id, ahj_id, inspection_fee, re_inspection_fee, payment_method, inspection_time_window, brs_inspection_rep, portal_url, portal_username, portal_password, obtaining_results_method, approval_document_method, obtaining_results_portal_url, obtaining_results_portal_username, obtaining_results_portal_password, business_license, contractor_license, archived, date_created, created_by_id, date_modified, modified_by_id, ladder_required, time_window, time_window_call_time, time_window_phone, scheduling_note, technician_instruction_note, scheduling_with_customer_note, obtaining_results_note, reinspection_note, documentation_note, required_inspection_types, mpu_inspection_note)
    (select id, ahj_id, inspection_fee, re_inspection_fee, payment_method, inspection_time_window, brs_inspection_rep, portal_url, portal_username, portal_password, obtaining_results_method, approval_document_method, obtaining_results_portal_url, obtaining_results_portal_username, obtaining_results_portal_password, business_license, contractor_license, archived, created, created_by_id, updated, updated_by_id, ladder_required, time_window, time_window_call_time, time_window_phone, scheduling_note, technician_instruction_note, scheduling_with_customer_note, obtaining_results_note, reinspection_note, documentation_note, required_inspection_types, mpu_inspection_note
     from blueraven.ahj_inspection);

SELECT setval('brs.ahj_inspection_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_inspection), 1), false);


insert into brs.ahj_inspection_link(id, ahj_inspection_id, name, link, username, password, notes, archived, date_created, created_by_id, date_modified, modified_by_id, link_type_id)
    (select id, ahj_inspection_id, name, link, username, password, notes, archived, created, created_by_id, updated, updated_by_id, link_type_id
     from blueraven.ahj_inspection_link);

SELECT setval('brs.ahj_inspection_link_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_inspection_link), 1), false);


insert into brs.ahj_permit(id, ahj_id, deposit_amount, average_permit_fee, engineering_letter_required, print_location, stamped_plan, archived, date_created, created_by_id, date_modified, modified_by_id, business_license_expiration_date, contractor_license_expiration_date, business_license, contractor_license, submission_note, revision_note, as_built_note, delivery_note, revision_fee_amount, as_built_fee_amount, follow_up_fee_amount, delivery_fee_amount, approval_timeline, documents_available, other_license, other_license_expiration_date)
    (select id, ahj_id, deposit_amount, average_permit_fee, engineering_letter_required, print_location, stamped_plan, archived, created, created_by_id, updated, updated_by_id, business_license_expiration_date, contractor_license_expiration_date, business_license, contractor_license, submission_note, revision_note, as_built_note, delivery_note, revision_fee_amount, as_built_fee_amount, follow_up_fee_amount, delivery_fee_amount, approval_timeline, documents_available, other_license, other_license_expiration_date
     from blueraven.ahj_permit);

SELECT setval('brs.ahj_permit_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_permit), 1), false);


insert into brs.ahj_permit_link(id, ahj_permit_id, name, link, username, password, notes, archived, date_created, created_by_id, date_modified, modified_by_id, link_type_id)
    (select id, ahj_permit_id, name, link, username, password, notes, archived, created, created_by_id, updated, updated_by_id, link_type_id
     from blueraven.ahj_permit_link);

SELECT setval('brs.ahj_permit_link_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_permit_link), 1), false);


insert into brs.ahj_utility_link(id, ahj_utility_id, name, link, username, password, notes, link_type_id, archived, date_created, created_by_id, date_modified, modified_by_id)
    (select id, ahj_utility_id, name, link, username, password, notes, link_type_id, archived, created, created_by_id, updated, updated_by_id
     from blueraven.ahj_utility_link);

SELECT setval('brs.ahj_utility_link_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_utility_link), 1), false);


insert into brs.ahj_note_type(id, type)
    (select id, type
     from blueraven.ahj_note_type);

SELECT setval('brs.ahj_note_type_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_note_type), 1), false);


insert into brs.ahj_note(id, note, archived, date_created, created_by_id, date_modified, modified_by_id, note_type_id)
    (select id, note, archived, created, created_by_id, updated, updated_by_id, note_type_id
     from blueraven.ahj_note);

SELECT setval('brs.ahj_note_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_note), 1), false);


insert into brs.ahj_utility_contact          SELECT * FROM blueraven.ahj_utility_contact;


insert into brs.ahj_utility_checklist        SELECT * FROM blueraven.ahj_utility_checklist;


insert into brs.ahj_requirement_type(id, name, archived, date_created, date_modified)
    (select id,
            name,
            CASE WHEN active IS FALSE THEN TRUE ELSE FALSE END,
            date_created,
            date_updated
     from blueraven.ahj_requirement_type);

SELECT setval('brs.ahj_requirement_type_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_requirement_type), 1), false);


insert into brs.ahj_requirement(id, requirement_type_id, description, date_created, created_by_id, date_modified, modified_by_id)
    (select id, requirement_type_id, description, date_created, created_by_id, date_updated, updated_by_id
     from blueraven.ahj_requirement);

SELECT setval('brs.ahj_requirement_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_requirement), 1), false);


insert into brs.ahj_requirement_status(id, name, display_order)
    (select id, name, display_order
     from blueraven.ahj_requirement_status);

SELECT setval('brs.ahj_requirement_status_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_requirement_status), 1), false);


insert into brs.ahj_utility_requirements(utility_id, requirement_id, position, original_requirement_id, status_id, complete, archived, date_created, created_by_id, date_modified, modified_by_id)
    (select utility_id, requirement_id, position, original_requirement_id, status_id, complete, CASE WHEN archived IS NULL THEN FALSE ELSE 1=1 END, date_created, created_by_id, date_updated, updated_by_id
     from blueraven.ahj_utility_requirements);


insert into brs.ahj_permit_contact           SELECT * FROM blueraven.ahj_permit_contact;


insert into brs.ahj_permit_note              SELECT * FROM blueraven.ahj_permit_note;


insert into brs.ahj_permit_checklist         SELECT * FROM blueraven.ahj_permit_checklist;


insert into brs.ahj_design(id, ahj_id, codes, archived, date_created, created_by_id, date_modified, modified_by_id, utility_id, note, reference_standards, ground_snow_load, wind_speed, roof_snow_load)
    (select id, ahj_id, codes, archived, created, created_by_id, updated, updated_by_id, utility_id, note, reference_standards, ground_snow_load, wind_speed, roof_snow_load
     from blueraven.ahj_design);

SELECT setval('brs.ahj_design_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_design), 1), false);


insert into brs.ahj_design_contact           SELECT * FROM blueraven.ahj_design_contact;


insert into brs.ahj_design_note              SELECT * FROM blueraven.ahj_design_note;


insert into brs.ahj_base_note_template(id, title, note, archived)
    (select id, title, note, archived
     from blueraven.ahj_base_note_template);

SELECT setval('brs.ahj_base_note_template_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.ahj_base_note_template), 1), false);


insert into brs.ahj_inspection_base_note     SELECT * FROM blueraven.ahj_inspection_base_note;


insert into brs.ahj_inspection_checklist     SELECT * FROM blueraven.ahj_inspection_checklist;


insert into brs.ahj_inspection_contact       SELECT * FROM blueraven.ahj_inspection_contact;


insert into brs.ahj_inspection_note          SELECT * FROM blueraven.ahj_inspection_note;


insert into brs.ahj_requirements(ahj_id, requirement_id, original_requirement_id, status_id, position, complete, archived, date_created, created_by_id, date_modified, modified_by_id)
    (select ahj_id, requirement_id, original_requirement_id, status_id, position, complete, CASE WHEN archived IS NULL THEN FALSE ELSE 1=1 END, date_created, created_by_id, date_updated, updated_by_id
     from blueraven.ahj_requirements);



-- insert into flow.custom_field(company_id, field_name, company_data_type_id, created_by_id, custom_field_sql_key_id)
-- values((select id from flow.company where company_name = 'Blue Raven Solar'), 'AHJ', 9, 2350555, 1);


-- with parent as (
--     insert into flow.list_of_value( name, parent_id, display_order, date_created,
--                                     created_by_id, archived)
--         values('Setter Appointment Outcome',null,1,now(),2350555,false)
--         returning id ),
--      t as (insert into flow.list_of_value( name, parent_id, display_order, date_created,
--                                            created_by_id, archived)
--          (select c.setter_appointment_outcome,(select p.id from parent p),1,now(),2350555,false
--           from blueraven.customer c
--           where c.setter_appointment_outcome is not null
--           group by c.setter_appointment_outcome))
-- INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id,list_of_value_id)
--     (select 'Setter Appointment Outcome',
--             7,
--             now(),
--             2350555,
--             (select id from flow.company where company_name = 'Blue Raven Solar'),
--             p.id
--      from parent p
--     );



-- with parent as (
--     insert into flow.list_of_value( name, parent_id, display_order, date_created,
--                                     created_by_id, archived)
--         values('Deal Stage',null,1,now(),2350555,false)
--         returning id ),
--      t as (insert into flow.list_of_value( name, parent_id, display_order, date_created,
--                                            created_by_id, archived)
--          (select c.deal_stage,(select p.id from parent p),1,now(),2350555,false
--           from blueraven.customer c
--           where c.deal_stage is not null
--           group by c.deal_stage))
-- INSERT INTO flow.custom_field (field_name, company_data_type_id, date_created, created_by_id, company_id,list_of_value_id)
--     (select 'Deal Stage',
--             7,
--             now(),
--             2350555,
--             (select id from flow.company where company_name = 'Blue Raven Solar'),
--             p.id
--      from parent p
--     );



DELETE FROM brs.list_of_value WHERE parent_id = 213 AND name = 'false';
UPDATE brs.list_of_value SET show_other = true WHERE name = 'Other' AND parent_id IN (1,31);


/*insert into commissions*/

insert into brs.commission_plan_status(id, status_type)
(select id,status_type
    from blueraven.commission_plan_status);

insert into brs.commission_plan(id, name, total, status_id, position_id, approved, created, created_by, approved_by, parent_id, description, notes)
(select id, name, total, status_id, position_id, approved, created, created_by, approved_by, parent_id, description, notes
    from blueraven.commission_plan);

insert into brs.commission_plan_user(id, commission_plan_id, user_id, start_date, end_date, note)
(select id, commission_plan_id, user_id, start_date, end_date, note
    from blueraven.commission_plan_user);

insert into brs.milestone_type(id, milestone_type, active, display_order)
(select id, milestone_type, active, display_order
    from blueraven.milestone_type);

insert into brs.fee_type(id, fee_type)
(select id,fee_type
    from blueraven.fee_type);

insert into brs.commission_plan_source_allocation(id, commission_plan_id, milestone_id, fee_amount, fee_type_id, source_id)
(select cpsa.id, commission_plan_id, milestone_id, fee_amount, fee_type_id, (select lov.id
                                                                        from flow.custom_field cf
                                                                        inner join flow.list_of_value lov on lov.parent_id = cf.list_of_value_id
                                                                        where cf.id = 573
                                                                        and lov.name = s.source_name
                                                                        and lov.parent_id = 520)
    from  blueraven.commission_plan_source_allocation cpsa
            inner join blueraven.source s on s.id =cpsa.source_id);


insert into brs.commission_plan_allocation(id, commission_plan_id, milestone_id, allocation)
(select cpa.id, commission_plan_id, mqc.milestone_id, allocation
    from blueraven.commission_plan_allocation cpa
    inner join blueraven.milestone_query_condition mqc on mqc.id = cpa.milestone_query_condition_id);


insert into brs.override_plan_status(id, status_type)
    (select id,status_type
     from blueraven.override_plan_status);

insert into brs.override_plan(id, name, description, total, status_id, position_id, created_by, created, updated_by, updated, approved_by, approved, parent_id)
(SELECT id, name, description, total, status_id, position_id, created_by, created, updated_by, updated, approved_by, approved, parent_id
from blueraven.override_plan);

insert into brs.override_plan_assigned_user(id, override_plan_id, user_id, start_date, end_date, note)
(select id, override_plan_id, user_id, start_date, end_date, note
    from blueraven.override_plan_assigned_user);

insert into brs.override_plan_receiving_user( override_plan_id, user_id, m1_allocation, m2_allocation, note)
(select  override_plan_id, user_id, (select (opru.allocation * (opma.allocation/100)) as m1_allocation
                                        from blueraven.override_plan_milestone_allocation opma
                                                 inner join blueraven.milestone_query_condition mqc on mqc.id = opma.milestone_query_condition_id
                                                 inner join blueraven.milestone_type mt on mt.id = mqc.milestone_id
                                                 inner join blueraven.override_plan op on op.id = opma.override_plan_id
                                                 inner join blueraven.override_plan_receiving_user op1 on op1.override_plan_id = op.id
                                        where opma.override_plan_id = opru.override_plan_id
                                          and op1.user_id = opru.user_id
                                          and mt.id = 1),
        (select (opru.allocation * (opma.allocation/100)) as m2_allocation
         from blueraven.override_plan_milestone_allocation opma
                  inner join blueraven.milestone_query_condition mqc on mqc.id = opma.milestone_query_condition_id
                  inner join blueraven.milestone_type mt on mt.id = mqc.milestone_id
                  inner join blueraven.override_plan op on op.id = opma.override_plan_id
                  inner join blueraven.override_plan_receiving_user op1 on op1.override_plan_id = op.id
         where opma.override_plan_id = opru.override_plan_id
           and op1.user_id = opru.user_id
           and mt.id = 2), note
    from blueraven.override_plan_receiving_user opru);


insert into brs.payroll_status
(select * from blueraven.payroll_status);


with updates as (
    with deals as (
        select unnest(selected_deal_ids) as deal_base_oid ,id
        from blueraven.payroll p
        group by id)
    select array_agg(d.id) deal_ids,d2.id payroll_id
    from blueraven.deal d
             inner join deals d2  on d2.deal_base_oid = d.deal_base_oid
    group by d2.id)
insert into brs.payroll(id, period_end, paid_date, description, payroll_status_id, created, updated, created_by, updated_by, current, selected_project_ids)
(select id, period_end, paid_date, description, payroll_status_id, created, updated, created_by, updated_by, current, u.deal_ids
from blueraven.payroll p
    inner join updates u on u.payroll_id = p.id
 union
 select id, period_end, paid_date, description, payroll_status_id, created, updated, created_by, updated_by, current, null
 from blueraven.payroll where id = 0);

insert into brs.payroll(id, period_end, paid_date, description, payroll_status_id, created, updated, created_by, updated_by, current)
(select id, period_end, paid_date, description, payroll_status_id, created, updated, created_by, updated_by, current
    from blueraven.payroll where selected_deal_ids = '{}' and id != 0);

insert into brs.payroll_adjustment_type
    (select * from blueraven.payroll_adjustment_type);


insert into brs.payroll_adjustment(id, payroll_id, project_id, closer_id, amount, note, created_by, created, payroll_adjustment_type_id)
(SELECT id, payroll_id, deal_id, closer_id, amount, note, created_by, created, payroll_adjustment_type_id
from blueraven.payroll_adjustment);

insert into brs.payroll_action_type
select * from blueraven.payroll_action_type;

insert into brs.payroll_action_history
select * from blueraven.payroll_action_history;

insert into brs.ledger_type
select * from blueraven.ledger_type;

insert into brs.project_commission_ledger(id, project_id, closer_id, ledger_type_id, amount, note, created_by, created, payroll_id, paid_to_date)
select id, deal_id, closer_id, ledger_type_id, amount, note, created_by, created, payroll_id, paid_to_date from blueraven.deal_commission_ledger;

insert into brs.project_commission_snapshot(id, payroll_id, project_id, customer_name, system_size, sales_rep_id, sales_rep, source, stage, cancelled, commission_plan_id, commission_plan, install_agreement_signed, final_design_signed, financial_agreement_sent, deposit, hoi, sc, commissions_earned, override_earned, override_plan_id, override_plan, commission_adjustment, commission_paid_to_date, overrides_paid_to_date, remaining_value, current_pay, project_total_value, updated, override_adjustment, total_commissions, current_pay_commissions, remaining_value_commissions, total_overrides, remaining_value_overrides, current_pay_overrides, percent_of_cash_deposit, utility_bill_verified_date)
select id, payroll_id, deal_id, customer_name, system_size, sales_rep_id, sales_rep, source, stage, cancelled, commission_plan_id, commission_plan, install_agreement_signed, final_design_signed, financial_agreement_sent, deposit, hoi, sc, commissions_earned, override_earned, override_plan_id, override_plan, commission_adjustment, commission_paid_to_date, overrides_paid_to_date, remaining_value, current_pay, deal_total_value, updated, override_adjustment, total_commissions, current_pay_commissions, remaining_value_commissions, total_overrides, remaining_value_overrides, current_pay_overrides, percent_of_cash_deposit, utility_bill_verified_date
from blueraven.deal_commission_snapshot;

insert into brs.project_override_commission_snapshot(id, project_commission_snapshot_id, user_id, milestone_type_id, total)
select id, deal_commission_snapshot_id, user_id, milestone_type_id, total
from blueraven.deal_override_commission_snapshot;

refresh materialized view blueraven.commission_plan_vw;
refresh materialized view blueraven.override_plan_vw;
insert into brs.project_commission(project_id, commission_plan_id)
    (select d.id,cpv.commission_plan_id
     from blueraven.deal d
              inner join flow.project p on p.id = d.id
              inner join blueraven.commission_plan_vw cpv on cpv.deal_id = d.id and milestone_id = 1
              inner join brs.commission_plan cp on cp.id = cpv.commission_plan_id);

insert into brs.project_override(project_id, override_plan_id)
    (select d.id,cpv.override_plan_id
     from blueraven.deal d
              inner join flow.project p on p.id = d.id
              inner join blueraven.override_plan_vw cpv on cpv.deal_id = d.id and milestone_id = 1
              inner join brs.override_plan op on op.id = cpv.override_plan_id);

insert into brs.exclude_commission(project_id)
    (select d.id
     from blueraven.deal d
     where d.exclude_commission is true
       and d.id in (select id from flow.project));


SELECT setval('brs.project_override_commission_snapshot_id_seq',
              COALESCE((SELECT MAX(id) + 1
                        FROM brs.project_override_commission_snapshot), 1), false);

SELECT setval('brs.project_commission_snapshot_id_seq',
              COALESCE((SELECT MAX(id) + 1
                        FROM brs.project_commission_snapshot), 1), false);

SELECT setval('brs.project_commission_ledger_id_seq',
              COALESCE((SELECT MAX(id) + 1
                        FROM brs.project_commission_ledger), 1), false);

SELECT setval('brs.payroll_adjustment_id_seq',
              COALESCE((SELECT MAX(id) + 1
                        FROM brs.payroll_adjustment), 1), false);

SELECT setval('brs.commission_plan_id_seq',
              COALESCE((SELECT MAX(id) + 1
                        FROM brs.commission_plan), 1), false);

SELECT setval('brs.commission_plan_user_id_seq',
              COALESCE((SELECT MAX(id) + 1
                        FROM brs.commission_plan_user), 1), false);

SELECT setval('brs.milestone_type_id_seq',
              COALESCE((SELECT MAX(id) + 1
                        FROM brs.milestone_type), 1), false);

SELECT setval('brs.fee_type_id_seq',
              COALESCE((SELECT MAX(id) + 1
                        FROM brs.fee_type), 1), false);

SELECT setval('brs.commission_plan_source_allocation_id_seq',
              COALESCE((SELECT MAX(id) + 1
                        FROM brs.commission_plan_source_allocation), 1), false);


SELECT setval('brs.commission_plan_allocation_id_seq',
              COALESCE((SELECT MAX(id) + 1
                        FROM brs.commission_plan_allocation), 1), false);

SELECT setval('brs.override_plan_id_seq',
              COALESCE((SELECT MAX(id) + 1
                        FROM brs.override_plan), 1), false);

SELECT setval('brs.override_plan_assigned_user_id_seq',
              COALESCE((SELECT MAX(id) + 1
                        FROM brs.override_plan_assigned_user), 1), false);

SELECT setval('brs.override_plan_receiving_user_id_seq',
              COALESCE((SELECT MAX(id) + 1
                        FROM brs.override_plan_receiving_user), 1), false);

SELECT setval('brs.payroll_id_seq',
              COALESCE((SELECT MAX(id) + 1
                        FROM brs.payroll), 1), false);


-- insert into flow.db_function(function_name, return_data_type_id)
-- values('brs.insert_commissions_on_project',6);
--
-- insert into  flow.db_function_param(db_function_id, parameter_name, display_order, data_type_id, parameter_type_id)
--     (select (select id from flow.db_function where function_name = 'brs.insert_commissions_on_project'),'project_id',1,6,1);
--
--
-- insert into flow.company_function(company_function_name, db_function_id, company_id)
--     (select 'Insert Commissions on Project',(select id from flow.db_function where function_name = 'brs.insert_commissions_on_project'),(select id from flow.company where company_name = 'Blue Raven Solar'));
--
-- insert into flow.company_function_param(company_function_id, system_value_id, db_function_param_id, created_by_id, modified_by_id, date_modified)
--     (select (select id from flow.company_function where company_function_name = 'Insert Commissions on Project'),2,(select id from flow.db_function_param where parameter_name = 'project_id'),2350555,2350555,now());



/*REBATE MIGRATION*/
insert into brs.project_rebate_payment_state(id, name)
select * from blueraven.deal_rebate_payment_state;

insert into brs.project_rebate_batch(id, project_rebate_payment_ids, batch_date, updated_date, voided_batch, updated_by_user_id)
select * from blueraven.deal_rebate_batch;

insert into brs.project_rebate_payment(id, project_id, payment_amount, created_by_user_id, created_date, approved_by_user_id, approved_date, updated_by_user_id, updated_date, project_rebate_payment_state_id, processed_date, processed_by_user_id, payment_nbr, project_rebate_batch_id, check_number, void_note)
select id, deal_id, payment_amount, created_by_user_id, created_date, approved_by_user_id, approved_date, updated_by_user_id, updated_date, state_id, processed_date, processed_by_user_id, payment_nbr, deal_rebate_batch_id, check_number, void_note from blueraven.deal_rebate_payment;

insert into brs.project_rebate_payment_audit(id, project_id, audit, changed_date, changed_by_user_id)
select * from blueraven.deal_rebate_payment_audit;


SELECT setval('brs.project_rebate_payment_state_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.project_rebate_payment_state), 1), false);
SELECT setval('brs.project_rebate_batch_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.project_rebate_batch), 1), false);
SELECT setval('brs.project_rebate_payment_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.project_rebate_payment), 1), false);
SELECT setval('brs.project_rebate_payment_audit_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.project_rebate_payment_audit), 1), false);


update flow.org o
set state_id = s.id
from blueraven.org o1
inner join blueraven.sales_area sa on sa.id = o1.sales_area_id
inner join blueraven.state s on s.id = sa.state_id
where o.id = o1.id and o1.sales_area_id is not null;


update flow.org o
set company_state_id = (select cs.id
                        from flow.org o1
                                 inner join blueraven.state s1 on s1.id = o1.state_id
                                 inner join flow.company_state cs on cs.company_id = o1.company_id
                                 inner join flow.state s on s.id = cs.state_id and s1.state = s.state
                        where o.id = o1.id);

alter table flow.org drop column if exists state_id;


insert into flow.organization_custom_field_value( org_id, custom_field_group_assignment_id,  text_value, date_created,
                                                 date_modified, created_by_id, modified_by_id)
(
    with org_types as (
        select distinct ot.id,ot.org_type,ot.org_parent_type_id,level
        from blueraven.org_hierarchy_filter_down('{216,217}') a
                 inner join blueraven.org_type ot on ot.id = a.org_type_id
        where org_type_id not in (15,16)
        union
        select distinct ot.id,ot.org_type,ot.org_parent_type_id,level
        from blueraven.org_hierarchy_filter_up(
                     '{216,217}') a
                 inner join blueraven.org_type ot on ot.id = a.org_type_id
        where org_type_id not in (15,16))
    select
        o.id,
    (SELECT cfa.id
     FROM flow.custom_field_group_assignment cfa
              inner join flow.custom_field cf on  cf.id = cfa.custom_field_id
              inner join flow.custom_field_group cfg on cfg.id = cfa.custom_field_group_id and cfg.company_object_type_id = 35
     WHERE field_name = 'Org Email'),
        o.email,
        now(),
        now(),
        2350555,
        2350555
    from blueraven.org o
            inner join flow.org o1 on o1.id = o.id
             inner join org_types ot on ot.id = o.org_type_id
    where o.id not in (215)
      and o.id not in (select id from blueraven.org_hierarchy_filter_down('{215}'))
      and o.email is not null);

insert into flow.organization_custom_field_value( org_id, custom_field_group_assignment_id,  text_value, date_created,
                                                  date_modified, created_by_id, modified_by_id)
    (
        with org_types as (
            select distinct ot.id,ot.org_type,ot.org_parent_type_id,level
            from blueraven.org_hierarchy_filter_down('{215}') a
                     inner join blueraven.org_type ot on ot.id = a.org_type_id
            where org_type_id not in (15,16)
            union
            select distinct ot.id,ot.org_type,ot.org_parent_type_id,level
            from blueraven.org_hierarchy_filter_up(
                         '{215}') a
                     inner join blueraven.org_type ot on ot.id = a.org_type_id
            where org_type_id not in (15,16))
        select
            o.id,
            (SELECT cfa.id
             FROM flow.custom_field_group_assignment cfa
                      inner join flow.custom_field cf on  cf.id = cfa.custom_field_id
                      inner join flow.custom_field_group cfg on cfg.id = cfa.custom_field_group_id and cfg.company_object_type_id = 5
             WHERE field_name = 'Org Email'),
            o.email,
            now(),
            now(),
            2350555,
            2350555
        from blueraven.org o
                 inner join flow.org o1 on o1.id = o.id
                 inner join org_types ot on ot.id = o.org_type_id
        where o.id not in (216,217)
          and o.id not in (select id from blueraven.org_hierarchy_filter_down('{216,217}'))
          and o.email is not null);



-- insert into flow.organization_custom_field_value( org_id, custom_field_group_assignment_id,  int_value, date_created,
--                                                   date_modified, created_by_id, modified_by_id)
--     (
--         with org_types as (
--             select distinct ot.id,ot.org_type,ot.org_parent_type_id,level
--             from blueraven.org_hierarchy_filter_down('{216,217}') a
--                      inner join blueraven.org_type ot on ot.id = a.org_type_id
--             where org_type_id not in (15,16)
--             union
--             select distinct ot.id,ot.org_type,ot.org_parent_type_id,level
--             from blueraven.org_hierarchy_filter_up(
--                          '{216,217}') a
--                      inner join blueraven.org_type ot on ot.id = a.org_type_id
--             where org_type_id not in (15,16))
--         select
--             o.id,
--             (SELECT cfa.id
--              FROM flow.custom_field_group_assignment cfa
--                       inner join flow.custom_field cf on  cf.id = cfa.custom_field_id
--                       inner join flow.custom_field_group cfg on cfg.id = cfa.custom_field_group_id and cfg.company_object_type_id = 35
--              WHERE field_name = 'Metro Area'),
--             lov.id,
--             now(),
--             now(),
--             2350555,
--             2350555
--         from blueraven.org o
--                  inner join flow.org o1 on o1.id = o.id
--                  inner join org_types ot on ot.id = o.org_type_id
--                  inner join blueraven.org_metro_area oma on oma.org_id = o.id
--                  inner join blueraven.metro_area ma on ma.id = oma.metro_area_id
--             inner join  blueraven.sales_area sa on sa.id = ma.sales_area_id
--             inner join flow.list_of_value lov on lov.name = sa.area || ' - ' || ma.metro_area and parent_id = 172
--         where o.id not in (215)
--           and o.id not in (select id from blueraven.org_hierarchy_filter_down('{215}'))
--           and o.email is not null
--           and  o.sales_metro_area_id is not null);
--
-- insert into flow.organization_custom_field_value( org_id, custom_field_group_assignment_id,  int_value, date_created,
--                                                   date_modified, created_by_id, modified_by_id)
--     (
--         with org_types as (
--             select distinct ot.id,ot.org_type,ot.org_parent_type_id,level
--             from blueraven.org_hierarchy_filter_down('{215}') a
--                      inner join blueraven.org_type ot on ot.id = a.org_type_id
--             where org_type_id not in (15,16)
--             union
--             select distinct ot.id,ot.org_type,ot.org_parent_type_id,level
--             from blueraven.org_hierarchy_filter_up(
--                          '{215}') a
--                      inner join blueraven.org_type ot on ot.id = a.org_type_id
--             where org_type_id not in (15,16))
--         select
--             o.id,
--             (SELECT cfa.id
--              FROM flow.custom_field_group_assignment cfa
--                       inner join flow.custom_field cf on  cf.id = cfa.custom_field_id
--                       inner join flow.custom_field_group cfg on cfg.id = cfa.custom_field_group_id and cfg.company_object_type_id = 5
--              WHERE field_name = 'Metro Area'),
--             lov.id,
--             now(),
--             now(),
--             2350555,
--             2350555
--         from blueraven.org o
--                  inner join flow.org o1 on o1.id = o.id
--                  inner join org_types ot on ot.id = o.org_type_id
--                  inner join blueraven.org_metro_area oma on oma.org_id = o.id
--                  inner join blueraven.metro_area ma on ma.id = oma.metro_area_id
--                  inner join  blueraven.sales_area sa on sa.id = ma.sales_area_id
--                  inner join flow.list_of_value lov on lov.name = sa.area || ' - ' || ma.metro_area and parent_id = 172
--         where o.id not in (216,217)
--           and o.id not in (select id from blueraven.org_hierarchy_filter_down('{216,217}'))
--           and o.email is not null
--           and  o.sales_metro_area_id is not null);


update brs.ahj a1
set metro_area_id = lov.id
from blueraven.ahj a
inner join blueraven.metro_area ma on ma.id = a.metro_area_id
inner join blueraven.sales_area sa on sa.id = ma.sales_area_id
inner join flow.list_of_value lov on lov.name = sa.area || ' - ' || ma.metro_area and parent_id = 172
where a.id = a1.id;


update brs.ahj_utility au
set metro_area_id = lov.id
from blueraven.ahj_utility a
         inner join blueraven.metro_area ma on ma.id = a.metro_area_id
         inner join blueraven.sales_area sa on sa.id = ma.sales_area_id
         inner join flow.list_of_value lov on lov.name = sa.area || ' - ' || ma.metro_area and parent_id = 172
where a.id = au.id;




-- INSERT INTO brs.proposal_log (id, proposal_date, source, proposal, project_id, proposal_nbr)
--     (SELECT pl.id, pl.proposal_date, pl.source, pl.proposal, d.id, pl.proposal_nbr
--     FROM blueraven.proposal_log pl
--     inner join blueraven.deal d on d.deal_base_oid = pl.deal_base_oid);
--
-- SELECT setval('brs.proposal_log_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.proposal_log), 1), false);



-- insert into brs.design_log_bom(id,project_id, reference_nbr, bom, note, created_by, time_submitted, delivery_time, email_sent)
-- (select dlb.id ,dlb.deal_id,dlb.reference_nbr, bom, note, created_by, time_submitted, delivery_time, email_sent
--     from blueraven.design_log_bom dlb);
--
--  SELECT setval('brs.design_log_bom_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.design_log_bom), 1), false);
--
--
--
-- INSERT INTO brs.design_log (id, design_date, design, source, project_id, design_nbr,bom)
--     (SELECT dl.id, dl.design_date, dl.design,dl.source, d.id, dl.design_nbr,dl.bom
--     FROM blueraven.design_log dl
--     inner join blueraven.deal d on d.deal_base_oid = dl.deal_base_oid);
--
--  SELECT setval('brs.design_log_id_seq', COALESCE((SELECT MAX(id) + 1 FROM brs.design_log), 1), false);

-- populate the project address fields.  this requires that v1_49 runs first to add the columns
update flow.project p set
      street1 = c.street1,
      street2 = c.street2,
      city = c.city,
      company_state_id = c.company_state_id,
      postal_code = c.postal_code,
      company_country_id = c.company_country_id
from (
         select id, street1, street2, city, company_state_id, postal_code, company_country_id
         from flow.contact
     ) as c
where c.id = p.contact_id;

alter table flow.project drop column if exists state_id;


refresh materialized view flow.user_positions_materialized_vw;
refresh materialized view flow.user_position_hierarchy_materialized_vw;

insert into flow.user_positions_vw
select * from flow.user_positions_materialized_vw;

insert into flow.user_position_hierarchy_vw
select * from flow.user_position_hierarchy_materialized_vw;


-- new requirement types
insert into flow.process_step_requirement_type(process_step_requirement_type)
values ('Project - Custom Field'), ('Contact - Custom Field');
update flow.process_step_requirement_type
set process_step_requirement_type = 'Process Step - Custom Field'
where id = 1;


CREATE TRIGGER project_audit_trg
    after INSERT or update or delete ON flow.project_custom_field_value
    FOR EACH ROW EXECUTE PROCEDURE flow.project_audit();
CREATE TRIGGER user_audit_trg
    after INSERT or update or delete ON flow.user_custom_field_value
    FOR EACH ROW EXECUTE PROCEDURE flow.user_audit();
CREATE TRIGGER contact_audit_trg
    after INSERT or update or delete ON flow.contact_custom_field_value
    FOR EACH ROW EXECUTE PROCEDURE flow.contact_audit();
CREATE TRIGGER organization_audit_trg
    after INSERT or update or delete ON flow.organization_custom_field_value
    FOR EACH ROW EXECUTE PROCEDURE flow.organization_audit();

INSERT INTO brs.funnel (id, name, ratio, display_order)
    (select id, name, ratio, display_order from blueraven.funnel);
INSERT INTO brs.setter_funnel (id, name, ratio, display_order)
    (select id, name, ratio, display_order from blueraven.setter_funnel);

-- this is so humes knows which process step to treat differently for the round robin crap - must be run after flyway scripts create the tables
insert into flow.unique_behavior_type(unique_behavior_type, date_created, created_by_id)
values('SCHEDULE_CLOSER_APPOINTMENT', now(), 2350555);

update flow.custom_field_group
set unique_behavior_type_id = 1
where process_step_id = 1
  and archived is not true
  and event_type_id = 1;


update flow.org o set
    company_timezone_id = (
        select ct.id
        from flow.company_timezone ct
                 inner join flow.timezone t on t.id = ct.timezone_id
                 inner join flow.state s on s.time_zone_abbreviation = t.timezone
                 inner join flow.company_state cs on cs.state_id = s.id
        where cs.id = o.company_state_id
          and ct.company_id = o.company_id
    )
where o.company_state_id is not null;

alter table flow.state drop column if exists time_zone_abbreviation;

insert into  flow.user_org_access(org_id, user_id, date_created,
                                  created_by_id
)
select * from (
                  (select distinct  unnest(calendar_org_ids) as org_id,id as user_id,
                                    now(),2350555
                   from blueraven.user
                   where calendar_org_ids is not null
                  )) as foo
where foo.user_id not in (select  user_id
                          from blueraven.role_permission rp
                                   inner join blueraven.role r on r.id = rp.role_id
                                   inner join blueraven.permission p on p.id = rp.permission_id
                                   inner join blueraven.user_role ur on ur.role_id = r.id
                                   inner join blueraven."user" u on u.id = ur.user_id
                          where  p.id = 201);


insert into  flow.user_org_access(org_id, user_id, date_created,
                                  created_by_id
)
with all_org_calendars as (
    select distinct  id as org_id
    from blueraven.org
    where has_calendar is true
) select  distinct org_id,user_id,now(),2350555
from blueraven.role_permission rp
         inner join blueraven.role r on r.id = rp.role_id
         inner join blueraven.permission p on p.id = rp.permission_id
         inner join blueraven.user_role ur on ur.role_id = r.id
         inner join blueraven."user" u on u.id = ur.user_id
         cross join all_org_calendars
where  p.id = 201;

grant connect on database blueraven_uat to brs_users;
grant usage on schema public to brs_users;
grant usage on schema base_mysql to brs_users;
grant usage on schema blueraven to brs_users;
grant usage on schema brs to brs_users;
grant usage on schema flow to brs_users;
grant usage on schema props to brs_users;
grant select on all tables in schema public to brs_users;
grant select on all tables in schema base_mysql to brs_users;
grant select on all tables in schema blueraven to brs_users;
grant select on all tables in schema brs to brs_users;
grant select on all tables in schema flow to brs_users;
grant select on all tables in schema props to brs_users;


insert into flow.attachment(attachment_type_id, company_id, filename, content_type, s3_key,
                            size,date_created, date_modified, created_by_id,migrated_deal_id,migrated_deal_resource_id)
    (select (select id from flow.attachment_type at
             where attachment_type = 'Migrated Documents'
               and at.company_id = c.company_id),c.company_id,filename,content_type,s3_key,size,
            created,updated,coalesce(u.id,2350555),d.id,dba.deal_resource_oid
     from blueraven.deal_base_document dba
              inner join blueraven.deal d on d.deal_base_oid = dba.deal_base_oid
              inner join flow.project p on p.id=d.id
              inner join flow.contact c on c.id = p.contact_id
              left join blueraven."user" u on (dba.created_by_id = u.user_base_oid or dba.created_by_id = u.user_base_setter_oid));


with project_documents as (
    select a.migrated_deal_resource_id
    from flow.attachment a
        except
    select deal_resource_oid
    from blueraven.deal_calendar_event_attachment)
insert into flow.project_attachment(attachment_id, project_id, date_created,
                                    created_by_id)
    (select a.id,p.id,now(),a.created_by_id
     from flow.project p
              inner join flow.attachment a on a.migrated_deal_id = p.id
              inner join project_documents pd on pd.migrated_deal_resource_id = a.migrated_deal_resource_id);


with position_features as (
    select  company_feature_id,access_control_id,enabled
    from flow.position_feature_access_control
    where position_id = 49),
     positions as (
         select distinct u.id,company_feature_id,access_control_id,enabled
         from flow.user u
                  inner join flow.user_position up on up.user_id =u.id and up.end_date is null
                  inner join flow.position p on p.id = up.position_id
                  cross join position_features
         where u.id not in (2350555,99999999,2405363, 2356764, 2410143) and p.position in ('Installation Scheduling Coordinator',
                                                                                           'Install Scheduling Closeout Coordinator',
                              'Installation Analyst', 'Install Scheduling Coordinator', 'Graphic Designer',
                              'Project Coordinator', 'Design Specialist', 'Accounts Payable Clerk', 'Retentions Specialist',
                              'Customer Insights Specialist', 'Human Resources Onboarding Coordinator', 'Operations Logistics',
                              'Customer Operations Trainer', 'Marketing and Media Specialist', 'Design Developer', 'Operations Coordinator',
                              'Event Coordinator', 'Rafter Upgrade Specialist', 'Human Resources Generalist', 'Compliance Specialist',
                              'Supply Chain Coordinator', 'EPC Partner', 'Placard Operator', 'Bureau Operations Coordinator',
                              'Site Survey Coordinator', 'Inspections Coordinator', 'Structural and Design Engineer',
                              'Engineer', 'Content Marketing Specialist', 'Digital Marketing Specialist', 'Permitting Coordinator',
                              'Reviews Coordinator', 'Marketing Strategy Intern', 'Outreach Marketing Specialist', 'Scheduling Coordinator',
                              'Customer Experience Specialist', 'Retentions Coordinator', 'Payroll Specialist', 'Inspection Quality Coordinator',
                              'Support Coordinator', 'Inspections Scheduler', 'Licensing Coordinator', 'Partners Coordinator',
                              'Utilities Coordinator', 'Onboarding Coordinator', 'Onboarding Coordinator', 'Engineering Specialist',
                              'Licensing Coordinator', 'Customer Experience Coordinator','Proposals Specialist', 'Proposals Mentor' ))
insert into flow.user_feature_access_control( company_feature_id, access_control_id, user_id, enabled)
    (select p.company_feature_id,p.access_control_id,id,p.enabled from positions p );


with position_features as (
    select  company_feature_id,access_control_id,enabled
    from flow.position_feature_access_control
    where position_id = 162),
     positions as (
         select distinct u.id,company_feature_id,access_control_id,enabled
         from flow.user u
                  inner join flow.user_position up on up.user_id =u.id and up.end_date is null
                  inner join flow.position p on p.id = up.position_id
                  cross join position_features
         where u.id not in (2350555,99999999,2405363, 2356764, 2410143) and p.position in ('Field Service Manager', 'Field Operations Director', 'Field Service Technician Manager', 'Field HR Manager',
                              'Installation Director', 'Installation Director', 'National Installation Manager', 'Regional Installation Manager',
                              'Installation Quality and Safety Manager', 'Installer Manager', 'Installation Scheduling Lead',
                              'Pre-Installation Director', 'Installation Director', 'Installation Scheduling Manager', 'Design Lead', 'Design Manager',
                              'Executive', 'Marketing Manager', 'EPC Lead', 'Operations Logistics Manager', 'Human Resources Manager',
                              'Operations Director', 'Management Trainee', 'Customer Experience Manager', 'General Operations Lead',
                              'Software Development', 'Controller', 'Quality Assurance Lead', 'Director of Human Resources', 'Marketing Senior Manager',
                              'Operations Manager', 'System Production Manager', 'EPC Operations Manager', 'Support Lead', 'Support Manager',
                              'Bureau Operations Lead', 'Bureau Operations Manager', 'Site Survey Manager','Technicians Manager', 'Field Operations Technician Manager',
                              'Inspections Manager', 'Inspections Lead', 'General Counsel', 'Supply Chain Manager', 'Operations Lead',
                              'Product Manager', 'Business Development Manager', 'Customer Insights Lead', 'Permitting Manager', 'EPC Regional',
                              'Marketing Director', 'Service Technician Manager', 'Reviews Lead', 'Mountain Project Manager',
                              'Engineering Manager', 'Project Manager', 'Scheduling Manager', 'Auditor', 'HR Business Partner',
                              'Rep Success Manager', 'Business Intelligence Senior Manager', 'Regional Director', 'Recruiting Budget Manager',
                              'Retentions Manager', 'Automation', 'Payroll Manager', 'Supply Chain Director', 'Leader Development Senior Manager',
                              'Partners Manager', 'Partners Lead', 'Service Operations Manager', 'Utilities Lead', 'Utilities Manager',
                              'Office Manager & Executive Assistant', 'Permitting Lead', 'Engineering Lead', 'Market Manager',
                              'Marketing and Business Development Manager', 'Customer Experience Manager', 'Customer Experience Lead',
                              'Business Development Senior Manager', 'Compliance Manager', 'Licensing Manager', 'BI Analyst', 'Director of Operations',
                              'VP of Operations', 'Systems Director','Proposals Lead','Proposals Manager'))
insert into flow.user_feature_access_control( company_feature_id, access_control_id, user_id, enabled)
    (select p.company_feature_id,p.access_control_id,id,p.enabled from positions p );


with position_features as (
    select  company_feature_id,access_control_id,enabled
    from flow.position_feature_access_control
    where position_id = 49),
     positions as (
         select distinct u.id,company_feature_id,access_control_id,enabled
         from flow.user u
                  inner join flow.user_position up on up.user_id =u.id and up.end_date is null
                  inner join flow.position p on p.id = up.position_id
                  cross join position_features
         where u.id not in (2354975,2350555,99999999,2405363, 2356764, 2410143) and p.position in ('Field Service Technician', 'Field Operations Technician', 'Field Operations Recruiter',
                              'Field Operations Recruiter', 'Field Operations Project Manager', 'Field Operations Technician Lead',
                              'Field Service Technican Lead', 'Field Recruiter', 'Field Service Coordinator', 'Field Service Lead',
                              'Site Surveyor', 'Installer', 'Installation Trainer', 'Installation Lead', 'Installation Trainer',
                              'Installation Coordinator', 'Installation Foreman', 'Supervising Electrician', 'Engineering EIT',
                              'Crew Lead', 'Electrician', 'Electrician - Crew', 'Crew Lead + Electrician'))
insert into flow.user_feature_access_control( company_feature_id, access_control_id, user_id, enabled)
    (select p.company_feature_id,p.access_control_id,id,p.enabled from positions p );


with position_features as (
    select  company_feature_id,access_control_id,enabled
    from flow.position_feature_access_control
    where position_id = 19),
     positions as (
         select distinct u.id,company_feature_id,access_control_id,enabled
         from flow.user u
                  inner join flow.user_position up on up.user_id =u.id and up.end_date is null
                  inner join flow.position p on p.id = up.position_id
                  cross join position_features
         where u.id not in (2350555,99999999,2405363, 2356764, 2410143) and p.position in ('Accounting Manager'))
insert into flow.user_feature_access_control( company_feature_id, access_control_id, user_id, enabled)
    (select p.company_feature_id,p.access_control_id,id,p.enabled from positions p );

insert into brs.company_dashboard_targets(target_date, bookings_brs, bookings_partner, final_designs_approved_brs, final_designs_approved_partner, substantial_completions_brs, substantial_completions_partner, final_completions_brs, final_completions_partner)
(select target_date, bookings_brs, bookings_partner, final_designs_approved_brs, final_designs_approved_partner, substantial_completions_brs, substantial_completions_partner, final_completions_brs, final_completions_partner from blueraven.company_dashboard_targets);


WITH orgs as (
    select id
    from flow.org
    where org_type_id in (6,8,14,7,19)
)

update flow.org
set available_to_children = TRUE
where id in (
    select id
    from orgs
);


with set_time_based_to_true as
         (
             select psa.id
             from flow.process_step_action psa
                      inner join flow.process_step ps on ps.id = psa.process_step_id
             where ps.process_step_name ILIKE ANY(ARRAY['%Pending%','%Holding%']) and psa.trigger_automatically is true and psa.archived is false and ps.archived is false
               and psa.time_based_trigger is false)

update flow.process_step_action
set time_based_trigger = TRUE
where id in (
    select id
    from set_time_based_to_true
);


-- update all closers to have a default home page of /closerDashboard
update flow.user_company as uc set
    home_page_company_feature_id = c.column_c
from (
         select up.user_id,
                p.company_id,
                (select cf2.id from flow.company_feature cf2 where cf2.feature_id = 14 and cf2.company_id = p.company_id)
         from flow.user_position up
                  inner join flow.position p on up.position_id = p.id
         where p.id in (select p2.id from flow.position p2 where p2.company_id = p.company_id and p2.position in ('Closer', 'Closer Manager', 'Closer Regional'))
           -- there are no other companies with the closer dashboard feature so we can limit this here
           and p.company_id = 3
     ) as c(column_a, column_b, column_c)
where c.column_a = uc.user_id
  and c.column_b = uc.company_id;
-- update all setters to have a default home page of /setterDashboard
update flow.user_company as uc set
    home_page_company_feature_id = c.column_c
from (
         select up.user_id,
                p.company_id,
                (select cf2.id from flow.company_feature cf2 where cf2.feature_id = 15 and cf2.company_id = p.company_id)
         from flow.user_position up
                  inner join flow.position p on up.position_id = p.id
         where p.id in (select p2.id from flow.position p2 where p2.company_id = p.company_id and p2.position in ('Setter', 'Setter Manager', 'Setter Regional'))
           -- there are no other companies with the setter dashboard feature so we can limit this here
           and p.company_id = 3
     ) as c(column_a, column_b, column_c)
where c.column_a = uc.user_id
  and c.column_b = uc.company_id;
-- update all closers not in child id = 3 to /projects
update flow.user_company as uc set
    home_page_company_feature_id = c.column_c
from (
         select up.user_id,
                p.company_id,
                (select cf2.id from flow.company_feature cf2 where cf2.feature_id = 11 and cf2.company_id = p.company_id)
         from flow.user_position up
                  inner join flow.position p on up.position_id = p.id
         where p.id in (select p2.id from flow.position p2 where p2.company_id = p.company_id and p2.position in ('Closer', 'Closer Manager', 'Closer Regional'))
           -- there are no other companies with the closer dashboard feature so we can limit this here
           and p.company_id != 3
     ) as c(column_a, column_b, column_c)
where c.column_a = uc.user_id
  and c.column_b = uc.company_id;
-- update all other non-closers and non-setters to be /companyDashboard (currently the feature only exists in BR corp)
update flow.user_company as uc set
    home_page_company_feature_id = c.column_c
from (
         select up.user_id,
                p.company_id,
                (select cf2.id from flow.company_feature cf2 where cf2.feature_id = 24 and cf2.company_id = p.company_id)
         from flow.user_position up
                  inner join flow.position p on up.position_id = p.id
         where p.id in (select p2.id from flow.position p2 where p2.company_id = p.company_id and p2.position not in ('Closer', 'Closer Manager', 'Closer Regional', 'Setter', 'Setter Manager', 'Setter Regional'))
     ) as c(column_a, column_b, column_c)
where c.column_a = uc.user_id
  and c.column_b = uc.company_id;


update flow.user_company set default_appointment_length = 90;


with owners as (
    select d.id,((added_on  AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC')::date as added_on
    from blueraven.deal d)
update flow.project p
set user_position_id = blueraven.get_user_position_for_closer(o.id::integer,o.added_on)
from owners o
where o.id = p.id;


with owner_projects_not_closers as (
    select distinct p.id as project_id, up2.id as user_position_id,d.closer_user_id
    from flow.project p
             inner join blueraven.deal d on d.id = p.id
             inner join blueraven.user_position up on up.user_id = d.closer_user_id and up.primary_flag is true
             inner join flow.user_position up2 on up2.id = up.id
    where p.user_position_id is null and d.closer_user_id is not null)
update flow.project p2
set user_position_id = opnc.user_position_id
from owner_projects_not_closers opnc
where opnc.project_id = p2.id
  and p2.user_position_id is null;


with insert_availability as (
    insert into flow.resource_schedule(company_id, user_id, start_date,
                                       end_date, date_created,
                                       created_by_id,migrated_user_id)
        (select 3,u.id,'2020-11-01',null,now(),2350555,ac.user_id
         from blueraven.user u
                  inner join base_mysql.availability_configurations ac on (ac.user_id = u.user_base_oid or ac.user_id = u.user_base_setter_oid)
         where ac.local_deleted = 0
           and (monday !='[]' or tuesday != '[]' or wednesday != '[]' or
                thursday != '[]' or friday != '[]' or saturday != '[]'))returning *)

insert into flow.resource_schedule_availability(resource_schedule_id, start_time, end_time,
                                                day_of_week_id, date_created,
                                                created_by_id
)
(select foo.id,(('2020-01-01 ' ||min(foo.from_time))::timestamp at time zone foo.timezone at time zone 'UTC')::time,(('2020-01-01 ' ||max(foo.to_time))::timestamp at time zone foo.timezone at time zone 'UTC')::time,foo.day_of_week,now(),2350555
from (
         select distinct iaa.id,ac.user_id,ac.appointment_duration,case
                                                                       when ac.timezone = 'America/Denver' then 'America/Denver'
                                                                       when ac.timezone = 'Mountain Time (US & Canada)' then 'US/Mountain'
                                                                       when ac.timezone = 'Pacific Time (US & Canada)' then 'US/Pacific'
                                                                       when ac.timezone = 'America/New_York' then 'America/New_York'
                                                                       when ac.timezone = 'Eastern Time (US & Canada)' then 'US/Eastern'
                                                                       when ac.timezone = 'America/Los_Angeles' then 'America/Los_Angeles'
                                                                       when ac.timezone = 'Central Time (US & Canada)' then 'US/Central'
                                                                       when ac.timezone = 'America/Indianapolis' then 'America/Indianapolis'
             end as timezone,1 as day_of_week,
                         ac1 ->> 'from' as from_time,ac1 ->> 'to' as to_time
         from base_mysql.availability_configurations ac
                  cross join LATERAL jsonb_array_elements(ac.monday::jsonb) ac1
                  inner join insert_availability iaa on ac.user_id = iaa.migrated_user_id
         where local_deleted = 0
         union
         select distinct iaa.id,ac.user_id,ac.appointment_duration,case
                                                                       when ac.timezone = 'America/Denver' then 'America/Denver'
                                                                       when ac.timezone = 'Mountain Time (US & Canada)' then 'US/Mountain'
                                                                       when ac.timezone = 'Pacific Time (US & Canada)' then 'US/Pacific'
                                                                       when ac.timezone = 'America/New_York' then 'America/New_York'
                                                                       when ac.timezone = 'Eastern Time (US & Canada)' then 'US/Eastern'
                                                                       when ac.timezone = 'America/Los_Angeles' then 'America/Los_Angeles'
                                                                       when ac.timezone = 'Central Time (US & Canada)' then 'US/Central'
                                                                       when ac.timezone = 'America/Indianapolis' then 'America/Indianapolis'
             end as timezone,2 as day_of_week,
                         ac2 ->> 'from' as tuesday_from,ac2 ->> 'to' as tuesday_to
         from base_mysql.availability_configurations ac
                  cross join LATERAL jsonb_array_elements(ac.tuesday::jsonb) ac2
                  inner join insert_availability iaa on ac.user_id = iaa.migrated_user_id
         where local_deleted = 0
         union
         select distinct iaa.id,ac.user_id,ac.appointment_duration,case
                                                                       when ac.timezone = 'America/Denver' then 'America/Denver'
                                                                       when ac.timezone = 'Mountain Time (US & Canada)' then 'US/Mountain'
                                                                       when ac.timezone = 'Pacific Time (US & Canada)' then 'US/Pacific'
                                                                       when ac.timezone = 'America/New_York' then 'America/New_York'
                                                                       when ac.timezone = 'Eastern Time (US & Canada)' then 'US/Eastern'
                                                                       when ac.timezone = 'America/Los_Angeles' then 'America/Los_Angeles'
                                                                       when ac.timezone = 'Central Time (US & Canada)' then 'US/Central'
                                                                       when ac.timezone = 'America/Indianapolis' then 'America/Indianapolis'
             end as timezone,3 as day_of_week,
                         ac2 ->> 'from' as wed_from,ac2 ->> 'to' as wed_to
         from base_mysql.availability_configurations ac
                  cross join LATERAL jsonb_array_elements(ac.wednesday::jsonb) ac2
                  inner join insert_availability iaa on ac.user_id = iaa.migrated_user_id
         where local_deleted = 0
         union
         select distinct iaa.id,ac.user_id,ac.appointment_duration,case
                                                                       when ac.timezone = 'America/Denver' then 'America/Denver'
                                                                       when ac.timezone = 'Mountain Time (US & Canada)' then 'US/Mountain'
                                                                       when ac.timezone = 'Pacific Time (US & Canada)' then 'US/Pacific'
                                                                       when ac.timezone = 'America/New_York' then 'America/New_York'
                                                                       when ac.timezone = 'Eastern Time (US & Canada)' then 'US/Eastern'
                                                                       when ac.timezone = 'America/Los_Angeles' then 'America/Los_Angeles'
                                                                       when ac.timezone = 'Central Time (US & Canada)' then 'US/Central'
                                                                       when ac.timezone = 'America/Indianapolis' then 'America/Indianapolis'
             end as timezone,4 as day_of_week,
                         ac2 ->> 'from' as thurs_from,ac2 ->> 'to' as thurs_to
         from base_mysql.availability_configurations ac
                  cross join LATERAL jsonb_array_elements(ac.thursday::jsonb) ac2
                  inner join insert_availability iaa on ac.user_id = iaa.migrated_user_id
         where local_deleted = 0
         union
         select distinct iaa.id,ac.user_id,ac.appointment_duration,case
                                                                       when ac.timezone = 'America/Denver' then 'America/Denver'
                                                                       when ac.timezone = 'Mountain Time (US & Canada)' then 'US/Mountain'
                                                                       when ac.timezone = 'Pacific Time (US & Canada)' then 'US/Pacific'
                                                                       when ac.timezone = 'America/New_York' then 'America/New_York'
                                                                       when ac.timezone = 'Eastern Time (US & Canada)' then 'US/Eastern'
                                                                       when ac.timezone = 'America/Los_Angeles' then 'America/Los_Angeles'
                                                                       when ac.timezone = 'Central Time (US & Canada)' then 'US/Central'
                                                                       when ac.timezone = 'America/Indianapolis' then 'America/Indianapolis'
             end as timezone,5 as day_of_week,
                         ac2 ->> 'from' as friday_from,ac2 ->> 'to' as friday_to
         from base_mysql.availability_configurations ac
                  cross join LATERAL jsonb_array_elements(ac.friday::jsonb) ac2
                  inner join insert_availability iaa on ac.user_id = iaa.migrated_user_id
         where local_deleted = 0
         union
         select distinct iaa.id,ac.user_id,ac.appointment_duration,case
                                                                       when ac.timezone = 'America/Denver' then 'America/Denver'
                                                                       when ac.timezone = 'Mountain Time (US & Canada)' then 'US/Mountain'
                                                                       when ac.timezone = 'Pacific Time (US & Canada)' then 'US/Pacific'
                                                                       when ac.timezone = 'America/New_York' then 'America/New_York'
                                                                       when ac.timezone = 'Eastern Time (US & Canada)' then 'US/Eastern'
                                                                       when ac.timezone = 'America/Los_Angeles' then 'America/Los_Angeles'
                                                                       when ac.timezone = 'Central Time (US & Canada)' then 'US/Central'
                                                                       when ac.timezone = 'America/Indianapolis' then 'America/Indianapolis'
             end as timezone,6 as day_of_week,
                         ac2 ->> 'from' as sat_from,ac2 ->> 'to' as sat_to
         from base_mysql.availability_configurations ac
                  cross join LATERAL jsonb_array_elements(ac.saturday::jsonb) ac2
                  inner join insert_availability iaa on ac.user_id = iaa.migrated_user_id
         where local_deleted = 0) as foo
group by id,day_of_week, foo.timezone);



insert into  flow.resource_appointment(company_id, user_id, start_time,
                                       end_time, all_day, description, date_created,
                                       created_by_id,
                                       archived)
    (
        with active_closers as (
            select distinct u.id as user_id,u.first_name,u.last_name,t.timezone,start_date.start_date
            from flow.user u
                     inner join flow.user_position up on up.user_id = u.id and up.position_id in (1,2,3) and up.end_date is null
                     inner join flow.org o on o.id = up.org_id
                     inner join blueraven.user  u1 on u1.id = u.id
                     left join flow.company_timezone ct on ct.id = o.company_timezone_id
                     left join flow.timezone t on t.id = ct.timezone_id
                     cross join generate_series('2020-11-30',
                                                '2021-11-30',interval '1 day') as start_date
            where u1.user_status_type_id = 1
              and t.timezone is not null and u.id not in (45988,46416,2294211,2294471))
        select 3,foo.user_id,foo.start_time,foo.end_time,
               false,'Initial Block Off',now(),2350555,
               false
        from (
                 select user_id,timezone,((start_date::date ||' 09:30:00')::timestamp at time zone ac.timezone at time zone 'UTC') as start_time,
                        ((start_date::date ||' 09:30:00')::timestamp at time zone ac.timezone at time zone 'UTC') + interval '30 minutes' as end_time
                 from active_closers ac
                 union
                 select user_id,timezone,((start_date::date ||' 11:30:00')::timestamp at time zone ac.timezone at time zone 'UTC') as start_time,
                        ((start_date::date ||' 11:30:00')::timestamp at time zone ac.timezone at time zone 'UTC') + interval '30 minutes' as end_time
                 from active_closers ac
                 union
                 select user_id,timezone,((start_date::date ||' 13:30:00')::timestamp at time zone ac.timezone at time zone 'UTC') as start_time,
                        ((start_date::date ||' 13:30:00')::timestamp at time zone ac.timezone at time zone 'UTC') + interval '30 minutes' as end_time
                 from active_closers ac
                 union
                 select user_id,timezone,((start_date::date ||' 15:30:00')::timestamp at time zone ac.timezone at time zone 'UTC') as start_time,
                        ((start_date::date ||' 15:30:00')::timestamp at time zone ac.timezone at time zone 'UTC') + interval '30 minutes' as end_time
                 from active_closers ac
                 union
                 select user_id,timezone,((start_date::date ||' 17:30:00')::timestamp at time zone ac.timezone at time zone 'UTC') as start_time,
                        ((start_date::date ||' 17:30:00')::timestamp at time zone ac.timezone at time zone 'UTC') + interval '30 minutes' as end_time
                 from active_closers ac)as foo) ;
