alter table flow.postal_code_zone_user add column if not exists user_id integer;


alter table flow.postal_code_zone_user add
CONSTRAINT pczu_user_id_fk FOREIGN KEY (user_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;


update flow.postal_code_zone_user pczu
set user_id = (select up.user_id
               from flow.postal_code_zone_user pczu1
                inner join flow.user_position up on pczu1.user_position_id = up.id
               where pczu1.id = pczu.id);


alter table flow.postal_code_zone_user drop column if  exists user_position_id;

