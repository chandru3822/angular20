drop function if exists flow.is_syntax_valid(query text);

create or replace function flow.is_syntax_valid(query text)
  returns bool
  language plpgsql
as
$$
begin
  BEGIN
    EXECUTE E'DO $IS_SYNTAX_VALID$ BEGIN\nRETURN;\n' || trim(trailing E'; \r\n\t' from query) || E';\nEND; $IS_SYNTAX_VALID$;';
  EXCEPTION
    WHEN syntax_error THEN
      return false;
    when others then
      return false;
  END;
  RETURN TRUE;
end
$$;
