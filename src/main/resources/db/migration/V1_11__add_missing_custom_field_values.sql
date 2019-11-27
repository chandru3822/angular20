DELETE FROM brs.list_of_value WHERE parent_id = 4;

INSERT INTO brs.list_of_value (name, parent_id, display_order, show_other, date_created, created_by_id)
VALUES ('1 Day', 4, 1, false, now(), 99999999),
       ('2 Days', 4, 2, false, now(), 99999999),
       ('3 Days', 4 , 3, false, now(), 99999999),
       ('4+ Days', 4, 4, false, now(), 99999999),
       ('Other', 4, 5, true, now(), 99999999);