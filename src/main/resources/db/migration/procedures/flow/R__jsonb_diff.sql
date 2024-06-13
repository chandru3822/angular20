drop function if exists flow.jsonb_diff(old jsonb, new jsonb);

create or replace function flow.jsonb_diff(old jsonb, new jsonb)
  returns jsonb
  language plpgsql
as
$$
declare
  result        jsonb;
  object_result jsonb;
  k             text;
  v             record;
  empty         jsonb = '{}'::jsonb;
begin
  if old is null or jsonb_typeof(old) = 'null'
  then
    return new;
  end if;

  if new is null or jsonb_typeof(new) = 'null'
  then
    return empty;
  end if;

  result = old;

  for k in select * from jsonb_object_keys(old)
    loop
      result = result || jsonb_build_object(k, null);
    end loop;

  for v in select * from jsonb_each(new)
    loop
      if jsonb_typeof(old -> v.key) = 'object' and jsonb_typeof(new -> v.key) = 'object'
      then
        object_result = public.jsonb_diff(old -> v.key, new -> v.key);
        if object_result = empty
        then
          result = result - v.key;
        else
          result = result || jsonb_build_object(v.key, object_result);
        end if;
      elsif old -> v.key = new -> v.key
      then
        result = result - v.key;
      else
        result = result || jsonb_build_object(v.key, v.value);
      end if;
    end loop;

  return result;

end;
$$;
