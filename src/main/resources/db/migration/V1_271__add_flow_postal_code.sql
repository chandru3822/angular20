create table if not exists flow.postal_code
(
  id           serial,
  country_code char(2),
  postal_code  varchar(20),
  place_name   varchar(180),
  admin_name1  varchar(100),
  admin_code1  varchar(20),
  admin_name2  varchar(100),
  admin_code2  varchar(20),
  admin_name3  varchar(100),
  admin_code3  varchar(20),
  latitude     double precision,
  longitude    double precision,
  accuracy     int,

  unique (postal_code, admin_name1)
);

comment on column flow.postal_code.country_code is 'iso country code';
comment on column flow.postal_code.postal_code is 'postal code';
comment on column flow.postal_code.place_name is 'place name';
comment on column flow.postal_code.admin_name1 is '1. order subdivision (state)';
comment on column flow.postal_code.admin_code1 is '1. order subdivision (state)';
comment on column flow.postal_code.admin_name2 is '2. order subdivision (county/province)';
comment on column flow.postal_code.admin_code2 is '2. order subdivision (county/province)';
comment on column flow.postal_code.admin_name3 is '3. order subdivision (community)';
comment on column flow.postal_code.admin_code3 is '3. order subdivision (community)';
comment on column flow.postal_code.latitude is 'estimated latitude (wgs84)';
comment on column flow.postal_code.longitude is 'estimated longitude (wgs84)';
comment on column flow.postal_code.accuracy is 'accuracy of lat/lng from 1=estimated, 4=geonameid, 6=centroid of addresses or shape';

create index if not exists postal_code_trgm_ix
  on flow.postal_code using gin (postal_code gin_trgm_ops);
