create table if not exists brs.colorado_springs_rebate_factor
(
  azimuth       int,
  tilt          int,
  percent_value numeric,
  date_modified timestamptz default now() not null,
  primary key (azimuth, tilt)
);
