 DROP FUNCTION IF EXISTS brs._final_median(NUMERIC[]);
 DROP AGGREGATE IF EXISTS median(NUMERIC);

CREATE OR REPLACE FUNCTION brs._final_median(NUMERIC[])
   RETURNS NUMERIC AS
$$
   SELECT AVG(val)
   FROM (
     SELECT val
     FROM unnest($1) val
     ORDER BY 1
     LIMIT  2 - MOD(array_upper($1, 1), 2)
     OFFSET CEIL(array_upper($1, 1) / 2.0) - 1
   ) sub;
$$
LANGUAGE 'sql' IMMUTABLE;

CREATE AGGREGATE median(NUMERIC) (
  SFUNC=array_append,
  STYPE=NUMERIC[],
  FINALFUNC=brs._final_median,
  INITCOND='{}'
);
