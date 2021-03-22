CREATE OR REPLACE FUNCTION brs.get_tournament_user_score(p_tournament_formula_id integer, p_start_date timestamp,
                                                          p_end_date timestamp, p_user_id integer)
    RETURNS integer
AS
$BODY$
declare
    v_score integer;
BEGIN

    case when p_user_id is not null
            then
                case when p_tournament_formula_id = 1 then
                        select 30
                        into v_score;
                    --                                 (select count(1)
--                                  from brs.project_details pd
--                                  where complete_date_booking between p_start_date and p_end_date
--                                    and pd.closer_user_id = p_user_id)
                else
                    v_score = null;
                end case;
        else
            v_score = 30;
        end case;
    return v_score;
END
$BODY$
    LANGUAGE plpgsql VOLATILE;



