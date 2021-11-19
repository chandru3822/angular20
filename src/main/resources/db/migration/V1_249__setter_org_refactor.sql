drop trigger if exists org_view_trg on flow.org;

update flow.org as t1 set
  parent_org_id = c.column_b
from (values
      (729, 3326),
      (715, 3325),
      (719, 3325),
      (721, 3322),
      (928, 3326),
      (840, 3327),
      (724, 3323),
      (894, 3325),
      (720, 3324),
      (725, 3327),
      (902, 3321),
      (717, 3326),
      (777, 3326),
      (2986, 3327),
      (779, 3325),
      (881, 3325),
      (726, 3325),
      (772, 3327),
      (778, 3326),
      (2968, 3326),
      (3236, 3324),
      (3208, 3325),
      (3011, 3325),
      (716, 3327),
      (3001, 3321),
      (3219, 3321),
      (769, 3323),
      (3220, 3326),
      (712, 3325),
      (811, 3325),
      (904, 3322),
      (3025, 3325),
      (2996, 3327)
     ) as c(column_a, column_b)
where c.column_a = t1.id
;

CREATE TRIGGER org_view_trg
  AFTER UPDATE
  ON flow.org
  FOR EACH ROW
EXECUTE PROCEDURE flow.refresh_org_records();

delete from flow.user_positions_vw;
delete from flow.user_position_hierarchy_vw;
refresh materialized view flow.user_positions_materialized_vw;
refresh materialized view flow.user_position_hierarchy_materialized_vw;
insert into flow.user_positions_vw
select * from flow.user_positions_materialized_vw;
insert into flow.user_position_hierarchy_vw
select * from flow.user_position_hierarchy_materialized_vw;
