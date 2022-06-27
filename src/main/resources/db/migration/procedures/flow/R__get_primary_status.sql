CREATE OR REPLACE FUNCTION flow.get_primary_status(p_project_process_step_id integer,
                                                   p_project_id integer,
                                                   p_type varchar(2))
    RETURNS boolean AS
$BODY$
declare
    fd_qa_id                   integer;
    fd_qa_status_type_id       integer;
    fd_qa_main                 boolean;
    fd_customer_id             integer;
    fd_customer_status_type_id integer;
    fd_customer_main           boolean;
    fd_created_date            timestamp;
    nr_customer_id             integer;
    nr_customer_status_type_id integer;
    nr_customer_main           boolean;
    nr_created_date            timestamp;
    rp_customer_id             integer;
    rp_customer_status_type_id integer;
    rp_customer_main           boolean;
    fd_id                      integer;
    fd_status_id               integer;
    fd_main                    boolean;
    nr_id                      integer;
    nr_status_id               integer;
    nr_main                    boolean;
    rp_id                      integer;
    rp_status_id               integer;
    rp_main                    boolean;
    rp_created_date            timestamp;
    v_project_id               integer;

BEGIN

    select pps.id, psst.id, pps.main,pps.date_created,pps.project_id
    into fd_id,fd_status_id,fd_main,fd_created_date,v_project_id
    from flow.project_process_step pps
             inner join flow.process_step ps
                        on pps.process_step_id = ps.id and ps.parent_process_step_id = 3113 ---create final design
             inner join flow.company_process_step_status_type cpsst
                        on pps.company_process_step_status_type_id = cpsst.id
             inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id
    where case
              when p_type = 'fd' then
                  pps.id = p_project_process_step_id
              else pps.project_id = p_project_id and
                   pps.main is true
              end;

    if fd_id is not null then
        select project_process_step_id, process_step_status_type_id, main
        into fd_qa_id,fd_qa_status_type_id,fd_qa_main
        from flow.get_correct_step(
                fd_id,
                3126,
            v_project_id,
            false);
        if fd_qa_id is not null then
            select project_process_step_id, process_step_status_type_id, main
            into fd_customer_id,fd_customer_status_type_id,fd_customer_main
            from flow.get_correct_step(
                    fd_qa_id,
                    3137,
                    v_project_id,
                    false);
        end if;
    end if;

    select pps.id, psst.id, pps.main,pps.date_created,pps.project_id
    into nr_id,nr_status_id,nr_main,nr_created_date,v_project_id
    from flow.project_process_step pps
             inner join flow.process_step ps
                        on pps.process_step_id = ps.id and ps.parent_process_step_id = 3165 --Needs a Redesign
             inner join flow.company_process_step_status_type cpsst
                        on pps.company_process_step_status_type_id = cpsst.id
             inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id
    where case
              when p_type = 'nr' then
                  pps.id = p_project_process_step_id
              else pps.project_id = p_project_id and
                   pps.main is true
              end;

    if nr_id is not null then
        select project_process_step_id, process_step_status_type_id, main
        into nr_customer_id,nr_customer_status_type_id,nr_customer_main
        from flow.get_correct_step(
                nr_id,
                3137,
                v_project_id,
                false);
    end if;

    select pps.id, psst.id, pps.main,pps.date_created,pps.project_id
    into rp_id,rp_status_id,rp_main,rp_created_date,v_project_id
    from flow.project_process_step pps
             inner join flow.process_step ps
                        on pps.process_step_id = ps.id and ps.parent_process_step_id = 3219 --Regenerate Proposal (Post Install Agreement)
             inner join flow.company_process_step_status_type cpsst
                        on pps.company_process_step_status_type_id = cpsst.id
             inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id
    where case
              when p_type = 'rp' then
                  pps.id = p_project_process_step_id
              else pps.project_id = p_project_id and
                   pps.main is true
              end;

    if rp_id is not null then
        select project_process_step_id, process_step_status_type_id, main
        into rp_customer_id,rp_customer_status_type_id,rp_customer_main
        from flow.get_correct_step(
                rp_id,
                3137,
                v_project_id,
                false);
    end if;

    if p_type = 'fd' then
        if fd_status_id is not null and fd_status_id = 3 then
            return false;
        elsif fd_main is false then
            return false;
        elsif fd_main is true and
           (nr_main is null or nr_main is false) and
           (rp_main is null or rp_main is false) then
            return true;
        elsif fd_status_id = 1
            and (nr_status_id is null or nr_status_id != 1) and
              (rp_status_id is null or rp_status_id != 1) then
            return true;
        elsif fd_status_id = 1 and ((nr_status_id is not null and nr_status_id = 1) or (rp_status_id is not null and rp_status_id = 1)) and
              fd_created_date > coalesce(greatest(rp_created_date,nr_created_date),'1990-01-01') then
            return true;
        elsif fd_qa_status_type_id is not null and fd_qa_status_type_id = 1 then
            return true;
        else
            if fd_customer_main is not null and fd_customer_main is true then
                raise notice 'i am here';
                return true;
            else
                return false;
            end if;
        end if;

    elsif p_type = 'nr' then
        if nr_status_id is not null and nr_status_id = 3 then
            return false;
        elsif nr_main is false then
            return false;
        elsif nr_main is true and
           (fd_main is null or fd_main is false) and
           (rp_main is null or rp_main is false) then
            return true;
        elsif nr_status_id = 1
            and (fd_status_id is null or fd_status_id != 1) and
              (rp_status_id is null or rp_status_id != 1) then
            return true;
        elsif nr_status_id = 1 and ((fd_status_id is not null and fd_status_id = 1) or (rp_status_id is not null and rp_status_id = 1)) and
              nr_created_date > coalesce(greatest(rp_created_date,fd_created_date),'1990-01-01') then
            return true;
        elsif fd_qa_status_type_id is not null and fd_qa_status_type_id = 1 then
            return false;
        else
            if nr_customer_main is not null and nr_customer_main is true then
                return true;
            else
                return false;
            end if;
        end if;
    elsif p_type = 'rp' then
        if rp_status_id is not null and rp_status_id = 3 then
            return false;
        elsif rp_main is false then
            return false;
        elsif rp_main is true and
           (fd_main is null or fd_main is false) and
           (nr_main is null or nr_main is false) then
            return true;
        elsif rp_status_id = 1
            and (fd_status_id is null or fd_status_id != 1) and
              (nr_status_id is null or nr_status_id != 1) then
            return true;
        elsif rp_status_id = 1 and ((fd_status_id is not null and fd_status_id = 1) or (nr_status_id is not null and nr_status_id = 1)) and
              rp_created_date > coalesce(greatest(nr_created_date,fd_created_date),'1990-01-01') then
            return true;
        elsif fd_qa_status_type_id is not null and fd_qa_status_type_id = 1 then
            return false;
        else
            if rp_customer_main is not null and rp_customer_main is true then
                return true;
            else
                return false;
            end if;
        end if;

    end if;
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
