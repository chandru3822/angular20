--make enough room for new inverter codes
alter table if exists flow.list_of_value
alter column code type varchar(25);

--add aurora codes for matching inverter names
with current as (
  select * from flow.list_of_value lov
  where parent_id = 143 and
        archived is false
  order by display_order
)
update flow.list_of_value lov
set code = case
             when lov.name = 'Enphase IQ7+ Microinverters' then 'IQ 7+ (240V)'
             when lov.name = 'Enphase IQ7 Microinverters' then 'IQ 7'
             when lov.name = 'Enphase IQ6 Microinverters' then 'IQ 6 (240V)'
             when lov.name = 'SolarEdge SE3000H' then 'SE3000H-US'
             when lov.name = 'SolarEdge SE3800H' then 'SE3800H-US (240V)'
             when lov.name = 'SolarEdge SE5000H' then 'SE5000H-US'
             when lov.name = 'SolarEdge SE6000H' then 'SE6000H-US (240V)'
             when lov.name = 'SolarEdge SE7600H' then 'SE7600H-US'
           end
from current
where lov.id = current.id;